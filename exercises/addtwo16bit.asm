; Cộng hai số 16 bit: số thứ nhất là nội dung của cặp ô nhớ SRAM có địa chỉ $200 và $201; 
; Số thứ hai là nội dung ô nhớ Flash có địa chỉ là $100
; Kết quả là số 16 bit cất vào cặp ô nhớ SRAM có địa chỉ là $202, $203
; Biết trong mỗi cặp ô nhớ SRAM thì ô nhớ có địa chỉ cao hơn chứa byte cao hơn.

LDS     R16, $200;  load nội dung của ô nhớ có địa chỉ $200
LDS     R17, $201;

LDI     ZL, LOW($100 << 1)
LDI     ZH, HIGHT($100 << 1) ; load 2 byte biễu diễn số thứ hai vào thanh ghi con trỏ Z

LPM     R18, Z+; R18 chứa bit thấp của số thứ hai
LPM     R19, Z; R19 chứa bit cao của số thứ hai

ADD     R16, R18; cộng hai byte thấp, không cờ C
ADC     R17, R19; cộng hai byte cao, có cờ nhớ C là kết quả từ việc cộng hai byte thấp
STS     $202, R16; lưu kết quả tổng hai byte thấp vào ô nhớ có địa chỉ $202;
STS     $203, R17; lưu kết quả tổng hai byte cao