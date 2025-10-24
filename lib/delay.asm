#include <p18f452.inc>
global _delay_125ms, _delay

.DELAY_DATA udata
		d0 res 1
		d1 res 1
		d2 res 1 

.DELAY code
; Delay = 0.125 seconds
; Clock frequency = 24 MHz
	_delay_125ms:
		movlw d'100'
		movwf d0
	i:
		movlw d'100'
		movwf d1
	j:
		movlw d'24'
		movwf d2
	k: 
		decfsz d2,f
		goto k

		decfsz d1,f
		goto j

		decfsz d0,f
		goto i

	return
	_delay:
		movlw d'100'
		movwf d0
	di:
		movlw d'60'
		movwf d1
	dj:
		movlw d'1'
		movwf d2
	dk: 
		decfsz d2,f
		goto dk

		decfsz d1,f
		goto dj

		decfsz d0,f
		goto di

	return

end

