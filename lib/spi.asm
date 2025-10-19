#include <p18f452.inc>
global _spi_recieve_complete

.SPI code
_spi_recieve_complete:
btfss SSPSTAT,BF
goto _spi_recieve_complete
return

end
