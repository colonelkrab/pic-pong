#define DCX_PORT PORTD
#define DCX RD4

; ST7735 COMMANDS
#define ST7735_SWRESET 0x01 ;requires delay > 120ms
#define ST7735_SLPOUT 0x11   ;requires delay > 120ms
#define ST7735_COLMOD 0x3a
#define ST7735_NORON 0x13
#define ST7735_DISPON 0x29 ;requires delay > 120ms between DISPON and DISPOFF
#define ST7735_CASET 0x2a
#define ST7735_RASET 0x2b
#define ST7735_RAMWR 0x2c

extern _st7735_spi_send_wreg_as_cmd, _st7735_spi_send_wreg_as_data, _delay_125ms

__st7735_spi_init macro
bcf TRISC, SDO
bcf TRISC, SCK
bcf TRISA, SS
bcf TRISD, DCX
bsf PORTA, SS
bsf SSPSTAT, CKE; rising edge; idle low
bsf SSPCON1, SSPEN
endm

__st7735_send_cmd macro byte
movlw byte
call _st7735_spi_send_wreg_as_cmd
endm

__st7735_send_data macro byte
movlw byte
call _st7735_spi_send_wreg_as_data
endm

__st7735_init_sequence macro
__st7735_send_cmd ST7735_SWRESET
call _delay_125ms
__st7735_send_cmd ST7735_SLPOUT
call _delay_125ms
__st7735_send_cmd ST7735_COLMOD
__st7735_send_data 0x55
__st7735_send_cmd ST7735_NORON
__st7735_send_cmd ST7735_DISPON
endm
