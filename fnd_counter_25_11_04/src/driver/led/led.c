/*
 * led.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: 82109
 */
#include "led.h"

void LED_Init(hLed *pLed, GPIO_TypeDef *gpio, int pinNum)
{
	uint8_t pin;

	pLed->gpio = gpio;
	pLed->pinNum = pinNum;
	pin = pLed->gpio->CR;
	pin |= (1<<pinNum);

	GPIO_Init(pLed->gpio, pin);
}

void LED_On(hLed *pLed)
{
	GPIO_Set(pLed->gpio, pLed->pinNum);
}

void LED_Off(hLed *pLed)
{
	GPIO_Reset(pLed->gpio, pLed->pinNum);
}

void LED_Toggle(hLed *pLed)
{
	GPIO_Toggle(pLed->gpio, pLed->pinNum);
}

hLed powerLed;
hLed upLed;
hLed downLed;

void led_main()
{
	//make application
	LED_Init(&powerLed, LED_GPIO, LED_0);
	//LED_Init(&upLed, LED_GPIO, LED_1);
	//LED_Init(&downLed, LED_GPIO, LED_2);

	FND_Init();

	while(1)
	{
		LED_On(&powerLed);
		usleep(10000); //0.1ms
		LED_On(&upLed);
		usleep(10000);
		LED_On(&downLed);
		usleep(10000);

		LED_Off(&powerLed);
		usleep(10000); //0.1ms
		LED_Off(&upLed);
		usleep(10000);
		LED_Off(&downLed);
		usleep(10000);
	}

}
