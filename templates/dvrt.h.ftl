/*******************************************************************************
  DVRT Source File

  Company
    Microchip Technology Inc.

  File Name
    ${DVRT_MODULE?lower_case}.h

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


#ifndef ${DVRT_MODULE}_H
#define ${DVRT_MODULE}_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

//  This section lists the other files that are included in this file.
#include "dvrt_local.h"

#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif

// *****************************************************************************
// *****************************************************************************
// Section: Interface Routines
// *****************************************************************************
// *****************************************************************************
/* The following functions make up the methods (set of possible operations) of
   this interface.
*/
<#if DVRT_CALLBACK_PROCESS == "Interrupt">
void ${DVRT_MODULE}_Initialize(void);
<#elseif DVRT_CALLBACK_PROCESS == "Polling">
void ${DVRT_MODULE}_Initialize(void);
void ${DVRT_MODULE}_Process(void);
void DVRT_Enable(void);
void DVRT_Disable(void);
</#if>

#ifdef __cplusplus  // Provide C++ Compatibility

    }

#endif


#endif //${DVRT_MODULE}_H

/*******************************************************************************
 End of File
*/