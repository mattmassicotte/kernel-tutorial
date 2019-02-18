// CGA text mode works like this:
// | 4 bit background color | 4 bit foreground color | 8 bit ascii character |

// The CGA device is memory-mapped to this address. It looks like a 2-D array of columns
// and rows.
volatile uint16_t* cga_memory = (volatile uint16_t*)0xb8000;
const uint16_t cga_column_count = 80;
const uint16_t cga_row_count = 24;

typedef enum {
    CGA_COLOR_BLACK = 0,
    CGA_COLOR_BLUE = 1,
    CGA_COLOR_GREEN = 2,
    CGA_COLOR_CYAN = 3,
    CGA_COLOR_RED = 4,
    CGA_COLOR_MAGENTA = 5,
    CGA_COLOR_BROWN = 6,
    CGA_COLOR_LIGHT_GREY = 7,
    CGA_COLOR_DARK_GREY = 8,
    CGA_COLOR_LIGHT_BLUE = 9,
    CGA_COLOR_LIGHT_GREEN = 10,
    CGA_COLOR_LIGHT_CYAN = 11,
    CGA_COLOR_LIGHT_RED = 12,
    CGA_COLOR_LIGHT_MAGENTA = 13,
    CGA_COLOR_LIGHT_BROWN = 14,
    CGA_COLOR_WHITE = 15,
} cga_color_code;

typedef struct {
    uint32_t row;
    uint32_t column;
} cga_device;

uint16_t cga_character_encode(char c, cga_color_code fg_color, cga_color_code bg_color) {
    const uint8_t color = fg_color | (bg_color << 4);

    return c | (color << 8);
}

void cga_write_character_at_position(uint16_t encoded_char, uint32_t column, uint32_t row) {
    cga_memory[column + row * cga_column_count] = encoded_char;
}

uint32_t cga_device_increment_p(cga_device* device) {
    return device->column + device->row * cga_column_count;
}

void cga_print_string(cga_device* device, const char* string) {
    for (; string != '\0'; ++string) {
        const uint16_t character = cga_character_encode(*string, CGA_COLOR_WHITE, CGA_COLOR_BLACK);

        cga_print_char(character, device->column, device->row);

        device->column += 1;
        if (device->column >= cga_column_count) {
            device->column = 0;
            device->row += 1;
        }

        if (device->row >= cga_row_count) {
            device->row = 0;
            device->column = 0;
        }
    }
}
