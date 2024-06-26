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

//------------------------------------------------------------------------------
/**
  Section: Variables
*/
<#if DVRT_CALLBACK_PROCESS == "Polling">
static bool timer_expired = false;
</#if>

static volatile uint8_t rxBufPtr;
static uint8_t tickCounter, temp_buffer;
static uint16_t DVStreamInterval, DVStreamInterval_Counter;
static uint16_t DVCmdInterval, DVCmdInterval_Counter;

static DVRT_VariablePointerTableEntry_t DVPMA[DYNAMIC_VAR_PTR_COUNT];      /* Dynamic Variable Pointer Monitor Array */

<#if DVRT_CALLBACK_PROCESS == "Polling">
static TIMER_IRQ_Data TimerIrqData =
{
    .hwTimerIntNum = TIMER_IRQ_NUMBER,
    .irq_Status = false
};
</#if>

static volatile union DVCmds
{
    DVRT_StreamUpdates_t stream;
    DVRT_VariableUpdate_t Var;
    DVRT_StreamIntervalUpdate_t interval;
    DVRT_CommandTemplate_t generic;
    uint8_t DVCmdArray[sizeof (DVRT_StreamUpdates_t)];
} DVRT_ReceivedCmd;

static struct flagS{
    bool streamOn;      /* Streaming On */
    bool osr;           /* One shot reading */
    bool ping;          /* Ping target microcontroller */
}DVflag;

size_t DVRT_WritePacket(void)
{
    uint8_t index, var_size;
    uint8_t write_buffer[100];
    size_t wrIndex=0U, nBytesWritten  = 0U;

    write_buffer[wrIndex++] = DV_START_OF_FRAME;
    write_buffer[wrIndex++] = tickCounter++;

    if(DVflag.ping != false)
    {
        write_buffer[wrIndex++] = (uint8_t)(DV_FW_CODE);
        write_buffer[wrIndex++] = (uint8_t)(DV_FW_CODE>>8);
    }
    else
    {
        for (index = 0; index < DYNAMIC_VAR_PTR_COUNT; index++)
        {
            for (var_size = 0; var_size < DVPMA[index].size; var_size++)
            {
                write_buffer[wrIndex++] = DVPMA[index].address[var_size];
            }
        }
    }

    write_buffer[wrIndex++] = DV_END_OF_FRAME;
    nBytesWritten = dvrt_USARTPlibAPI.write_t((uint8_t*)write_buffer, wrIndex);

    return nBytesWritten;
}

void DVRT_Process(void)
{
<#if DVRT_CALLBACK_PROCESS == "Interrupt">
    if(dvrt_USARTPlibAPI.errorGet() != 0U)
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
        if(DVflag.streamOn == true)
        {
            (void)DVRT_WritePacket();
        }
    }

    if((DVflag.osr == true)||(DVflag.ping == true))             // One shot reading or ping command execution
    {   DVflag.osr = false;
        DVflag.ping = false;
        DVflag.streamOn = false;                                // stop streaming
    }
<#elseif DVRT_CALLBACK_PROCESS == "Polling">
    if( timer_expired == true)
    {
        if(dvrt_USARTPlibAPI.errorGet() != 0U)
        {
            rxBufPtr = 0;
            return;
        }

        if(DVCmdInterval_Counter >= DVCmdInterval)
        {
            DVCmdInterval_Counter = 0;
            DVRT_HandleCommand();
        }

        if(DVStreamInterval_Counter >= DVStreamInterval)
        {
            DVStreamInterval_Counter = 0;
            if(DVflag.streamOn == true)
            {
                (void)DVRT_WritePacket();
            }
        }

        if((DVflag.osr == true)||(DVflag.ping == true))         // One shot reading or ping command execution
        {   DVflag.osr = false;
            DVflag.ping = false;
            DVflag.streamOn = false;                            // stop streaming
        }
        timer_expired =0;
    }
</#if>
}

static void DVRT_TMR_Callback_Handler(uint32_t status, uintptr_t context)
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

