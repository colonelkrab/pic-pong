#include <p18f452.inc>
#include <include/uart.inc>
#include <include/st7735.inc>
#include <include/st7735_graphics.inc>
#define F_CPU 24000000
#define BALL_SIZE .3
#define P1_Y .10
#define P2_Y .150
#define PLAYER_WIDTH .20
#define PLAYER_HEIGHT .2

#define TRIS_PLAYERS TRISD
#define LAT_PLAYERS LATD
#define PIN_P1_DECR RD0
#define PIN_P1_INCR RD2
#define PIN_P2_DECR RD5
#define PIN_P2_INCR RD7
#define TRIS_LED TRISD
#define PORT_LED PORTD
#define PIN_LED RD1

config OSC = HS
config WDT = OFF
config LVP = OFF

extern _delay
extern _delay_125ms
extern @WINDOW_XS, @WINDOW_XE, @WINDOW_YS, @WINDOW_YE
extern @WINDOW_NCOLUMNS, @WINDOW_NROWS
extern @COLORU, @COLORL
extern @st7735_select_window
extern @st7735_fill_window

.GAME_DATA udata
        @P1_X res 1			; regsiters with x values of p1 and p2
        @P2_X res 1
        @BALL_X res 1			; registers which hold BALL x,y coordinates
        @BALL_Y res 1
        @BALL_DX res 1			; registers which hold direction of BALL
        @BALL_DY res 1
	COLLISION_WIDTH res 1		; this is a constant required during comparision operations
					; it is initialized at the start of code

.RESET code 0x00
        goto 	_main

.MAIN code
	_main:
        	bcf	TRIS_LED, PIN_LED
        	bsf 	PORT_LED, PIN_LED	
		
		movlw	(1<<PIN_P1_DECR) | (1<<PIN_P1_INCR) | (1<<PIN_P2_DECR) | (1<<PIN_P2_INCR)
		movwf	TRIS_PLAYERS
        	__st7735_spi_init
        	__st7735_init_sequence
        	__st7735_fill_screen COLOR_16(0, 0, 0)
        	__st7735_fill_rect XS_MIN, YS_MIN, .1, SCREEN_HEIGHT, COLOR_16(255, 255, 255)
        	__st7735_fill_rect XE_MAX, YS_MIN, .1, SCREEN_HEIGHT, COLOR_16(255, 255, 255)

        	movlw 	PLAYER_WIDTH + BALL_SIZE + .1
        	movwf 	COLLISION_WIDTH

	_game_start:

	; Initialize game variables
        	movlw 	.50
        	movwf 	@P1_X
        	movlw	.100
        	movwf 	@P2_X
        	movlw 	.55
        	movwf 	@BALL_X
        	movwf 	@BALL_Y
        	movlw 	.1
        	movwf 	@BALL_DX
        	movlw 	.1
        	movwf 	@BALL_DY
        	movlw 	YE_MAX
        	movwf 	@WINDOW_YE 			; this reg won't be written again
        	call 	@draw_frame

	_game_loop:
        	call 	@clear_frame
		call	@set_player_pos
        	call 	@set_ball_pos
		
		; check if game over
        	movlw 	YE_MAX - BALL_SIZE
        	cpfseq 	@BALL_Y
        	bra 	$+4
        	bra 	_game_start			; P1 wins
        	movlw 	YS_MIN
        	cpfseq 	@BALL_Y
        	bra 	$+4
        	bra 	_game_start			; P2 wins

		; if game not over keep looping	
        	call 	@draw_frame
        	call 	_delay
        	goto 	_game_loop

	@set_player_pos:

	; logic for moving player 1
	if_decr_p1:
        	movlw 	XS_MIN
        	cpfsgt 	@P1_X
        	bra 	if_incr_p1
        	btfss 	LAT_PLAYERS, PIN_P1_DECR
        	decf 	@P1_X, f
	if_incr_p1:
        	movlw 	XE_MAX - PLAYER_WIDTH
        	cpfslt 	@P1_X
        	bra 	if_dec_p2
        	btfss 	LAT_PLAYERS, PIN_P1_INCR
        	incf 	@P1_X, f

	; logic for moving player 2
	if_dec_p2:
		movlw 	XS_MIN
        	cpfsgt 	@P2_X
        	bra 	if_incr_p2
        	btfss 	LAT_PLAYERS, PIN_P2_DECR
        	decf 	@P2_X, f
	if_incr_p2:
        	movlw 	XE_MAX - PLAYER_WIDTH
        	cpfslt 	@P2_X
		return
        	btfss 	LAT_PLAYERS, PIN_P2_INCR
        	incf 	@P2_X, f
	return

	; Logic for ball bounce
	@set_ball_pos:

	; Sets the X position of the ball
        	movlw 	XE_MAX - BALL_SIZE
        	cpfseq 	@BALL_X
        	bra 	$+4				; branch to next condition
        	bra 	reverse_ball_x
        	movlw 	XS_MIN + .1
        	cpfseq 	@BALL_X
        	bra 	set_ball_pos_x
	reverse_ball_x:
        	negf 	@BALL_DX
	set_ball_pos_x:
        	movf 	@BALL_DX, w
        	addwf 	@BALL_X, f

	; Sets the Y position of the ball
        	movlw 	P2_Y - BALL_SIZE
        	cpfseq 	@BALL_Y
        	bra 	$+4
		; bra 	check_p2_collision
        	bra 	reverse_ball_y
        	movlw 	P1_Y + PLAYER_HEIGHT
        	cpfseq 	@BALL_Y
        	bra 	set_ball_pos_y
		; bra	reverse_ball_y
        	bra 	check_p1_collision
	check_p2_collision:
        	movlw 	BALL_SIZE + .1
        	subwf 	@P2_X, w
        	subwf 	@BALL_X, w 			; w = ballx - p2x
        	cpfsgt 	COLLISION_WIDTH 		; skip if 20 > w
        	bra 	set_ball_pos_y 			; no collision
        	bra 	reverse_ball_y
	check_p1_collision:
        	movlw 	BALL_SIZE + .1
        	subwf 	@P1_X, w
        	subwf 	@BALL_X, w			; w = ballx - p2x
        	cpfsgt 	COLLISION_WIDTH			; skip if 20 > w
        	bra 	set_ball_pos_y			; no collision
        	bra 	reverse_ball_y
	reverse_ball_y:
        	negf 	@BALL_DY
	set_ball_pos_y:
        	movf 	@BALL_DY, w
        	addwf 	@BALL_Y, f
        return

	@draw_players:

	; Draw player 1 
        	movf 	@P1_X, w
        	movwf 	@WINDOW_XS
        	addlw 	PLAYER_WIDTH - .1
        	movwf 	@WINDOW_XE
        	movlw 	P1_Y
        	movwf 	@WINDOW_YS
        	call 	@draw_player_common

	; Draw player 2
        	movf 	@P2_X, w
        	movwf 	@WINDOW_XS
        	addlw 	PLAYER_WIDTH - .1
        	movwf 	@WINDOW_XE
        	movlw 	P2_Y
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

end
