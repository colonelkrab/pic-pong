#include <p18f452.inc>
#include <include/st7735.inc>

global _st7735_fill_selected_window_with_color_reg, _COLOR_UPPER, _COLOR_LOWER, _SELECTED_WINDOW_ROWS, 
global _SELECTED_WINDOW_COLUMNS, WINDOW_XS, WINDOW_XE, WINDOW_YS, WINDOW_YE, _st7735_select_window_using_window_regs, 

.ST7735_GRAPHICS_DATA udata
_COLOR_UPPER res 1
_COLOR_LOWER res 1
WINDOW_XS res 1
WINDOW_XE res 1
WINDOW_YS res 1
WINDOW_YE res 1
_SELECTED_WINDOW_ROWS res 1
_SELECTED_WINDOW_COLUMNS res 1
y res 1
x res 1

.ST7735_GRAPHICS code
	;_XS _XE _YS _YE should be set before calling this
	_st7735_select_window_using_window_regs:
		__st7735_send_cmd ST7735_CASET
		__st7735_send_data 0x00
		movf WINDOW_XS, w
		call _st7735_spi_send_wreg_as_data
		__st7735_send_data 0x00
		movf WINDOW_XE, w
		call _st7735_spi_send_wreg_as_data
		__st7735_send_cmd ST7735_RASET
		__st7735_send_data 0x00
		movf WINDOW_YS, w
		call _st7735_spi_send_wreg_as_data
		__st7735_send_data 0x00
		movf WINDOW_YE, w
		call _st7735_spi_send_wreg_as_data
	return

	_st7735_fill_selected_window_with_color_reg:
		__st7735_send_cmd ST7735_RAMWR
		movff _SELECTED_WINDOW_ROWS, y
	i:
		movff _SELECTED_WINDOW_COLUMNS, x
	j:
		movf _COLOR_UPPER, w	
		call _st7735_spi_send_wreg_as_data
		movf _COLOR_LOWER, w	
		call _st7735_spi_send_wreg_as_data
		decfsz x,f
		goto j 

		decfsz y,f
		goto i
	return
end
