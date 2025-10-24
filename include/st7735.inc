#define DCX_PORT 	PORTD
#define DCX 		RD4
#define XS_MIN 		.2
#define XE_MAX 		.129
#define YS_MIN 		.1
#define YE_MAX 		.160
#define SCREEN_WIDTH 	.128
#define SCREEN_HEIGHT 	.160

; ST7735 COMMANDS
#define ST7735_SWRESET 	0x01 ;requires delay > 120ms
#define ST7735_SLPOUT 	0x11 ;requires delay > 120ms
#define ST7735_COLMOD 	0x3a
#define ST7735_NORON 	0x13
#define ST7735_DISPON 	0x29 ;requires delay > 120ms between DISPON and DISPOFF
#define ST7735_CASET 	0x2a
#define ST7735_RASET 	0x2b
#define ST7735_RAMWR 	0x2c
#define ST7735_MADCTL 	0x36
#define ST7735_PWCTR1 	0xc0
#define ST7735_FRMCTR1 	0xb1


;16 bit color defines
#define COLOR_16_UPPER(r, g) 	((((r) & (0xff << 3)) | ((g) >> 5)) & 0xffff)
#define COLOR_16_LOWER(g, b) 	(((g) << 3) & (0xff << 5)) | ((b) >> 3)
#define COLOR_16(r, g, b) 	(((COLOR_16_UPPER((r), (g))) << 8) | COLOR_16_LOWER((g), (b)))

extern @st7735_spi_send_wreg_as_cmd
extern @st7735_spi_send_wreg_as_data
extern _delay_125ms

__st7735_spi_init MACRO
		bcf 	TRISC, SDO
		bcf 	TRISC, SCK
		bcf 	TRISA, SS
		bcf 	TRISD, DCX
		bsf 	PORTA, SS
		bsf 	SSPSTAT, CKE		; rising edge; idle low
		bsf 	SSPCON1, SSPEN
endm

__st7735_send_cmd MACRO byte
		movlw 	byte
		call 	@st7735_spi_send_wreg_as_cmd
endm

__st7735_send_data MACRO byte
		movlw 	byte
		call 	@st7735_spi_send_wreg_as_data
endm

__st7735_init_sequence MACRO
		__st7735_send_cmd ST7735_SWRESET
		call 	_delay_125ms
		__st7735_send_cmd ST7735_SLPOUT
		call 	_delay_125ms
		__st7735_send_cmd ST7735_COLMOD
		__st7735_send_data 0x55		; 16 bit colors
		__st7735_send_cmd ST7735_MADCTL
		__st7735_send_data 0x00		; rgb mode
		__st7735_send_cmd ST7735_NORON
		__st7735_send_cmd ST7735_DISPON
endm

__st7735_set_window MACRO xs, xe, ys, ye
		__st7735_send_cmd ST7735_CASET
		__st7735_send_data 0x00
		__st7735_send_data xs
		__st7735_send_data 0x00
		__st7735_send_data xe
		__st7735_send_cmd ST7735_RASET
		__st7735_send_data 0x00
		__st7735_send_data ys
		__st7735_send_data 0x00
		__st7735_send_data ye
endm

