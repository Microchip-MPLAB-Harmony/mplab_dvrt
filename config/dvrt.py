# coding: utf-8
"""*****************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
*****************************************************************************"""
import re
global sort_alphanumeric

dvrt_mcc_helpkeyword = "mcc_h3_dvrt_configurations"

def handleMessage(messageID, args):
    global dvrt_useSystick
    global dvrt_tmrPLIB
    global dvrt_AchievableTickRateMsComment
    global dvrt_TickRateMs
    global plibUsed
        
    sysTickRate = {"sys_time_tick_ms" : 0.0}
    sysTickPLIBConfig = dict()
    result_dict = dict()

    if dvrt_useSystick.getValue() == True:
        dvrt_tmrPLIB.setValue("core")
        
    if  messageID == "DVRT_PLIB_CAPABILITY":
        if args["plib_mode"] == "PERIOD_MODE":
            if dvrt_tmrPLIB.getValue() == "CORE_TIMER":
                result_dict.update({"TIMER_MODE": "DVRT_PLIB_MODE_PERIOD", "dvrt_tick_millisec": 1})   
                dvrt_TickRateMs.setVisible(False)
                dvrt_AchievableTickRateMsComment.setVisible(False)
            else:   
                result_dict.update({"TIMER_MODE": "DVRT_PLIB_MODE_PERIOD", "dvrt_tick_millisec": 1})
                dvrt_TickRateMs.setReadOnly(True)
                dvrt_TickRateMs.setReadOnly(False)
                dvrt_TickRateMs.setVisible(True)
                dvrt_AchievableTickRateMsComment.setVisible(True)
                
    elif messageID == "DVRT_SYS_TICK_PLIB_CAPABILITY":                                                  
        dvrt_TickRateMs.setVisible(True)
        dvrt_AchievableTickRateMsComment.setVisible(True)
        sysTickPLIBConfig["plib_mode"] = "DVRT_PLIB_MODE_PERIOD"                                        
        sysTickPLIBConfig["sys_tick_ms"] = float(dvrt_TickRateMs.getValue())                            
        return sysTickPLIBConfig
            
    elif messageID == "DVRT_ACHIEVABLE_TICK_RATE_HZ":
        dvrt_AchievableTickRateHz.setValue(args["tick_rate_hz"])
        
    elif (messageID == "REQUEST_CONFIG_PARAMS"):
        if args.get("localComponentID") != None:

            result_dict = Database.sendMessage(args["localComponentID"], "UART_RING_BUFFER_MODE", {"isEnabled":True, "isReadOnly":True})

            result_dict = Database.sendMessage(args["localComponentID"], "UART_RING_BUFFER_FIFO_MODE", {"isEnabled":True, "isReadOnly":True})

    return result_dict

def onAttachmentConnected(source, target):
    global deviceUsed

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]
    localID = localComponent.getID()
    dvrtDict = {"ID":"dvrt"}

    if connectID == "UART" :
        if "USART" or "UART" or "SERCOM" or "FLEXCOM" or "DBGU" in remoteID:
            deviceUsed = localComponent.getSymbolByID("USART_PLIB_CONNECTED")
            deviceUsed.clearValue()
            deviceUsed.setValue(remoteID.upper())

    elif ((connectID == "TMR") or (connectID == "core_timer")):
        plibUsed = localComponent.getSymbolByID("TMR_PLIB_COMPONENT_CONNECTED")
        plibUsed.clearValue()
        plibUsed.setValue(remoteID.upper())
        #Request PLIB to publish it's capabilities
        plib_Dict = Database.sendMessage(remoteID, "DVRT_PUBLISH_CAPABILITIES", dvrtDict)
        
        
def onAttachmentDisconnected(source, target):
    global plibUsed

    localComponent = source["component"]
    remoteComponent = target["component"]
    remoteID = remoteComponent.getID()
    connectID = source["id"]
    targetID = target["id"]
    dummyDict = {}

    if connectID == "UART":

        dummyDict = Database.sendMessage(remoteID, "UART_NON_BLOCKING_MODE", {"isReadOnly":False})

        dummyDict = Database.sendMessage(remoteID, "UART_NON_BLOCKING_FIFO_MODE", {"isReadOnly":False})

        dummyDict = Database.sendMessage(remoteID, "UART_NON_BLOCKING_DMA_TX_RX_MODE", {"isReadOnly":False})

        plibUsed = localComponent.getSymbolByID("USART_PLIB_CONNECTED")
        plibUsed.clearValue()

    elif ((connectID == "TMR") or (connectID == "core_timer")):
        plibUsed = localComponent.getSymbolByID("TMR_PLIB_COMPONENT_CONNECTED")
        plibUsed.clearValue()
        
        
