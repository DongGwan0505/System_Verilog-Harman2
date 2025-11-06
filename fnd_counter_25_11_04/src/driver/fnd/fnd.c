/*
 * fnd.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: 82109
 */

#include "fnd.h"
#include "sleep.h"
#include "../led/led.h"

hFnd fnd;
int fndNumber;

void FND_Init()
{
	fnd.gpio_seg = GPIOA;
	fnd.gpio_com = GPIOB;
	fnd.digit_1 = GPIO_PIN_0;
	fnd.digit_10 = GPIO_PIN_1;
	fnd.digit_100 = GPIO_PIN_2;
	fnd.digit_1000 = GPIO_PIN_3;
	fnd.gpio_seg->CR = 0xff;
	fnd.gpio_com->CR = 0xff;
}

hLed powerLed;
hLed upLed;
hLed downLed;


void FND_DispNumber(int number)
{
	fndNumber = number;
	//LED_Init(&powerLed, LED_GPIO, LED_0);
	FND_Init();

	FND_AllOff();
	//LED_On(&powerLed);
	//LED_On(&upLed);
	//LED_On(&downLed);
	FND_ShowDigit(fndNumber%10);
	FND_SelDigit(fnd.digit_1);
	usleep(1000);

	FND_AllOff();
	FND_ShowDigit(fndNumber/10%10);
	FND_SelDigit(fnd.digit_10);
	usleep(1000);

	FND_AllOff();
	FND_ShowDigit(fndNumber/100%10);
	FND_SelDigit(fnd.digit_100);
	usleep(1000);

	FND_AllOff();
	FND_ShowDigit(fndNumber/1000%10);
	FND_SelDigit(fnd.digit_1000);
	//LED_Off(&powerLed);
	//LED_Off(&upLed);
	//LED_Off(&downLed);
	usleep(1000);
}

void FND_AllOff()
{
	GPIO_Set(fnd.gpio_com, fnd.digit_1);
	GPIO_Set(fnd.gpio_com, fnd.digit_10);
	GPIO_Set(fnd.gpio_com, fnd.digit_100);
	GPIO_Set(fnd.gpio_com, fnd.digit_1000);
}

void FND_SelDigit(int digit)
{
	GPIO_Reset(fnd.gpio_com, digit);
}

void FND_ShowDigit(int digit)
{
	uint8_t segFont[10] = {0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90};

	GPIO_Write(fnd.gpio_seg, segFont[digit]);
}
