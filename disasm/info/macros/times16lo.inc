; times16lo — lookup table: entry[i] = <(i * 16), 216 entries
.repeat 216, i
    .byte <(i * 16)
.endrepeat
