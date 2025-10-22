;extern _st7735_fill_selected_window_with_color_reg, _COLOR_UPPER, _COLOR_LOWER, _SELECTED_WINDOW_ROWS, _SELECTED_WINDOW_COLUMNS

__st7735_fill_screen MACRO color_16
		movlw color_16 >> 8
		movwf _COLOR_UPPER
		movlw color_16
		movwf _COLOR_LOWER
		movlw XE_MAX
		movwf _SELECTED_WINDOW_COLUMNS
		movlw YE_MAX
		movwf _SELECTED_WINDOW_ROWS
		__st7735_set_window XS_MIN,XE_MAX,YS_MIN,YE_MAX
		call _st7735_fill_selected_window_with_color_reg
endm

__st7735_fill_rect MACRO x0,y0,w,h,color_16
		movlw color_16 >> 8
		movwf _COLOR_UPPER
		movlw color_16
		movwf _COLOR_LOWER
		movlw w
		movwf _SELECTED_WINDOW_COLUMNS
		movlw h
		movwf _SELECTED_WINDOW_ROWS
		__st7735_set_window x0,(x0+w-1),y0,(y0+h-1)
		call _st7735_fill_selected_window_with_color_reg
endm
