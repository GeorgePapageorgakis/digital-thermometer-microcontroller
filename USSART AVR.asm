;PROGRAM USING THE USART FOR SENDING 5 BYTES STORED
;IN CONSEQUITIVE RAM POSITIONS (START ADDRESS $60)
;EVERY FIFTEEN MINUTES
;ASSUME 4 MHz CRYSTAL ON AVR AND BAUD RATE 19200
;
.include 	"m16def.inc"
.org 0		;Reset
rjmp start
.org $0C 		;Timer1 compare match interrupt vector
rjmp timer1isr
.org $18		;USART Data Register Empty interrupt
rjmp usartisr
.org $2A
start:

ldi r30,$5F		;STACK POINTER INITIALIZATION
out SPL,r30		;TO HIGHEST RAM ADDRESS
ldi r30,$02
out SPH,r30

;RAM ADDRESS INITIALIZATION

ldi YH,$00		;Initialize Y register to SRAM first position
ldi YL,$60

;TIMER 1 INITIALIZATION

ldi r18,60		;60x15sec = 15 minutes  
ldi r16,$01     ;timer 1 counts 15 secs
out OCR1AH,r16	;compare register A takes value $E4E1 (58594)
ldi r16,$F0     ;
out OCR1AL,r16
ldi r16,$10  	;TIMSK enable compare match A
out TIMSK,r16
ldi r16,$09		;TCCR1B prescaler /1024 and clear timer on compare match
out TCCR1B,r16

; USART INITIALIZATION

ldi r20,12		;Set Baud rate to 19200
out UBRRL,r20
ldi r20,0
out UBRRH,r20
ldi r20,$B6		;Set odd parity, 8 bit data and one stop bit
out UCSRC,r20
sbi DDRD,1		;Set PD1 as output (USART TXD)

sei  			;Global interrupt enable, SREG
loop:
rjmp loop 

;Timer 1 Interrupt routine

timer1isr:
nop
dec r18
breq sendvalues
reti

sendvalues:
sei 
ldi r18,60		;Reload value for 15 minutes

ldi r22,5		;number of RAM words to be sent

ld r16,Y+		;total transmission time less than 15 seconds
out UDR,r16		;write byte to USART data register
ldi r20,$28		;Enable USART transmitter and data reg empty interrupt
out UCSRB,r20
dec r22

waittx:
breq end_tx		;return to timer interupt routine if all words sent
rjmp waittx		;wait to transmit byte

usartisr:
ld r16,Y+		;total transmission time less than 15 seconds
out UDR,r16		;write byte to UART data register
dec r22
reti

end_tx:
ldi r20,0
out UCSRB,r20	;Disable USART transmitter
reti


