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

extern _delay
extern _delay_125ms
extern @WINDOW_XS, @WINDOW_XE, @WINDOW_YS, @WINDOW_YE
extern @WINDOW_NCOLUMNS, @WINDOW_NROWS
extern @COLORU, @COLORL
extern @st7735_select_window
extern @st7735_fill_window

.GAME_DATA udata
	@P1_X res 1
	@P2_X res 1
	@BALL_X res 1
	@BALL_Y res 1
	@BALL_DX res 1
	@BALL_DY res 1
	collision_width res 1


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
		movlw 	PLAYER_WIDTH + BALL_SIZE + .1
		movwf 	collision_width
		; goto $
	_game_start:	
		movlw 	.50
		movwf 	@P1_X
		movlw	.50
		movwf 	@P2_X
		movlw 	.55
		movwf 	@BALL_X
		movwf 	@BALL_Y
		movlw 	.1
		movwf 	@BALL_DX
		movlw	.1
		movwf 	@BALL_DY
		movlw 	YE_MAX
		movwf 	@WINDOW_YE
		call 	@draw_frame
	_game_loop:
		call 	@clear_frame
		call 	@set_ball_pos
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
		movlw	YE_MAX - BALL_SIZE
		cpfseq	@BALL_Y
		bra	$+4
		bra	_game_start		; p1 wins
		movlw	YS_MIN
		cpfseq 	@BALL_Y
		bra	$+4
		bra	_game_start		; p2 wins
		call 	@draw_frame
		call 	_delay
		goto 	_game_loop
;
;
	; Logic for ball bounce
	@set_ball_pos:
		;
		; X
		;
		movlw 	XE_MAX - BALL_SIZE
		cpfseq 	@BALL_X
		bra 	$+4 			; branch to next condition
		bra 	reverse_ball_x
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
		bra	reverse_ball_y
		movlw 	P1_Y + BALL_SIZE
		cpfsgt 	@BALL_Y
		bra 	check_p1_collision
		; bra	reverse_ball_y
		bra 	set_ball_pos_y
	check_p2_collision:
		; movf 	@P2_X, w
		movlw	BALL_SIZE + .1
		subwf	@P2_X, w
		subwf	@BALL_X, w		; w = ballx - p2x
		cpfsgt	collision_width		; skip if 20 > w
		bra	set_ball_pos_y		; no collision
		bra 	reverse_ball_y
	check_p1_collision:
		movlw	BALL_SIZE + .1
		subwf	@P1_X, w
		subwf	@BALL_X, w		; w = ballx - p2x
		cpfsgt	collision_width		; skip if 20 > w
		bra	set_ball_pos_y		; no collision
		bra 	reverse_ball_y
	reverse_ball_y:
		negf 	@BALL_DY
	set_ball_pos_y:
		movf 	@BALL_DY, w
		addwf 	@BALL_Y, f
	return

	@draw_players:
		;
		; PLAYER 1
		movf 	@P1_X, w
		movwf 	@WINDOW_XS
		addlw 	PLAYER_WIDTH - .1
		movwf 	@WINDOW_XE
		movlw 	P1_Y
		movwf 	@WINDOW_YS
		call 	@draw_player_common
		;
		; PLAYER 2
		movf 	@P2_X, w
		movwf 	@WINDOW_XS
		addlw 	PLAYER_WIDTH - .1
		movwf 	@WINDOW_XE
		movlw	P2_Y
		movwf 	@WINDOW_YS
		call 	@draw_player_common
	return

	@draw_player_common:
		call 	@st7735_select_window
		movlw 	PLAYER_WIDTH
		movwf 	@WINDOW_NCOLUMNS
		movlw 	PLAYER_HEIGHT
		movwf 	@WINDOW_NROWS
		call 	@st7735_fill_window
	return

	@draw_ball:
		movf 	@BALL_X, w
		movwf 	@WINDOW_XS
		addlw 	BALL_SIZE - .1
		movwf 	@WINDOW_XE
		movf 	@BALL_Y, w
		movwf 	@WINDOW_YS
		call 	@st7735_select_window
		movlw 	BALL_SIZE
		movwf 	@WINDOW_NCOLUMNS
		movwf 	@WINDOW_NROWS
		call 	@st7735_fill_window
	return

	@draw_frame:
		setf 	@COLORU
		setf 	@COLORL
		call 	@draw_ball
		call 	@draw_players
	return

	@clear_frame:
		clrf 	@COLORU
		clrf 	@COLORL
		call 	@draw_ball
		call 	@draw_players
	return
;
;
end
