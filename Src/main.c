#include "main.h"

// Simple delay function
void delay(volatile uint32_t count) {
    while (count--);
}

// This is a dummy function to satisfy the linker, which expects this
// when linking against parts of the C library. In a bare-metal context
// with -nostdlib, we provide an empty one.
void _init(void) {}

int main(void) {
    // 1. Enable the clock for GPIOA
    // The GPIOA peripheral is on the AHB2 bus.
    // We need to set the GPIOAEN bit in the RCC_AHB2ENR register.
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;

    // 2. Configure GPIO Pin PA5 as Output
    // The mode is configured in the GPIOx_MODER register.
    // 00: Input, 01: General purpose output, 10: Alternate function, 11: Analog
    
    // First, clear the bits for PA5 (bits 11:10)
    GPIOA->MODER &= ~GPIO_MODER_MODE5_Msk;
    // Then, set the mode to General purpose output (01)
    GPIOA->MODER |= GPIO_MODER_MODE5_0;

    // Optional: Configure output type and speed
    // GPIOA->OTYPER &= ~GPIO_OTYPER_OT5; // Output push-pull (default)
    // GPIOA->OSPEEDR &= ~GPIO_OSPEEDR_OSPEED5; // Low speed (default)

    while (1) {
        // A safer way is to use the atomic Bit Set/Reset Register (BSRR)
        // Set PA5 high (turn on LED)
        GPIOA->BSRR = GPIO_BSRR_BS5;
        delay(500000);

        // Set PA5 low (turn off LED)
        GPIOA->BSRR = GPIO_BSRR_BR5;
        delay(500000);
    }

    return 0; // Should never be reached
}