def destroyComponent(dvrtComponent):
    Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":False})
    if dvrtComponent.getSymbolByID("DVRT_USE_SYSTICK").getValue() == True:
        # Let the core.systick know that DVRT is no longer using the systick module
        sysTickDict = {"ID":"None"}
        sysTickDict = Database.sendMessage("core", "DVRT_PUBLISH_CAPABILITIES", sysTickDict)

def usartplibnamecallback(symbol, event):
    global res
    global commconnected

    localComponent = symbol.getComponent()

    if (event["id"] == "USART_PLIB_CONNECTED"):
        commconnected = localComponent.getSymbolByID("USART_PLIB_CONNECTED")
        if commconnected.getValue() != "":
            res = re.findall('(\d+|[A-Za-z]+)', commconnected.getValue())[0]
            symbol.setValue(res)

def displayDVRTSuperloopComment(symbol, event):
    if (event["value"] == 1):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

def onUsingSystickChange(symbol, event):
    global dvrt_AchievableTickRateMsComment
    
    dvrtDict = {"ID":"dvrt"}
    localComponent = symbol.getComponent()
   
    if event["id"] == "DVRT_USE_SYSTICK":
        if event["value"] == True:
            localComponent.getSymbolByID("TMR_PLIB_COMPONENT_CONNECTED").setValue("core")
            localComponent.setDependencyEnabled("TMR", False)
            #Request PLIB to publish it's capabilities
            Database.sendMessage("core", "DVRT_PUBLISH_CAPABILITIES", dvrtDict)
        else:
            localComponent.getSymbolByID("TMR_PLIB_COMPONENT_CONNECTED").setValue("")
            localComponent.setDependencyEnabled("TMR", True)
            #Let sys_tick PLIB know that DVRT no longer uses sys_tick PLIB
            Database.sendMessage("core", "DVRT_PUBLISH_CAPABILITIES", {"ID":"None"})
            #dvrt_AchievableTickRateMsComment.setValue(False)
            dvrt_AchievableTickRateHz.setValue(0)
    elif event["id"] == "SYSTICK_BUSY":
        if event["value"] == False:
            localComponent.getSymbolByID("DVRT_USE_SYSTICK").setVisible(True)
        if event["value"] == True:
            if (localComponent.getSymbolByID("DVRT_USE_SYSTICK").getValue() == True):
                localComponent.getSymbolByID("DVRT_USE_SYSTICK").setVisible(True)
            elif (localComponent.getSymbolByID("DVRT_USE_SYSTICK").getValue() == False):
                localComponent.getSymbolByID("DVRT_USE_SYSTICK").setVisible(False)
                
def Dvrt_SysTickRateCallback(symbol, event):
    global dvrt_tmrPLIB

    dummyDict = {}
    sysTickRate = {"dvrt_tick_ms" : 0.0}                                                                                 

    if (event["id"] == "DVRT_TICK_RATE_MS"):
        if dvrt_tmrPLIB.getValue() != "" :
            sysTickRate["dvrt_tick_ms"] = float(symbol.getValue())
            dummyDict = Database.sendMessage(dvrt_tmrPLIB.getValue().lower(), "DVRT_TICK_RATE_CHANGED", sysTickRate)            
            
def Dvrt_AchievableTickRateMsCallback(symbol, event):

    if (event["id"] == "DVRT_ACHIEVABLE_TICK_RATE_HZ"):
        if event["value"] != 0:
            achievableRateMs =  100000.0 / event["value"]
        else:
            achievableRateMs = 0
        achievableRateMs = achievableRateMs * 1000.0
        symbol.setLabel("Achievable Tick Rate Resolution (ms):" + str(achievableRateMs) + "ms")

