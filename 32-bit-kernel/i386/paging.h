// paging.h

#pragma once

#include <stdbool.h>

#define ATTR_PACK(x) __attribute((packed, aligned(x)))

typedef struct {
    bool present:1;          // 0
    bool writable:1;         // 1
    bool user_accessable:1;  // 2
    bool write_through:1;    // 3
    bool caching_disabled:1; // 4
    bool accessed:1;         // 5
    bool ignored1:1;         // 6
    uint8_t reserved1:1;     // 7
    uint8_t ignored2:4;      // 11:8
    uint64_t address:40;     // M–1:12 (M = 52)
    uint8_t ignored3:11      // 62:52
    bool no_execute:1;       // 63
} pml4_entry_t ATTR_PACK(1);
_Static_assert(sizeof(pml4_entry_t) == 8, "size of pml4_entry_t must be 8 bytes");

typedef struct {
    bool present:1;           // 0
    bool writable:1;          // 1
    bool user_accessable:1;   // 2
    bool write_through:1;     // 3
    bool caching_disabled:1;  // 4
    bool accessed:1;          // 5
    bool dirty:1;             // 6
    bool 1gb_page_size:1;     // 7
    bool global:1;            // 8
    uint8_t ignored1:3;       // 11-9
    bool pat_enabled:1;       // 12
    uint8_t resreved1:17;     // 29:13
    uint8_t address:22;       // M–1:30 (M = 52)
    uint8_t ignored2:7;       // 58:52
    uint8_t protection_key:4; // 62:59 
    bool no_execute:1;        // 63
} pdpt_1gb_entry_t ATTR_PACK(1);
_Static_assert(sizeof(pdpt_1gb_entry_t) == 8, "size of pdpt_1gb_entry_t must be 8 bytes");

typedef struct {
    bool present:1;            // 0
    bool writable:1;           // 1
    bool user_accessable:1;    // 2
    bool write_through:1;      // 3
    bool caching_disabled:1;   // 4
    bool accessed:1;           // 5
    bool ignored1:1;           // 6
    bool 1gb_page_size:1;      // 7
    uint8_t ignored2:4;        // 11-8
    uint8_t address:40;        // M–1:12 (M = 52)
    uint8_t ignored3:11;       // 62:52
    bool no_execute:1;         // 63
} pdpt_pd_entry_t ATTR_PACK(1);
_Static_assert(sizeof(pdpt_pd_entry_t) == 8, "size of pdpt_pd_entry_t must be 8 bytes");

typedef struct {
    bool present:1;            // 0
    bool writable:1;           // 1
    bool user_accessable:1;    // 2
    bool write_through:1;      // 3
    bool caching_disabled:1;   // 4
    bool accessed:1;           // 5
    bool dirty:1;              // 6
    bool 2mb_page_size:1;      // 7
    bool global:1;             // 8
    bool pat_enabled:1;        // 12
    uint8_t resreved1:8;       // 20:13
    uint8_t address:31;        // M–1:21 (M = 52)
    uint8_t ignored2:7;        // 58:52
    uint8_t protection_key:4;  // 62:59
    bool no_execute:1;         // 63
} pd_2mb_entry_t ATTR_PACK(1);
_Static_assert(sizeof(pd_2mb_entry_t) == 8, "size of pd_2mb_entry_t must be 8 bytes");

typedef struct {
    uint8_t present:1;
    uint8_t writable:1;
    uint8_t user_accessable:1;
    uint8_t write_through_caching:1;
    uint8_t caching_disabled:1;
    uint8_t accessed:1;
    uint8_t dirty:1;
    uint8_t unused:1;
    uint8_t global:1;
    uint8_t available:3;
    uint32_t physical_page_address:20;
} page_table_entry ATTR_PACK(1);
_Static_assert(sizeof(page_table_entry) == 8, "size of page_table_entry must be 8 bytes");
