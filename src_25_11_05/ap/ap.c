/*
 * ap.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: 82109
 */

#include "ap.h"
#include "sleep.h"
#include "../driver/btn/button.h"

hButton upBtn;
hLed led0;

void ISR();
void millisCounter();

void ap_main()
{
   initPowerInd();
   initUpCounter();

   while(1)
   {
	   dispPowerInd(); //세그먼트 on
	   exeUpCounter();
	   counterIncDec();

	   ISR(); //Interrupt Service Routine
   }

}

void ISR() //Interrupt Service Routine
{
	millisCounter();

	FND_DispNumber();
}

void millisCounter()
{
	incMillis();
	usleep(1000);
}
