#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

#include "multiboot.h"

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

void cga_print_string(const char* string) {
    for (uint32_t i = 0; *string != '\0'; ++string, ++i) {
        cga_memory[i] = *string | cga_white_on_black_color_code;
    }
}

void kernel_main(multiboot_info_t* multiboot_info) {
#pragma unused(multiboot_info)
    cga_clear_screen();

    cga_print_string("i'm a kernel");

    // returning here will result in our 'hang' routine executing
}
