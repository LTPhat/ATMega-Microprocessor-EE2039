; Viết chương trình liên tục thu dữ liệu 9 bit từ cổng nối tiếp USART0. Nếu bit thứ 9 của dữ liệu là bit 0 thì xuất 8 bit thấp dữ liệu ra portA, ngược lại xuất 8 bit thấp của dữ liệu ra portB


.ORG        0x00
RJMP        MAIN
.ORG        0x40
MAIN:
    LDI     R21, HIGH(RAMEND)
    OUT     SPH, R21
    LDI     R21, LOW(RAMEND)
    OUT     SPL, R21
    LDI     R21, 0xFF
    OUT     DDRA, R21       ; Port A xuất
    OUT     DDRB, R21       ; Port B xuất
    RCALL   USART_INIT
AGAIN:
    RCALL   USART_REC9BITS
    SBRC    R17, 0          ; Kiểm tra LSB của R17 có bằng 0 ?
    RJMP    LSB_1           ; Nếu không (LSB R17 = 1) chuyển tới LSB_1
    OUT     PORTA, R16      ; Nếu phải, xuất dữ liệu nhận được lưu trong R16 ra portA
    RJMP    AGAIN
LSB_1:
    OUT     PORTB, R16
    RJMP    AGAIN

USART_INIT:     ; Chương trình con khởi tạo USART0
    LDI     R16, (1 << RXEN0) | (1 << UCSZ02)   ; Cho phép thu, UCSZ02: UCSZ01: UCSZ00 = 111 để khởi tạo mode data 9 bits
    STS     UCSR0B, R16
    LDI     R16, (1 << UCSZ01) | (1 << UCSZ00)  ; Mode 9 bit data, no party, 
    STS     UCSR0C, R16
    LDI     R16, 0x00   
    STS     UBRR0H, R16
    LDI     R16, 51         ; Baud rate = 9600
    STS     UBRR0L, R16
    RET
USART_REC9BITS:     ; Chương trình con nhận 9 bits data
    ; Output: R17 (LSB chứa bit thứ 9), R16 (chứa 8 bit thấp data)
    LDI     R17, UCSR0A
    SBRS    R17, RXC0       ; Check cờ RXC0 = 1
    RJMP    USART_REC9BITS
    LDS     R17, UCSR0B     ; Bit 1 của UCSR0B chứa bit thứ 9 của data, load thanh ghi UCSR0B
    LDS     R16, UDR0       ; Load 8 bit data còn lại vào thanh ghi R16
    LSR     R17             ; Dịch phải, khi đó LSB của R17 chính là bit thứ 9 của data
    ANDI    R17, 0x01       ; R17 = 0000000(bit9)
    RET