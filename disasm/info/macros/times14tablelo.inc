; times14tablelo — lookup table: entry[i] = <(i * 14)
times14tablelo_1 := times14tablelo + 1
.repeat 256, i
    .byte <(i * 14)
.endrepeat
