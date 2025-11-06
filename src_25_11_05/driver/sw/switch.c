/*
 * switch.c
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */
#include "switch.h"

void Switch_Init(hSwitch *sw, GPIO_TypeDef *gpio, uint8_t pinNum)
{
	int pinMode;

	sw->gpio = gpio;
	sw->pinNum = pinNum;
	sw->prevState = OFF;

	pinMode = sw->gpio->CR;
	pinMode &= ~(1 << pinNum);
	sw->gpio->CR = pinMode;
}

int Switch_getState(hSwitch *sw)
{
	int curState = GPIO_ReadPin(sw->gpio, sw->pinNum);

	if ((curState == ON) && (sw->prevState == OFF)){
		usleep(10000);
		sw->prevState = ON;
		return ACT_ON;
	}
	else if ((curState == OFF) && (sw->prevState == ON)){
		usleep(10000);
		sw->prevState = OFF;
		return ACT_OFF;
	}
	return N_ACT;
}
