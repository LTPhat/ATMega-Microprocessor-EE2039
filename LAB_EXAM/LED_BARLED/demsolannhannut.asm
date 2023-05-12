;Kết nối 1 switch đến 1 chân port của AVR, kết nối module BAR LED đến 1 port của AVR, kết nối LCD đến 1 port của AVR
;Viết chương trình đếm số lần nhấn nút và xuất kết quả ra barled, đồng thời xuất ra LCD (không chống rung)
;Thêm tính năng chống rung phím vào chương trình
;Thực hiện chương trình, nhấn/nhả nút và quan sát kết quả

        .EQU INPORT=PINB ;DATA O PINB
		.EQU INPORT_DDR=DDRB
		.EQU SETPORT=PORTB

		.EQU BLED=PORTA ;PORT DIEU KHIEN BARLED
		.EQU BLED_DDR=DDRA

		.EQU LCD4=PORTD ;PORTC DIEU KHIEN LCD4
		.EQU LCD4_DDR=DDRD

		.EQU SW=0	;VI TRI SWITCH COUNTER
		.EQU RST=1	;VI TRI SWITCH RESET COUNTER
		.EQU RS=0	;BIT RS
		.EQU RW=1	;BIT RW
		.EQU E=2	;BIT E

		.ORG 0
		RJMP MAIN
		.ORG 0x40
MAIN:	
		LDI R16,HIGH(RAMEND)
		OUT SPH,R16
		LDI R16,LOW(RAMEND)
		OUT SPL,R16

		CLR R16
		OUT INPORT_DDR,R16	;PORTB LA INPUT

		LDI R16,$FF
		OUT SETPORT,R16		;DIEN TRO KEO LEN O PORTB

		LDI R16,$FF
		OUT BLED_DDR,R16	;PORTA LA OUTPUT

		LDI R16,$FF
		OUT LCD4_DDR,R16	;PORTC LA OUTPUT

		CBI LCD4,RS
		CBI LCD4,RW
		CBI LCD4,E

;KHOI DONG LCD
		LDI R16,250
		RCALL DELAY_US
		LDI R16,250
		RCALL DELAY_US

		CBI LCD4,RS
		LDI R17,$30 
		RCALL OUT_LCD4 ;GHI 3XH

		LDI R16,42
		RCALL DELAY_US

		CBI LCD4,RS
		LDI R17,$30
		RCALL OUT_LCD4 ;GHI XONG 33H

		LDI R16,2
		RCALL DELAY_US

		CBI LCD4,RS
		LDI R17,$32
		RCALL OUT_LCD40

		LDI R18,$28 ;FUNCTION SET GIAO TIEP 4 BIT 2 DONG FONT 5x8
		LDI R19,$01 ;CLEAR DISPLAY
		LDI R20,$0C ;DISPLAY ON, CON TRO OFF
		LDI R21,$06 ;ENTRY MODE SET: DICH PHAI CON TRO
		RCALL INIT_LCD4

START:
		CLR R25
LOOP:	
		RCALL KEY_RD
		OUT BLED,R25 ;XUAT GIA TRI SO DEM RA BARLED
		MOV R17,R25
		PUSH R17
		
		LDI R16,1
		RCALL DELAY_US
		CBI LCD4,RS ;DICH CHUYEN CON TRO
		LDI R17,$87
		RCALL OUT_LCD40

		POP R17
		LDI R16,10
		RCALL DIV8_8
		PUSH R18 ;CAT HANG DON VI
		LDI R16,10
		RCALL DIV8_8 
		PUSH R18 ;CAT HANG CHUC
		PUSH R17 ;CAT HANG TRAM
		

		POP R17 ;LAY HANG TRAM
		RCALL BCD_ASCII
		SBI LCD4,RS
		RCALL OUT_LCD40

		POP R17 ;LAY HANG CHUC
		RCALL BCD_ASCII
		SBI LCD4,RS
		RCALL OUT_LCD40

		POP R17 ;LAY HANG DON VI
		RCALL BCD_ASCII
		SBI LCD4,RS
		RCALL OUT_LCD40
		RJMP LOOP

;........................
;CHUONG TRINH CON GET_KEY
;C=0 NEU KHONG CO PHIM AN
;C=1 NEU CO PHIM AN
GET_KEY:
		IN R17,INPORT
		ANDI R17,(1<<SW) ;LOC LAY SW DEM
		CPI R17,(1<<SW)
		BRNE SET_FLG
		CLC
		RJMP EXIT 
