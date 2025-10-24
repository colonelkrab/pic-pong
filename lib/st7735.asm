#include <p18f452.inc>
#define DCX_PORT PORTD
#define DCX RD4
global @st7735_spi_send_wreg_as_cmd
global @st7735_spi_send_wreg_as_data

.ST7735_SPI code
	@st7735_spi_recieve_complete:
		btfss 	PIR1, SSPIF
		; btfss SSPSTAT,BF			; slightly slower alternative
		goto 	@st7735_spi_recieve_complete
		nop
	return

	@st7735_spi_send_wreg:
		bcf 	PORTA, SS
		movwf 	SSPBUF
		call 	@st7735_spi_recieve_complete
		bsf 	PORTA, SS
	return

	@st7735_spi_send_wreg_as_cmd:
		bcf 	DCX_PORT, DCX 
		call 	@st7735_spi_send_wreg
	return

	@st7735_spi_send_wreg_as_data:
		bsf 	DCX_PORT, DCX 
		call 	@st7735_spi_send_wreg
	return
end
