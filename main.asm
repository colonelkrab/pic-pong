#include <p18f452.inc>
#define F_CPU 24000000
#include <include/uart.inc>
#include <include/st7735.inc>

config OSC=HS
config WDT=OFF
config LVP=ON

.RESET code 0x00
goto _main

.MAIN code
_main:
__st7735_spi_init
__st7735_init_sequence
goto $
end
