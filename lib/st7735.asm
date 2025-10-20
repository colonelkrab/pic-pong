#include <p18f452.inc>
#define DCX_PORT PORTD
#define DCX RD4
global _st7735_spi_send_wreg_as_cmd, _st7735_spi_send_wreg_as_data

.ST7735_SPI code
_st7735_spi_recieve_complete:
btfss SSPSTAT,BF
goto _st7735_spi_recieve_complete
return

; active low slave select
_st7735_spi_send_wreg:
bcf PORTA, SS
movwf SSPBUF
call _st7735_spi_recieve_complete
bsf PORTA, SS
return

_st7735_spi_send_wreg_as_cmd:
bcf DCX_PORT, DCX 
call _st7735_spi_send_wreg
return

_st7735_spi_send_wreg_as_data:
bsf DCX_PORT, DCX 
call _st7735_spi_send_wreg
return
end
