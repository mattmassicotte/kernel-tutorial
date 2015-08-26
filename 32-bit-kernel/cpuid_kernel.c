#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

#include "multiboot.h"
#include "i386/cpuid.h"

// The CGA graphics device is memory-mapped. We're not going to go into a ton 
// of detail here, but the basic idea is:

// | 4 bit background color | 4 bit foreground color | 8 bit ascii character |
// 24 rows of text, with 80 columns per row
volatile uint16_t* cga_memory = (volatile uint16_t*)0xb8000;
const uint32_t cga_column_count = 80;
const uint32_t cga_row_count = 24;
const uint16_t cga_white_on_black_color_code = (15 << 8);

void cga_clear_screen(void) {
    // would be nice to use memset here, but remember, there is no libc available
    for (uint32_t i = 0; i < cga_row_count * cga_column_count; ++i) {
        cga_memory[i] = 0;
    }
}

void cga_print_string(const char* string, uint32_t column, uint32_t row) {
    // this allows us to better control where on screen text will appear
    const uint32_t initial_index = column + cga_column_count * row;

    for (uint32_t i = initial_index; *string != '\0'; ++string, ++i) {
        cga_memory[i] = *string | cga_white_on_black_color_code;
    }
}

bool machine_supports_64bit(void) {
    uint32_t cpuidResults[4];

    cpuid(CPUIDExtendedFunctionSupport, 0, cpuidResults);

    if (cpuidResults[CPUID_EAX] < CPUIDExtendedProcessorInfo) {
        return false;
    }

    cpuid(CPUIDExtendedProcessorInfo, 0, cpuidResults);

    return cpuidResults[CPUID_EDX] & (1 << 29);
}

void kernel_main(multiboot_info_t* multiboot_info) {
    cga_clear_screen();

    cga_print_string("i'm a kernel", 0, 0);

    if (multiboot_info->flags & MULTIBOOT_INFO_CMDLINE) {
        cga_print_string("cmdline: ", 0, 1);
        cga_print_string((const char*)multiboot_info->cmdline, 9, 1);
    }

    if (multiboot_info->flags & MULTIBOOT_INFO_MODS && multiboot_info->mods_count > 0) {
        const multiboot_module_t* module = (const multiboot_module_t*)multiboot_info->mods_addr;

        cga_print_string("module: ", 0, 2);
        cga_print_string((const char*)module->mod_start, 8, 2);
    }

    if (!cpuid_supported()) {
        cga_print_string("cpuid unsupported", 0, 3);
        return;
    }

    cga_print_string("64-bit: ", 0, 3);
    cga_print_string(machine_supports_64bit() ? "supported" : "unsupported", 8, 3);

    // returning here will result in our 'hang' routine executing
}
