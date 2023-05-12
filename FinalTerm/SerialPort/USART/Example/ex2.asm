; Viết chương trình thu chuỗi ký tự từ cổng USART0, cộng thêm $05 vào mỗi byte và lưu vào SRAM bắt đầu từ địa chỉ $100. Quá trình thu kết thúc khi gặp ký tự $0D. Sau khi thu phát ra lại cổng USART0 các giá trị vừa chuyển đổi xong
; Cho baudrate = 9600, 8bit data, 1 stopbit, Fosc = 8MHz, no party
; SỬ DỤNG NGẮT


.INCLUDE <M324PDEF.INC>
.DEF DATA_RX = R18
.DEF DATA_TX = R19
.ORG    0
RJMP    MAIN
.ORG    0x28                ; Địa chỉ vecto ngắt thu xong
RJMP    USART_RECEIVER_CHAR_ISR
.ORG    0x2A
RJMP    USART_SEND_CHAR_ISR ; Địa chỉ vecto ngắt bộ đệm phát trống, UDER0 = 1
.ORG    0x40
MAIN:
    RCALL USART_INIT
    LDI     XH, $01
    LDI     XL, $00     ; Load địa chỉ đầu SRAM
    SEI                 ; Cho phép ngắt cục bộ
HERE: RJMP HERE

;------------------------
USART_INIT:
	LDI R16, (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)	;Cho phép thu/ phát và ngắt thu
	STS UCSR0B, R16

	LDI R16, $00
	STS UBRR0H, R16
	LDI R16, 51				;Set baudrate to 9600bps with 8Mhz clock
	STS UBRR0L, R16

	LDI R16, (1<<UCSZ01) | (1<<UCSZ00)	;8 bit data, no parity, 1 stop bit
	STS UCSR0C, R16
	RET
;--------------------------
USART_RECEIVER_CHAR_ISR:
    LDS     DATA_RX, UDR0  ; Đọc data thu được vào R18
    MOV     R20, DATA_RX
    CPI     DATA_RX, $0D
    BRNE    NEXT
    ST      X, DATA_RX
    MOV     R29, XH     ; Lưu địa chỉ thu cuối cùng vào con trỏ Y
    MOV:    R28, XL
    LDI     XH, $01     ; Load lại địa chỉ SRAM đầu để phát dữ liệu đã thu
    LDI     Xl, $00
    LDS     R16, UCSR0B
    CBR     R16, (1<<RXCIE0)    ; Cấm ngắt thu
    ORI     R16, (1<<UDRIE0)    ; Cho phép ngắt bộ đệm phát trống
    STS     UCSR0B, R16
    RJMP    EXIT_USART_RECEIVER_CHAR_ISR
NEXT:  
    LDI     R16, 0x05
    ADD     R20, R16
    ST      X+, R20
EXIT_USART_RECEIVER_CHAR_ISR: RETI
;---------------------------
USART_SEND_CHAR_ISR:        ; Vecto ngắt bộ đệm phát trống chưa phát -> Nên phải phát 
    LD      DATA_RX, X+     ;Load data nhận từ SRAM
    STS     UDR0, DATA_TX   ; Phát ký tự
    CP      R26, R28        ; So sánh YL = XL
    BRNE    EXIT_USART_SEND_CHAR_ISR
    CP      R27, R19        ; Khi Yl=XL, tiếp tục so sánh YH = XH
    BRNE    EXIT_USART_SEND_CHAR_ISR
    LDI     XH, $01         ; Khi X = Y phát xong, load lại địa chỉ đầu SRAM chuẩn bị phát
    LDI     XL, $00
    LDS     R16, UCSR0B
    CBR     R16, (1<<UDRIE0); Cấm ngắt bộ đệm phát trống
    ORI     R16, (1<<RXCIE0); Cho phép ngắt thu
    STS     UCSR0B, R16
EXIT_USART_SEND_CHAR_ISR: RETI


