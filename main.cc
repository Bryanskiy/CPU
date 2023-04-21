#include <filesystem>
#include <elfio/elfio.hpp>
#include <cstdint>
#include <memory>

#include "Vtop.h"
#include "verilated.h"

using Addr = std::uint32_t;

class ELF
{
public:
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

    const ELFIO::section* getSectionPtr(const std::string &name) const
    {
        auto *section = elfFile_.sections[name];

        if (section == nullptr)
            throw std::runtime_error{"Unknown section name: " + name};

        return section;
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

int main(int argc, char **argv)
{
    auto contextp = std::make_shared<VerilatedContext>();
    contextp->commandArgs(argc, argv);
    auto top = std::make_shared<Vtop>(&*contextp);
    while (!contextp->gotFinish())
    {
        top->eval();
    }
    return 0;
}