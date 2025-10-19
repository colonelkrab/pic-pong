#include <p18f452.inc>
global delay

udata
count1 res 1
count2 res 1
count3 res 1

code
delay
movlw d'25'
movwf count1
movwf count2
movwf count3
loop1
	loop2

		loop3 
		decfsz count3,f
		goto loop3

		decfsz count2,f
		goto loop2
	decfsz count1,f
	goto loop1
return
end

