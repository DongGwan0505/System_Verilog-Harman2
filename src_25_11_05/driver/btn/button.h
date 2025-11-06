#ifndef SRC_DRIVER_BTN_BUTTON_H_
#define SRC_DRIVER_BTN_BUTTON_H_

#include "../../device/gpio/gpio.h"
#include <stdint.h>
#include "sleep.h"

#define BUTTON_GPIO     GPIOC
#define BUTTON_0			GPIO_PIN_0
#define BUTTON_1			GPIO_PIN_1
#define BUTTON_2			GPIO_PIN_2
#define BUTTON_3			GPIO_PIN_3

enum {RELEASED = 0, PUSHED};
enum {ACT_PUSHED = 0, ACT_RELEASED, NO_ACT};

typedef struct{
	GPIO_TypeDef *gpio;
	int pinNum;
	int prevState;
}hButton;

void Button_Init(hButton *btn, GPIO_TypeDef *gpio, uint8_t pinNum);
int Button_getState(hButton *btn);

#endif
