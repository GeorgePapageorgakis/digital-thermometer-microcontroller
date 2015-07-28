;   digital-thermometer-microcontroller.asm
;   	A simple implementation of a digital thermometer 
;	using Atmel MEGA16-P microcontroller
;
;	
;    @author George Papageorgakis
;    @version 1.0 2/2007
;

.INCLUDE "M16DEF.INC"

.EQU LCD_ON=PIND4			
.EQU LCD_RS=PIND5
.EQU LCD_RW=PIND6
.EQU LCD_E=PIND7

.org $0000
 jmp RESET		; Reset Handler
 jmp EXT_INT0		; IRQ0 Handler
 jmp EXT_INT1 		; IRQ1 Handler
 jmp TIM2_COMP 		; Timer2 Compare Handle
 jmp TIM2_OVF 		; Timer2 Overflow Handler
 jmp TIM1_CAPT		; Timer1 Capture Handler
 jmp TIM1_COMPA 	; Timer1 CompareA Handler
 jmp TIM1_COMPB 	; Timer1 CompareB Handler
 jmp TIM1_OVF 		; Timer1 Overflow Handler
 jmp TIM0_OVF 		; Timer0 Overflow Handler
 jmp SPI_STC 		; SPI Transfer Complete Handler
 jmp USART_RXC 		; UART RX Complete Handler
 jmp USART_DRE 		; UDR Empty Handler
 jmp USART_TXC 		; UART TX Complete Handler
 jmp ADC_CONV 		; ADC Conversion Complete Interrupt
 jmp EE_RDY		; EEPROM Ready Handler
 jmp ANA_COMP 		; Analog Comparator Handler
 jmp TWI		; Twowire serial interface
 jmp INT2_		; External interrupt request 2
 jmp TIMER0_COMP 	; Timer/counter0 Compare match	
 jmp SPM_RDY


RESET:
CLI 			 ;Disable INTERRUPTS

LDI R20,255 		;Port C output
OUT DDRC,R20
OUT DDRD,R20		;Port D output
;-------------------------------------------------------------------------------------------------------------	

LDI R20,HIGH(RAMEND) 	;Enable Stack
OUT SPH,R20
LDI R20,LOW(RAMEND)
OUT SPL,R20

;--------------------------------------------------------------------------------------------------------------

LDI R21,255
RCALL DELAY
LDI R21,255
RCALL DELAY
SBI PORTD,LCD_ON 	; Enable LCD

LDI R21,255
RCALL DELAY
LDI R21,255
RCALL DELAY

RCALL  LCD_INIT

;-----------------------------------------TIMER_COUNTER_1_SETUP ----------------------------------------------
;TIMER  for every 30 second routine call to read ADC
;CRYSTAL FREQ./PRESCALLER=COUNT  12.8MHZ/1024=12500 COUNTS=  1 SEC  

LDI R19,1		; First time counter is 1

LDI R20,0X08		;bit3 0CF1B (output compare B match flag)
OUT TIFR,R20

LDI R20,0X88    	;1B INTERRUPT MATCH ENABLE
OUT TIMSK,R20

LDI R20,0X05		;0X05 PRESSCALLER 1024
OUT TCCR1B,R20  

LDI R20,0XF4		;0XF4 value for comparison with counter H
OUT OCR1BH,R20

LDI R20,0X24		;0X24 value for comparison with counter L
OUT OCR1BL,R20
	

;----------------------------------------ADC SETUP------------------------------------------------------
ADC_INIT:	

LDI R16,0X80 		;0X80 for 5V REF KAI 0xC0 INT 2.56 REF
OUT ADMUX,R16
LDI R16,0X86
OUT ADCSRA,R16

;-------------------------------------------------------------------------------------------------------
			
LDI ZH,HIGH(SYMBC*2)	;Read the temp message, number of digits to be read
LDI ZL,LOW(SYMBC*2)
LDI R20,15

RCALL SHOW

