; times32tablelo — lookup table: entry[i] = <(i * 64), 14 entries
.repeat 14, i
    .byte <(i * 64)
.endrepeat
