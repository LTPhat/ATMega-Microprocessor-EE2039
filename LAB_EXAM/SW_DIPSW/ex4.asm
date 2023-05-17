.EQU T_HIGH = 249
.DEF OUTPORT = PORTC
XUNG25:
    SBI     DDRC, 0
    LDI     R22, 3
    LDI     R16, 249 
    OUT     OCR0A, R16
    LDI     R16, 0x02   ; CTC
    OUT     TCCR0A, R16
LOOP:
    SBI     PORTC, 0
    RCALL   DELAY_TO
    CBI     PORTC
LOOP1:
    RCALL   DELAY_TO
    DEC     R22
    BRNE    LOOP1
    RET
;--------------------------------
DELAY_TO:
    LDI     R16, 0x02   ; N = 8
    OUT     TCCR0B, R16
WAIT:
    IN      R17, TIFR0
    SBRS    R17, OCF0A
    RJMP    WAIT
    OUT     TIFR0, R17
    RET


.EQU T_HIGH = 249
.DEF OUTPORT = PORTC
XUNG75:
    SBI     DDRC, 0
    LDI     R22, 3
    LDI     R16, 249 
    OUT     OCR0A, R16
    LDI     R16, 0x02   ; CTC
    OUT     TCCR0A, R16
LOOP:
    SBI     PORTC, 0
    RCALL   DELAY_TO
    DEC     R22
    BRNE    LOOP
    CBI     PORTC
    RCALL   DELAY_TO
    RET
;--------------------------------
DELAY_TO:
    LDI     R16, 0x02   ; N = 8
    OUT     TCCR0B, R16
    IN      R17, TIFR0
    SBRS    R17, OCF0A
    RJMP    DELAY_TO
    OUT     TIFR0, R17
    REI



;--------------------------------------------------------------------------------

MAIN:
    RCALL   USART_INIT
AGAIN:
    RCALL   USART_REC9BITS
    MOV     R20, R16
    CPI     R16, 0x00
    BREQ    AGAIN
    SBRS    R17, 0
    RJMP    XUAT_XUNG25
    RCALL   LOOP_XUNG75
    RJMP    AGAIN
XUAT_XUNG25: 
    RCALL   LOOP_XUNG25
    RJMP    AGAIN


;------------------------------------
LOOP_XUNG25:   
    RCALL   XUNG25
    DEC     R20
    BRNE    LOOP_XUNG25
    RET
    
LOOP_XUNG75:   
    RCALL   XUNG75
    DEC     R20
    BRNE    LOOP_XUNG75
    RET

USART_INIT:                                     ; Chương trình con khởi tạo USART0
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
    LDS     R17, UCSR0A
    SBRS    R17, RXC0       ; Check cờ RXC0 = 1
    RJMP    USART_REC9BITS
    LDS     R17, UCSR0B     ; Bit 1 của UCSR0B chứa bit thứ 9 của data, load thanh ghi UCSR0B
    LDS     R16, UDR0       ; Load 8 bit data còn lại vào thanh ghi R16
    LSR     R17             ; Dịch phải, khi đó LSB của R17 chính là bit thứ 9 của data
    ANDI    R17, 0x01       ; R17 = 0000000(bit9)
    RET