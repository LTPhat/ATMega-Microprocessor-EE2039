; Viết chương trình tạo xung ở hai ngõ ra ở PC0 và PC1 như hình.
; Phân tích: Có 4 ngắt trong 1 chu kỳ
; Dùng Timer2 (CTC mode chỉ dùng so sánh kênh A) và Timer0 chuyển đổi giữa hai mode CTC và NOR

; 0-2ms: Timer0 NOR mode (n = -250, N = 64)
; TIMER0_OVF_ISR: Set PC0 = 1, chuyển sang mode CTC của Timer0, OCR0B = 124 (1ms), OCR0A = 249 (2ms)
; TIMER0_COMPB_ISR: Clear PC0 = 0, 
; TIMER0_COMPA_ISR: Set PC1 = 1, chuyển sang Timer2 NOR mode, cấm ngắt Timer 0 trong quá trình Timer2 chạy NOR mode
; TIMER2_COMPA: Clear PC1 = 0, chuyển sang Timer0 NOR mode, cấm ngắt Timer 2 trong quá trình Timer0 chạy

.INCLUDE <M324PDEF.INC>
.EQU F0 = 0     ; bit 0
.EQU F1 = 1     ; bit 1
.ORG    0
RJMP    MAIN
.ORG    0x12    ; TIMER2_COMPA_ISR
RJMP    TIMER2_COMPA_ISR
.ORG    0x20    ; TIMER0_COMPA_ISR
RJMP    TIMER0_COMPA_ISR
.ORG    0x22    ; TIMER0_COMPA_ISR
RJMP    TIMER0_COMPB_ISR
.ORG    0x24    ; TIMER0_OVF_ISR
RJMP    TIMER0_OVF_ISR
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
;--------------------
    LDI     R16, (1<<F0)|(1<<F1)    
    OUT     DDRC, R16   ; PC0, PC1 output
    CBI     PORTC, F0   ; PC0 ban đầu bằng 0
    CBI     PORTC, F1   ; PC1 ban đầu bằng 0
    LDI     R16, 249    ; Nạp giá trị cho OCR0A
    OUT     OCR0A, R16
    LDI     R16, 124    ; Nạp giá trị cho OCR0B của Timer0
    OUT     OCR0B, R16
    OUT     OCR2A, R16  ; Nạp giá trị cho OCR2A của Timer 2
    LDI     R16, -250   ; Nạp giá trị cho TCNT0 mode NOR, mode này chạy đầu tiên
    OUT     TCNT0, R16
START:  
    LDI     R16, 0x02   ; Timer2 mode CTC
    STS     TCCR2A, R16
    LDI     R16, 0x00   ; Timer 0 mode NOR
    OUT     TCCR0A, R16
    LDI     R16, 0x03   ; N = 64, chạy Timer0 mode NOR trước
    OUT     TCCR0B, R16
    SEI                 ; Cho phép ngắt toàn cục
    LDI     R16, (1<<TOIE0) ; Cho phép ngắt tràn Timer0
    STS     TIMSK0, R16
HERE:   RJMP    HERE        ; Lặp tại chỗ
;----------------------------------
TIMER0_OVF_ISR:
    SBI     PORTC, F0       ; Set PC0=1
    LDI     R16, 0x02       ; Timer0 mode CTC
    OUT     TCCR0A, R16     
    LDI     R16, 0x03       ; N = 64, chạy Timer0
    OUT     TCCR0B, R16
    LDI     R16, (1<<OCIE0A)|(1<<OCIE0B)    ; Cho phép ngắt so sánh kênh A, B
    STS     TIMSK0, R16
    RETI
;-----------------------------------
TIMER0_COMPB_ISR:
    CBI     PORTC, F0       ; Clear PC0
    RETI
;--------------------------------------
TIMER0_COMPA_ISR:
    LDI     R16, 0x00
    OUT     TCCR0B, R16     ; Ngừng Timer0
    SBI     PORC, F1        ; Set PC1=1
    LDS     R16, TIMSK0
    CBR     R16, (1<<OCIE0A)|(1<<OCIE0B)  ; Cấm ngắt so sánh kênh A, B Timer0 khi chạy Timer2
    STS     TIMSK0, R16
    LDI     R16, 0x04       ; Timer2 chạy N=64
    STS     TCCR2B, R16
    LDI     R16, (1<<OCIE2A) ; Cho phép ngắt kênh A Timer2
    STS     TIMSK2, R16
    RETI
;--------------------------------------
TIMER2_COMPA_ISR:
    CBI     PORTC, 1    ; Clear PC0
    LDI     R16, 0x00
    STS     TCCR2B, R16 ; Dừng Timer2
    LDI     R16, 0x00
    OUT     TCCR0A, R16 ; Timer0 mode NOR
    LDI     R16, 0x03   ; Timer0 chạy N = 64
    OUT     TCCR0B, R16
    LDS     R16, TIMSK2
    CBR     R16, (1<<OCIE2A)    ; Cấm ngắt Timer2 khi Timer0 chạy
    STS     TIMSK2, R16
    RETI

    