#include <p18f452.inc>
#define F_CPU 24000000
 #include <include/uart.inc>
 #include <include/st7735.inc>
#include <include/st7735_graphics.inc>
config OSC=HS
config WDT=OFF
config LVP=OFF

.GAME_DATA udata
P1_POS res 1
P2_POS res 1

extern _st7735_fill_selected_window_with_color_reg, _st7735_select_window_using_window_regs, _COLOR_UPPER, _COLOR_LOWER, _SELECTED_WINDOW_ROWS

extern _SELECTED_WINDOW_COLUMNS, WINDOW_XS, WINDOW_XE, WINDOW_YS, WINDOW_YE, _delay_125ms

.RESET code 0x00
		goto _main
			
.MAIN code
	_main:
		clrf TRISD
		; setf PORTD
		bsf PORTD, RD1
		__st7735_spi_init
		__st7735_init_sequence
		__st7735_fill_screen COLOR_16(0,0,0)
		; __st7735_fill_rect .1,.20,.20,.1,COLOR_16(255,255,255)
		movlw .1
		movwf P1_POS
		movlw .100
		movwf P2_POS
		call _draw_frame
	goto $
	_draw_player_1:
		movf P1_POS, w
		movwf WINDOW_XS
		addlw (.20 -.1)
		movwf WINDOW_XE
		movlw .20
		movwf WINDOW_YS
		movwf WINDOW_YE
		movwf _SELECTED_WINDOW_COLUMNS
		movlw .1
		movwf _SELECTED_WINDOW_ROWS
		call _st7735_select_window_using_window_regs
		call _st7735_fill_selected_window_with_color_reg
	return
	_draw_player_2:
		movf P2_POS, w
		movwf WINDOW_XS
		addlw (.20 -.1)
		movwf WINDOW_XE
		movlw .140
		movwf WINDOW_YS
		movwf WINDOW_YE
		movwf _SELECTED_WINDOW_COLUMNS
		movlw .1
		movwf _SELECTED_WINDOW_ROWS
		call _st7735_select_window_using_window_regs
		call _st7735_fill_selected_window_with_color_reg
	return
	_draw_frame:
		setf _COLOR_UPPER
		setf _COLOR_LOWER
		call _draw_player_1	
		call _draw_player_2
	return

	_clear_frame:
		clrf _COLOR_UPPER
		clrf _COLOR_LOWER
		call _draw_player_1	
		call _draw_player_2
	return

		
end
