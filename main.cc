#include <filesystem>
#include <cstdint>
#include <memory>
#include <cassert>

#include <elfio/elfio.hpp>
#include <CLI/App.hpp>
#include <CLI/Config.hpp>
#include <CLI/Formatter.hpp>

#include <verilated_vcd_c.h>
#include "Vtop.h"
#include "Vtop_top.h"
#include "Vtop_imem.h"
#include "Vtop_dmem.h"
#include "Vtop_cpu.h"
#include "Vtop_regfile.h"
#include "Vtop_datapath.h"
#include "verilated.h"

using Addr = std::uint32_t;
using Word = std::uint32_t;

class ELF
{
public:
    using IndexT = unsigned;

    void load(std::filesystem::path &path)
    {
        if (!elfFile_.load(path))
            throw std::runtime_error{"Failed while loading input file: " + path.string()};

        check();
    }

    Addr getEntryPoint() const
    {
        return static_cast<Addr>(elfFile_.get_entry());
    }

    const ELFIO::segment *getSegmentPtr(IndexT index) const
    {
        auto *segment = elfFile_.segments[index];

        if (segment == nullptr)
            throw std::runtime_error{"Unknown segment index: " + std::to_string(index)};

        return segment;
    }

    std::vector<IndexT> getLoadableSegments() const
    {
        std::vector<IndexT> res{};
        for (auto &&segment : elfFile_.segments)
            if (ELFIO::PT_LOAD == segment->get_type())
                res.push_back(segment->get_index());
        return res;
    }

private:
    void check() const
    {
        if (auto diagnosis = elfFile_.validate(); !diagnosis.empty())
            throw std::runtime_error{diagnosis};

        if (elfFile_.get_class() != ELFIO::ELFCLASS32)
            throw std::runtime_error{"Wrong elf file class: only elf32 supported"};

        if (elfFile_.get_encoding() != ELFIO::ELFDATA2LSB)
            throw std::runtime_error{
                "Wrong encoding: only 2's complement little endian supported"};

        if (elfFile_.get_type() != ELFIO::ET_EXEC)
            throw std::runtime_error{
                "Wrong file type: only executable files are supported"};

        if (elfFile_.get_machine() != ELFIO::EM_RISCV)
            throw std::runtime_error{"Wrong machine type: only RISC-V supported"};
    }

private:
    ELFIO::elfio elfFile_{};
};

struct TopModule
{
    int init(int argc, char **argv)
    {
        /* Verilator init */
        Verilated::commandArgs(argc, argv);
        top = std::make_shared<Vtop>();

        Verilated::traceEverOn(true);
        vcd = std::make_unique<VerilatedVcdC>();
        top->trace(vcd.get(), 10); // Trace 10 levels of hierarchy
        vcd->open("out.vcd");      // Open the dump file

        /* Parse command line */
        CLI::App app{"Simulator"};
        std::filesystem::path input{};
        app.add_option("input", input, "Executable file")
            ->required()
            ->check(CLI::ExistingFile);

        try
        {
            app.parse(argc, argv);
        }
        catch (const CLI::ParseError &e)
        {
            return app.exit(e);
        }

        /*  Init top module: imem, clk, entry pc */
        ELF elfLoader;
        elfLoader.load(input);

        for (auto segmentIdx : elfLoader.getLoadableSegments())
        {
            auto segment = elfLoader.getSegmentPtr(segmentIdx);

            auto fileSize = segment->get_file_size(); // in bytes
            Addr va = segment->get_virtual_address();
            assert(va < (1 << 18 - 1) && "Failed to load data in imem");

            const auto *begin = reinterpret_cast<const uint8_t *>(segment->get_data());
            uint8_t *dst = reinterpret_cast<uint8_t *>(top->top->imem->RAM.data());

            std::copy(begin, begin + fileSize, dst + va);
        }

        top->clk = 1;

        top->top->cpu->datapath->pcn = elfLoader.getEntryPoint();
        return 0;
    }

    std::shared_ptr<Vtop> top;
    std::shared_ptr<VerilatedVcdC> vcd;
};

struct Logger
{
    struct State
    {
        bool regWrite = 0;
        bool memWrite = 0;
        uint32_t regChanged;
        uint32_t addr;
        uint32_t data;
        uint32_t pc;
    };

    void dumpChangedState(const State &st) const
    {
        std::cout << "-----------------------" << std::endl;
        std::cout << "NUM=" << std::dec << instrCounter_ << std::endl;
        if (st.regWrite)
        {
            std::cout << "x" << std::dec << st.regChanged << "=0x" << std::hex << st.data << std::endl;
        }
        else if (st.memWrite)
        {
            std::cout << "M[" << std::hex << st.addr << "]=0x" << std::hex << st.data << std::endl;
        }
        std::cout << "PC=0x" << std::hex << st.pc << std::endl;
    }

    void next()
    {
        instrCounter_ += 1;
    }

private:
    uint32_t instrCounter_ = 1;
};

int main(int argc, char **argv)
try
{
    TopModule topModule;
    auto res = topModule.init(argc, argv);
    if (res)
    {
        return res;
    }

    auto *regfile = topModule.top->top->cpu->datapath->regfile->GRF.data();
    auto *dmem = topModule.top->top->dmem->RAM.data();
    vluint64_t vtime = 0;
    Logger logger;

    bool prevMemWrite = false;
    bool prevRegWrite = false;
    uint32_t prevReg = 256;
    uint64_t prevAddr = 0;
    while (!Verilated::gotFinish())
    {
        vtime += 1;
        if (vtime % 8 == 0)
        {
            topModule.top->clk ^= 1;
            if ((!topModule.top->clk) && (vtime != 8))
            {
                Logger::State st{
                    0,                     // regWrite
                    0,                     // memWrite
                    10000,                 // regChanged (invalid by default)
                    0,                     // addr (invalid by default)
                    0,                     // data
                    topModule.top->top->pc // pc
                };

                if (prevMemWrite)
                {
                    st.memWrite = prevMemWrite;
                    st.data = dmem[prevAddr >> 2];
                    st.addr = prevAddr;
                }

                if (prevRegWrite) {
                    st.regWrite = prevRegWrite;
                    st.data = regfile[prevReg];
                    st.regChanged = prevReg;
                }

                logger.dumpChangedState(st);
                logger.next();
            }
            if (topModule.top->top->finish && topModule.top->clk)
            {
                break;
            }

            prevMemWrite = topModule.top->top->memWrite;
            prevRegWrite = topModule.top->top->cpu->regWrite;
            prevReg = topModule.top->top->cpu->rd;
            prevAddr = topModule.top->top->ALUResult;
        }
        topModule.top->eval();
        topModule.vcd->dump(vtime);
    }

    topModule.top->final();
    topModule.vcd->close();

    return 0;
}
catch (std::runtime_error &e)
{
    std::cerr << e.what() << std::endl;
}