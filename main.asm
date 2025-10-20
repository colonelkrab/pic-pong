#include <p18f452.inc>
#define F_CPU 24000000
#include <include/uart.inc>
#include <include/st7735.inc>
#define RED color_16(0,0,255)
config OSC=HS
config WDT=OFF
config LVP=ON

udata 
		x res 1
		y res 1

.RESET code 0x00
		goto _main

.MAIN code
	_main:
		__st7735_spi_init
		__st7735_init_sequence
		__st7735_set_window d'1',d'130',d'1',d'160'
		__st7735_send_cmd ST7735_RAMWR
		movlw d'160'
		movwf y
	i:
		movlw d'130'
		movwf x
	j:
		__st7735_send_data RED >> 8
		__st7735_send_data RED
		decfsz x,f
		goto j 

		decfsz y,f
		goto i

	goto $
end
