


; Ban đầu PC1 = 1
; 0-0.333ms: Timer1 NOR mode (n = -333, N = 8)
; TIMER1_OVF_ISR: Set PC2 = 1, chuyển sang mode CTC của Timer1, OCR0B = 20875-1(0.167ms), OCR0A = 62500-1 (5ms) (N=64)
; TIMER1_COMPB_ISR: Clear PC1 = 0
; TIMER1_COMPA_ISR: Clear PC2 = 0, chuyển sang Timer2 NOR mode, cấm ngắt Timer 1 trong quá trình Timer2 chạy NOR mode (N = 8, n = -167) (0.167 ms)
; TIMER2_OVF: Set PC1 = 1, chuyển sang Timer1 NOR mode, cấm ngắt Timer 2 trong quá trình Timer0 chạy

.INCLUDE <M324PDEF.INC>
.EQU F1 = 1     ; bit 1
.EQU F2 = 2     ; bit 2
.ORG    0
RJMP    MAIN
.ORG	0x16			; Địa chỉ vecto ngắt tràn Timer2
RJMP	TIMER2_OVF_ISR
.ORG	0x1A			; Địa chỉ vecto ngắt so sánh kênh A Timer1
RJMP	TIMER1_COMPA_ISR
.ORG	0x1C			; Địa chỉ vecto ngắt so sánh kênh B Timer1
RJMP	TIMER1_COMPB_ISR
.ORG	0x1E			; Địa chỉ vecto ngắt tràn Timer1
RJMP	TIMER1_OVF_ISR
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
;--------------------
    LDI     R16, (1<<F1)|(1<<F2)    
    OUT     DDRC, R16   ; PC1, PC1 output
    CBI     PORTC, F1   ; PC1 ban đầu bằng 0
    SBI     PORTC, F2   ; PC2 ban đầu bằng 1
	;----------------------------
    LDI     R16, HIGH(62500-1); Nạp giá trị cho OCR1A
    STS     OCR1AH, R16
    LDI     R16, LOW(62500-1)
    STS     OCR1AL, R16
    LDI     R16, HIGH(20875-1) ; Nạp giá trị cho OCR0B của Timer1
    STS     OCR1BH, R16
	LDI		R16, LOW(20875-1)
	STS		OCR1BL, R16
    LDI     R16, HIGH(-333) ; Nạp giá trị bộ đếm cho Timer 1 NOR mode, mode này chạy đầu tiên
    STS     TCNT1H, R16
    LDI     R16, LOW(-333)  
    STS     TCNT1L, R16
    LDI     R16, -167   ; Nạp giá trị cho TCNT2 mode NOR, mode này sau cùng
    STS     TCNT2, R16
START:  
    LDI     R16, 0x00   ; Timer1 chạy mode NOR
    STS     TCCR1A, R16
    LDI     R16, 0x02   ; N = 8, chạy Timer1 mode NOR trước
    STS     TCCR1B, R16
    SEI                     ; Cho phép ngắt toàn cục
    LDI     R16, (1<<TOIE1) ; Cho phép ngắt tràn Timer1
    STS     TIMSK1, R16
HERE:   RJMP    HERE        ; Lặp tại chỗ
;----------------------------------
TIMER1_OVF_ISR:
    SBI     PORTC, F2       ; Set PC2=1
    LDI     R16, 0x0B       ; Timer1 chạy mode CTC, N = 64 (00001011)
    STS     TCCR1B, R16     
    LDI     R16, (1<<OCIE1A)|(1<<OCIE1B)    ; Cho phép ngắt so sánh kênh A, B
    STS     TIMSK1, R16
    RETI
;-----------------------------------
TIMER1_COMPB_ISR:
    CBI     PORTC, F1       ; Clear PC1
    RETI
;--------------------------------------
TIMER1_COMPA_ISR:
    LDI     R16, 0x00
    STS     TCCR1B, R16      ; Ngừng Timer1
    CBI     PORTC, F1        ; Clear PC2=0
    LDS     R16, TIMSK1
    CBR     R16, (1<<OCIE0A)|(1<<OCIE0B)  ; Cấm ngắt so sánh kênh A, B Timer1 khi chạy Timer2
    STS     TIMSK1, R16
    LDI     R16, 0x04       ; Timer2 chạy N=64
    STS     TCCR2B, R16
    LDI     R16, (1<<TOIE2) ; Cho phép ngắt tràn Timer2
    STS     TIMSK2, R16
    RETI
;--------------------------------------
TIMER2_OVF_ISR:
    SBI     PORTC, F1    ; Set PC1=1
    LDI     R16, 0x00
    STS     TCCR2B, R16 ; Dừng Timer2
    LDI     R16, 0x00
    STS     TCCR1A, R16 ; Timer1 mode NOR
    LDI     R16, 0x03   ; Timer1 chạy N = 64
    STS     TCCR1B, R16
    LDS     R16, TIMSK1
    CBR     R16, (1<<TOIE2)    ; Cấm ngắt tràn Timer2 khi Timer1 chạy
    STS     TIMSK2, R16
    RETI
