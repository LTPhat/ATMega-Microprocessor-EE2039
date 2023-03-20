; Viết chương trình nhập dữ liệu là mã ký tự ASCII từ port A. 
; Nếu dữ liệu là mã ASCII của ký tự viết in hoa (41H - 51H) thì đổi sang mã ASCII của ký tự chữ viết thường tương ứng (61H - 71H) và xuất ra port C
; Nếu dữ liệu là mã ASCII chữ viết thường thì xuất dữ liệu đó ra port C
; Nếu không phải hai trường hợp trên thì xuất giá trị 0 ra port C


; ------- $41   $51 ------- $61   $71
;  a          b        c        d     e
 
.ORG    0
LDI     R16, $00
OUT     DDRA, R16       ;Port A ở chế độ nhập
LDI     R16, $FF
OUT     DDRC, R16       ;Port C ở chế độ xuất

LAP:    IN      R16, PINA 
        CPI     R16, $41
        BRLO    DELETE      ;Nếu R16 nhỏ hơn $41, xuất giá trị 0 và kết thúc
        CPI     R16, $5B
        BRLO    UPPER_CASE  ;Nếu $41 <= R16 < $5B thì chuyển tù in hoa sang in thường
        CPI     R16, $61
        BRLO    DELETE      ;Nếu $52 <= R16 < $7B, xuất giá trị 0 và kết thúc
        CPI     R16, $7B
        BRSH    DELETE      ;Nếu $7B <= R16, xuất giá trị 0 và kết thúc
DELETE:     CLR     R16
            RJMP    OUTPUT
OUTPUT:     OUT     PORTC, R16
            RJMP    LAP
UPPER_CASE: LDI     R17, $20
            ADD     R16, R17 
            RJMP    OUTPUT   