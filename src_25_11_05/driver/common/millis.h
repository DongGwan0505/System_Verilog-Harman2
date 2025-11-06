/*
 * millis.h
 *
 *  Created on: 2025. 11. 5.
 *      Author: 82109
 */

#ifndef SRC_DRIVER_COMMON_MILLIS_H_
#define SRC_DRIVER_COMMON_MILLIS_H_
#include <stdint.h>

void incMillis();
void clearMillis();
void setMillis(uint32_t t);
uint32_t millis();

#endif /* SRC_DRIVER_COMMON_MILLIS_H_ */
