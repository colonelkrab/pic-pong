#include <p18f452.inc>
#define F_CPU 24000000
 #include <include/uart.inc>
 #include <include/st7735.inc>
#include <include/st7735_graphics.inc>
#define BALL_SIZE .3
#define P1_Y .10
#define P2_Y .150
#define PLAYER_WIDTH .20
#define PLAYER_HEIGHT .2
config OSC	= HS
config WDT	= OFF
config LVP	= OFF

.GAME_DATA udata
	@P1_X res 	1
	@P2_X res 	1
	@BALL_X res 	1
	@BALL_Y res 	1
	@BALL_DX res 	1
	@BALL_DY res 	1

extern _st7735_fill_selected_window_with_color_reg, _st7735_select_window_using_window_regs, _COLOR_UPPER, _COLOR_LOWER, _SELECTED_WINDOW_ROWS

extern _SELECTED_WINDOW_COLUMNS, WINDOW_XS, WINDOW_XE, WINDOW_YS, WINDOW_YE, _delay_125ms, _delay

.RESET code 0x00
		goto _main
			
.MAIN code
	_main:
		clrf	TRISD
		; setf PORTD
		bsf 	PORTD, RD1
		bsf 	TRISD, RD3
		bsf 	TRISD, RD2

		__st7735_spi_init
		__st7735_init_sequence
		__st7735_fill_screen COLOR_16(0,0,0)

		__st7735_fill_rect XS_MIN,YS_MIN,.1,SCREEN_HEIGHT,COLOR_16(255,255,255)
		__st7735_fill_rect XE_MAX,YS_MIN,.1,SCREEN_HEIGHT,COLOR_16(255,255,255)
	game_over:
		movlw 	.50
		movwf 	@P1_X
		movwf 	@P2_X
		movlw 	.1
		movwf 	@BALL_DX
		movwf 	@BALL_DY
		movlw 	YE_MAX
		movwf 	WINDOW_YE
		movlw 	.50
		movwf 	@BALL_X
		movwf 	@BALL_Y
		call 	_draw_frame
	game_loop:
		call 	_clear_frame
		call 	_set_ball_pos
		; logic for moving player 1
		movlw 	.1
		cpfsgt 	@P1_X
		bra 	skip_dec
		btfss 	LATD, RD3
		decf 	@P1_X,f
	skip_dec:
		movlw 	.110
		cpfslt 	@P1_X
		bra 	skip_inc
		btfss 	LATD, RD2
		incf 	@P1_X,f
	skip_inc:
		call 	_draw_frame
		call _delay
		goto 	game_loop

			
	goto $
	; Logic for ball bounce
	_set_ball_pos:
		;
		; X
		;
		movlw 	XE_MAX - BALL_SIZE
		cpfseq 	@BALL_X
		bra 	$+4 			; branch to next condition
		bra reverse_ball_x
		movlw 	XS_MIN + .1
		cpfseq 	@BALL_X
		bra 	set_ball_pos_x
	reverse_ball_x:
		negf 	@BALL_DX
	set_ball_pos_x: 	
		movf 	@BALL_DX, w
		addwf 	@BALL_X, f
		;
		; Y
		;
		movlw 	P2_Y - BALL_SIZE
		cpfslt 	@BALL_Y
		; bra 	check_p2_collision
		bra 	reverse_ball_y
		movlw 	P1_Y + BALL_SIZE
		cpfsgt 	@BALL_Y
		bra 	reverse_ball_y
		; bra check_p1_collision
		bra 	set_ball_pos_y
	; check_p2_collision:
	; p2_left:
	; 	movf 	@P2_X, w
	; 	cpfslt 	@BALL_X;
	; 	bra	
	; 	bra 	game_over
	; 	movf P2_X,w
	; 	addlw PLAYER_WIDTH -.1
	; 	cpfslt B_X
	; 	bra game_over
	; 	bra reverse_ball_y
	; check_p1_collision:
	; 	movf P1_X,w
	; 	cpfsgt B_X
	; 	bra game_over
	; 	movf P1_X,w
	; 	addlw PLAYER_WIDTH -.1
	; 	cpfslt B_X
	; 	bra game_over
	; 	bra reverse_ball_y
	reverse_ball_y:
		negf 	@BALL_DY
	set_ball_pos_y:
		movf 	@BALL_DY, w
		addwf 	@BALL_Y, f
	return

	; _draw_players:
	; 	;
	; 	; PLAYER 1
	; 	movf P1_X, w
	; 	movwf WINDOW_XS
	; 	addlw (PLAYER_WIDTH - .1)
	; 	movwf WINDOW_XE
	; 	movlw P1_Y
	; 	movwf WINDOW_YS
	; 	call _draw_player_common
	; 	;
	; 	; PLAYER 2
	; 	movf P2_X, w
	; 	movwf WINDOW_XS
	; 	addlw (PLAYER_WIDTH - .1)
	; 	movwf WINDOW_XE
	; 	movlw P2_Y
	; 	movwf WINDOW_YS
	; 	call _draw_player_common
	; return
	;
	; _draw_player_common:
	; 	movlw PLAYER_WIDTH; width
	; 	movwf _SELECTED_WINDOW_COLUMNS
	; 	movlw PLAYER_HEIGHT; height
	; 	movwf _SELECTED_WINDOW_ROWS
	; 	call _st7735_select_window_using_window_regs
	; 	call _st7735_fill_selected_window_with_color_reg
	; return

	_draw_ball:
		movf 	@BALL_X, w
		movwf 	WINDOW_XS
		addlw 	BALL_SIZE-.1
		movwf 	WINDOW_XE
		movf 	@BALL_Y, w
		movwf 	WINDOW_YS
		movlw 	BALL_SIZE
		movwf 	_SELECTED_WINDOW_ROWS
		movwf 	_SELECTED_WINDOW_COLUMNS
		; movlw .2
		call 	_st7735_select_window_using_window_regs
		call 	_st7735_fill_selected_window_with_color_reg
	return

	_draw_frame:
		setf 	_COLOR_UPPER
		setf 	_COLOR_LOWER
		call 	_draw_ball
		; call _draw_players
	return

	_clear_frame:
		clrf 	_COLOR_UPPER
		clrf 	_COLOR_LOWER
		call 	_draw_ball
		; call _draw_players
	return

		
end
