/*
 * switch.h
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */

#ifndef SRC_DRIVER_SW_SWITCH_H_
#define SRC_DRIVER_SW_SWITCH_H_

#include "../../device/gpio/gpio.h"
#include <stdint.h>
#include "sleep.h"

#define SWITCH_GPIO     GPIOC
#define SWITCH_0		GPIO_PIN_4
#define SWITCH_1		GPIO_PIN_5
#define SWITCH_2		GPIO_PIN_6
#define SWITCH_3		GPIO_PIN_7

enum {OFF = 0, ON};
enum {ACT_OFF = 0, ACT_ON, N_ACT};

typedef struct{
	GPIO_TypeDef *gpio;
	int pinNum;
	int prevState;
}hSwitch;

void Switch_Init(hSwitch *sw, GPIO_TypeDef *gpio, uint8_t pinNum);
int Switch_getState(hSwitch *sw);

#endif /* SRC_DRIVER_SW_SWITCH_H_ */
