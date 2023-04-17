; Viết chương trình tạo chuỗi xung vuông đối xứng chu kỳ 24uS xuất ra PB1 sử dụng ngắt so sánh kênh A của Timer 0
; Lập trình sao cho có thể xuất xung ra với chu kỳ bé nhất

; Bắt ngõ vào Timer: Khi TCNTn = OCRnA/B, xung đếm kế tiếp phần cứng nạp cờ OCFnA/B = 1 là tín hiệu báo ngắt timer
; Cho phép ngắt Timer: Đặt bit OCIEnA/B = 1 (Thanh ghi TIMSKn)
; Mode CTC, N = 1, nạp OCR0A = (n-1) = (96-1) = 95


.EQU    P_OUT   = 1
.ORG    0
RJMP    MAIN
.ORG    0x20        ; Điểm vào ISR so sánh kênh A   (3MC)
EOR     R17, R16    ; Đảo bit P_out     1MC, 2byte
OUT     PORTB, R17  ; Xuất ra portB     1MC, 2byte
RETI
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16 
    LDI     R16, (1 << P_OUT)
    OUT     DDRB, R16
    LDI     R17, 95
    OUT     OCR0A, R17      ; Nạp giá trị so sánh
    SEI                     ; Set cờ I = 1, ngắt toàn cục
    LDI     R17, (1 << OCIE0A)  ; Cho phép ngắt so sánh kênh A
    STS     TIMSK0, R17
    LDI     R17, 0x02       ; WGM2:WGM0 = 010 -> CTC mode
    OUT     TCCR0A, R17 
    LDI     R17, 0x01       ; Timer0 chạy, N = 1
    OUT     TCCR0B, R17
    LDI     R17, 0          ; Ban đầu set bit 0
START:      RJMP    START   ;(2MC)

; Thời gian thực thi lệnh hiện hành và cả ISR là 2 + 9 = 11 MC, nên giá trị nạp tối thiếu OCR0A = 12
; Do đó chu kỳ xung ra tối thiểu là T = (13x2)x0.125 = 3.25uS