static size_t DVRT_UART_RX_CallBack_handler(uintptr_t context)
{
    uint32_t nUnreadBytesAvailable;
    size_t nBytesRead = 0U;

    nUnreadBytesAvailable = dvrt_USARTPlibAPI.readCountGet();

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
        if(nUnreadBytesAvailable != 0U)
        {
            nBytesRead = dvrt_USARTPlibAPI.read_t(&temp_buffer, 1U);
            DVRT_ReceivedCmd.DVCmdArray[rxBufPtr++] = temp_buffer;
        }
    }
    DVCmdInterval_Counter = 0;
    return nBytesRead;
}

<#if DVRT_CALLBACK_PROCESS == "Polling">
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
</#if>

void DVRT_Initialize(void)
{
    uint8_t index;

    for (index = 0; index < DYNAMIC_VAR_PTR_COUNT; index++)
    {
        DVPMA[index].address = NULL;
        DVPMA[index].size = 0;
    }

    DVflag.streamOn = true;
    DVStreamInterval = DV_STREAM_TIME;
    DVCmdInterval = DV_RX_CMD_TIMEOUT;

    dvrt_USARTPlibAPI.readThresholdSet(1);
    dvrt_USARTPlibAPI.readNotificationEnable(true, false);
    dvrt_USARTPlibAPI.readCallbackRegister((DVRT_USART_PLIB_CALLBACK)DVRT_UART_RX_CallBack_handler, (uintptr_t)0U);
    dvrt_TMRPlibAPI.timerCallbackRegister((DVRT_TMR_PLIB_CALLBACK)DVRT_TMR_Callback_Handler, (uintptr_t)0U);
    dvrt_TMRPlibAPI.timerStart();
}

void DVRT_HandleCommand(void)
{
    uint8_t VARcount, StartOfFrame, EndOfFrame;
    uint8_t index;
    DVRT_commands command_type;

    if(rxBufPtr >= DV_RX_CMD_MIN_SIZE)
    {
        StartOfFrame = DVRT_ReceivedCmd.DVCmdArray[0];
        index = rxBufPtr-1U;
        EndOfFrame = DVRT_ReceivedCmd.DVCmdArray[index];

        if((StartOfFrame == DV_START_OF_FRAME) && (EndOfFrame == DV_END_OF_FRAME))
        {
            command_type = (DVRT_commands)DVRT_ReceivedCmd.stream.command;
            switch (command_type)
            {
                case UPDATE_VARIABLE_POINTER_TABLE:
                {
                    VARcount = 0;
                    while (VARcount < DVRT_ReceivedCmd.stream.size)
                    {
                        DVPMA[VARcount].size = DVRT_ReceivedCmd.stream.DVPMT[VARcount].size;
                        DVPMA[VARcount].address = DVRT_ReceivedCmd.stream.DVPMT[VARcount].address;
                        VARcount++;
                    }
                    break;
                }
                case UPDATE_VARIABLE_VALUE:
                {
                    VARcount = 0;
                <#if core.CoreArchitecture == "MIPS" >
                    (void)EVIC_INT_Disable();
                <#elseif ((core.CoreArchitecture?contains("ARM")) || (core.CoreArchitecture?contains("CORTEX-A5")))>
                    (void)AIC_INT_IrqDisable();
                <#elseif core.CoreArchitecture?contains("CORTEX-M")>
                    (void)NVIC_INT_Disable();
                <#else>
                    (void)GIC_INT_IrqDisable();
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
                        DVflag.streamOn = false;
                        break;
                }
                case TURN_STREAMING_ON:
                {
                        DVflag.streamOn = true;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
                case ONE_SHOT_READ:
                {
                        DVflag.osr = true;
                        DVflag.streamOn = true;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
                case PING:
                {
                        DVflag.ping = true;
                        DVflag.streamOn = true;
                        DVStreamInterval_Counter = DVStreamInterval;
                        break;
                }
                default:
                        /* Do nothing */
                        break;
            }
        }
    }
    rxBufPtr = 0;
}