//#include <stdio.h>
//#include <stdint.h>
#include "xil_printf.h"
//#include "xparameters.h"

#include "ap/ap.h"

//#define FND_SEG_BASEADDR  	XPAR_GPIO_0_S00_AXI_BASEADDR
//#define FND_COM_BASEADDR  	XPAR_GPIO_1_S00_AXI_BASEADDR
//#define BTN_BASEADDR     	XPAR_GPIO_2_S00_AXI_BASEADDR

//typedef struct {
//	volatile uint32_t CR;
//	volatile uint32_t ODR;
//	volatile uint32_t IDR;
//}GPIO_TypeDef;

//#define FND_SEG           ((GPIO_TypeDef *)FND_SEG_BASEADDR)
//#define FND_COM           ((GPIO_TypeDef *)FND_COM_BASEADDR)
//#define BTN               ((GPIO_TypeDef *)BTN_BASEADDR)

int main()
{
	//FND_SEG -> CR = 0xff;
	//FND_COM -> CR = 0xff;
	//BTN->CR = 0x00;

	printf("hello world!\n");
	xil_printf("Hello World\n");
	ap_main();
	led_main();

	//FND_COM->ODR = 0x00;

	while(1)
	{
		//FND_SEG -> ODR = 0xff;
		//FND_COM -> ODR = 0xf0;
		//usleep(300000);
		//FND_SEG -> ODR = 0x00;
		//FND_COM -> ODR = 0x00;
		//usleep(300000);
	}

	return 0;
}
