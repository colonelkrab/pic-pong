
extern @WINDOW_XS, @WINDOW_XE, @WINDOW_YS, @WINDOW_YE
extern @WINDOW_NCOLUMNS, @WINDOW_NROWS
extern @COLORU, @COLORL
extern @st7735_select_window
extern @st7735_fill_window

__st7735_fill_screen MACRO color_16
		movlw 	color_16 >> 8
		movwf 	@COLORU
		movlw 	color_16
		movwf 	@COLORL
		movlw 	SCREEN_WIDTH
		movwf 	@WINDOW_NCOLUMNS
		movlw 	SCREEN_HEIGHT
		movwf 	@WINDOW_NROWS
		__st7735_set_window XS_MIN,XE_MAX,YS_MIN,YE_MAX
		call 	@st7735_fill_window
endm

__st7735_fill_rect MACRO x0,y0,w,h,color_16
		movlw 	color_16 >> 8
		movwf 	@COLORU
		movlw 	color_16
		movwf 	@COLORL
		movlw 	w
		movwf 	@WINDOW_NCOLUMNS
		movlw 	h
		movwf 	@WINDOW_NROWS
		__st7735_set_window x0,(x0+w-1),y0,(y0+h-1)
		call	@st7735_fill_window
endm
