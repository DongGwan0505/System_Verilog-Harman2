/*
 * ap.c
 *
 *  Created on: 2025. 11. 4.
 *      Author: 82109
 */

#include "ap.h"
#include "sleep.h"

hLed powerLed;
hLed upLed;
hLed downLed;

void ap_main()
{
   LED_Init(&powerLed, LED_GPIO, LED_0);

   FND_Init();
   int counter;

   while(1)
   {

      static int init = 0;
      if (!init) { counter = 0; init = 1; }

      for (int i = 0; i < 120; i++)
      {
         FND_DispNumber(counter);

         if (i < 30) {
            LED_On(&powerLed);
            LED_Off(&upLed);
            LED_Off(&downLed);
         } else if (i < 60) {
            LED_Off(&powerLed);
            LED_On(&upLed);
            LED_Off(&downLed);
         } else if (i < 90) {
            LED_Off(&powerLed);
            LED_Off(&upLed);
            LED_On(&downLed);
         } else {
            LED_Off(&powerLed);
            LED_Off(&upLed);
            LED_Off(&downLed);
         }

         usleep(1000);
      }

      counter = (counter + 1) % 10000;
   }


}
