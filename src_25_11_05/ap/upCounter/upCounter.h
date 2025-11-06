/*
 * upCounter.h
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */
#ifndef SRC_AP_UPCOUNTER_UPCOUNTER_H_
#define SRC_AP_UPCOUNTER_UPCOUNTER_H_
#include <stdint.h>
#include "../../driver/fnd/fnd.h"
#include "../../driver/led/led.h"
#include "../../driver/btn/button.h"
#include "../../driver/sw/switch.h"
#include "../../driver/common/millis.h"

void initUpCounter();
void runUpCounter();
void runDownCounter();
void clearUpCounter();
void exeUpCounter();
void counterIncDec();

#endif /* SRC_AP_UPCOUNTER_UPCOUNTER_H_ */