def instantiateComponent(dvrtComponent):

    global dvrtmoduleName
    global dvrtTimerDep
    global dvrt_useSystick
    global dvrt_tmrPLIB
    global dvrt_TickRateMs
    global dvrt_AchievableTickRateHz
    global dvrt_AchievableTickRateMsComment
    
    systickNode = ATDF.getNode('/avr-tools-device-file/modules/module@[name="SysTick"]')
    
    dvrtmoduleName = dvrtComponent.createStringSymbol("DVRT_MODULE", None)
    dvrtmoduleName.setVisible(False)
    dvrtmoduleName.setDefaultValue(dvrtComponent.getID().upper())

  #  res = Database.activateComponents(["HarmonyCore"])
  #  Enable "Generate Harmony Driver Common Files" option in MHC
  #  Database.sendMessage("HarmonyCore", "ENABLE_DRV_COMMON", {"isEnabled":True})
  #  Enable "Generate Harmony System Service Common Files" option in MHC
  #  Database.sendMessage("HarmonyCore", "ENABLE_SYS_COMMON", {"isEnabled":True})

    dvrt_uartPLIB = dvrtComponent.createStringSymbol("USART_PLIB_CONNECTED", None)
    dvrt_uartPLIB.setLabel("uart PLIB Used")
    dvrt_uartPLIB.setHelp(dvrt_mcc_helpkeyword)
    dvrt_uartPLIB.setReadOnly(True)
    dvrt_uartPLIB.setVisible(False)
    dvrt_uartPLIB.setDefaultValue("")

    dvrt_uartPLIBname = dvrtComponent.createStringSymbol("CONNECTED_PLIB_NAME", None)
    dvrt_uartPLIBname.setLabel("uart plib name")
    dvrt_uartPLIBname.setVisible(False)
    dvrt_uartPLIBname.setDefaultValue("")
    dvrt_uartPLIBname.setDependencies(usartplibnamecallback, ["USART_PLIB_CONNECTED"])

    dvrt_tmrPLIB = dvrtComponent.createStringSymbol("TMR_PLIB_COMPONENT_CONNECTED", None)           
    dvrt_tmrPLIB.setLabel("tmr PLIB Used")
    dvrt_tmrPLIB.setHelp(dvrt_mcc_helpkeyword)
    dvrt_tmrPLIB.setReadOnly(True)
    dvrt_tmrPLIB.setVisible(False)
    dvrt_tmrPLIB.setDefaultValue("")

    dvrt_useSystick = dvrtComponent.createBooleanSymbol("DVRT_USE_SYSTICK", None)           
    dvrt_useSystick.setLabel("Use Systick?")
    dvrt_useSystick.setHelp(dvrt_mcc_helpkeyword)
    dvrt_useSystick.setDefaultValue(False)
    dvrt_useSystick.setVisible(systickNode != None) 
    dvrt_useSystick.setDependencies(onUsingSystickChange, ["DVRT_USE_SYSTICK", "core.SYSTICK_BUSY"])
    
    dvrt_TickRateMs = dvrtComponent.createFloatSymbol("DVRT_TICK_RATE_MS", None)                            
    dvrt_TickRateMs.setLabel("Tick Rate (ms)")
    dvrt_TickRateMs.setHelp(dvrt_mcc_helpkeyword)
    dvrt_TickRateMs.setMax(5000)          #5 seconds
    dvrt_TickRateMs.setMin(0.1)           #0.1 msec
    dvrt_TickRateMs.setDefaultValue(1)
    dvrt_TickRateMs.setVisible(True)
    dvrt_TickRateMs.setDependencies(Dvrt_SysTickRateCallback, ["DVRT_TICK_RATE_MS"])
    
    dvrt_AchievableTickRateHz = dvrtComponent.createLongSymbol("DVRT_ACHIEVABLE_TICK_RATE_HZ", None)        
    dvrt_AchievableTickRateHz.setDefaultValue(1)
    dvrt_AchievableTickRateHz.setVisible(False)
    
    dvrt_AchievableTickRateMsComment = dvrtComponent.createCommentSymbol("DVRT_ACHIEVABLEE_TICK_RATE_COMMENT", None)                                    
    dvrt_AchievableTickRateMsComment.setLabel("Achievable Tick Rate Resolution (ms):" + str(dvrt_AchievableTickRateHz.getValue()) + "ms")
    dvrt_AchievableTickRateMsComment.setVisible(True)
    dvrt_AchievableTickRateMsComment.setDependencies(Dvrt_AchievableTickRateMsCallback, ["DVRT_ACHIEVABLE_TICK_RATE_HZ"])
    
    #DVRT Run Process
    dvrt_runProcess = dvrtComponent.createKeyValueSetSymbol("DVRT_CALLBACK_PROCESS", None)
    dvrt_runProcess.setLabel("Select DVRT process to be called from")
    dvrt_runProcess.addKey("Interrupt", "0", "Interrupt context")
    dvrt_runProcess.addKey("Polling", "1", "Polling context")
    dvrt_runProcess.setOutputMode("Key")
    dvrt_runProcess.setDisplayMode("Key")
    dvrt_runProcess.setDefaultValue(0)
    dvrt_runProcess.setVisible(True)

    dvrt_Instancetype = dvrtComponent.createStringSymbol("API Prefix Test", None)
    dvrt_Instancetype.setVisible(False)
    dvrt_Instancetype.setDefaultValue("DVRT")

    #Project Firmware Code
    dvrt_fmwr_code = dvrtComponent.createIntegerSymbol("PJT_FMWR_CODE", None)
    dvrt_fmwr_code.setLabel("Project Firmware Code")
    dvrt_fmwr_code.setHelp(dvrt_mcc_helpkeyword)
    dvrt_fmwr_code.setDefaultValue(261)

    #Dynamic Variables
    dvrt_dynamic_variable_count = dvrtComponent.createIntegerSymbol("DYNAMIC_VARIABLES_COUNT", None)
    dvrt_dynamic_variable_count.setLabel("Num Of Dynamic Variables")
    dvrt_dynamic_variable_count.setHelp(dvrt_mcc_helpkeyword)
    dvrt_dynamic_variable_count.setDefaultValue(8)
    dvrt_dynamic_variable_count.setMin(1)
    dvrt_dynamic_variable_count.setMax(32)

    #Communication Protocol
    dvrt_Instancetype = dvrtComponent.createStringSymbol("COMM_PROTOCOL", None)
    dvrt_Instancetype.setLabel("Communication Protocol")
    dvrt_Instancetype.setVisible(False)
    dvrt_Instancetype.setReadOnly(True)
    dvrt_Instancetype.setDefaultValue("UART")

    dvrt_runComment = dvrtComponent.createCommentSymbol("DVRT_SUPERLOOP_ENABLE_COMMENT", None)
    dvrt_runComment.setVisible(False)
    dvrt_runComment.setLabel("**** Call dvrt_process from main function ****")
    dvrt_runComment.setDependencies(displayDVRTSuperloopComment, ["DVRT_CALLBACK_PROCESS"])

    configName = Variables.get("__CONFIGURATION_NAME")

    #DVRT definitions header
    dvrtSystemDefFile = dvrtComponent.createFileSymbol("DVRT_FILE_SYS_DEF", None)
    dvrtSystemDefFile.setType("STRING")
    dvrtSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    dvrtSystemDefFile.setSourcePath("templates/system/system_definitions.h.ftl")
    dvrtSystemDefFile.setMarkup(True)

    #DVRT Source File
    dvrtMainSourceFile = dvrtComponent.createFileSymbol("DVRT_FILE_SRC_MAIN", None)
    dvrtMainSourceFile.setSourcePath("templates/dvrt.c.ftl")
    dvrtMainSourceFile.setOutputName(dvrtComponent.getID().lower()+".c")
    dvrtMainSourceFile.setDestPath("dvrt/")
    dvrtMainSourceFile.setProjectPath("config/" + configName + "/dvrt/")
    dvrtMainSourceFile.setType("SOURCE")
    dvrtMainSourceFile.setMarkup(True)

    #DVRT Header File
    dvrtInstHeaderFile = dvrtComponent.createFileSymbol("DVRT_FILE_MAIN_HEADER", None)
    dvrtInstHeaderFile.setSourcePath("templates/dvrt.h.ftl")
    dvrtInstHeaderFile.setOutputName(dvrtComponent.getID().lower()+".h")
    dvrtInstHeaderFile.setDestPath("dvrt/")
    dvrtInstHeaderFile.setProjectPath("config/" + configName + "/dvrt/")
    dvrtInstHeaderFile.setType("HEADER")
    dvrtInstHeaderFile.setMarkup(True)

    #DVRT Local Header File
    dvrtInstLocalHeaderFile = dvrtComponent.createFileSymbol("DVRT_FILE_MAIN_LOCAL_HEADER", None)
    dvrtInstLocalHeaderFile.setSourcePath("templates/dvrt_local.h.ftl")
    dvrtInstLocalHeaderFile.setOutputName(dvrtComponent.getID().lower()+"_local.h")
    dvrtInstLocalHeaderFile.setDestPath("dvrt/")
    dvrtInstLocalHeaderFile.setProjectPath("config/" + configName + "/dvrt/")
    dvrtInstLocalHeaderFile.setType("HEADER")
    dvrtInstLocalHeaderFile.setMarkup(True)
    
    #DVRT Initialize data
    dvrtSystemInitFile = dvrtComponent.createFileSymbol("DVRT_FILE_SYS_INIT", None)
    dvrtSystemInitFile.setType("STRING")
    dvrtSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_DRIVERS")
    dvrtSystemInitFile.setSourcePath("templates/system/system_initialize.c.ftl")
    dvrtSystemInitFile.setMarkup(True)

    #DVRT Initialize
    dvrtSystemInitDataFile = dvrtComponent.createFileSymbol("DVRT_INIT_DATA", None)
    dvrtSystemInitDataFile.setType("STRING")
    dvrtSystemInitDataFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYSTEM_INITIALIZATION")
    dvrtSystemInitDataFile.setSourcePath("templates/system/system_initialize_data.c.ftl")
    dvrtSystemInitDataFile.setMarkup(True)



