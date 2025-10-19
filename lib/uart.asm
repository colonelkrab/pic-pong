#include <p18f452.inc>
global UART_TRANSMIT_TABLE_BYTE_COUNT, _uart_transmit_table, _uart_transmit_complete

.UART_DATA udata
UART_TRANSMIT_TABLE_BYTE_COUNT res 1

.UART code 
_uart_transmit_complete:
btfss PIR1,TXIF
goto _uart_transmit_complete
return

; tblptr need to be set to the start of the required table
; UART_TRANSMIT_TABLE_BYTE_COUNT is the length of bytes of the table
_uart_transmit_table:
tblrd *+
call _uart_transmit_complete
movff TABLAT, TXREG
decfsz UART_TRANSMIT_TABLE_BYTE_COUNT,f
goto _uart_transmit_table
return

end

