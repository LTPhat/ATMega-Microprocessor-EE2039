.org	00
	ldi r16,0x01
	out	DDRA, r16
start:
       sbi	PORTA,PINA0
       cbi	PORTA, PINA0
       rjmp start
