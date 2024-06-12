
const DVRT_USART_PLIB_INTERFACE dvrt_USARTPlibAPI = {
	.readCallbackRegister = (DVRT_USART_PLIB_READ_CALLBACK_REG)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_ReadCallbackRegister,

	.read_t = (DVRT_USART_PLIB_READ)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_Read,
	
	.readCountGet = (DVRT_USART_PLIB_READ_COUNT_GET)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_ReadCountGet,
	
	.write_t = (DVRT_USART_PLIB_WRITE)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_Write,
	
	.errorGet = (DVRT_USART_PLIB_ERROR_GET)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_ErrorGet,
	
	.readThresholdSet = (DVRT_USART_PLIB_READ_THRESHOLD_SET)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_ReadThresholdSet,
	
	.readNotificationEnable = (DVRT_USART_PLIB_READ_NOTIFICATION_ENABLE)${.vars["${USART_PLIB_CONNECTED?lower_case}"].USART_PLIB_API_PREFIX}_ReadNotificationEnable            

};

const DVRT_TMR_PLIB_INTERFACE dvrt_TMRPlibAPI = {
    .timerStart = (DVRT_TMR_PLIB_START)${.vars["${TMR_PLIB_COMPONENT_CONNECTED?lower_case}"].TIMER_START_API_NAME},

    .timerStop = (DVRT_TMR_PLIB_STOP)${.vars["${TMR_PLIB_COMPONENT_CONNECTED?lower_case}"].TIMER_STOP_API_NAME},
	
	.timerPeriodSet = (DVRT_TMR_PLIB_PERIOD_SET)NULL,

    .timerCallbackRegister = (DVRT_TMR_PLIB_CALLBACK_REGISTER)${.vars["${TMR_PLIB_COMPONENT_CONNECTED?lower_case}"].CALLBACK_API_NAME}
};

// </editor-fold>