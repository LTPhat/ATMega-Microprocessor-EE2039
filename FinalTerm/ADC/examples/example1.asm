; Viết chương trình liên tục đọc điện áp Vin: 0-5 V ở ngõ vào ADC1, với độ phân giải < 5mV, xuất giá trị số ra portD (byte cao), portB (byte thấp)
; Chọn Vref = 5V, độ phân giải RES = Vref/2^10 = 4.88mV < 5mV (thỏa mãn)

.EQU    ADC_PORT = PORTA
.EQU    ADC_DR = DDRA
.EQU    ADC_PIN = PINA
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
    OUT     ADC_DR, R16     ; PortA input
    LDI     R16, 0xFF
    LDI     ADC_PORT, R16   ; Port A pull-up resistor
    LDI     R16, 0b01000001 ; Vref = Acc = 5V, SE, ADC1, dịch phải dữ liệu
    STS     ADMUX, R16
    LDI     R16, 0b10000110 ; ADEN = 1, prescale = 64, f = fosc/64 = 125kHz
    STS     ADCSRA, R16
START:
    LDS     R16, ADCSRA
    ORG     R16, (1 << ADSC)    ; Bit ADSC = 1, bắt đầu chuyển đổi
    STS     ADCSRA, R16
WAIT:
    LDS     R16, ADCSRA
    SBRS    R16, ADIF           ; Check cờ ADIF = 1
    RJMP    WAIT
    STS     ADCSRA, R16         ; Xóa cờ ADIF bằng cách ghi 1 vào bit ADIF
    LDS     R17, ADCL           ; Lấy byte thấp của kết quả
    OUT     PORTB, R17
    LDS     R17, ADCH
    OUT     PORTD, R17
    RJMP    START
