; DIPSW * 9 --< Output BARLED


.EQU INPUT_DDR=DDRA
.EQU INPUT=PINA			; KEY DIPSW INPUT
.EQU INPUT_RES=PORTA    ; PULLUP RES
.EQU OUTLED = PORTD     ; OUTPUT LED7SEGMENT
.EQU OUTLED_DDR = DDRD
.EQU SL_LED = PORTB     ; SELECT MODE 
.EQU SL_LED_DDR = DDRB
.EQU nLE0 =PB0     	  ; CONTROL KEY LED
.EQU nLE1 =PB1          ; CONTROL SELECT LED


.DEF CONT9 =R9    ; STORE CONT = 9
.DEF REG_IN = R10 ; STORE INPUT DIPSW
.EQU	BCD_BUF=0X100
.DEF OPD1_L = R20
.DEF OPD1_H = R21
.DEF OPD2 = R23
.DEF OPD3 = R8
.DEF COUNT = R16
.include "m324PAdef.inc"
.ORG 0
RJMP MAIN
.ORG 40

MAIN:
// SETUP PORT:
	CLR R16
	OUT INPUT_DDR,R16
	SER R16
	OUT OUTLED_DDR,R16	
	OUT INPUT_RES,R16	
	LDI R16,(1<<nLE0)|(1<<nLE1)
	OUT SL_LED_DDR,R16
	
	LDI R16,9
	MOV CONT9,R16   ; CONT
START:

	IN REG_IN,INPUT ; PINA TO R10
	COM REG_IN
	MUL CONT9,REG_IN
	MOV OPD1_L,R0
	MOV OPD1_H,R1
	RCALL BIN16_BCD4DG
	RCALL SCAN_4LA
	RJMP START

BIN16_BCD4DG:

		LDI XH,HIGH(BCD_BUF) ; X TRỎ ĐỊA CHỈ ĐẦU BUFFER BCD
		LDI XL,LOW(BCD_BUF)
		LDI COUNT,4          
		LDI R17,0X00         ; NẠP GIÁ TRỊ ĐẦU LÀ 0
LP_CL:
		ST X+,R17			; XÓA BUFFER BỘ NHỚ
		DEC COUNT			
		BRNE LP_CL
		LDI OPD2,10         
DIV_NXT:
		RCALL DIV16_8       
		ST -X,OPD3           
		CPI OPD1_L,0         
		BRNE DIV_NXT         
		RET
DIV16_8:

	LDI COUNT,16  ; COUNT ĐẾM 16 LẦN BĂNG 16 BIT
	CLR OPD3      ; XÓA DƯ SỐ
SH_NXT:
	CLC			  ; C=0=BIT THƯƠNG SỐ
	LSL OPD1_L    ; DỊCH TRÁI SBC_L, BIT0=C=THƯƠNG SỐ
	ROL OPD1_H	  ; QUAY TRÁI SỐ BỊ CHIA 8 BIT CAO, C= BIT7
	ROL OPD3	  ; DỊCH BIT7 SBC CAO VÀO DƯ SỐ
	BRCS OV_C     ; TRÀN BIT C=1, CÒN CHIA ĐƯỢC
	SUB OPD3,OPD2 ; TRỪ DƯ SỐ VỚI SỐ CHIA
	BRCC GT_TH	  ; C=0 CÒN CHIA ĐƯỢC ; BỎ QUA LỆNH TIẾP THEO
	ADD OPD3,OPD2 ; C=1 KHÔNG CHIA ĐƯỢC NỮA , CỘNG LẠI SỐ CHIA VÀO SỐ DƯ
	RJMP NEXT
OV_C:
	SUB OPD3,OPD2 ; TRỪ DƯ SỐ VỚI SỐ CHIA
GT_TH:
	SBR OPD1_L,1  ; CHIA ĐƯỢC , THƯƠNG SỐ =1
NEXT:
	DEC COUNT	  ; ĐẾM SỐ LẦN DỊCH SBC
	BRNE SH_NXT   ; CHƯA ĐỦ TIẾP TỤC DỊCH BIT
	RET
;---------------------------------------------------------------------

;------------------------------------------
SCAN_4LA:     
	LDI	   R18, 4	         ;R18 số lần quét LED
	LDI	   R19, 0xF7         ;mã quét led anode
				             ;bắt đầu LED3 ( TRÁI QUA PHẢI)
							 	
	LDI XH,HIGH(BCD_BUF) ; X TRỎ ĐỊA CHỈ ĐẦU BUFFER BCD
	LDI XL,LOW(BCD_BUF)
LOOP:	
	LDI	   R17, 0xFF   ;làm tối các đèn
	OUT	   OUTLED, R17
	SBI	   SL_LED , nLE1      ;mở U5
	CBI	   SL_LED ,nLE1	    ;khóa U5  // XUẤT MÃ ĐK CHỌN LED // TẮT HẾT LED

	LD R17,X+
	RCALL GET_7SEG	    ;lấy mã 7 đoạn
	OUT   OUTLED, R17  ;xuất mã 7 đoạn
	SBI	 SL_LED ,nLE0	    ;mở U4    // ĐỂ XUẤT MÃ LED7 ĐOẠN
	CBI	 SL_LED ,nLE0	    ;khóa U4
	
	OUT	 OUTLED, R19  ;xuất mã quét anode LED 
	SBI	 SL_LED ,nLE1	    ;mở U5
	CBI	 SL_LED ,nLE1	    ;khóa U5   // XUẤT MÃ LÀM SÁNG LED

	RCALL	 DELAY_5MS	    ;tạo trễ 5ms sáng đèn
	SEC			            ;C=1 chuẩn bị quay trái GÁN VÀO LẦN KẾ TIẾP F7 THÀNH FE THÀNH FD.....
	ROR	 R19		        ;mã quét anode kế tiếp
	DEC	 R18		        ;đếm số lần quét
	BRNE	 LOOP	        ;thoát khi quét đủ 4 lần
	RET
;------------------------------------------------------------
; Define delay function using Timer0 in CTC mode with CLK/1024
DELAY_5MS:
		  PUSH R17
		  PUSH R16
		  LDI R16,39-1				; TOP
		  OUT OCR0A,R16				;GIA TRI SO SANH KENH A
		  LDI R16, (1 << WGM01) 
		  OUT TCCR0A,R16
		  LDI R16,(1 << CS02) | (1 << CS00)
		  OUT TCCR0B,R16			;SETUP CHE DO CTC (010), PRESCALER = 1024 
WAIT:
		    SBIS TIFR0,OCF0A		;chờ cờ OCF0A=1 báo kết quả so sánh kênh A 2/1MC
			RJMP WAIT				;cờ OCF0A=0 tiếp tục chờ 2MC
			SBI TIFR0,OCF0A			;OCF0A=1  xóa cờ OCF0A 2MC  
			POP R16
			POP R17
			RET
;-----------------------------------------
GET_7SEG:
	LDI	ZH, HIGH(TAB_7SA<<1)	
	LDI	ZL, LOW(TAB_7SA<<1)	
	ADD	R30, R17	;cộng offset vào ZL
	LDI	R17, 0
	ADC	R31, R17	;cộng carry vào ZH
	LPM	R17, Z		;lấy mã 7 đoạn	
	RET	
;-------------------------------------------
TAB_7SA:
     .DB 0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xf8, 0x80, 0x90 

