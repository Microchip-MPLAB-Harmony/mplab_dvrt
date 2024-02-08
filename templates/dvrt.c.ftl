/*******************************************************************************
  DVRT Source File

  Company
    Microchip Technology Inc.

  File Name
    ${DVRT_MODULE?lower_case}.c

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


// *****************************************************************************
// *****************************************************************************
// Included Files
// *****************************************************************************
// *****************************************************************************

#include "${DVRT_MODULE?lower_case}.h"

// *****************************************************************************
// *****************************************************************************
// Local Data Type Definitions
// *****************************************************************************
// *****************************************************************************

DVRT_error_t error;

/**
  Section: Driver Interface
*/
void DVRT_UART_RX_CallBack(void);
void DVRT_HandleCommand(void);
void DVRT_UART_WriteByte(uint8_t);
void DVRT_WritePacket(void);
void DVRT_Error_Callback(void);

//------------------------------------------------------------------------------
/**
  Section: Variables
*/
volatile bool timer_expired=0;
volatile uint8_t rxBufPtr, tickCounter;
uint16_t DVStreamInterval, DVStreamInterval_Counter;
uint16_t DVCmdInterval, DVCmdInterval_Counter;

DVRT_VariablePointerTableEntry_t DVPMT[DYNAMIC_VAR_PTR_COUNT];      /* Dynamic Variable Pointer Monitor Array */

static TIMER_IRQ_Data TimerIrqData =
{
    .hwTimerIntNum = TIMER_IRQ_NUMBER,
    .irq_Status = false
};

volatile union DVCmds
{
    DVRT_StreamUpdates_t stream;
    DVRT_VariableUpdate_t Var;
    DVRT_StreamIntervalUpdate_t interval;
    DVRT_CommandTemplate_t generic;
    uint8_t DVCmdArray[sizeof (DVRT_StreamUpdates_t)];
} DVRT_ReceivedCmd;

struct flagS{
    unsigned streamOn   : 1;    /* Streaming On */
    unsigned osr        : 1;    /* One shot reading */
    unsigned ping       : 1;    /* Ping target microcontroller */
}DVflag;

void DVRT_WritePacket(void)
{
    uint8_t index, var_size, wrIndex=0;
    uint8_t write_buffer[100];

    write_buffer[wrIndex++] = DV_START_OF_FRAME;
    write_buffer[wrIndex++] = tickCounter++;

    if(DVflag.ping)
    {
        write_buffer[wrIndex++] = (uint8_t)(DV_FW_CODE);
        write_buffer[wrIndex++] = (uint8_t)(DV_FW_CODE>>8);
    }
    else
    {
        for (index = 0; index < DYNAMIC_VAR_PTR_COUNT; index++)
        {
            for (var_size = 0; var_size < DVPMT[index].size; var_size++)
            {
                write_buffer[wrIndex++] = *(DVPMT[index].address + var_size);
            }
        }
    }

    write_buffer[wrIndex++] = DV_END_OF_FRAME;
    dvrt_USARTPlibAPI.write_t((uint8_t*)write_buffer, wrIndex);
}

void TMR_Callback_Handler(uint8_t status, uintptr_t context)
{
<#if DVRT_CALLBACK_PROCESS == "Interrupt">
    DVRT_Process();
<#elseif DVRT_CALLBACK_PROCESS == "Polling">
    timer_expired = 1;
    DVCmdInterval_Counter++;
    DVStreamInterval_Counter++;
<#else>
</#if>
}

void DVRT_Disable(void)
{
<#if core.CoreArchitecture?contains("CORTEX-M")>
    TimerIrqData.irq_Status = NVIC_INT_SourceDisable(TimerIrqData.hwTimerIntNum);
<#elseif ((core.CoreArchitecture?contains("ARM")) || (core.CoreArchitecture?contains("CORTEX-A5")))>
    TimerIrqData.irq_Status = AIC_INT_SourceDisable(TimerIrqData.hwTimerIntNum);
<#elseif core.CoreArchitecture?contains("CORTEX-A7")>
    TimerIrqData.irq_Status = GIC_INT_SourceDisable(TimerIrqData.hwTimerIntNum);
<#elseif core.CoreArchitecture?contains("MIPS")>
    TimerIrqData.irq_Status = EVIC_INT_SourceDisable(TimerIrqData.hwTimerIntNum);
</#if>
}

