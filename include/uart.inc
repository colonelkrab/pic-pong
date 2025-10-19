extern UART_TRANSMIT_TABLE_BYTE_COUNT, _uart_transmit_table, _uart_transmit_complete

__init_uart_tx macro baud
local x = (F_CPU/baud/16) - 1
bcf TRISC, TX
movlw x;
movwf SPBRG
bcf TXSTA, SYNC; async mode
bsf TXSTA, BRGH; high speed mode
bsf RCSTA, SPEN; enable 
bsf TXSTA, TXEN; enable tx
endm

__print_string macro string, unique_id
local n = unique_id
str#v(n): data string
len#v(n) equ $-str#v(n)
movlw upper str#v(n)
movwf TBLPTRU
movlw high str#v(n)
movwf TBLPTRH
movlw low str#v(n)
movwf TBLPTRL

movlw len#v(n)
movwf UART_TRANSMIT_TABLE_BYTE_COUNT
call _uart_transmit_table
endm

__uart_send_byte macro byte
movlw byte
call _uart_transmit_complete
movwf TXREG
endm
