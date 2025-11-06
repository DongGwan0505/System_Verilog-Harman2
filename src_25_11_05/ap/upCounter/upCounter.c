/*
 * upCounter.c
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */
#include "upCounter.h"


enum {STOP, RUN, CLEAR, DOWN};
enum {IDLE, INCREASE_1, INCREASE_100, DECREASE_1, DECREASE_100};


int upCounterState = STOP;
int cntIncDecState = IDLE;
int counter = 0;

hSwitch sw0;
hSwitch sw1;
hSwitch sw2;
hSwitch sw3;

hLed upLed;
hLed downLed;
hLed stopLed;

hButton btnUpCounting;
hButton btnClear;
hButton btnDownCounting;
hButton btnStop;

void initUpCounter()
{
	upCounterState=STOP;
	counter = 0;
	FND_Init();
	LED_Init(&upLed, LED_GPIO, LED_1);
	LED_Init(&downLed, LED_GPIO, LED_2);
	LED_Init(&stopLed, LED_GPIO, LED_3);

	Button_Init(&btnUpCounting, BUTTON_GPIO, BUTTON_0); 	// UP button
	Button_Init(&btnClear, BUTTON_GPIO, BUTTON_1);			// Left button
	Button_Init(&btnStop, BUTTON_GPIO, BUTTON_2);		    // Right button
	Button_Init(&btnDownCounting, BUTTON_GPIO, BUTTON_3);	// Down button
}

void counterIncDec()
{
	switch (cntIncDecState)
	{
	case IDLE:
		if ((Switch_getState(&sw0)==ON) && (Button_getState(&btnUpCounting) == ACT_PUSHED)) {
			cntIncDecState = INCREASE_1;
		}
		else if ((Switch_getState(&sw1)==ON) && (Button_getState(&btnUpCounting) == ACT_PUSHED)) {
			cntIncDecState = INCREASE_100;
		}
		else if ((Switch_getState(&sw2)==ON) && (Button_getState(&btnUpCounting) == ACT_PUSHED)) {
			cntIncDecState = DECREASE_1;
		}
		else if ((Switch_getState(&sw3)==ON) && (Button_getState(&btnUpCounting) == ACT_PUSHED)) {
			cntIncDecState = DECREASE_100;
		}
		break;
	case INCREASE_1:
		counter = counter + 1;
		if(counter>9999){
			counter = 0;
		}
		cntIncDecState = IDLE;
		break;
	case INCREASE_100:
		counter = counter + 100;
		if(counter>9999){
			counter = 0;
		}
		cntIncDecState = IDLE;
		break;
	case DECREASE_1:
		counter = counter - 1;
		if(counter<9999){
			counter = 9999;
		}
		cntIncDecState = IDLE;
		break;
	case DECREASE_100:
		counter = counter - 100;
		if(counter<9999){
			counter = 9999;
		}
		cntIncDecState = IDLE;
		break;
	}
}

void exeUpCounter()
{
	switch (upCounterState)
	{
	case STOP:
		LED_On(&stopLed);
		LED_Off(&upLed);
		LED_Off(&downLed);
		if (Button_getState(&btnUpCounting) == ACT_PUSHED) {
			upCounterState = RUN;
		}
		else if (Button_getState(&btnClear)==ACT_PUSHED){
			upCounterState = CLEAR;
		}
		else if (Button_getState(&btnDownCounting)==ACT_PUSHED){
			upCounterState = DOWN;
		}
		break;
	case RUN:
		LED_Off(&stopLed);
		LED_Off(&downLed);
		runUpCounter();
		if (Button_getState(&btnStop) == ACT_PUSHED) {
			upCounterState = STOP;
		}
		else if (Button_getState(&btnDownCounting) == ACT_PUSHED) {
			upCounterState = DOWN;
		}
		else if (Button_getState(&btnClear) == ACT_PUSHED) {
			upCounterState = CLEAR;
		}
		break;
	case CLEAR:
		LED_Off(&upLed);
		LED_Off(&downLed);
		clearUpCounter();
		upCounterState = STOP;
		break;
	case DOWN:
		LED_Off(&stopLed);
		LED_Off(&upLed);
		runDownCounter();
		if (Button_getState(&btnStop) == ACT_PUSHED) {
			upCounterState = STOP;
		}
		else if (Button_getState(&btnUpCounting) == ACT_PUSHED) {
			upCounterState = RUN;
		}
		else if (Button_getState(&btnClear) == ACT_PUSHED) {
			upCounterState = CLEAR;
		}
		break;
	}
}

void runUpCounter()
{
	if(counter==9999){
		counter = 0;
	}

	static uint32_t prevTime = 0;
	uint32_t curTime = millis();
	if (curTime - prevTime < 100) return;
	prevTime = curTime;

	FND_SetNumber(counter++);

	LED_Toggle(&upLed);
}

void runDownCounter()
{
	if(counter==0){
		counter = 9999;
	}

	static uint32_t prevTime = 0;
	uint32_t curTime = millis();
	if (curTime - prevTime < 100) return;
	prevTime = curTime;

	FND_SetNumber(counter--);

	LED_Toggle(&downLed);
}

void clearUpCounter()
{
	counter = 0;
	FND_SetNumber(counter);
}