void DVRT_Enable(void)
{
<#if core.CoreArchitecture?contains("CORTEX-M")>
    NVIC_INT_SourceRestore(TimerIrqData.hwTimerIntNum, TimerIrqData.irq_Status);
<#elseif ((core.CoreArchitecture?contains("ARM")) || (core.CoreArchitecture?contains("CORTEX-A5")))>
    AIC_INT_SourceRestore(TimerIrqData.hwTimerIntNum, TimerIrqData.irq_Status);
<#elseif core.CoreArchitecture?contains("CORTEX-A7")>
    GIC_INT_SourceRestore(TimerIrqData.hwTimerIntNum, TimerIrqData.irq_Status);
<#elseif core.CoreArchitecture?contains("MIPS")>
    EVIC_INT_SourceRestore(TimerIrqData.hwTimerIntNum, TimerIrqData.irq_Status);
</#if>
}

<#if CONNECTED_PLIB_NAME?? && ((CONNECTED_PLIB_NAME == "UART") || (CONNECTED_PLIB_NAME == "DBGU") || (CONNECTED_PLIB_NAME == "USART"))>
void UART_RX_CallBack_handler(${CONNECTED_PLIB_NAME}_EVENT event, uintptr_t context)
<#else>
void UART_RX_CallBack_handler(${CONNECTED_PLIB_NAME}_USART_EVENT event, uintptr_t context)
</#if>
{
<#if CONNECTED_PLIB_NAME?? && CONNECTED_PLIB_NAME == "FLEXCOM">
    if(dvrt_USARTPlibAPI.errorGet() != ${CONNECTED_PLIB_NAME}_USART_ERROR_NONE)
<#elseif CONNECTED_PLIB_NAME?? && ((CONNECTED_PLIB_NAME == "UART") || (CONNECTED_PLIB_NAME == "DBGU"))>
    if(dvrt_USARTPlibAPI.errorGet() != ${CONNECTED_PLIB_NAME}_ERROR_NONE)
<#else>
    if(dvrt_USARTPlibAPI.errorGet() != USART_ERROR_NONE)
</#if>
    {
        rxBufPtr = 0;
    }
    else
    {
        if(dvrt_USARTPlibAPI.readCountGet() != 0)
        {
            dvrt_USARTPlibAPI.read_t((uint8_t*)&DVRT_ReceivedCmd.DVCmdArray[rxBufPtr++], 1);
        }
    }
    DVCmdInterval_Counter = 0;
}

void DVRT_Initialize(void)
{
    uint8_t index;

    for (index = 0; index < DYNAMIC_VAR_PTR_COUNT; index++)
    {
        DVPMT[index].address = 0;
        DVPMT[index].size = 0;
    }

    DVflag.streamOn = 1;
    DVStreamInterval = DV_STREAM_TIME;
    DVCmdInterval = DV_RX_CMD_TIMEOUT;

    dvrt_USARTPlibAPI.readThresholdSet(1);
    dvrt_USARTPlibAPI.readNotificationEnable(true, false);
    dvrt_USARTPlibAPI.readCallbackRegister((DVRT_USART_PLIB_CALLBACK)UART_RX_CallBack_handler, (uintptr_t)NULL);
    dvrt_TMRPlibAPI.timerCallbackRegister((DVRT_TMR_PLIB_CALLBACK)TMR_Callback_Handler, (uintptr_t)NULL);
    dvrt_TMRPlibAPI.timerStart();
}

