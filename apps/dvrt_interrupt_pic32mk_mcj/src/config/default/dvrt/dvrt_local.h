/*******************************************************************************
  DVRT Source File

  Company
    Microchip Technology Inc.

  File Name
    dvrt_local.h

  Summary
    Data Visualizer interface.

  Description

  Remarks:

*******************************************************************************/


/*******************************************************************************
* Copyright (C) 2024 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/


#ifndef DVRT_LOCAL_H
#define DVRT_LOCAL_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

//  This section lists the other files that are included in this file.
#include "peripheral/uart/plib_uart_common.h"
#include "peripheral/evic/plib_evic.h"


#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif


#define DYNAMIC_VAR_PTR_COUNT       8U                      /* Number of Dynamic Variables Pointers in the Monitor Table */
#define DV_STREAM_TIME              20U                                              /* Streaming time interval (time dependent on main loop tick) */
#define DV_RX_CMD_TIMEOUT           200U                                             /* Command timeout: Timeout after number of times DVRT_process() is called */
#define DV_FW_CODE                  261U                                /* Project Firmware Code */

#define DV_START_OF_FRAME           0x03U                                            /* Start Frame Byte */
#define DV_END_OF_FRAME             0xFCU                                            /* End Frame Byte */
#define DV_RX_CMD_MIN_SIZE          3U                                               /* Minimun number of byte in a RX command */

#define TIMER_IRQ_NUMBER            9

typedef size_t (* DVRT_USART_PLIB_CALLBACK)( uintptr_t context);

typedef uint32_t (*DVRT_USART_PLIB_ERROR_GET)(void);
typedef size_t(*DVRT_USART_PLIB_READ_COUNT_GET)(void);
typedef size_t(*DVRT_USART_PLIB_READ)(void *buffer, const size_t size);
typedef size_t(*DVRT_USART_PLIB_WRITE)(void *buffer, const size_t size);
typedef void (*DVRT_USART_PLIB_READ_THRESHOLD_SET)(uint32_t nBytesThreshold);
typedef void (*DVRT_USART_PLIB_READ_NOTIFICATION_ENABLE)(bool isEnabled, bool isPersistent);
typedef void(*DVRT_USART_PLIB_READ_CALLBACK_REG)(DVRT_USART_PLIB_CALLBACK callback, uintptr_t context);

typedef void (*DVRT_TMR_PLIB_START)(void);
typedef void (*DVRT_TMR_PLIB_STOP)(void);
typedef void (*DVRT_TMR_PLIB_CALLBACK)(uint32_t status, uintptr_t context);
typedef void (*DVRT_TMR_PLIB_CALLBACK_REGISTER)( DVRT_TMR_PLIB_CALLBACK callback, uintptr_t context);

typedef void (*DVRT_TMR_PLIB_PERIOD_SET)(uint16_t period);

typedef struct
{
    INT_SOURCE   hwTimerIntNum;
    bool        irq_Status;
}TIMER_IRQ_Data;

typedef struct
{
    DVRT_TMR_PLIB_START                   timerStart;

    DVRT_TMR_PLIB_STOP                    timerStop;

    DVRT_TMR_PLIB_PERIOD_SET              timerPeriodSet;

    DVRT_TMR_PLIB_CALLBACK_REGISTER       timerCallbackRegister;
}DVRT_TMR_PLIB_INTERFACE;

typedef struct
{
    DVRT_USART_PLIB_READ_CALLBACK_REG readCallbackRegister;
    DVRT_USART_PLIB_READ read_t;
    DVRT_USART_PLIB_READ_COUNT_GET readCountGet;
    DVRT_USART_PLIB_WRITE write_t;
    DVRT_USART_PLIB_ERROR_GET errorGet;
    DVRT_USART_PLIB_READ_THRESHOLD_SET readThresholdSet;
    DVRT_USART_PLIB_READ_NOTIFICATION_ENABLE readNotificationEnable;

} DVRT_USART_PLIB_INTERFACE;

extern const DVRT_TMR_PLIB_INTERFACE dvrt_TMRPlibAPI;
extern const DVRT_USART_PLIB_INTERFACE dvrt_USARTPlibAPI;

// *****************************************************************************
/*
  Summary:
        DVRT_commands
  Description:
        Enum containing a list of commands used to implement the DV Run Time protocol.
*/

