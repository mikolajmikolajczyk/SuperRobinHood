; runtablelo — acceleration ramp: 47 entries of i * 5 (= 256/48), plus trailing 0
.repeat 47, i
    .byte (i * 5) & $FF
.endrepeat
    .byte $00
