/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include "definitions.h"                // SYS function prototypes

volatile uint16_t counter = 10, LED_toggle_delay=500;
volatile int16_t demo_int16 = 0;
volatile uint16_t demo_uint16_array[] = {0};

void TMR4_Callback_InterruptHandler(uint32_t status, uintptr_t context)
{
    if(counter % 2 == 0)
    {
        demo_uint16_array[0] += 250; 
    } 
    counter++;
}

int main ( void )
{
        /* Initialize all modules */
        SYS_Initialize ( NULL );
        
        /* Register callback function for TMR4 period interrupt */
        TMR4_CallbackRegister(TMR4_Callback_InterruptHandler, (uintptr_t)NULL);
        
        /* Start the timer*/
        TMR4_Start();           //1ms 
        
        while ( true )
        {
            if(counter > LED_toggle_delay)
            {
                LED_Toggle();
                counter = 0;
                demo_int16 += 500;
            }
        }
        /* Execution should not come here during normal operation */
        return ( EXIT_FAILURE );
}

/*******************************************************************************
 End of File
*/
