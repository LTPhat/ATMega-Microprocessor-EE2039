; Viết chương trình liên tục đọc điện áp Vin: 0-5 V ở ngõ vào ADC1, với độ phân giải < 5mV, xuất giá trị số ra portD (byte cao), portB (byte thấp)
; Điều kiện, sau mỗi 1 giây đọc ADC 1 lần dùng mô thức tự kích

; Chọn nguồn tạo tín hiệu kích khởi là cờ báo so sánh Timer1B OCF1B
; Delay 1s: Chọn prescaler N = 256, Timer1 B mode CTC4, n = 31250, giá trị nạp vào Timer1 = n - 1 = 31249

.EQU    ADC_PORT = PORTA
.EQU    ADC_DR = DDRA
.EQU    ADC_PIN = PINA
.EQU    TF = 31249         ; Giá trị đặt vào OCR
.ORG    0                   
RJMP    MAIN
.ORG    0x40
MAIN:
    LDI     R16, HIGH(RAMEND)
    OUT     SPH, R16
    LDI     R16, LOW(RAMEND)
    OUT     SPL, R16
    LDI     R16, 0xFF
    OUT     DDRD, R16       ; PortD output
    OUT     DDRB, R16       ; PortB output
    LDI     R16, 0x00
    OUT     ADC_DR, R16     ; Port A input
    LDI     R16, 0xFF
    LDI     ADC_PORT, R16   ; Port A pull-up resistor
    ;-----Set up Timer 1----------
    LDI     R16, HIGH(TF)   ; Nạp byte cao của TF vào OCR1AH
    STS     OCR1AH, R16
    STS     OCR1BH, R16
    LDI     R16, LOW(TF)
    STS     OCR1AL, R16
    STS     OCR1BL, R16
    LDI     R16, 0b00000000  ; WGM11: WGM10 = 00 
    STS     TCCR1A, R16
    LDI     R16, 0b00001100 ; WGM13:WG12 = 01, CS12:CS11:CS10 = 100, N = 256
    STS     TCCR1B, R16
    ;-----Set up ADC-----------
    LDI     R16, 0b10000001 ; Chọn Vref = AVcc, SE, ADC1
    STS     ADMUX, R16
    LDI     R16, 10100110   ; ADEN = 1, ADATE = 1, ADSC = 0 cho phép mức tự kích
    STS     ADCSRA, R16
    LDI     R16, 0b00000101 ; Cho phép nguồn kích khởi là cờ báo so sánh Timer1B OCF1B
    STS     ADCSRB, R16
    ;----MAIN----
START:
    LDS     R16, ADCSRA
    SBRS    R16, ADIF   ; Kiểm tra cờ báo chuyển đổi xong ADIF
    RJMP    START
    STS     ADCSRA, R16 ; Xóa cờ ADIF
    LDS     R17, ADCL   ; Lấy byte thấp trước
    OUT     PORTB, R17
    LDS     R17, ADCH
    OUT     PORTD, R17
    IN      R17, TIFR1
    OUT     TIFR1, R17  ; Xóa cờ TIFR1 nếu OCF1A
    RJMP    START
    
