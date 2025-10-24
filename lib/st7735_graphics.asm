#include <p18f452.inc>
#include <include/st7735.inc>

global @WINDOW_XS, @WINDOW_XE, @WINDOW_YS, @WINDOW_YE
global @WINDOW_NCOLUMNS, @WINDOW_NROWS
global @COLORU, @COLORL
global @st7735_select_window
global @st7735_fill_window

.ST7735_GRAPHICS_DATA udata
	@COLORU res 1
	@COLORL res 1
	@WINDOW_XS res 1
	@WINDOW_XE res 1
	@WINDOW_YS res 1
	@WINDOW_YE res 1
	@WINDOW_NCOLUMNS res 1
	@WINDOW_NROWS res 1
	y res 1
	x res 1

.ST7735_GRAPHICS code
	; selects window based on values of _XS _XE _YS _YE registers
	@st7735_select_window:
		__st7735_send_cmd ST7735_CASET
		__st7735_send_data 0x00
		movf 	@WINDOW_XS, w
		call 	@st7735_spi_send_wreg_as_data
		__st7735_send_data 0x00
		movf 	@WINDOW_XE, w
		call 	@st7735_spi_send_wreg_as_data
		__st7735_send_cmd ST7735_RASET
		__st7735_send_data 0x00
		movf 	@WINDOW_YS, w
		call 	@st7735_spi_send_wreg_as_data
		__st7735_send_data 0x00
		movf 	@WINDOW_YE, w
		call	@st7735_spi_send_wreg_as_data
	return

	; fills _NROWS * _NCOLUMNS pixels in the selected window
	@st7735_fill_window:
		__st7735_send_cmd ST7735_RAMWR
		movff 	@WINDOW_NROWS, @y
	i:
		movff 	@WINDOW_NCOLUMNS, @x
	j:
		movf 	@COLORU, w	
		call 	@st7735_spi_send_wreg_as_data
		movf 	@COLORL, w	
		call 	@st7735_spi_send_wreg_as_data
		decfsz 	x, f
		bra 	j 

		decfsz 	y, f
		bra 	i
	return
end
