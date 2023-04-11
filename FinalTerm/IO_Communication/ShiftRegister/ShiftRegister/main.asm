; Vi?t ch??ng tr�nh nh?p data t? port D, xu?t ra d??i d?ng n?i ti?p giao ti?p d�ng thanh ghi d?ch 74HC595


.ORG	0
RJMP	MAIN
.ORG	40
MAIN:	
		// Khai b�o thi?t l?p pointer
		LDI		R16, HIGH(RAMEND)
		OUT		SPH, R16
		LDI		R16, LOW(RAMEND)
		OUT		SPL, R16
		LDI		R16, 0x00
		OUT		PORTD, R16	; Port D nh?p
		LDI		R16, 0x07	; PB0: DS, PB1: CK d?ch; PB2: CK xu?t
		OUT		DDRB, R16
		CBI		PORTB, 1	; CK d?ch = 0
		CBI		PORTB, 2	; CK xu?t = 0
START:	IN		R17, PORTD	; L?y data t? portD
		RCALL	SHIFT_OUT
		RJMP	START
;
; SHIFT_OUT:
; Input: R17 ch?a data c?n d?ch
; Output: R17 b?o to�n n?i dung

SHIFT_OUT:
		LDI		R16, 8		; S? bit c?n d?ch
SH_O:	ROL		R17			; quay tr�i R17 qua C
		BRCC	BIT_0		; C = 0, xu?t bit 0
		SBI		PORTB, 0	; C = 1, xu?t bit 1
		RJMP	SH_CK		; Nh?y ??n t?o CK d?ch
BIT_0:	CBI		PORTB, 0
SH_CK:	SBI		PORTB, 1	; L�n
		CBI		PORTB, 1	; Xu?ng --> T?o xung clock cho CK d?ch
		DEC		R16			; Gi?m s? bit c?n d?ch
		BRNE	SH_O		; D?ch ti?p cho ?? s? bit
		SBI		PORTB, 2	; CK xu?t l�n
		CBI		PORTB, 2	; Ck xu?t xu?ng
		ROL		R17			; D?ch ph?c h?i R17
		RET
