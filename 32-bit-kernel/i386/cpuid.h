// cpuid.h

#pragma once

#include <stddef.h>
#include <stdbool.h>
#include <stdint.h>

// cpuid support
typedef enum {
    CPUIDGetVendorID = 0x0,
    CPUIDProcessorInfo = 0x1,
    CPUIDExtendedFeatures = 0x7,
    CPUIDExtendedFunctionSupport = 0x80000000,
    CPUIDExtendedProcessorInfo = 0x80000001
} CPUIDLevel;

typedef enum {
    CPUID_EAX = 0,
    CPUID_EBX = 1,
    CPUID_ECX = 2,
    CPUID_EDX = 3
} CPUIDRegister;

extern bool cpuid_supported(void);

extern bool cpuid(CPUIDLevel level, uint32_t sublevel, uint32_t result[static 4]);
