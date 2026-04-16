.segment "HEADER"
    .byte $4E, $45, $53, $1A ; "NES" + MS-DOS EOF
    .byte $04               ; 4 x 16 KiB PRG ROM
    .byte $00               ; 0 x 8 KiB CHR ROM (CHR-RAM)
    .byte $71               ; Flags 6: vertical mirroring, mapper low nibble
    .byte $48               ; Flags 7: mapper high nibble (NES 2.0)
    .byte $00, $00, $00, $07, $02, $00, $00, $01