LDI ZH,HIGH(SYMBF*2)
LDI ZL,LOW(SYMBF*2)

RCALL LCD_WAIT
LDI R16,0XC0		;SET DDRAM ADDRESS LINE LCD line2
RCALL LCD_CMD
LDI R20,15
	
RCALL SHOW	
RCALL TIM1_COMPB 	;Subroutine Call interrupt as a simple routine
	
SEI			;ACTIVATION OF INTERRUPTS

WAIT:			;LOOP 
RJMP WAIT

SHOW:
REPE:	RCALL LCD_WAIT
	LPM			;Store in R0 value pointed by Z
	MOV R16,R0
	RCALL LCD_WRITE_DATA
			
	ADIW ZH:ZL,1		;Inc by 1 the address to be read from the Table
	DEC R20			;Repeat until the end
	BRNE REPE
		
RET		

LCD_CMD:	
CBI PORTD,LCD_RS		; R5->0
	OUT PORTC,R16		;bit 4-5 ->1
	SBI PORTD,LCD_E		;LCD signal enable
	NOP
	NOP
	NOP
	NOP
	CBI PORTD,LCD_E
RET

LCD_WRITE_DATA:
SBI PORTD,LCD_RS		;Set R5
	OUT PORTC,R16		;Output to the Pins that r16 points to
	SBI PORTD,LCD_E		;LCD enabled
	NOP
	NOP
	NOP
	NOP
	CBI PORTD,LCD_E		;Clear enable
	CBI PORTD,LCD_RS	;Clear R5
RET

LCD_READ_ADDRESS:
	CBI PORTD,LCD_RS	;Clear R5
	SBI PORTD,LCD_RW	;Set R/W
	LDI R16,0		
	OUT DDRC,R16		;Inputs port C
	OUT PORTC,R16
	SBI PORTD,LCD_E		;LCD enable
	NOP
	NOP
	NOP
	NOP
	IN R16,PINC		;Load of pinC in R16
 	LDI R17,255
	OUT DDRC,R17		;Output port C	
	CBI PORTD,LCD_RW	;R/W of portD -> 0
RET
LCD_WAIT:
	RCALL LCD_READ_ADDRESS
	SBRC R16,7
	RJMP LCD_WAIT
RET
	
DELAY:				;Delay Routine
	
	LOOP3:		LDI R22,5
	LOOP2:		LDI R23,53
	LOOP1:		DEC R23
			
	BRNE LOOP1
	DEC R22
	BRNE LOOP2
	DEC R21
	BRNE LOOP3

RET

LCD_INIT:			;LCD initialization

LDI R21,255
RCALL DELAY
ldi r16,0b00110000 
rcall lcd_CMD

LDI R21,255
RCALL DELAY
ldi r16,0b00110000 
rcall lcd_CMD

LDI R21,5
RCALL DELAY
ldi r16,0b00110000 
rcall lcd_CMD

RCALL LCD_WAIT
ldi r16,0b00111000 
rcall lcd_CMD

rcall LCD_WAIT
ldi r16,0B00001000 
rcall lcd_CMD

rcall lcd_wait
LDI R16,0b00001100 
RCALL LCD_CMD

rcall LCD_WAIT
ldi r16,1
rcall lcd_CMD

rcall lcd_wait
ldi r16,0b00000110 
rcall lcd_CMD

RET

TIM1_COMPB:
	LDI R21,0
	OUT TCNT1L,R21		;Initial value for counting 0
	OUT TCNT1H,R21
	
	DEC R19
	BRNE NOT_30_SEC_YET
	
SBI ADCSRA,ADSC			;Start ADC convertion

WAITADC:	
SBIS ADCSR,ADIF 		;skip if ADIF is set (when transformation is finished -> set)
	RJMP WAITADC

	IN R24,ADCL 
	IN R25,ADCH		;For the sampling results

	RCALL SELECTION
	LDI R19,6		;Reload the counter