typedef enum DVRT_commands{
    UPDATE_VARIABLE_POINTER_TABLE=0U,
    UPDATE_VARIABLE_VALUE=1U,
    UPDATE_STREAMING_TICK=2U,
    TURN_STREAMING_OFF=3U,
    TURN_STREAMING_ON=4U,
    ONE_SHOT_READ=5U,
    PING=6U
} DVRT_commands;


// *****************************************************************************
/*
  Summary:
        DVRT_VariablePointerTableEntry
  Description:
        Defines one entry of the Variable Pointer Table.
*/

typedef struct __attribute__((packed)) DVRT_VariablePointerTableEntry {
    uint8_t size;                             /* Size of address */
    uint8_t * address;                        /* Pointer to address of Variable Pointer Table */
} DVRT_VariablePointerTableEntry_t;


// *****************************************************************************
/*
  Summary:
        DVRT_StreamUpdates
  Description:
        Defines the data structure for updating the stream of variables sent to the Data Visualizer.
*/

typedef struct DVRT_StreamUpdates {
    uint8_t startOfFrame;                     /* Start of frame byte.  */
    uint8_t command;                          /* Byte indicating the command type. This should be set to UPDATE_VARIABLE_POINTER_TABLE (0) for this command. */
    uint8_t size;                             /* Byte indicating the size of variable pointer table */
    DVRT_VariablePointerTableEntry_t DVPMT[DYNAMIC_VAR_PTR_COUNT];   /* Array of DVRT_VariablePointerTableEntry_t structs representing the addresses of the variable pointer table. */
    uint8_t endOfFrame;                       /* End of frame byte. */
} DVRT_StreamUpdates_t;


//*****************************************************************************
/*
  Summary:
        DVRT_VariableUpdate
  Description:
        Defines the data structure needed to update the Variable Pointer Table (DVPMT).
*/

typedef struct __attribute__((packed)) DVRT_VariableUpdate {
    uint8_t startOfFrame;                     /* Start of frame */
    uint8_t command;                          /* Byte indicating the command type. This should be set to UPDATE_VARIABLE_VALUE (1) for this command. */
    uint8_t variablePointerTableSize;         /* Size of the variable pointer table */
    uint8_t * variableAddress;                /* Address of the variable to add to the pointer table */
    uint8_t variableValue[5];                 /* Value of the variable */
    uint8_t endOfFrame;                       /* End of frame */
} DVRT_VariableUpdate_t;


//*****************************************************************************
/*
  Summary:
        DVRT_StreamIntervalUpdate
  Description:
        Defines the data structure for updating the streaming period of frames sent from the DVRT to the Data Visualizer.
*/

typedef struct DVRT_StreamIntervalUpdate {
    uint8_t startOfFrame;                     /* Start of frame byte. */
    uint8_t command;                          /* Byte indicating the command type. This should be set to UPDATE_STREAMING_TICK (2) for this command. */
    uint16_t period;                          /* The streaming interval period, in milliseconds. */
    uint8_t endOfFrame;                       /* End of frame byte. */
} DVRT_StreamIntervalUpdate_t;


// *****************************************************************************
/*
  Summary:
        DVRT_CommandTemplate
  Description:
        Typedef for struct containing the elements needed for a generic DVRT command.
*/

typedef struct DVRT_CommandTemplate{
    uint8_t startOfFrame;                    /* Start of frame */
    uint8_t command;                         /* DVRT Command */
    uint8_t data;                            /* Data payload of command */
    uint8_t endOfFrame;                      /* End of frame */
} DVRT_CommandTemplate_t;


// *****************************************************************************
/*
  Summary:
        DVRT_
  Description:
        Typedef for element of the Dynamic Variable Pointer Monitor Table (DVPMT).
*/

typedef struct DVPMTs {
    uint8_t * address;                      /* Size of address */
    uint8_t size;                           /* Pointer to address of Variable Pointer Table */
} DVPMT_t;


typedef size_t DVRT_error_t;                /* Type used for catching UART errors */


// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************
/**
  Section: Driver Interface
*/
void DVRT_HandleCommand(void);
size_t DVRT_WritePacket(void);
void DVRT_Process(void);
#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif


#endif //DVRT_LOCAL_H

/*******************************************************************************
 End of File
*/