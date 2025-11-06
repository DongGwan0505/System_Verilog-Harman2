
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"

typedef struct{
	volatile uint32_t DR;
	volatile uint32_t CR;
}GPIO_TypeDef;

#define GPIO_BASE_ADDR		0x40000000

#define GPIOA				((GPIO_TypeDef *)(GPIO_BASE_ADDR))

void LED_write(GPIO_TypeDef * gpio, uint32_t data);
void delay_m(uint32_t ms);

int main()
{
    //GPIO_CR = 0x0000; //all output
    GPIOA->CR = 0x0000;

    printf("Hello World\n\r");
    printf("Successfully ran Hello World application\n\r");

    while(1)
    {
    	LED_write(GPIOA, 0xffff);
    	delay_m(300);
    	LED_write(GPIOA, 0x0000);
    	delay_m(300);
    }

    return 0;
}

void delay_m(uint32_t ms)
{
	usleep(ms * 1000);
}



void LED_write(GPIO_TypeDef * gpio, uint32_t data)
{
	gpio->DR = data;
}
