; times14tablehi — lookup table: entry[i] = >(i * 14)
times14tablehi_1 := times14tablehi + 1
.repeat 256, i
    .byte >(i * 14)
.endrepeat
