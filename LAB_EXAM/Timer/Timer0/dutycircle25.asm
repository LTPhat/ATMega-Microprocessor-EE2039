;Viết chương trình tạo ra 1 xung tần số 1Khz, duty cycle 25% trên chân OC0B
.EQU P_OUT=4 ;gán ký hiệu P_OUT=5
	.EQU OUTPORT= PORTB
	.EQU SETPORT= DDRB
	.EQU TP_H= -31 ;giá trị đặt trước mức 1
	.EQU TP_L= -94 ;giá trị đặt trước mức 0

	.ORG 0
	RJMP MAIN
	.ORG 0x40
MAIN: 
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, (1<<P_OUT) ;đặt PB4 output
	OUT SETPORT, R16
	LDI R17, 0x00 ;Timer0 mode NOR
	OUT TCCR0A, R17
	LDI R17, 0x00 ;mode NOR, dừng
	OUT TCCR0B, R17

START:SBI OUTPORT, P_OUT ;output=1	1MC
	LDI R17,TP_H ;nạp TP_H	1MC
	RCALL DELAY_T0 ;ctc chạy Timer0	3MC
	CBI OUTPORT, P_OUT ;output=0 1MC
	LDI R17, TP_L ;nạp TP_L 1MC
	RCALL DELAY_T0 ;ctc chạy Timer0	3MC
	RJMP START		;2MC

DELAY_T0:
	OUT TCNT0, R17 ; 1MC
	LDI R17, 0x03 ;chạy, chia N=64 1MC
	OUT TCCR0B, R17 ; 1MC
WAIT: IN R17,TIFR0 ; 1MC
	SBRS R17, TOV0 ; 2/1MC
	RJMP WAIT ; 2MC
	OUT TIFR0, R17 ; 1MC
	LDI R17, 0x00 ;dừng 1MC
	OUT TCCR0B,R17 ; 1MC
	RET ; 4MC