NOT_30_SEC_YET:		
RETI

SELECTIO:	
	LDI ZL,LOW(2*CELSIUS)	;Initialization of counters
	LDI ZH,HIGH(2*CELSIUS)
	LDI XL,LOW(2*FARENHEIT)
	LDI XH,HIGH(2*FARENHEIT)

	LDI YH,0X00
	LDI YL,0X00
	
	ADIW	R25:R24,4 	;add 4 to R24-R25 (ADCH-ADCL)

	LSR R25			;for the 8 MSB resolution
	ROR R24
	
AGAIN:	CP R24,YL		;compare the value of ADC with matching
	BRNE NEXT			
	CP R25,YH		;address of LUT
	BRNE NEXT

RCALL VISUALISE 		;its R25:R24=Y and Z points to LUT to the corresponding temp value
RJMP OK

NEXT:	ADIW YH:YL,1 

ADIW ZH:ZL,6			;R30-R31 Celsious		 	
ADIW XH:XL,6			;R28-R29 Farenheit (per 6 slots in the LUT)												 								
	
EDO:	CPI YL,0X9C			
	BRNE AGAIN
	CPI YH,0X01
	BRNE AGAIN

RCALL OUT_OF_RANGE 
	OK: NOP
RET

OUT_OF_RANGE:
	LDI ZL,LOW(OOR*2)	
	LDI ZH,HIGH(OOR*2)
	RCALL VISUALISE
RET

VISUALISE:	
	RCALL LCD_WAIT
	LDI R16,0X86 		;1000/0110
RCALL LCD_CMD
	LDI R20,6		
	
REP:	    			;For the first line in LCD
RCALL LCD_WAIT
	LPM
	MOV R16,R0
	RCALL LCD_WRITE_DATA
	ADIW ZH:ZL,1
	DEC R20
	BRNE REP

	RCALL LCD_WAIT
	LDI R16,0XC6 
	RCALL LCD_CMD
	
	LDI R20,6
	MOV ZL,XL	
	MOV ZH,XH

REP2:	RCALL LCD_WAIT		;For the second line in LCD
	LPM
	MOV R16,R0
	RCALL LCD_WRITE_DATA
	ADIW ZH:ZL,1	
	DEC R20
	BRNE REP2
	
RET

EXT_INT0: reti
EXT_INT1: reti 
TIM2_COMP: reti 
TIM2_OVF: reti 
TIM1_CAPT: reti 
TIM1_COMPA: reti 
;TIM1_COMPB: reti 
TIM1_OVF: reti 
TIM0_OVF: reti 
SPI_STC: reti
USART_RXC: reti 
USART_DRE: reti
USART_TXC: reti 
ADC_CONV: RETI
EE_RDY: reti
ANA_COMP: reti 
TWI: ret
INT2_:reti
TIMER0_COMP:  reti 
SPM_RDY: reti