SET_FLG:
		SEC
EXIT:	RET

;........................
;CTC CHONG RUNG PHIM NHAN BIET BANG CO CARRY
KEY_RD:
		;KIEM TRA SW RESET COUNTER
		SBIC INPORT,RST 
		RJMP CONTINUE
		LDI R16,100 ;DELAY 10MS
		RCALL DELAY_US
		SBIC INPORT,RST
		RJMP CONTINUE
		CLR R25
		RJMP GO

CONTINUE:
		LDI R18,50
BACK1:	RCALL GET_KEY
		BRCC KEY_RD
		DEC R18
		BRNE BACK1 
WAIT:		LDI R18,50
BACK2:	RCALL GET_KEY
		BRCS WAIT
		DEC R18
		BRNE BACK2
		INC R25 ;TANG BIEN DEM
GO:		RET

;.........................................		
;INIT_LCD KHOI DONG LCD GHI 4 BYTE MA LENH
;FUNCTION SET: R18=$28 GIAO TIEP 4 BIT, 2 DONG FONT 5x8
;CLEAR DISPLAY: R19=$01 XOA MAN HINH
;DISPLAY CONTROL: R20=$0C MAN HINH ON, CON TRO OFF
;ENTRY MODE SET: R21=$06 DICH PHAI CON TRO
;RS BIT0=0, RW BIT1=0
INIT_LCD4:
		CBI LCD4,RS
		MOV R17,R18 ;FUNCTION SET
		RCALL OUT_LCD40

		MOV R17,R19 
		RCALL OUT_LCD40

		LDI R16,20 
		RCALL DELAY_US ;CHO 2ms

		MOV R17,R20
		RCALL OUT_LCD40

		MOV R17,R21
		RCALL OUT_LCD40
		RET

;........................................
;OUT_LCD40 GHI 1BYTE MA LENH/DATA RA LCD4
;INPUT=R17 CHUA MA LENH/DATA,R16=LOC LENH RS
OUT_LCD40:
		LDI R16,1 ;CHO 100us
		RCALL DELAY_US

		IN R16,LCD4 
		ANDI R16,(1<<RS) ;LOC BIT RS
		PUSH R16
		PUSH R17
		ANDI R17,$F0
		OR R17,R16 ;GHEP LENH VA DATA XUAT LED4
		RCALL OUT_LCD4 ;GHI RA LCD

		LDI R16,1 ;CHO 100us
		RCALL DELAY_US

		POP R17
		POP R16
		SWAP R17
		ANDI R17,$F0
		OR R17,R16
		RCALL OUT_LCD4
		RET

;................................
;OUT_LCD GHI MA LENH/DATA RA LCD
;INPUT R17 CHUA MA LENH/DATA
OUT_LCD4:
		OUT LCD4,R17 ;GHI LENH/DATA RA LCD
		SBI LCD4,E ;TAO XUNG CANH XUONG
		NOP
		CBI LCD4,E
		RET

;................................
TABLE:	.DB "0","1","2","3","4","5","6","7","8","9"
;R17 LA OFFSET
;KET QUA LUU LAI R17
BCD_ASCII:
		LDI ZH,HIGH(TABLE<<1)
		LDI ZL,LOW(TABLE<<1)
		ADD ZL,R17
		CLR R16
		ADC ZH,R16
		LPM R17,Z
		RET

;..............................
;DELAY_US TAO THOI GIAN TRE = R16*100uF (FOSC=8MHz)
;INPUT R16 LA HE SO NHAN THOI GIAN TRE 1 DEN 255
DELAY_US:
		MOV R15,R16 ;1MC
		LDI R16,200 ;1MC
L1:		MOV R14,R16 ;1MC NAP DATA CHO R14
L2:		NOP ;1MC
		DEC R14 ;1MC
		BRNE L2 ;2/1MC
		DEC R15 ;1MC
		BRNE L1 ;2/1MC
		RET ;4MC

;.............................
;CTC PHEP CHIA R17:R16
;TRA VE R17=KQ ;R18= SO DU
DIV8_8:
		CLC
		CLR R18
L3:		INC R18
		SUB R17,R16
		BRCC L3
		DEC R18
		ADD R17,R16
		PUSH R18
		MOV R18,R17
		POP R17
RET 