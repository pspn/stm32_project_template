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
    // 1. Enable the clocks for GPIOA (LED) and GPIOC (User button)
    // Both peripherals are on the AHB2 bus.
    RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN | RCC_AHB2ENR_GPIOCEN;

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

    // 3. Configure GPIO Pin PC13 as Input for the user button
    GPIOC->MODER &= ~GPIO_MODER_MODE13_Msk; // 00: Input mode

    uint8_t led_on = 0;
    while (1) {
        // Poll the user button on PC13 (active high)
        if (GPIOC->IDR & GPIO_IDR_ID13) {
            // Simple debounce delay
            delay(10000);
            // Confirm button is still pressed
            if (GPIOC->IDR & GPIO_IDR_ID13) {
                // Wait for button release
                while (GPIOC->IDR & GPIO_IDR_ID13);

                // Toggle LED state
                led_on ^= 1;
                if (led_on) {
                    GPIOA->BSRR = GPIO_BSRR_BS5;
                } else {
                    GPIOA->BSRR = GPIO_BSRR_BR5;
                }
            }
        }
    }

    return 0; // Should never be reached
}

