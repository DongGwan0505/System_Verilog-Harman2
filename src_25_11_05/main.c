
#include "xil_printf.h"
#include "driver/common/millis.h"
#include "ap/ap.h"

int main()
{
	//printf("hello world!\n");
	xil_printf("Hello World\n");

	ap_main();

	return 0;
}