void DVRT_Process(void)
{
<#if DVRT_CALLBACK_PROCESS == "Interrupt">
    if(dvrt_USARTPlibAPI.errorGet())
    {
        rxBufPtr = 0;
        return;
    }

    if(DVCmdInterval_Counter++ >= DVCmdInterval)
    {
        DVCmdInterval_Counter = 0;
        DVRT_HandleCommand();
    }

    if(DVStreamInterval_Counter++ >= DVStreamInterval)
    {
        DVStreamInterval_Counter = 0;
        if(DVflag.streamOn)
        {
            DVRT_WritePacket();
        }
    }

    if(DVflag.osr || DVflag.ping)           // One shot reading or ping command execution
    {   DVflag.osr = 0;
        DVflag.ping = 0;
        DVflag.streamOn = 0;                // stop streaming
    }
<#elseif DVRT_CALLBACK_PROCESS == "Polling">
    if( timer_expired == 1)
    {
        if(dvrt_USARTPlibAPI.errorGet())
        {
            rxBufPtr = 0;
            return;
        }

        if(DVCmdInterval_Counter++ >= DVCmdInterval)
        {
            DVCmdInterval_Counter = 0;
            DVRT_HandleCommand();
        }

        if(DVStreamInterval_Counter++ >= DVStreamInterval)
        {
            DVStreamInterval_Counter = 0;
            if(DVflag.streamOn)
            {
                DVRT_WritePacket();
            }
        }

        if(DVflag.osr || DVflag.ping)           // One shot reading or ping command execution
        {   DVflag.osr = 0;
            DVflag.ping = 0;
            DVflag.streamOn = 0;                // stop streaming
        }
        timer_expired =0;
    }
</#if>
}

void DVRT_HandleCommand(void)
{
    uint8_t VARcount;

    if(rxBufPtr >= DV_RX_CMD_MIN_SIZE)
    {
        if((DVRT_ReceivedCmd.DVCmdArray[0] == DV_START_OF_FRAME) && (DVRT_ReceivedCmd.DVCmdArray[rxBufPtr-1] == DV_END_OF_FRAME))
        {
            switch (DVRT_ReceivedCmd.stream.command)
            {
                case UPDATE_VARIABLE_POINTER_TABLE:
                {
                    VARcount = 0;
                    while (VARcount < DVRT_ReceivedCmd.stream.size)
                    {
                        DVPMT[VARcount].size = DVRT_ReceivedCmd.stream.DVPMT[VARcount].size;
                        DVPMT[VARcount].address = DVRT_ReceivedCmd.stream.DVPMT[VARcount].address;
                        VARcount++;
                    }
                    break;
                }
                case UPDATE_VARIABLE_VALUE:
                {
                    VARcount = 0;
                <#if core.CoreArchitecture == "MIPS" >
                    EVIC_INT_Disable();
                <#elseif ((core.CoreArchitecture?contains("ARM")) || (core.CoreArchitecture?contains("CORTEX-A5")))>
                    AIC_INT_IrqDisable();
                <#elseif core.CoreArchitecture?contains("CORTEX-M")>
                    NVIC_INT_Disable();
                <#else>
                    GIC_INT_IrqDisable();
                </#if>
                    while (VARcount < DVRT_ReceivedCmd.Var.variablePointerTableSize)
                    {
                        *(uint8_t *)(DVRT_ReceivedCmd.Var.variableAddress + VARcount) = DVRT_ReceivedCmd.Var.variableValue[VARcount];
                        VARcount++;
                    }
                <#if core.CoreArchitecture == "MIPS" >
                    EVIC_INT_Enable();
                <#elseif ((core.CoreArchitecture?contains("ARM")) || (core.CoreArchitecture?contains("CORTEX-A5")))>
                    AIC_INT_IrqEnable();
                <#elseif core.CoreArchitecture?contains("CORTEX-M")>
                    NVIC_INT_Enable();
                <#else>
                    GIC_INT_IrqEnable();
                </#if>
                    break;
                }
                case UPDATE_STREAMING_TICK:
                {
                        DVStreamInterval = DVRT_ReceivedCmd.interval.period;
                        DVStreamInterval_Counter = 0;
                        break;
                }
                case TURN_STREAMING_OFF:
                {
                        DVflag.streamOn = 0;
                        break;
                }
                case TURN_STREAMING_ON:
                {
                        DVflag.streamOn = 1;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
                case ONE_SHOT_READ:
                {
                        DVflag.osr = 1;
                        DVflag.streamOn = 1;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
                case PING:
                {
                        DVflag.ping = 1;
                        DVflag.streamOn = 1;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
            }
        }
    }
    rxBufPtr = 0;
}