#include <filesystem>
#include <cstdint>
#include <memory>
#include <cassert>

#include <elfio/elfio.hpp>
#include <CLI/App.hpp>
#include <CLI/Config.hpp>
#include <CLI/Formatter.hpp>

#include <verilated_vcd_c.h>
#include "Vriscv.h"
#include "Vriscv_riscv.h"
#include "Vriscv_fetch.h"

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
        top = std::make_shared<Vriscv>();

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
            uint8_t *dst = reinterpret_cast<uint8_t *>(top->riscv->fetch->RAM.data());

            std::copy(begin, begin + fileSize, dst + va);
        }

        top->clk = 0;
        top->reset = 0;
        top->riscv->fetch->pc = elfLoader.getEntryPoint();

        return 0;
    }

    std::shared_ptr<Vriscv> top;
    std::shared_ptr<VerilatedVcdC> vcd;
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

    vluint64_t vtime = 0;
    while (!Verilated::gotFinish())
    {
        vtime += 1;
        if (vtime % 8 == 0)
        {
            topModule.top->clk ^= 1;
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