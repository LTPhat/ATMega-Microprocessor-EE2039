; Viết chương trình xuất 0123 ra BARLED


.EQU OUTLED = PORTD
.EQU OUTLED_DDR = DDRD
.EQU SL_LED = PORTB
.EQU SL_LED_DDR = DDRB
.EQU nLE0 =PB0     ; CONTROL KEY LED
.EQU nLE1 =PB1     ; CONTROL SELECT LED

.ORG 0
RJMP MAIN
.ORG 40

MAIN:
	SER R16
	OUT OUTLED_DDR,R16		
	LDI R16,(1<<nLE0)|(1<<nLE1)
	OUT SL_LED_DDR,R16
START:
	RCALL SCAN_4LA
	RJMP START

;------------------------------------------
SCAN_4LA:     
	LDI	   R18, 4	    ; Số lần quét LED   
	LDI	   R19, 0xF7   ; Mã quét LED     				                
	CLR R20		    ; Giá trị in ra LED		
LOOP:	
	LDI	   R17, 0xFF   ; Ban đầu LED tắt
	OUT	   OUTLED, R17
	SBI	   SL_LED , nLE1   ; Mở chốt chọn LED
	CBI	   SL_LED ,nLE1	   ; Đóng chốt chọn LED
	
	MOV R17,R20		   ; 
	RCALL GET_7SEG	        ; Lấy mã 7 LED
	OUT   OUTLED, R17  	
	SBI	 SL_LED ,nLE0	    ; Mở chốt 	
	CBI	 SL_LED ,nLE0	    ; Đóng chốt
	INC R20                  ; Tăng giá trị hiển thị
	
	OUT	 OUTLED, R19  	    ; Xuất mã quét LED
	SBI	 SL_LED ,nLE1	    	
	CBI	 SL_LED ,nLE1	    
	RCALL	 DELAY_5MS	    	
	SEC			            
	ROR	 R19		        	
	DEC	 R18		        	
	BRNE	 LOOP	        	
	RET
;------------------------------------------------------------
; Define delay function using Timer0 in CTC mode with CLK/1024
DELAY_5MS:
		  PUSH R17
		  PUSH R16
		  LDI R16,39-1						  
		  OUT OCR0A,R16						  
		  LDI R16, (1 << WGM01) 
		  OUT TCCR0A,R16
		  LDI R16,(1 << CS02) | (1 << CS00)
		  OUT TCCR0B,R16			
WAIT:
		  SBIS TIFR0,OCF0A					
		  RJMP WAIT							
		  SBI TIFR0,OCF0A						
		  POP R16
		  POP R17
		  RET
;-----------------------------------------
GET_7SEG:
	LDI	ZH, HIGH(TAB_7SA<<1)	
	LDI	ZL, LOW(TAB_7SA<<1)	
	ADD	R30, R17		
	LDI	R17, 0
	ADC	R31, R17		
	LPM	R17, Z			
	RET	
;-------------------------------------------
TAB_7SA: .DB 0xC0, 0xF9, 0xA4, 0xB0
