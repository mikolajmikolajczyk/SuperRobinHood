; times32tablehi — lookup table: entry[i] = >(i * 64 + $2000), 14 entries
.repeat 14, i
    .byte >(i * 64 + $2000)
.endrepeat
