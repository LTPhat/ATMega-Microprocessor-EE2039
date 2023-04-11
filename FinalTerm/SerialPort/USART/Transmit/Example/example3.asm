; Viết chương trình phát chuỗi "VI XỬ LÝ" ra cổng nối tiếp USART1.
; 8 bit data, 2 stop bit, bit kiểm tra lẻ, baud rate 38.4K, fosc = 8MHz


.EQU    NUMB = 9
.DEF    DATA_TX = R18       ; Thanh ghi chứa dữ liệu phát
.DEF    LOOP_COUNT = R19    ; Thanh ghi chứa số vòng lặp
.ORG    0
RJMP    MAIN
.ORG    0x40
MAIN:
    LDI     ZL, LOW(TABLE << 1)     ; Byte thấp địa chỉ bảng
    LDI     ZH, HIGH(TABLE << 1)    ; Byte cao
    LDI     LOOP_COUNT, NUMB               ; Khởi tạo số vòng lặp
    CALL    USART_INIT
LOOP:
    LPM     DATA_TX, Z+
    CALL    USART_TRANS
    DEC     LOOP_COUNT
    BRNE    LOOP
    RJMP    MAIN

USART_INIT:
    LDI     R16, (1 << TXEN1)       ; Transmit enable
    STS     UCSR1B, R16
    LDI     R16, (1 << UPM11)| (1 << UPM10) | (1 << USBS1) | (1 << UCSZ11) | (1 << UCSZ10) ; UPM1[1:0] = 11 -> Party lẻ, USBS->2 stop bit, UCSZ11: UCSZ10 = 11 -> 8 bit data
    STS     UCSR1C, R16
    LDI     R16, 0x00
    STS     UBRR1H, R16
    LDI     R16, 12                 ; Baud rate = 38.4K, n = 12
    STS     UBRR1L, R16 
    RET
USART_TRANS:
    LDI     R17, UCSR1A
    SBRS    R17, UDRE1              ; Kiểm tra bit UDRE1 = 1
    RJMP    USART_TRANS
    STS     UDR1, DATA_TX
    RET
TABLE: .DB "VI XU LY"

