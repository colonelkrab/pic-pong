extern _spi_recieve_complete

__spi_init_master_mode macro
bcf TRISC, SDO
bcf TRISC, SCK
bcf TRISA, SS
bsf PORTA, SS
bsf SSPSTAT, CKE; rising edge; idle low
bsf SSPCON1, SSPEN
endm

__spi_send_byte macro byte
movlw byte
movwf SSPBUF
call _spi_recieve_complete
endm
