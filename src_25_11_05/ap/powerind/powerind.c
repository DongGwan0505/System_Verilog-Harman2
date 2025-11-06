/*
 * powerind.c
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */
#include "powerind.h"

hLed powerLed;

void initPowerInd()
{
	LED_Init(&powerLed, LED_GPIO, LED_0);

}

void dispPowerInd()
{
	static uint32_t prevTime = 0;
	uint32_t curTime = millis();

	if(curTime - prevTime < 500) return;
	prevTime = curTime;
	LED_Toggle(&powerLed);
}
