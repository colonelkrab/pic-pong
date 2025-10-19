#include <p18f452.inc>
#include <include/uart.inc>
#include <include/spi.inc>
#define F_CPU 16000000
config OSC=HS
config WDT=OFF

.RESET code 0x00
goto _main

.MAIN code
_main:
goto $
end