CELSIUS:
.DB " -55.0"," -54.5"," -54.0"," -53.5"," -53.0"," -52.5"," -52.0"," -51.5"," -51.0"," -50.5"," -50.0"," -49.5"," -49.0"," -48.5"," -48.0"," -47.5"," -47.0"," -46.5"," -46.0"," -45.5"," -45.0"," -44.5"," -44.0"," -43.5"," -43.0"," -42.5"," -42.0"," -41.5"," -41.0"," -40.5"," -40.0"," -39.5"," -39.0"," -38.5"," -38.0"," -37.5"," -37.0"," -36.5"," -36.0"," -35.5"," -35.0"," -34.5"," -34.0"," -33.5"," -33.0"," -32.5"," -32.0"," -31.5"," -31.0"," -30.5"," -30.0"," -29.5"," -29.0"," -28.5"," -28.0"," -27.5"," -27.0"," -26.5"," -26.0"," -25.5"," -25.0"," -24.5"," -24.0"," -23.5"," -23.0"," -22.5"," -22.0"," -21.5"," -21.0"," -20.5"," -20.0"," -19.5"," -19.0"," -18.5"," -18.0"," -17.5"," -17.0"," -16.5"," -16.0"," -15.5"," -15.0"," -14.5"," -14.0"," -13.5"," -13.0"," -12.5"," -12.0"," -11.5"," -11.0"," -10.5"," -10.0","  -9.5","  -9.0","  -8.5","  -8.0","  -7.5","  -7.0","  -6.5","  -6.0","  -5.5","  -5.0","  -4.5","  -4.0","  -3.5","  -3.0","  -2.5","  -2.0","  -1.5","  -1.0","  -0.5","    0 ","  +0.5","  +1.0","  +1.5"," +2.0 "," +2.5 "," +3.0 "," +3.5 "," +4.0 "," +4.5 "," +5.0 "," +5.5 "," +6.0 "," +6.5 "," +7.0 "," +7.5 "," +8.0 "," +8.5 "," +9.0 "," +9.5 ","+10.0 ","+10.5 ","+11.0 ","+11.5 ","+12.0 ","+12.5 ","+13.0 ","+13.5 ","+14.0 ","+14.5 ","+15.0 ","+15.5 ","+16.0 ","+16.5 ","+17.0 ","+17.5 ","+18.0 ","+18.5 ","+19.0 ","+19.5 ","+20.0 ","+20.5 ","+21.0 ","+21.5 ","+22.0 ","+22.5 ","+23.0 ","+23.5 ","+24.0 ","+24.5 ","+25.0 ","+25.5 ","+26.0 ","+26.5 ","+27.0 ","+27.5 ","+28.0 ","+28.5 ","+29.0 ","+29.5 ","+30.0 ","+30.5 ","+31.0 ","+31.5 ","+32.0 ","+32.5 ","+33.0 ","+33.5 ","+34.0 ","+34.5 ","+35.0 ","+35.5 ","+36.0 ","+36.5 ","+37.0 ","+37.5 ","+38.0 ","+38.5 ","+39.0 ","+39.5 ","+40.0 ","+40.5 ","+41.0 ","+41.5 ","+42.0 ","+42.5 ","+43.0 ","+43.5 ","+44.0 ","+44.5 ","+45.0 ","+45.5 ","+46.0 ","+46.5 ","+47.0 ","+47.5 ","+48.0 ","+48.5 ","+49.0 ","+49.5 ","+50.0 ","+50.5 ","+51.0 ","+51.5 ","+52.0 ","+52.5 ","+53.5 ","+53.0 ","+54.0 ","+54.5 ","+55.0 ","+55.5 ","+56.0 ","+56.5 ","+57.0 "
.DB "+57.5 ","+58.0 ","+58.5 ","+59.0 ","+59.5 ","+60.0 ","+60.5 ","+61.0 ","+61.5 ","+62.0 ","+62.5 ","+63.0 ","+63.5 ","+64.0 ","+64.5 ","+65.0 ","+65.5 ","+66.0 ","+66.5 ","+67.0 ","+67.5 ","+68.0 ","+68.5 ","+69.0 ","+69.5 ","+70.0 ","+70.5 ","+71.0 ","+71.5 ","+72.0 ","+72.5 ","+73.0 ","+73.5 ","+74.0 ","+74.5 ","+75.0 ","+75.5 ","+76.0 ","+76.5 ","+77.0 ","+77.5 ","+78.0 ","+78.5 ","+79.0 ","+79.5 ","+80.0 ","+80.5 ","+81.0 ","+81.5 ","+82.0 ","+82.5 ","+83.0 ","+83.5 ","+84.0 ","+84.5 ","+85.0 ","+85.5 ","+86.0 ","+86.5 ","+87.0 ","+87.5 ","+88.0 ","+88.5 ","+89.0 ","+89.5 ","+90.0 ","+90.5 ","+91.0 ","+91.5 ","+92.0 ","+92.5 ","+93.0 ","+93.5 ","+94.0 ","+94.5 ","+95.0 ","+95.5 ","+96.0 ","+96.5 ","+97.0 ","+97.5 ","+98.0 ","+98.5 ","+99.0 ","+99.5 ","+100.0","+100.5","+101.0","+101.5","+102.0","+102.5","+103.0","+103.5","+104.0","+104.5","+105.0","+105.5","+106.0","+106.5","+107.0","+107.5","+108.0","+108.5","+109.0","+109.5","+110.0","+110.5","+111.0","+111.5","+112.0","+112.5","+113.0","+113.5","+114.0","+114.5","+115.0","+115.5","+116.0","+116.5","+117.0","+117.5","+118.0","+118.5","+119.0","+119.5","+120.0","+120.5","+121.0","+121.5","+122.0","+122.5","+123.0","+123.5","+124.0","+124.5","+125.0","+125.5","+126.0","+126.5","+127.0","+127.5","+128.0","+128.5","+129.0","+129.5","+130.0","+130.5","+131.0","+131.5","+132.0","+132.5","+133.0","+133.5","+134.0","+134.5","+135.0","+135.5","+136.0","+136.5","+137.0","+137.5","+138.0","+138.5","+139.0","+139.5","+140.0","+140.5","+141.0","+141.5","+142.0","+142.5","+143.0","+143.5","+144.0","+144.5","+145.0","+145.5","+146.0","+146.5","+147.0","+147.5","+148.0","+148.5","+149.0","+149.5","+150.0","+150.5","+151.0"		
FARENHEIT:
.DB " -67.0"," -66.0"," -65.5"," -64.5"," -63.5"," -62.5"," -61.5"," -60.5"," -60.0"," -59.0"," -58.0"," -57.0"," -56.0"," -55.5"," -54.5"," -53.5"," -52.5"," -51.5"," -51.0"," -50.0"," -49.0"," -48.0"," -47.0"," -46.5"," -45.5"," -45.5"," -43.5"," -42.5"," -42.0"," -41.0"," -40.0"," -39.0"," -38.0"," -37.5"," -36.5"," -35.5"," -34.5"," -33.5"," -33.0"," -32.0"," -31.0"," -30.0"," -29.0"," -28.5"," -27.5"," -26.5"," -25.5"," -24.5"," -24.0"," -23.0"," -22.0"," -21.0"," -20.0"," -19.5"," -18.5"," -17.5"," -16.5"," -15.5"," -15.0"," -14.0"," -13.0"," -12.0"," -11.0"," -10.5"," -9.5 "," -8.5 "," -7.5 "," -6.5 "," -6.0 "," -5.0 "," -4.0 "," -3.0 "," -2.0 "," -1.5 "," -0.5 ","+ 0.5 ","+ 1.5 ","+ 2.5 ","+ 3.0 ","+ 4.0 ","+ 5.0 ","+ 6.0 ","+ 7.0 ","+ 7.5 ","+ 8.5 ","+ 9.5 ","+10.5 ","+11.5 ","+12.0 ","+13.0 ","+14.0 ","+15.0 ","+16.0 ","+16.5 ","+17.5 ","+18.5 ","+19.5 ","+20.5 ","+21.0 ","+22.0 ","+23.0 ","+24.0 ","+25.0 ","+25.5 ","+26.5 ","+27.5 ","+28.5 ","+29.5 ","+30.0 ","+31.0 ","+32.0 ","+33.0 ","+34.0 ","+34.5 ","+35.5 ","+36.5 ","+37.5 ","+38.5 ","+39.0 ","+40.0 ","+41.0 ","+42.0 ","+43.0 ","+43.5 ","+44.5 ","+45.5 ","+46.5 ","+47.5 ","+48.0 ","+49.0 ","+50.0 ","+51.0 ","+52.0 ","+52.5 ","+53.5 ","+54.5 ","+55.5 ","+56.5 ","+57.0 ","+58.0 ","+59.0 ","+60.0 ","+61.0 ","+61.5 ","+62.5 ","+63.5 ","+64.5 ","+65.5 ","+66.0 ","+67.0 ","+68.0 ","+69.0 ","+70.0 ","+70.5 ", "+71.5 ","+72.5 ","+73.5 ","+74.5 ","+75.0 ","+76.0 ","+77.0 ","+78.0 ","+79.0 ","+79.5 ","+80.5 ","+81.5 ","+82.5 ","+83.5 ","+84.0 ","+85.0 ","+86.0 ","+87.0 ","+88.0 ","+88.5 ","+89.5 ","+90.5 ","+91.5 ","+92.5 ","+93.0 ","+94.0 ","+95.0 ","+96.0 ","+97.0 ","+97.5 ","+98.5 ","+99.5 ","+100.5","+101.5","+102.0","+103.0","+104.0","+105.0","+106.0","+106.5","+107.5","+108.5","+109.5","+110.5","+111.0","+112.0","+113.0","+114.0","+115.0","+115.5","+116.5","+117.5","+118.5","+119.5","+120.0","+121.0","+122.0","+123.0","+124.0","+124.5","+125.5","+126.5","+127.5","+128.5","+129.0","+130.0","+131.0","+132.0","+133.5","+133.5","+134.5"
.DB "+135.5","+136.5","+137.5","+138.0","+139.0","+140.0","+141.0","+141.5","+142.5","+143.5","+144.5","+145.5","+146.5","+147.0","+148.0","+149.0","+150.0","+151.0","+151.5","+152.5","+153.5","+154.5","+155.5","+156.0","+157.0","+158.0","+159.0","+160.0","+160.5","+161.5","+162.5","+163.5","+164.5","+165.0","+166.0","+167.0","+168.0","+169.0","+169.5","+170.5","+171.5","+172.5","+173.5","+174.0","+175.0","+176.0","+177.0","+178.0","+178.5","+170.5","+180.5","+181.5","+182.5","+183.0","+184.0","+185.0","+186.0","+187.0","+187.5","+188.5","+189.5","+190.5","+191.5","+192.0","+193.0","+194.0","+195.0","+195.0","+196.5","+197.5","+198.5","+199.5","+200.5","+201.0","+202.0","+203.0","+204.0","+205.0","+205.5","+206.5","+207.5","+208.5","+209.5","+210.0","+211.0","+212.0","+213.0","+214.0","+214.5","+215.5","+216.5","+217.5","+218.5","+219.0","+220.0","+221.0","+222.0","+223.0","+223.5","+224.5","+225.5","+226.5","+227.5","+228.0","+229.0","+230.0","+231.0","+232.0","+233.0","+233.5","+234.5","+235.5","+236.5","+237.0","+238.0","+239.0","+240.0","+241.0","+241.5","+242.5","+243.5","+244.5","+245.5","+246.0","+247.0","+248.0","+249.0","+250.0","+251.0","+251.5","+252.5","+253.5","+254.5","+255.0","+256.0","+257.0","+258.0","+259.0","+259.5","+260.5","+261.5","+262.5","+263.5","+264.0","+265.0","+266.0","+267.0","+268.0","+268.5","+269.5","+270.5","+271.5","+272.5","+273.0","+274.0","+275.0","+276.0","+277.0","+277.5","+278.5","+279.5","+280.5","+281.5","+282.0","+283.0","+284.0","+285.0","+286.0","+286.5","+287.5","+288.5","+289.5","+290.5","+291.0","+292.0","+293.0","+294.0","+295.0","+295.5","+296.5","+297.5","+298.5","+299.5","+300.0","+301.0","+302.0","++++++"
SYMBC:.DB"Temp: ______ ",0XDF,"C"
SYMBF:.DB"Temp: ______ ",0XDF,"F"
OOR:.DB"++++++"	
