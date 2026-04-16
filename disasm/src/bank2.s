; da65 V2.18 - N/A
; Created:    2026-04-12 21:16:35
; Input file: banks/bank2.bin
; Page:       1


        .setcpu "6502"

; ----------------------------------------------------------------------------
cm_frames       := $0000
control0        := $0001
control1        := $0002
interon         := $0003
seed            := $0004
pad             := $0007
debounce        := $0008
y_scroll        := $0009
x_scroll        := $000A
vrampointer     := $000C
bankno          := $000D
spriteblockpointer:= $000E
blockpointer    := $000F
counter         := $0010
toplevvar1      := $0011
toplevvar2      := $0012
toplevvar3      := $0013
toplevvar4      := $0014
toplevvar5      := $0015
toplevvar6      := $0016
toplevvar7      := $0017
toplevvar8      := $0018
toplevvar9      := $0019
toplevvar10     := $001A
address         := $001B
address2        := $001F
rom_check_zp    := $0020
address5        := $0025
address9        := $002D
temp1           := $0032
temp4           := $0035
scrxl           := $003B
scrxh           := $003C
attripointer    := $003E
blockattri      := $003F
mappointer      := $0040
pause           := $0044
palversion      := $0046
scrolldir       := $0047
lives           := $0048
heartcounter    := $004A
noofparas       := $004B
extravarpointer := $004C
heartxl         := $004F
hearty          := $0051
set_bank_zp     := $0086
normalvars      := $0300
cm_flags        := $07FE
cm_powerup      := $07FF
_control0       := $2000
_control1       := $2001
_spriteaddr     := $2003
_scrollcon      := $2005
_vramaddr       := $2006
_vramdata       := $2007
_dmafunc        := $4014
_kpreg1         := $4016
_kpreg2         := $4017
LF1E0           := $F1E0
_bank           := $FFFE
; ----------------------------------------------------------------------------

.segment        "BANK_2": absolute

; CM_LOGO - Codemasters logo intro routine
; ==========================================================================
; CMLOGO.ROU
; ==========================================================================
cm_logo:ldx     #$00                            ; 8000 A2 00                    ..
        stx     _control0                       ; 8002 8E 00 20                 .. 
        stx     _control1                       ; 8005 8E 01 20                 .. 
; Clear zero page and fill sprite page ($0300) with $FF
cm_init_loop:  lda     #$00                            ; 8008 A9 00                    ..
        sta     cm_frames,x                     ; 800A 95 00                    ..
        lda     #$FF                            ; 800C A9 FF                    ..
        sta     normalvars,x                    ; 800E 9D 00 03                 ...
        inx                                     ; 8011 E8                       .
        bne     cm_init_loop                           ; 8012 D0 F4                    ..
        ldx     #$97                            ; 8014 A2 97                    ..
        lda     cm_flags                        ; 8016 AD FE 07                 ...
        and     #$3F                            ; 8019 29 3F                    )?
        cmp     #$04                            ; 801B C9 04                    ..
        ora     #$40                            ; 801D 09 40                    .@
        bcs     cm_powerup_detect                           ; 801F B0 05                    ..
        cpx     cm_powerup                      ; 8021 EC FF 07                 ...
        beq     cm_reset_handler                           ; 8024 F0 05                    ..
cm_powerup_detect:  stx     cm_powerup                      ; 8026 8E FF 07                 ...
        lda     #$00                            ; 8029 A9 00                    ..
cm_reset_handler:  sta     cm_flags                        ; 802B 8D FE 07                 ...
        ldx     #$04                            ; 802E A2 04                    ..
cm_setup_init:  lda     cm_inittab,x                    ; 8030 BD 65 83                 .e.
        sta     interon,x                       ; 8033 95 03                    ..
        dex                                     ; 8035 CA                       .
        bpl     cm_setup_init                           ; 8036 10 F8                    ..
        jsr     cm_characters                   ; 8038 20 23 84                  #.
        jmp     cm_sfx_setup                           ; 803B 4C 95 80                 L..

; CLS - clear nametable
; ----------------------------------------------------------------------------
        asl     rom_check_zp                    ; 803E 06 20                    . 
        ldx     #$00                            ; 8040 A2 00                    ..
        stx     _vramaddr                       ; 8042 8E 06 20                 .. 
        ldy     #$10                            ; 8045 A0 10                    ..
        txa                                     ; 8047 8A                       .
cm_cls_loop:  sta     _vramdata                       ; 8048 8D 07 20                 .. 
        dex                                     ; 804B CA                       .
        bne     cm_cls_loop                           ; 804C D0 FA                    ..
        dey                                     ; 804E 88                       .
        bne     cm_cls_loop                           ; 804F D0 F7                    ..
; Print 'AB' (Codemasters logo tilemap)
cm_ab_print:  lda     #$22                            ; 8051 A9 22                    ."
        sta     _vramaddr                       ; 8053 8D 06 20                 .. 
        lda     cm_abmap,x                      ; 8056 BD D9 83                 ...
        sta     _vramaddr                       ; 8059 8D 06 20                 .. 
        inx                                     ; 805C E8                       .
        ldy     #$15                            ; 805D A0 15                    ..
cm_ab_inner:  lda     cm_abmap,x                      ; 805F BD D9 83                 ...
        sta     _vramdata                       ; 8062 8D 07 20                 .. 
        inx                                     ; 8065 E8                       .
        dey                                     ; 8066 88                       .
        bne     cm_ab_inner                           ; 8067 D0 F6                    ..
        cpx     #$3F                            ; 8069 E0 3F                    .?
        bcc     cm_ab_print                           ; 806B 90 E4                    ..
        ; 'AB' attribute patch
        lda     #$23                            ; 806D A9 23                    .#
        sta     _vramaddr                       ; 806F 8D 06 20                 .. 
        lda     #$E0                            ; 8072 A9 E0                    ..
        sta     _vramaddr                       ; 8074 8D 06 20                 .. 
        ldy     #$03                            ; 8077 A0 03                    ..
        lda     #$50                            ; 8079 A9 50                    .P
cm_ab_attr_outer:  ldx     #$08                            ; 807B A2 08                    ..
cm_ab_attr_inner:  sta     _vramdata                       ; 807D 8D 07 20                 .. 
        dex                                     ; 8080 CA                       .
        bne     cm_ab_attr_inner                           ; 8081 D0 FA                    ..
        lda     #$55                            ; 8083 A9 55                    .U
        dey                                     ; 8085 88                       .
        bne     cm_ab_attr_outer                           ; 8086 D0 F3                    ..
        ldy     #$23                            ; 8088 A0 23                    .#
        sty     _vramaddr                       ; 808A 8C 06 20                 .. 
        ldy     #$CD                            ; 808D A0 CD                    ..
        sty     _vramaddr                       ; 808F 8C 06 20                 .. 
        sta     _vramdata                       ; 8092 8D 07 20                 .. 
; SFX setup - silence all APU channels
cm_sfx_setup:  ldx     #$13                            ; 8095 A2 13                    ..
        lda     #$00                            ; 8097 A9 00                    ..
cm_sfx_clear:  sta     $4000,x                         ; 8099 9D 00 40                 ..@
        dex                                     ; 809C CA                       .
        bpl     cm_sfx_clear                           ; 809D 10 FA                    ..
        lda     #$80                            ; 809F A9 80                    ..
        sta     _control0                       ; 80A1 8D 00 20                 .. 
        ; Main loop - wait for vblank then process frame
        jsr     cm_vblank                           ; 80A4 20 5E 81                  ^.
        lda     #$00                            ; 80A7 A9 00                    ..
        sta     $4015                           ; 80A9 8D 15 40                 ..@
        ldx     cm_frames                       ; 80AC A6 00                    ..
        txa                                     ; 80AE 8A                       .
        ; Noise freq - alternates each frame
        and     #$01                            ; 80AF 29 01                    ).
        sta     vrampointer                     ; 80B1 85 0C                    ..
        cpx     #$18                            ; 80B3 E0 18                    ..
        bcs     cm_noise_post                           ; 80B5 B0 04                    ..
        txa                                     ; 80B7 8A                       .
        lsr     a                               ; 80B8 4A                       J
        bpl     cm_nmi_write                           ; 80B9 10 0E                    ..
cm_noise_post:  txa                                     ; 80BB 8A                       .
        lsr     a                               ; 80BC 4A                       J
        lsr     a                               ; 80BD 4A                       J
        lsr     a                               ; 80BE 4A                       J
        tay                                     ; 80BF A8                       .
        lda     cm_quart_nextrow,y                         ; 80C0 B9 5E 83                 .^.
        cmp     #$02                            ; 80C3 C9 02                    ..
        bcs     cm_nmi_write                           ; 80C5 B0 02                    ..
        adc     vrampointer                     ; 80C7 65 0C                    e.
cm_nmi_write:  sta     $400E                           ; 80C9 8D 0E 40                 ..@
        ldy     #$00                            ; 80CC A0 00                    ..
        sty     $4003                           ; 80CE 8C 03 40                 ..@
        dey                                     ; 80D1 88                       .
        sty     $4007                           ; 80D2 8C 07 40                 ..@
        sty     $400F                           ; 80D5 8C 0F 40                 ..@
        lda     #$15                            ; 80D8 A9 15                    ..
        sta     $400C                           ; 80DA 8D 0C 40                 ..@
        cpx     #$18                            ; 80DD E0 18                    ..
        bcc     cm_precircle_sfx                           ; 80DF 90 23                    .#
        lda     #$30                            ; 80E1 A9 30                    .0
        sta     $4002                           ; 80E3 8D 02 40                 ..@
        ; Fading saw ping - volume ramps down over time
        txa                                     ; 80E6 8A                       .
        sec                                     ; 80E7 38                       8
        sbc     #$10                            ; 80E8 E9 10                    ..
        eor     #$FF                            ; 80EA 49 FF                    I.
        lsr     a                               ; 80EC 4A                       J
        lsr     a                               ; 80ED 4A                       J
        cmp     #$30                            ; 80EE C9 30                    .0
        bcs     cm_saw_vol                           ; 80F0 B0 02                    ..
        lda     #$00                            ; 80F2 A9 00                    ..
cm_saw_vol:  ora     #$90                            ; 80F4 09 90                    ..
        sta     $4000                           ; 80F6 8D 00 40                 ..@
        cpx     #$38                            ; 80F9 E0 38                    .8
        bcc     cm_timeout_check                           ; 80FB 90 26                    .&
        lda     #$10                            ; 80FD A9 10                    ..
        sta     $400C                           ; 80FF 8D 0C 40                 ..@
        bne     cm_timeout_check                           ; 8102 D0 1F                    ..
; Pre-circle: rising saw waves on pulse channels 1+2
cm_precircle_sfx:  txa                                     ; 8104 8A                       .
        lsr     a                               ; 8105 4A                       J
        ora     #$90                            ; 8106 09 90                    ..
        sta     $4000                           ; 8108 8D 00 40                 ..@
        sta     $4004                           ; 810B 8D 04 40                 ..@
        txa                                     ; 810E 8A                       .
        asl     a                               ; 810F 0A                       .
        asl     a                               ; 8110 0A                       .
        asl     a                               ; 8111 0A                       .
        sta     $4002                           ; 8112 8D 02 40                 ..@
        sta     $4006                           ; 8115 8D 06 40                 ..@
        lda     #$02                            ; 8118 A9 02                    ..
        clc                                     ; 811A 18                       .
        adc     vrampointer                     ; 811B 65 0C                    e.
        sta     $4003                           ; 811D 8D 03 40                 ..@
        sta     $4007                           ; 8120 8D 07 40                 ..@
; Timeout check - exit after animation completes
cm_timeout_check:  lda     cm_frames                       ; 8123 A5 00                    ..
        beq     cm_timeout                           ; 8125 F0 23                    .#
        bit     cm_flags                        ; 8127 2C FE 07                 ,..
        bvc     cm_loop_jmp                           ; 812A 50 1B                    P.
        cmp     #$40                            ; 812C C9 40                    .@
        bcc     cm_loop_jmp                           ; 812E 90 17                    ..
        ldy     #$01                            ; 8130 A0 01                    ..
        sty     _kpreg1                         ; 8132 8C 16 40                 ..@
        dey                                     ; 8135 88                       .
        sty     _kpreg1                         ; 8136 8C 16 40                 ..@
        ldy     #$08                            ; 8139 A0 08                    ..
cm_joypad_loop:  lda     _kpreg1                         ; 813B AD 16 40                 ..@
        ora     _kpreg2                         ; 813E 0D 17 40                 ..@
        lsr     a                               ; 8141 4A                       J
        bcs     cm_timeout                           ; 8142 B0 06                    ..
        dey                                     ; 8144 88                       .
        bne     cm_joypad_loop                           ; 8145 D0 F4                    ..
cm_loop_jmp:  nop                                     ; 8147 EA                       .
        nop                                     ; 8148 EA                       .
        nop                                     ; 8149 EA                       .
; Timeout: disable PPU, silence APU, set flags, return to game
cm_timeout:  lda     #$00                            ; 814A A9 00                    ..
        sta     _control0                       ; 814C 8D 00 20                 .. 
        sta     _control1                       ; 814F 8D 01 20                 .. 
        sta     $4015                           ; 8152 8D 15 40                 ..@
        lda     cm_flags                        ; 8155 AD FE 07                 ...
        ora     #$80                            ; 8158 09 80                    ..
        sta     cm_flags                        ; 815A 8D FE 07                 ...
        rts                                     ; 815D 60                       `

; CM_VBLANK - wait for next frame, update PPU during vblank
; ----------------------------------------------------------------------------
cm_vblank:  lda     cm_frames                       ; 815E A5 00                    ..
cm_vblank_wait:  cmp     cm_frames                       ; 8160 C5 00                    ..
        beq     cm_vblank_wait                           ; 8162 F0 FC                    ..
        ldx     #$00                            ; 8164 A2 00                    ..
        ; Upload palette - 8 colors repeated 4 times to fill 32 entries
        lda     #$3F                            ; 8166 A9 3F                    .?
        sta     _vramaddr                       ; 8168 8D 06 20                 .. 
        stx     _vramaddr                       ; 816B 8E 06 20                 .. 
        ldy     #$04                            ; 816E A0 04                    ..
cm_pal_outer:  ldx     #$07                            ; 8170 A2 07                    ..
cm_pal_inner:  lda     cm_palette,x                    ; 8172 BD 1B 84                 ...
        sta     _vramdata                       ; 8175 8D 07 20                 .. 
        dex                                     ; 8178 CA                       .
        bpl     cm_pal_inner                           ; 8179 10 F7                    ..
        dey                                     ; 817B 88                       .
        bne     cm_pal_outer                           ; 817C D0 F2                    ..
        ldx     control1                        ; 817E A6 02                    ..
        ldy     #$3F                            ; 8180 A0 3F                    .?
        sty     _vramaddr                       ; 8182 8C 06 20                 .. 
        lda     #$11                            ; 8185 A9 11                    ..
        sta     _vramaddr                       ; 8187 8D 06 20                 .. 
        ; Colour fade-in: gradually brighten logo palette over time
        lda     cm_colfade,x                    ; 818A BD AC 83                 ...
        bmi     cm_strip                           ; 818D 30 3E                    0>
        sta     _vramdata                       ; 818F 8D 07 20                 .. 
        lda     cm_colfade_1,x                         ; 8192 BD AD 83                 ...
        sta     _vramdata                       ; 8195 8D 07 20                 .. 
        lda     cm_colfade_2,x                         ; 8198 BD AE 83                 ...
        sta     _vramdata                       ; 819B 8D 07 20                 .. 
        sty     _vramaddr                       ; 819E 8C 06 20                 .. 
        ldy     #$03                            ; 81A1 A0 03                    ..
        sty     _vramaddr                       ; 81A3 8C 06 20                 .. 
        sta     _vramdata                       ; 81A6 8D 07 20                 .. 
        sta     _vramdata                       ; 81A9 8D 07 20                 .. 
        sta     _vramdata                       ; 81AC 8D 07 20                 .. 
        sta     _vramdata                       ; 81AF 8D 07 20                 .. 
        sta     _vramdata                       ; 81B2 8D 07 20                 .. 
        ldy     #$3F                            ; 81B5 A0 3F                    .?
        sty     _vramaddr                       ; 81B7 8C 06 20                 .. 
        ldy     #$1B                            ; 81BA A0 1B                    ..
        sty     _vramaddr                       ; 81BC 8C 06 20                 .. 
        sta     _vramdata                       ; 81BF 8D 07 20                 .. 
        inx                                     ; 81C2 E8                       .
        inx                                     ; 81C3 E8                       .
        inx                                     ; 81C4 E8                       .
        dec     seed                            ; 81C5 C6 04                    ..
        bne     cm_strip                           ; 81C7 D0 04                    ..
        inc     seed                            ; 81C9 E6 04                    ..
        stx     control1                        ; 81CB 86 02                    ..
; CM_STRIP - write one more column of 'MASTERS' characters per frame
cm_strip:  lda     #$04                            ; 81CD A9 04                    ..
        sta     _control0                       ; 81CF 8D 00 20                 .. 
        lda     #$21                            ; 81D2 A9 21                    .!
        sta     _vramaddr                       ; 81D4 8D 06 20                 .. 
        lda     $05                             ; 81D7 A5 05                    ..
        sta     _vramaddr                       ; 81D9 8D 06 20                 .. 
        inc     $05                             ; 81DC E6 05                    ..
        ldx     control0                        ; 81DE A6 01                    ..
        ldy     cm_stdata,x                     ; 81E0 BC 6A 83                 .j.
        dey                                     ; 81E3 88                       .
        bpl     cm_codewrite                           ; 81E4 10 13                    ..
cm_strip_skip:  lda     _vramdata                       ; 81E6 AD 07 20                 .. 
        dey                                     ; 81E9 88                       .
        bmi     cm_strip_skip                           ; 81EA 30 FA                    0.
cm_strip_write:  inx                                     ; 81EC E8                       .
        lda     cm_stdata,x                     ; 81ED BD 6A 83                 .j.
        bmi     cm_strip_done                           ; 81F0 30 05                    0.
        sta     _vramdata                       ; 81F2 8D 07 20                 .. 
        bpl     cm_strip_write                           ; 81F5 10 F5                    ..
; CM_CODEWRITE - write 'Code' as background tiles when scrolling done
cm_strip_done:  stx     control0                        ; 81F7 86 01                    ..
cm_codewrite:  lda     $0323                           ; 81F9 AD 23 03                 .#.
        cmp     #$A1                            ; 81FC C9 A1                    ..
        bne     cm_tm_write                           ; 81FE D0 3B                    .;
        lda     #$21                            ; 8200 A9 21                    .!
        sta     _vramaddr                       ; 8202 8D 06 20                 .. 
        lda     #$4C                            ; 8205 A9 4C                    .L
        sta     _vramaddr                       ; 8207 8D 06 20                 .. 
        lda     #$08                            ; 820A A9 08                    ..
        sta     _vramdata                       ; 820C 8D 07 20                 .. 
        lda     #$F4                            ; 820F A9 F4                    ..
        sta     counter                         ; 8211 85 10                    ..
        ldy     #$01                            ; 8213 A0 01                    ..
        ldx     #$00                            ; 8215 A2 00                    ..
cm_code_loop:  lda     #$20                            ; 8217 A9 20                    . 
        sta     _vramaddr                       ; 8219 8D 06 20                 .. 
        lda     counter                         ; 821C A5 10                    ..
        sta     _vramaddr                       ; 821E 8D 06 20                 .. 
        dec     counter                         ; 8221 C6 10                    ..
        lda     cm_codemap,x                    ; 8223 BD C5 83                 ...
cm_code_shift:  asl     a                               ; 8226 0A                       .
        beq     cm_code_next                           ; 8227 F0 0D                    ..
        bcc     cm_code_skip                           ; 8229 90 06                    ..
        sty     _vramdata                       ; 822B 8C 07 20                 .. 
        iny                                     ; 822E C8                       .
        bne     cm_code_shift                           ; 822F D0 F5                    ..
cm_code_skip:  bit     _vramdata                       ; 8231 2C 07 20                 ,. 
        bcc     cm_code_shift                           ; 8234 90 F0                    ..
cm_code_next:  inx                                     ; 8236 E8                       .
        cpx     #$09                            ; 8237 E0 09                    ..
        bne     cm_code_loop                           ; 8239 D0 DC                    ..
cm_tm_write:  lda     #$20                            ; 823B A9 20                    . 
        sta     _control0                       ; 823D 8D 00 20                 .. 
        sta     _vramaddr                       ; 8240 8D 06 20                 .. 
        lda     #$F4                            ; 8243 A9 F4                    ..
        sta     _vramaddr                       ; 8245 8D 06 20                 .. 
        ldx     #$8E                            ; 8248 A2 8E                    ..
        stx     _vramdata                       ; 824A 8E 07 20                 .. 
        inx                                     ; 824D E8                       .
        stx     _vramdata                       ; 824E 8E 07 20                 .. 
        lda     #$00                            ; 8251 A9 00                    ..
        sta     _spriteaddr                     ; 8253 8D 03 20                 .. 
        lda     #$03                            ; 8256 A9 03                    ..
        sta     _dmafunc                        ; 8258 8D 14 40                 ..@
        lda     #$81                            ; 825B A9 81                    ..
        sta     _control0                       ; 825D 8D 00 20                 .. 
        ; Vertical scroll - logo scrolls down then stops
        lda     interon                         ; 8260 A5 03                    ..
        beq     cm_scroll_setup                           ; 8262 F0 05                    ..
        sec                                     ; 8264 38                       8
        sbc     #$04                            ; 8265 E9 04                    ..
        sta     interon                         ; 8267 85 03                    ..
cm_scroll_setup:  asl     a                               ; 8269 0A                       .
        eor     #$FF                            ; 826A 49 FF                    I.
        sta     _scrollcon                      ; 826C 8D 05 20                 .. 
        lda     interon                         ; 826F A5 03                    ..
        sta     _scrollcon                      ; 8271 8D 05 20                 .. 
        lda     #$1E                            ; 8274 A9 1E                    ..
        sta     _control1                       ; 8276 8D 01 20                 .. 
        ldy     #$00                            ; 8279 A0 00                    ..
        lda     $06                             ; 827B A5 06                    ..
        clc                                     ; 827D 18                       .
        adc     #$08                            ; 827E 69 08                    i.
        cmp     #$A9                            ; 8280 C9 A9                    ..
        beq     cm_quart                           ; 8282 F0 5D                    .]
        sta     $06                             ; 8284 85 06                    ..
        lda     pad                             ; 8286 A5 07                    ..
        sec                                     ; 8288 38                       8
        sbc     #$04                            ; 8289 E9 04                    ..
        sta     pad                             ; 828B 85 07                    ..
        ldx     #$0A                            ; 828D A2 0A                    ..
        lda     #$19                            ; 828F A9 19                    ..
        jsr     cm_codeplot                           ; 8291 20 98 82                  ..
        ldx     #$00                            ; 8294 A2 00                    ..
        lda     #$01                            ; 8296 A9 01                    ..
; CM_CODEPLOT - plot sprite bitmap from codemap data
cm_codeplot:  sta     blockpointer                    ; 8298 85 0F                    ..
        lda     $06                             ; 829A A5 06                    ..
        sta     vrampointer                     ; 829C 85 0C                    ..
cm_codeplot_loop:  lda     pad                             ; 829E A5 07                    ..
        sta     bankno                          ; 82A0 85 0D                    ..
        lda     cm_codemap,x                    ; 82A2 BD C5 83                 ...
        beq     cm_codeplot_done                           ; 82A5 F0 39                    .9
        sta     spriteblockpointer              ; 82A7 85 0E                    ..
        inx                                     ; 82A9 E8                       .
cm_codeplot_shift:  asl     spriteblockpointer              ; 82AA 06 0E                    ..
        beq     cm_codeplot_nxtrow                           ; 82AC F0 29                    .)
        bcc     cm_codeplot_next                           ; 82AE 90 1E                    ..
        lda     blockpointer                    ; 82B0 A5 0F                    ..
        inc     blockpointer                    ; 82B2 E6 0F                    ..
        sta     $0301,y                         ; 82B4 99 01 03                 ...
        lda     #$02                            ; 82B7 A9 02                    ..
        sta     $0302,y                         ; 82B9 99 02 03                 ...
        lda     vrampointer                     ; 82BC A5 0C                    ..
        cmp     #$E0                            ; 82BE C9 E0                    ..
        bcs     cm_codeplot_done                           ; 82C0 B0 1E                    ..
        sta     $0303,y                         ; 82C2 99 03 03                 ...
        lda     bankno                          ; 82C5 A5 0D                    ..
        sta     normalvars,y                    ; 82C7 99 00 03                 ...
        iny                                     ; 82CA C8                       .
        iny                                     ; 82CB C8                       .
        iny                                     ; 82CC C8                       .
        iny                                     ; 82CD C8                       .
cm_codeplot_next:  lda     bankno                          ; 82CE A5 0D                    ..
        clc                                     ; 82D0 18                       .
        adc     #$08                            ; 82D1 69 08                    i.
        sta     bankno                          ; 82D3 85 0D                    ..
        bne     cm_codeplot_shift                           ; 82D5 D0 D3                    ..
cm_codeplot_nxtrow:  lda     vrampointer                     ; 82D7 A5 0C                    ..
        sec                                     ; 82D9 38                       8
        sbc     #$08                            ; 82DA E9 08                    ..
        sta     vrampointer                     ; 82DC 85 0C                    ..
        bne     cm_codeplot_loop                           ; 82DE D0 BE                    ..
cm_codeplot_done:  rts                                     ; 82E0 60                       `

; CM_QUART - display circle quarter sprites with 4-way symmetry
; ----------------------------------------------------------------------------
cm_quart:  lda     #$21                            ; 82E1 A9 21                    .!
        sta     blockpointer                    ; 82E3 85 0F                    ..
        lda     #$2F                            ; 82E5 A9 2F                    ./
        sta     bankno                          ; 82E7 85 0D                    ..
        ldx     #$00                            ; 82E9 A2 00                    ..
        ldy     #$20                            ; 82EB A0 20                    . 
cm_quart_loop:  lda     #$59                            ; 82ED A9 59                    .Y
        sta     vrampointer                     ; 82EF 85 0C                    ..
        lda     cm_quartmap,x                   ; 82F1 BD BF 83                 ...
        sta     spriteblockpointer              ; 82F4 85 0E                    ..
        inx                                     ; 82F6 E8                       .
cm_quart_shift:  asl     spriteblockpointer              ; 82F7 06 0E                    ..
        bcc     cm_quart_next                           ; 82F9 90 4F                    .O
        lda     blockpointer                    ; 82FB A5 0F                    ..
        inc     blockpointer                    ; 82FD E6 0F                    ..
        sta     $0301,y                         ; 82FF 99 01 03                 ...
        sta     $0305,y                         ; 8302 99 05 03                 ...
        sta     $0309,y                         ; 8305 99 09 03                 ...
        sta     $030D,y                         ; 8308 99 0D 03                 ...
        lda     #$20                            ; 830B A9 20                    . 
        sta     $0302,y                         ; 830D 99 02 03                 ...
        lda     #$60                            ; 8310 A9 60                    .`
        sta     $0306,y                         ; 8312 99 06 03                 ...
        lda     #$A0                            ; 8315 A9 A0                    ..
        sta     $030A,y                         ; 8317 99 0A 03                 ...
        lda     #$E0                            ; 831A A9 E0                    ..
        sta     $030E,y                         ; 831C 99 0E 03                 ...
        lda     vrampointer                     ; 831F A5 0C                    ..
        sta     $0303,y                         ; 8321 99 03 03                 ...
        sta     $030B,y                         ; 8324 99 0B 03                 ...
        eor     #$FF                            ; 8327 49 FF                    I.
        sec                                     ; 8329 38                       8
        sbc     #$05                            ; 832A E9 05                    ..
        sta     $0307,y                         ; 832C 99 07 03                 ...
        sta     $030F,y                         ; 832F 99 0F 03                 ...
        lda     bankno                          ; 8332 A5 0D                    ..
        sta     normalvars,y                    ; 8334 99 00 03                 ...
        sta     $0304,y                         ; 8337 99 04 03                 ...
        eor     #$FF                            ; 833A 49 FF                    I.
        sec                                     ; 833C 38                       8
        sbc     #$49                            ; 833D E9 49                    .I
        sta     $0308,y                         ; 833F 99 08 03                 ...
        sta     $030C,y                         ; 8342 99 0C 03                 ...
        tya                                     ; 8345 98                       .
        clc                                     ; 8346 18                       .
        adc     #$10                            ; 8347 69 10                    i.
        tay                                     ; 8349 A8                       .
cm_quart_next:  lda     vrampointer                     ; 834A A5 0C                    ..
        clc                                     ; 834C 18                       .
        adc     #$08                            ; 834D 69 08                    i.
        sta     vrampointer                     ; 834F 85 0C                    ..
        cmp     #$81                            ; 8351 C9 81                    ..
        bne     cm_quart_shift                           ; 8353 D0 A2                    ..
        lda     bankno                          ; 8355 A5 0D                    ..
        clc                                     ; 8357 18                       .
        adc     #$08                            ; 8358 69 08                    i.
        sta     bankno                          ; 835A 85 0D                    ..
        cmp     #$5F                            ; 835C C9 5F                    ._
cm_quart_nextrow:  bne     cm_quart_loop                           ; 835E D0 8D                    ..
        rts                                     ; 8360 60                       `

; --- CMLOGO data: SFX noise, init table, strip data, bitmaps, palette ---
; ----------------------------------------------------------------------------
cm_sfxnoise:
        .byte   $04,$06,$01,$01                 ; 8361 04 06 01 01              ....
cm_inittab:
        .byte   $5C,$18,$09,$F1,$8F             ; 8365 5C 18 09 F1 8F           \....
cm_stdata:
        .byte   $88,$2F,$30,$86,$31,$32,$33,$34 ; 836A 88 2F 30 86 31 32 33 34  ./0.1234
        .byte   $85,$35,$36,$37,$38,$85,$39,$3A ; 8372 85 35 36 37 38 85 39 3A  .5678.9:
        .byte   $3B,$84,$3C,$3D,$3E,$3F,$40,$84 ; 837A 3B 84 3C 3D 3E 3F 40 84  ;.<=>?@.
        .byte   $41,$42,$43,$44,$19,$84,$45,$46 ; 8382 41 42 43 44 19 84 45 46  ABCD..EF
        .byte   $47,$48,$83,$49,$4A,$4B,$4C,$4D ; 838A 47 48 83 49 4A 4B 4C 4D  GH.IJKLM
        .byte   $82,$4E,$4F,$50,$51,$52,$0B,$82 ; 8392 82 4E 4F 50 51 52 0B 82  .NOPQR..
        .byte   $53,$54,$55,$56,$0B,$82,$57,$58 ; 839A 53 54 55 56 0B 82 57 58  STUV..WX
        .byte   $59,$0B,$82,$5A,$5B,$5C,$81,$5D ; 83A2 59 0B 82 5A 5B 5C 81 5D  Y..Z[\.]
        .byte   $5E,$80                         ; 83AA 5E 80                    ^.
cm_colfade:
        .byte   $04                             ; 83AC 04                       .
cm_colfade_1:  .byte   $04                             ; 83AD 04                       .
cm_colfade_2:  .byte   $04,$04,$04,$03,$04,$04,$13,$03 ; 83AE 04 04 04 03 04 04 13 03  ........
        .byte   $14,$12,$02,$16,$11,$01,$18,$11 ; 83B6 14 12 02 16 11 01 18 11  ........
        .byte   $80                             ; 83BE 80                       .
cm_quartmap:
        .byte   $38,$78,$E0,$C0,$80,$80         ; 83BF 38 78 E0 C0 80 80        8x....
cm_codemap:
        .byte   $22,$22,$62,$E2,$72,$7A,$7A,$7A ; 83C5 22 22 62 E2 72 7A 7A 7A  ""b.rzzz
        .byte   $0E,$00,$12,$12,$12,$1A,$0A,$02 ; 83CD 0E 00 12 12 12 1A 0A 02  ........
        .byte   $06,$06,$02,$00                 ; 83D5 06 06 02 00              ....
cm_abmap:
        .byte   $85,$5F,$60,$61,$62,$63,$64,$65 ; 83D9 85 5F 60 61 62 63 64 65  ._`abcde
        .byte   $66,$63,$67,$00,$60,$60,$68,$63 ; 83E1 66 63 67 00 60 60 68 63  fcg.``hc
        .byte   $63,$68,$5F,$69,$6A,$6B,$A5,$6C ; 83E9 63 68 5F 69 6A 6B A5 6C  ch_ijk.l
        .byte   $6D,$6E,$6F,$70,$71,$63,$72,$70 ; 83F1 6D 6E 6F 70 71 63 72 70  mnopqcrp
        .byte   $73,$00,$6D,$74,$75,$70,$70,$75 ; 83F9 73 00 6D 74 75 70 70 75  s.mtuppu
        .byte   $6C,$76,$77,$78,$E5,$79,$7A,$7B ; 8401 6C 76 77 78 E5 79 7A 7B  lvwx.yz{
        .byte   $7C,$7D,$7E,$7F,$80,$81,$82,$83 ; 8409 7C 7D 7E 7F 80 81 82 83  |}~.....
        .byte   $84,$85,$86,$87,$88,$89,$8A,$8B ; 8411 84 85 86 87 88 89 8A 8B  ........
        .byte   $8C,$8D                         ; 8419 8C 8D                    ..
cm_palette:
        .byte   $34,$24,$14,$04,$11,$28,$1D,$04 ; 841B 34 24 14 04 11 28 1D 04  4$...(..
; CM_CHARACTERS - decompress PP1 character data to CHR RAM
; ----------------------------------------------------------------------------
cm_characters:
        lda     #$0E                            ; 8423 A9 0E                    ..
        sta     bankno                          ; 8425 85 0D                    ..
        lda     #$00                            ; 8427 A9 00                    ..
        jmp     LF1E0                           ; 8429 4C E0 F1                 L..

; --- CMLOGO.PP1 compressed character data ---
; ----------------------------------------------------------------------------
cmlogo_pp1:
        .byte   $91,$09,$D8,$FF,$FF,$8F,$62,$C4 ; 842C 91 09 D8 FF FF 8F 62 C4  ......b.
        .byte   $63,$6B,$75,$3B,$9D,$F8,$FF,$CB ; 8434 63 6B 75 3B 9D F8 FF CB  cku;....
        .byte   $3C,$E1,$C8,$C3,$5F,$A3,$FF,$CB ; 843C 3C E1 C8 C3 5F A3 FF CB  <..._...
        .byte   $FA,$27,$D5,$95,$B2,$BB,$28,$36 ; 8444 FA 27 D5 95 B2 BB 28 36  .'....(6
        .byte   $91,$A6,$3C,$BD,$AB,$8C,$7F,$F8 ; 844C 91 A6 3C BD AB 8C 7F F8  ..<.....
        .byte   $BB,$31,$99,$12,$2C,$9D,$49,$B4 ; 8454 BB 31 99 12 2C 9D 49 B4  .1..,.I.
        .byte   $9A,$D7,$5A,$DB,$5A,$F5,$6D,$55 ; 845C 9A D7 5A DB 5A F5 6D 55  ..Z.Z.mU
        .byte   $8A,$A8,$D2,$C5,$28,$FB,$FF,$BF ; 8464 8A A8 D2 C5 28 FB FF BF  ....(...
        .byte   $DB,$F8,$F7,$E2,$E6,$2C,$11,$26 ; 846C DB F8 F7 E2 E6 2C 11 26  .....,.&
        .byte   $35,$FF,$AA,$75,$66,$9C,$E9,$9C ; 8474 35 FF AA 75 66 9C E9 9C  5..uf...
        .byte   $CF,$AF,$F7,$FF,$FF,$F6,$7C,$42 ; 847C CF AF F7 FF FF F6 7C 42  ......|B
        .byte   $6A,$B4,$2D,$C5,$B3,$5C,$64,$C6 ; 8484 6A B4 2D C5 B3 5C 64 C6  j.-..\d.
        .byte   $4F,$CC,$FF,$5F,$D7,$B5,$7C,$FE ; 848C 4F CC FF 5F D7 B5 7C FE  O.._..|.
        .byte   $9E,$F2,$FF,$7F,$EC,$FC,$87,$D4 ; 8494 9E F2 FF 7F EC FC 87 D4  ........
        .byte   $9D,$6B,$AD,$B5,$D7,$AE,$D2,$75 ; 849C 9D 6B AD B5 D7 AE D2 75  .k.....u
        .byte   $27,$66,$5C,$CB,$4C,$6D,$C9,$EF ; 84A4 27 66 5C CB 4C 6D C9 EF  'f\.Lm..
        .byte   $F3,$F8,$7E,$37,$C6,$F1,$EE,$3A ; 84AC F3 F8 7E 37 C6 F1 EE 3A  ..~7...:
        .byte   $E3,$58,$EB,$1A,$13,$FA,$FC,$BD ; 84B4 E3 58 EB 1A 13 FA FC BD  .X......
        .byte   $AB,$F1,$FF,$8F,$C3,$E2,$3C,$48 ; 84BC AB F1 FF 8F C3 E2 3C 48  ......<H
        .byte   $98,$3E,$7B,$CF,$B9,$EB,$3D,$CB ; 84C4 98 3E 7B CF B9 EB 3D CB  .>{...=.
        .byte   $D9,$7A,$4B,$B2,$BA,$75,$A7,$EA ; 84CC D9 7A 4B B2 BA 75 A7 EA  .zK..u..
        .byte   $9F,$D2,$79,$25,$A9,$BD,$1F,$DF ; 84D4 9F D2 79 25 A9 BD 1F DF  ..y%....
        .byte   $CB,$F3,$EF,$9F,$EF,$3E,$F3,$9E ; 84DC CB F3 EF 9F EF 3E F3 9E  .....>..
        .byte   $F7,$8B,$7E,$39,$03,$FA,$F6,$5B ; 84E4 F7 8B 7E 39 03 FA F6 5B  ..~9...[
        .byte   $84,$E0,$E0,$C0,$C2,$41,$9C,$F2 ; 84EC 84 E0 E0 C0 C2 41 9C F2  .....A..
        .byte   $7C,$BD,$AD,$E9,$D8,$EF,$97,$F1 ; 84F4 7C BD AD E9 D8 EF 97 F1  |.......
        .byte   $FE,$79,$CF,$31,$E7,$33,$EB,$FA ; 84FC FE 79 CF 31 E7 33 EB FA  .y.1.3..
        .byte   $FC,$BB,$A7,$D0,$8C,$3E,$1F,$D7 ; 8504 FC BB A7 D0 8C 3E 1F D7  .....>..
        .byte   $D5,$BC,$FC,$78,$C3,$9F,$8F,$10 ; 850C D5 BC FC 78 C3 9F 8F 10  ...x....
        .byte   $FA,$FE,$BD,$AD,$E9,$F1,$E3,$08 ; 8514 FA FE BD AD E9 F1 E3 08  ........
        .byte   $11,$FF,$1F,$63,$FF,$1E,$C6,$8E ; 851C 11 FF 1F 63 FF 1E C6 8E  ...c....
        .byte   $41,$22,$C7,$FC,$5F,$33,$EB,$FD ; 8524 41 22 C7 FC 5F 33 EB FD  A".._3..
        .byte   $5F,$8F,$FC,$7E,$1F,$03,$C4,$71 ; 852C 5F 8F FC 7E 1F 03 C4 71  _..~...q
        .byte   $C7,$88,$D3,$11,$E6,$75,$79,$5A ; 8534 C7 88 D3 11 E6 75 79 5A  .....uyZ
        .byte   $A9,$46,$BD,$AD,$4E,$BF,$9A,$FF ; 853C A9 46 BD AD 4E BF 9A FF  .F..N...
        .byte   $8F,$FF,$1F,$87,$C4,$63,$88,$E1 ; 8544 8F FF 1F 87 C4 63 88 E1  .....c..
        .byte   $19,$03,$24,$CD,$65,$4C,$AF,$F8 ; 854C 19 03 24 CD 65 4C AF F8  ..$.eL..
        .byte   $F8,$1E,$31,$C7,$18,$DD,$4A,$32 ; 8554 F8 1E 31 C7 18 DD 4A 32  ..1...J2
        .byte   $DE,$13,$18,$9C,$70,$71,$F9,$71 ; 855C DE 13 18 9C 70 71 F9 71  ....pq.q
        .byte   $FF,$1F,$FE,$3F,$63,$E7,$8F,$38 ; 8564 FF 1F FE 3F 63 E7 8F 38  ...?c..8
        .byte   $F2,$1E,$88,$FF,$E3,$F4,$7C,$C7 ; 856C F2 1E 88 FF E3 F4 7C C7  ......|.
        .byte   $9C,$73,$C6,$7C,$4F,$60,$F6,$0E ; 8574 9C 73 C6 7C 4F 60 F6 0E  .s.|O`..
        .byte   $CB,$DC,$BB,$0B,$B1,$08,$C5,$B9 ; 857C CB DC BB 0B B1 08 C5 B9  ........
        .byte   $6D,$AB,$8F,$8E,$30,$48,$31,$FF ; 8584 6D AB 8F 8E 30 48 31 FF  m...0H1.
        .byte   $1F,$87,$C0,$F1,$1C,$63,$1E,$23 ; 858C 1F 87 C0 F1 1C 63 1E 23  .....c.#
        .byte   $C4,$70,$1D,$27,$52,$6D,$5D,$6B ; 8594 C4 70 1D 27 52 6D 5D 6B  .p.'Rm]k
        .byte   $5B,$55,$8A,$68,$A5,$89,$D8,$9B ; 859C 5B 55 8A 68 A5 89 D8 9B  [U.h....
        .byte   $19,$B0,$96,$1C,$B5,$25,$FC,$7F ; 85A4 19 B0 96 1C B5 25 FC 7F  .....%..
        .byte   $F9,$13,$1B,$FE,$E9,$EC,$8E,$2E ; 85AC F9 13 1B FE E9 EC 8E 2E  ........
        .byte   $25,$79,$AF,$F4,$7F,$37,$E4,$1E ; 85B4 25 79 AF F4 7F 37 E4 1E  %y...7..
        .byte   $13,$C0,$FC,$BF,$97,$3A,$D7,$59 ; 85BC 13 C0 FC BF 97 3A D7 59  .....:.Y
        .byte   $E4,$4E,$2F,$EB,$F2,$F6,$B7,$AB ; 85C4 E4 4E 2F EB F2 F6 B7 AB  .N/.....
        .byte   $A7,$A7,$4B,$7F,$FD,$FA,$5F,$01 ; 85CC A7 A7 4B 7F FD FA 5F 01  ..K..._.
        .byte   $74,$52,$22,$36,$74,$BD,$5F,$75 ; 85D4 74 52 22 36 74 BD 5F 75  tR"6t._u
        .byte   $ED,$1B,$36,$F9,$B5,$D1,$AE,$6D ; 85DC ED 1B 36 F9 B5 D1 AE 6D  ..6....m
        .byte   $CD,$A0,$7F,$07,$42,$53,$06,$E0 ; 85E4 CD A0 7F 07 42 53 06 E0  ....BS..
        .byte   $8A,$13,$03,$FF,$91,$22,$3F,$FE ; 85EC 8A 13 03 FF 91 22 3F FE  ....."?.
        .byte   $FF,$17,$31,$61,$25,$18,$33,$F2 ; 85F4 FF 17 31 61 25 18 33 F2  ..1a%.3.
        .byte   $7E,$4D,$35,$D2,$B6,$7A,$C7,$5F ; 85FC 7E 4D 35 D2 B6 7A C7 5F  ~M5..z._
        .byte   $EB,$EA,$EE,$AE,$67,$9C,$E7,$93 ; 8604 EB EA EE AE 67 9C E7 93  ....g...
        .byte   $E5,$ED,$6F,$57,$A7,$DC,$EF,$DF ; 860C E5 ED 6F 57 A7 DC EF DF  ..oW....
        .byte   $FB,$FC,$E7,$06,$11,$5B,$2B,$4D ; 8614 FB FC E7 06 11 5B 2B 4D  .....[+M
        .byte   $63,$D5,$3A,$B3,$55,$15,$58,$AA ; 861C 63 D5 3A B3 55 15 58 AA  c.:.U.X.
        .byte   $8A,$D3,$5F,$F4,$3A,$91,$D3,$E1 ; 8624 8A D3 5F F4 3A 91 D3 E1  .._.:...
        .byte   $F3,$33,$CB,$FE,$B8,$D3,$29,$FE ; 862C F3 33 CB FE B8 D3 29 FE  .3....).
        .byte   $77,$25,$FD,$FF,$C8,$21,$7F,$5F ; 8634 77 25 FD FF C8 21 7F 5F  w%...!._
        .byte   $8F,$A7,$E5,$F1,$D1,$12,$23,$1F ; 863C 8F A7 E5 F1 D1 12 23 1F  ......#.
        .byte   $27,$EB,$8D,$69,$AA,$75,$4C,$99 ; 8644 27 EB 8D 69 AA 75 4C 99  '..i.uL.
        .byte   $8F,$35,$33,$2A,$65,$1F,$A8,$D5 ; 864C 8F 35 33 2A 65 1F A8 D5  .53*e...
        .byte   $0E,$9F,$67,$D8,$DD,$0B,$4C,$A3 ; 8654 0E 9F 67 D8 DD 0B 4C A3  ..g...L.
        .byte   $8C,$EA,$F6,$B6,$D3,$B8,$14,$38 ; 865C 8C EA F6 B6 D3 B8 14 38  .......8
        .byte   $CF,$E4,$48,$9F,$BF,$CF,$E2,$6D ; 8664 CF E4 48 9F BF CF E2 6D  ..H....m
        .byte   $29,$99,$26,$A1,$75,$B8,$AE,$53 ; 866C 29 99 26 A1 75 B8 AE 53  ).&.u..S
        .byte   $99,$D1,$CD,$1A,$73,$4E,$79,$9F ; 8674 99 D1 CD 1A 73 4E 79 9F  ....sNy.
        .byte   $33,$A6,$68,$4F,$F5,$F9,$7B,$57 ; 867C 33 A6 68 4F F5 F9 7B 57  3.hO..{W
        .byte   $CF,$A0,$EA,$4B,$19,$A5,$84,$98 ; 8684 CF A0 EA 4B 19 A5 84 98  ...K....
        .byte   $5D,$8A,$C4,$C3,$08,$F2,$24,$4F ; 868C 5D 8A C4 C3 08 F2 24 4F  ].....$O
        .byte   $7B,$AD,$1C,$96,$D5,$74,$EE,$0D ; 8694 7B AD 1C 96 D5 74 EE 0D  {....t..
        .byte   $E0,$BE,$1F,$89,$B8,$A5,$8A,$A8 ; 869C E0 BE 1F 89 B8 A5 8A A8  ........
        .byte   $AB,$9A,$D3,$26,$35,$C6,$AC,$CE ; 86A4 AB 9A D3 26 35 C6 AC CE  ...&5...
        .byte   $79,$3F,$5F,$56,$FA,$7D,$3E,$E6 ; 86AC 79 3F 5F 56 FA 7D 3E E6  y?_V.}>.
        .byte   $1E,$43,$E8,$FC,$A7,$CD,$FB,$FF ; 86B4 1E 43 E8 FC A7 CD FB FF  .C......
        .byte   $FB,$F2,$6A,$E4,$47,$51,$6B,$B2 ; 86BC FB F2 6A E4 47 51 6B B2  ..j.GQk.
        .byte   $BA,$95,$DA,$77,$4B,$C9,$58,$13 ; 86C4 BA 95 DA 77 4B C9 58 13  ...wK.X.
        .byte   $19,$EF,$2F,$EB,$EA,$EE,$AF,$27 ; 86CC 19 EF 2F EB EA EE AF 27  ../....'
        .byte   $C9,$C9,$31,$F8,$7A,$8E,$71,$9E ; 86D4 C9 C9 31 F8 7A 8E 71 9E  ..1.z.q.
        .byte   $27,$C1,$E9,$7B,$5D,$8A,$D8,$AB ; 86DC 27 C1 E9 7B 5D 8A D8 AB  '..{]...
        .byte   $1A,$D8,$AF,$41,$7D,$07,$65,$E8 ; 86E4 1A D8 AF 41 7D 07 65 E8  ...A}.e.
        .byte   $5D,$80,$8C,$5D,$27,$8F,$8C,$38 ; 86EC 5D 80 8C 5D 27 8F 8C 38  ]..]'..8
        .byte   $1B,$FC,$4F,$38,$C2,$31,$5A,$9A ; 86F4 1B FC 4F 38 C2 31 5A 9A  ..O8.1Z.
        .byte   $78,$C4,$1B,$B2,$C1,$D7,$18,$3C ; 86FC 78 C4 1B B2 C1 D7 18 3C  x......<
        .byte   $6B,$C6,$A0,$C4,$08,$2C,$54,$A5 ; 8704 6B C6 A0 C4 08 2C 54 A5  k....,T.
        .byte   $80,$59,$40,$3C,$80,$42,$A1,$51 ; 870C 80 59 40 3C 80 42 A1 51  .Y@<.B.Q
        .byte   $28,$52,$81,$0A,$55,$20,$C2,$C0 ; 8714 28 52 81 0A 55 20 C2 C0  (R..U ..
        .byte   $3E,$31,$AA,$22,$BA,$00,$3C,$05 ; 871C 3E 31 AA 22 BA 00 3C 05  >1."..<.
        .byte   $4C,$00,$D1,$40,$32,$F0,$B2,$E0 ; 8724 4C 00 D1 40 32 F0 B2 E0  L..@2...
        .byte   $14,$71,$AC,$A2,$7C,$80,$56,$83 ; 872C 14 71 AC A2 7C 80 56 83  .q..|.V.
        .byte   $28,$24,$46,$64,$2E,$69,$2E,$69 ; 8734 28 24 46 64 2E 69 2E 69  ($Fd.i.i
        .byte   $1C,$E2,$08,$E2,$04,$62,$A8,$E2 ; 873C 1C E2 08 E2 04 62 A8 E2  .....b..
        .byte   $A5,$C4,$CB,$E0,$10,$0C,$01,$00 ; 8744 A5 C4 CB E0 10 0C 01 00  ........
        .byte   $42,$A1,$58,$52,$A9,$06,$53,$38 ; 874C 42 A1 58 52 A9 06 53 38  B.XR..S8
        .byte   $5F,$83,$F8,$3F,$46,$A8,$C6,$A5 ; 8754 5F 83 F8 3F 46 A8 C6 A5  _..?F...
        .byte   $8C,$CB,$C4,$1C,$44,$1A,$05,$51 ; 875C 8C CB C4 1C 44 1A 05 51  ....D..Q
        .byte   $C5,$4B,$89,$E5,$C8,$8D,$48,$8C ; 8764 C5 4B 89 E5 C8 8D 48 8C  .K....H.
        .byte   $C1,$8A,$A1,$44,$C0,$50,$A8,$0A ; 876C C1 8A A1 44 C0 50 A8 0A  ...D.P..
        .byte   $0C,$40,$15,$10,$0C,$71,$C0,$81 ; 8774 0C 40 15 10 0C 71 C0 81  .@...q..
        .byte   $D5,$11,$D4,$A3,$99,$63,$04,$71 ; 877C D5 11 D4 A3 99 63 04 71  .....c.q
        .byte   $04,$44,$41,$28,$15,$95,$15,$A1 ; 8784 04 44 41 28 15 95 15 A1  .DA(....
        .byte   $15,$C2,$27,$90,$4F,$5B,$85,$EE ; 878C 15 C2 27 90 4F 5B 85 EE  ..'.O[..
        .byte   $0F,$B4,$1F,$68,$D5,$B2,$EA,$59 ; 8794 0F B4 1F 68 D5 B2 EA 59  ...h...Y
        .byte   $73,$3B,$8C,$0B,$8D,$56,$8D,$51 ; 879C 73 3B 8C 0B 8D 56 8D 51  s;...V.Q
        .byte   $EA,$47,$99,$8E,$08,$C5,$4A,$50 ; 87A4 EA 47 99 8E 08 C5 4A 50  .G....JP
        .byte   $04,$4B,$0B,$E6,$48,$99,$A6,$26 ; 87AC 04 4B 0B E6 48 99 A6 26  .K..H..&
        .byte   $64,$F2,$91,$06,$82,$22,$50,$92 ; 87B4 64 F2 91 06 82 22 50 92  d...."P.
        .byte   $CA,$12,$50,$15,$22,$65,$7E,$5B ; 87BC CA 12 50 15 22 65 7E 5B  ..P."e~[
        .byte   $D2,$ED,$96,$F1,$04,$88,$CD,$63 ; 87C4 D2 ED 96 F1 04 88 CD 63  .......c
        .byte   $58,$A7,$31,$66,$45,$BF,$22,$8D ; 87CC 58 A7 31 66 45 BF 22 8D  X.1fE.".
        .byte   $70,$05,$F7,$1C,$AE,$35,$5C,$6A ; 87D4 70 05 F7 1C AE 35 5C 6A  p....5\j
        .byte   $5C,$60,$2E,$42,$C2,$29,$20,$BE ; 87DC 5C 60 2E 42 C2 29 20 BE  \`.B.) .
        .byte   $21,$6B,$A5,$6B,$C2,$BE,$10,$70 ; 87E4 21 6B A5 6B C2 BE 10 70  !k.k...p
        .byte   $10,$F0,$1F,$41,$FA,$0F,$84,$AA ; 87EC 10 F0 1F 41 FA 0F 84 AA  ...A....
        .byte   $B2,$04,$09,$00,$85,$3E,$CB,$84 ; 87F4 B2 04 09 00 85 3E CB 84  .....>..
        .byte   $06,$1C,$2E,$C2,$BC,$20,$E0,$21 ; 87FC 06 1C 2E C2 BC 20 E0 21  ..... .!
        .byte   $E0,$3D,$83,$EC,$1E,$16,$F9,$71 ; 8804 E0 3D 83 EC 1E 16 F9 71  .=.....q
        .byte   $35,$C4,$CB,$84,$8E,$11,$7C,$02 ; 880C 35 C4 CB 84 8E 11 7C 02  5.....|.
        .byte   $5F,$06,$5F,$27,$19,$13,$2C,$88 ; 8814 5F 06 5F 27 19 13 2C 88  _._'..,.
        .byte   $16,$89,$8B,$44,$A6,$28,$88,$25 ; 881C 16 89 8B 44 A6 28 88 25  ...D.(.%
        .byte   $71,$42,$B5,$A4,$46,$8B,$18,$2B ; 8824 71 42 B5 A4 46 8B 18 2B  qB..F..+
        .byte   $8C,$12,$C6,$65,$C5,$23,$C2,$53 ; 882C 8C 12 C6 65 C5 23 C2 53  ...e.#.S
        .byte   $84,$93,$08,$A7,$00,$A8,$30,$0A ; 8834 84 93 08 A7 00 A8 30 0A  ......0.
        .byte   $A4,$02,$54,$83,$2C,$F6,$34,$8A ; 883C A4 02 54 83 2C F6 34 8A  ..T.,.4.
        .byte   $74,$54,$E0,$AC,$B8,$25,$2E,$65 ; 8844 74 54 E0 AC B8 25 2E 65  tT...%.e
        .byte   $C7,$45,$1C,$15,$8F,$F1,$A4,$A3 ; 884C C7 45 1C 15 8F F1 A4 A3  .E......
        .byte   $06,$A3,$49,$4C,$14,$7F,$8F,$C3 ; 8854 06 A3 49 4C 14 7F 8F C3  ..IL....
        .byte   $E6,$3F,$0F,$FB,$DA,$33,$04,$4D ; 885C E6 3F 0F FB DA 33 04 4D  .?...3.M
        .byte   $90,$44,$33,$3D,$D1,$FC,$56,$04 ; 8864 90 44 33 3D D1 FC 56 04  .D3=..V.
        .byte   $22,$D0,$E6,$33,$89,$D1,$FD,$AB ; 886C 22 D0 E6 33 89 D1 FD AB  "..3....
        .byte   $04,$EE,$98,$26,$D9,$8E,$71,$FC ; 8874 04 EE 98 26 D9 8E 71 FC  ...&..q.
        .byte   $7A,$1C,$C6,$7C,$73,$1E,$A3,$FF ; 887C 7A 1C C6 7C 73 1E A3 FF  z..|s...
        .byte   $0B,$5A,$18,$5B,$1F,$DB,$FD,$A9 ; 8884 0B 5A 18 5B 1F DB FD A9  .Z.[....
        .byte   $60,$19,$46,$A2,$3F,$F7,$D8,$10 ; 888C 60 19 46 A2 3F F7 D8 10  `.F.?...
        .byte   $82,$51,$FF,$BA,$80,$58,$2A,$E5 ; 8894 82 51 FF BA 80 58 2A E5  .Q...X*.
        .byte   $C7,$FB,$7F,$75,$1A,$06,$A9,$B4 ; 889C C7 FB 7F 75 1A 06 A9 B4  ...u....
        .byte   $8F,$FC,$15,$6A,$C7,$51,$AE,$3F ; 88A4 8F FC 15 6A C7 51 AE 3F  ...j.Q.?
        .byte   $8E,$A3,$20,$CE,$3A,$8F,$83,$20 ; 88AC 8E A3 20 CE 3A 8F 83 20  .. .:.. 
        .byte   $EB,$1F,$C7,$E1,$F2,$15,$B4,$90 ; 88B4 EB 1F C7 E1 F2 15 B4 90  ........
        .byte   $B2,$3F,$D8,$F1,$3C,$31,$12,$62 ; 88BC B2 3F D8 F1 3C 31 12 62  .?..<1.b
        .byte   $6C,$7F,$ED,$2B,$43,$0B,$63,$FF ; 88C4 6C 7F ED 2B 43 0B 63 FF  l..+C.c.
        .byte   $60,$99,$46,$35,$8E,$8F,$F1,$F8 ; 88CC 60 99 46 35 8E 8F F1 F8  `.F5....
        .byte   $7C,$6F,$23,$F3,$7F,$1F,$DD,$F1 ; 88D4 7C 6F 23 F3 7F 1F DD F1  |o#.....
        .byte   $FE,$3A,$8C,$97,$56,$3F,$8E,$7F ; 88DC FE 3A 8C 97 56 3F 8E 7F  .:..V?..
        .byte   $6D,$A3,$F8,$FC,$0F,$5E,$B0,$4A ; 88E4 6D A3 F8 FC 0F 5E B0 4A  m....^.J
        .byte   $0D,$C7,$FF,$C1,$F8,$FF,$8B,$43 ; 88EC 0D C7 FF C1 F8 FF 8B 43  .......C
        .byte   $37,$8F,$F8,$CE,$CB,$80,$E3,$3E ; 88F4 37 8F F8 CE CB 80 E3 3E  7......>
        .byte   $3F,$B6,$A0,$20,$38,$EC,$82,$6D ; 88FC 3F B6 A0 20 38 EC 82 6D  ?.. 8..m
        .byte   $38,$DC                         ; 8904 38 DC                    8.
; SMILEY self-test - ROM/RAM verification by Jon Menzies and Gavin Raeburn
; ----------------------------------------------------------------------------
; ==========================================================================
; SMILEY.ROU
; ==========================================================================
smiley: ldx     #$20                            ; 8906 A2 20                    . 
smiley_copy_loop:  lda     smiley_rom_check,x                         ; 8908 BD E8 89                 ...
        sta     cm_frames,x                     ; 890B 95 00                    ..
        inx                                     ; 890D E8                       .
        bne     smiley_copy_loop                           ; 890E D0 F8                    ..
        stx     _control0                       ; 8910 8E 00 20                 .. 
        stx     _control1                       ; 8913 8E 01 20                 .. 
        jsr     smiley_keypad                           ; 8916 20 F3 89                  ..
        sty     toplevvar3                      ; 8919 84 13                    ..
        lda     toplevvar6                      ; 891B A5 16                    ..
        and     #$BF                            ; 891D 29 BF                    ).
        cmp     #$BF                            ; 891F C9 BF                    ..
        bne     smiley_no_eq                           ; 8921 D0 0C                    ..
        lda     #$0F                            ; 8923 A9 0F                    ..
        sta     toplevvar4                      ; 8925 85 14                    ..
        lda     a:$B9                           ; 8927 AD B9 00                 ...
        sta     toplevvar7                      ; 892A 85 17                    ..
        jsr     rom_check_zp                    ; 892C 20 20 00                   .
smiley_no_eq:  lda     toplevvar6                      ; 892F A5 16                    ..
        and     #$7F                            ; 8931 29 7F                    ).
        cmp     #$7F                            ; 8933 C9 7F                    ..
        bne     smiley_check_result                           ; 8935 D0 03                    ..
        jsr     smiley_test2                           ; 8937 20 49 89                  I.
smiley_check_result:  lda     toplevvar3                      ; 893A A5 13                    ..
        beq     smiley_exit                           ; 893C F0 0A                    ..
        and     #$0C                            ; 893E 29 0C                    ).
        bne     smiley_failed                           ; 8940 D0 03                    ..
        jmp     smiley_good_face                ; 8942 4C A2 8A                 L..

; ----------------------------------------------------------------------------
smiley_failed:  jmp     smiley_bad_face                 ; 8945 4C A8 8A                 L..

; ----------------------------------------------------------------------------
smiley_exit:  rts                                     ; 8948 60                       `

; Test 2 - Char RAM test: write/read incrementing and complement patterns
; ----------------------------------------------------------------------------
smiley_test2:  jsr     smiley_test2_set                           ; 8949 20 E6 89                  ..
smiley_test1a:  ldy     #$40                            ; 894C A0 40                    .@
smiley_test1b:  stx     _vramdata                       ; 894E 8E 07 20                 .. 
        inx                                     ; 8951 E8                       .
        stx     _vramdata                       ; 8952 8E 07 20                 .. 
        inx                                     ; 8955 E8                       .
        stx     _vramdata                       ; 8956 8E 07 20                 .. 
        inx                                     ; 8959 E8                       .
        stx     _vramdata                       ; 895A 8E 07 20                 .. 
        inx                                     ; 895D E8                       .
        dey                                     ; 895E 88                       .
        bne     smiley_test1b                           ; 895F D0 ED                    ..
        inx                                     ; 8961 E8                       .
        sec                                     ; 8962 38                       8
        sbc     #$01                            ; 8963 E9 01                    ..
        bne     smiley_test1a                           ; 8965 D0 E5                    ..
        jsr     smiley_test2_set                           ; 8967 20 E6 89                  ..
        ldy     _vramdata                       ; 896A AC 07 20                 .. 
smiley_test2a:  ldy     #$40                            ; 896D A0 40                    .@
smiley_test2b:  cpx     _vramdata                       ; 896F EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 8972 D0 6B                    .k
        inx                                     ; 8974 E8                       .
        cpx     _vramdata                       ; 8975 EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 8978 D0 65                    .e
        inx                                     ; 897A E8                       .
        cpx     _vramdata                       ; 897B EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 897E D0 5F                    ._
        inx                                     ; 8980 E8                       .
        cpx     _vramdata                       ; 8981 EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 8984 D0 59                    .Y
        inx                                     ; 8986 E8                       .
        dey                                     ; 8987 88                       .
        bne     smiley_test2b                           ; 8988 D0 E5                    ..
        inx                                     ; 898A E8                       .
        sec                                     ; 898B 38                       8
        sbc     #$01                            ; 898C E9 01                    ..
        bne     smiley_test2a                           ; 898E D0 DD                    ..
        jsr     smiley_test2_set                           ; 8990 20 E6 89                  ..
        ldx     #$DA                            ; 8993 A2 DA                    ..
smiley_test3a:  ldy     #$40                            ; 8995 A0 40                    .@
smiley_test3b:  stx     _vramdata                       ; 8997 8E 07 20                 .. 
        dex                                     ; 899A CA                       .
        stx     _vramdata                       ; 899B 8E 07 20                 .. 
        dex                                     ; 899E CA                       .
        stx     _vramdata                       ; 899F 8E 07 20                 .. 
        dex                                     ; 89A2 CA                       .
        stx     _vramdata                       ; 89A3 8E 07 20                 .. 
        dex                                     ; 89A6 CA                       .
        dey                                     ; 89A7 88                       .
        bne     smiley_test3b                           ; 89A8 D0 ED                    ..
        dex                                     ; 89AA CA                       .
        sec                                     ; 89AB 38                       8
        sbc     #$01                            ; 89AC E9 01                    ..
        bne     smiley_test3a                           ; 89AE D0 E5                    ..
        jsr     smiley_test2_set                           ; 89B0 20 E6 89                  ..
        ldx     #$DA                            ; 89B3 A2 DA                    ..
        ldy     _vramdata                       ; 89B5 AC 07 20                 .. 
smiley_test4a:  ldy     #$40                            ; 89B8 A0 40                    .@
smiley_test4b:  cpx     _vramdata                       ; 89BA EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 89BD D0 20                    . 
        dex                                     ; 89BF CA                       .
        cpx     _vramdata                       ; 89C0 EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 89C3 D0 1A                    ..
        dex                                     ; 89C5 CA                       .
        cpx     _vramdata                       ; 89C6 EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 89C9 D0 14                    ..
        dex                                     ; 89CB CA                       .
        cpx     _vramdata                       ; 89CC EC 07 20                 .. 
        bne     smiley_cram_fail                           ; 89CF D0 0E                    ..
        dex                                     ; 89D1 CA                       .
        dey                                     ; 89D2 88                       .
        bne     smiley_test4b                           ; 89D3 D0 E5                    ..
        dex                                     ; 89D5 CA                       .
        sec                                     ; 89D6 38                       8
        sbc     #$01                            ; 89D7 E9 01                    ..
        bne     smiley_test4a                           ; 89D9 D0 DD                    ..
        lda     #$02                            ; 89DB A9 02                    ..
        bne     smiley_store_result                           ; 89DD D0 02                    ..
smiley_cram_fail:  lda     #$08                            ; 89DF A9 08                    ..
smiley_store_result:  ora     toplevvar3                      ; 89E1 05 13                    ..
        sta     toplevvar3                      ; 89E3 85 13                    ..
        rts                                     ; 89E5 60                       `

; TEST2_SET - set VRAM address to $0000 for CHR RAM access
; ROM_CHECK - source of relocating code copied to ZP for self-modifying execution
; ----------------------------------------------------------------------------
smiley_test2_set:  lda     #$20                            ; 89E6 A9 20                    . 
smiley_rom_check:  ldx     #$25                            ; 89E8 A2 25                    .%
        ldy     #$00                            ; 89EA A0 00                    ..
        sty     _vramaddr                       ; 89EC 8C 06 20                 .. 
        sty     _vramaddr                       ; 89EF 8C 06 20                 .. 
        rts                                     ; 89F2 60                       `

; KEYPAD - read controller 1 into pad1 variable
; ----------------------------------------------------------------------------
smiley_keypad:  ldx     #$01                            ; 89F3 A2 01                    ..
        stx     _kpreg1                         ; 89F5 8E 16 40                 ..@
        dex                                     ; 89F8 CA                       .
        stx     _kpreg1                         ; 89F9 8E 16 40                 ..@
        ldy     #$08                            ; 89FC A0 08                    ..
smiley_pad_loop:  lda     _kpreg1                         ; 89FE AD 16 40                 ..@
        lsr     a                               ; 8A01 4A                       J
        rol     toplevvar6                      ; 8A02 26 16                    &.
        dey                                     ; 8A04 88                       .
        bne     smiley_pad_loop                           ; 8A05 D0 F7                    ..
        rts                                     ; 8A07 60                       `

; ROM checksum loop: checksums all banks, compares against expected values
; ----------------------------------------------------------------------------
        ldy     #$00                            ; 8A08 A0 00                    ..
smiley_here2:  lda     toplevvar4                      ; 8A0A A5 14                    ..
        jsr     set_bank_zp                     ; 8A0C 20 86 00                  ..
        lda     #$10                            ; 8A0F A9 10                    ..
        sta     toplevvar5                      ; 8A11 85 15                    ..
        lda     #$80                            ; 8A13 A9 80                    ..
        sta     $41                             ; 8A15 85 41                    .A
        lda     #$90                            ; 8A17 A9 90                    ..
        sta     lives                           ; 8A19 85 48                    .H
        lda     #$A0                            ; 8A1B A9 A0                    ..
        sta     heartxl                         ; 8A1D 85 4F                    .O
        lda     #$B0                            ; 8A1F A9 B0                    ..
        sta     $56                             ; 8A21 85 56                    .V
        ldx     #$00                            ; 8A23 A2 00                    ..
        txa                                     ; 8A25 8A                       .
        clc                                     ; 8A26 18                       .
smiley_here:  adc     cm_logo,x                       ; 8A27 7D 00 80                 }..
        bcc     smiley_herea                           ; 8A2A 90 02                    ..
        iny                                     ; 8A2C C8                       .
        clc                                     ; 8A2D 18                       .
smiley_herea:  adc     bank2_page_9000,x                         ; 8A2E 7D 00 90                 }..
        bcc     smiley_hereb                           ; 8A31 90 02                    ..
        iny                                     ; 8A33 C8                       .
        clc                                     ; 8A34 18                       .
smiley_hereb:  adc     bank2_page_a000,x                         ; 8A35 7D 00 A0                 }..
        bcc     smiley_herec                           ; 8A38 90 02                    ..
        iny                                     ; 8A3A C8                       .
        clc                                     ; 8A3B 18                       .
smiley_herec:  adc     bank2_page_b000,x                         ; 8A3C 7D 00 B0                 }..
        bcc     smiley_hered                           ; 8A3F 90 02                    ..
        iny                                     ; 8A41 C8                       .
        clc                                     ; 8A42 18                       .
smiley_hered:  inx                                     ; 8A43 E8                       .
        bne     smiley_here                           ; 8A44 D0 E1                    ..
        inc     $41                             ; 8A46 E6 41                    .A
        inc     lives                           ; 8A48 E6 48                    .H
        inc     heartxl                         ; 8A4A E6 4F                    .O
        inc     $56                             ; 8A4C E6 56                    .V
        dec     toplevvar5                      ; 8A4E C6 15                    ..
        bne     smiley_here                           ; 8A50 D0 D5                    ..
        ldx     toplevvar4                      ; 8A52 A6 14                    ..
        cmp     a:$A7,x                         ; 8A54 DD A7 00                 ...
        bne     smiley_fail_it                           ; 8A57 D0 0F                    ..
        lda     toplevvar4                      ; 8A59 A5 14                    ..
        dec     toplevvar4                      ; 8A5B C6 14                    ..
        cmp     #$0C                            ; 8A5D C9 0C                    ..
        bne     smiley_here2                           ; 8A5F D0 A9                    ..
        lda     #$01                            ; 8A61 A9 01                    ..
        cpy     a:$B7                           ; 8A63 CC B7 00                 ...
        beq     smiley_test2_balls                           ; 8A66 F0 02                    ..
; ROM check failed: set bit 2 in test_byte
smiley_fail_it:  lda     #$04                            ; 8A68 A9 04                    ..
smiley_test2_balls:  sta     toplevvar3                      ; 8A6A 85 13                    ..
        lda     toplevvar7                      ; 8A6C A5 17                    ..
        tax                                     ; 8A6E AA                       .
        sta     $C00A,x                         ; 8A6F 9D 0A C0                 ...
        rts                                     ; 8A72 60                       `

; --- SMILEY checksum expected values + NOP padding ---
; ----------------------------------------------------------------------------
smiley_checksums:
        .byte   $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA ; 8A73 EA EA EA EA EA EA EA EA  ........
        .byte   $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA ; 8A7B EA EA EA EA EA EA EA EA  ........
        .byte   $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA ; 8A83 EA EA EA EA EA EA EA EA  ........
        .byte   $EA,$EA,$EA,$EA,$00,$00,$00,$00 ; 8A8B EA EA EA EA 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; 8A93 00 00 00 00 00 00 00 00  ........
        .byte   $70,$88,$53,$58,$E0,$14,$0E     ; 8A9B 70 88 53 58 E0 14 0E     p.SX...
; Good face: green smiley ($55 checkerboard, $1A green background)
; ----------------------------------------------------------------------------
smiley_good_face:
        ldx     #$55                            ; 8AA2 A2 55                    .U
        lda     #$1A                            ; 8AA4 A9 1A                    ..
        bne     smiley_show_face                           ; 8AA6 D0 04                    ..
; Bad face: red smiley ($AA inverse checkerboard, $16 red background)
smiley_bad_face:
        ldx     #$AA                            ; 8AA8 A2 AA                    ..
        lda     #$16                            ; 8AAA A9 16                    ..
; SHOW_FACE - A=bg colour, X=face mask. Writes diagnostic result to $4400
smiley_show_face:  stx     toplevvar8                      ; 8AAC 86 18                    ..
        ldx     toplevvar3                      ; 8AAE A6 13                    ..
        stx     $4400                           ; 8AB0 8E 00 44                 ..D
        ldy     #$00                            ; 8AB3 A0 00                    ..
        sty     _control1                       ; 8AB5 8C 01 20                 .. 
        ldx     #$3F                            ; 8AB8 A2 3F                    .?
        stx     _vramaddr                       ; 8ABA 8E 06 20                 .. 
        sty     _vramaddr                       ; 8ABD 8C 06 20                 .. 
        jsr     smiley_store                           ; 8AC0 20 2D 8B                  -.
        ora     #$30                            ; 8AC3 09 30                    .0
        jsr     smiley_store                           ; 8AC5 20 2D 8B                  -.
        jsr     smiley_store                           ; 8AC8 20 2D 8B                  -.
        ; Download 1 solid character (16 bytes of $FF to CHR RAM)
        sty     _vramaddr                       ; 8ACB 8C 06 20                 .. 
        sty     _vramaddr                       ; 8ACE 8C 06 20                 .. 
        ldx     #$10                            ; 8AD1 A2 10                    ..
        dey                                     ; 8AD3 88                       .
smiley_solid_chr:  sty     _vramdata                       ; 8AD4 8C 07 20                 .. 
        dex                                     ; 8AD7 CA                       .
        bne     smiley_solid_chr                           ; 8AD8 D0 FA                    ..
        ; Print face - fill nametable with incrementing tiles
        lda     #$20                            ; 8ADA A9 20                    . 
        sta     _vramaddr                       ; 8ADC 8D 06 20                 .. 
        stx     _vramaddr                       ; 8ADF 8E 06 20                 .. 
        txa                                     ; 8AE2 8A                       .
        ldy     #$04                            ; 8AE3 A0 04                    ..
smiley_print_face:  sta     _vramdata                       ; 8AE5 8D 07 20                 .. 
        inx                                     ; 8AE8 E8                       .
        bne     smiley_print_face                           ; 8AE9 D0 FA                    ..
        dey                                     ; 8AEB 88                       .
        bne     smiley_print_face                           ; 8AEC D0 F7                    ..
        ; Write face attribute data masked by pass/fail pattern
        lda     #$23                            ; 8AEE A9 23                    .#
        sta     _vramaddr                       ; 8AF0 8D 06 20                 .. 
        lda     #$C8                            ; 8AF3 A9 C8                    ..
        sta     _vramaddr                       ; 8AF5 8D 06 20                 .. 
        ldy     #$00                            ; 8AF8 A0 00                    ..
smiley_attr_loop:  lda     face_data,y                     ; 8AFA B9 3A 8B                 .:.
        and     toplevvar8                      ; 8AFD 25 18                    %.
        sta     _vramdata                       ; 8AFF 8D 07 20                 .. 
        iny                                     ; 8B02 C8                       .
        cpy     #$30                            ; 8B03 C0 30                    .0
        bcc     smiley_attr_loop                           ; 8B05 90 F3                    ..
        ldx     #$00                            ; 8B07 A2 00                    ..
        stx     _control0                       ; 8B09 8E 00 20                 .. 
        stx     _vramaddr                       ; 8B0C 8E 06 20                 .. 
        stx     _vramaddr                       ; 8B0F 8E 06 20                 .. 
        stx     _scrollcon                      ; 8B12 8E 05 20                 .. 
        stx     _scrollcon                      ; 8B15 8E 05 20                 .. 
        lda     #$0E                            ; 8B18 A9 0E                    ..
        sta     _control1                       ; 8B1A 8D 01 20                 .. 
        ; Wait a few seconds then turn screen off
        ldy     #$0A                            ; 8B1D A0 0A                    ..
smiley_wait:  dec     temp1                           ; 8B1F C6 32                    .2
        bne     smiley_wait                           ; 8B21 D0 FC                    ..
        dex                                     ; 8B23 CA                       .
        bne     smiley_wait                           ; 8B24 D0 F9                    ..
        dey                                     ; 8B26 88                       .
        bne     smiley_wait                           ; 8B27 D0 F6                    ..
        sty     _control1                       ; 8B29 8C 01 20                 .. 
        rts                                     ; 8B2C 60                       `

; ----------------------------------------------------------------------------
smiley_store:  sta     _vramdata                       ; 8B2D 8D 07 20                 .. 
        sta     _vramdata                       ; 8B30 8D 07 20                 .. 
        sta     _vramdata                       ; 8B33 8D 07 20                 .. 
        sta     _vramdata                       ; 8B36 8D 07 20                 .. 
        rts                                     ; 8B39 60                       `

; --- face tile data (48 bytes) ---
; ----------------------------------------------------------------------------
face_data:
        .byte   $00,$C0,$FC,$FF,$FF,$F0,$00,$00 ; 8B3A 00 C0 FC FF FF F0 00 00  ........
        .byte   $40,$FF,$87,$FF,$B7,$CF,$73,$00 ; 8B42 40 FF 87 FF B7 CF 73 00  @.....s.
        .byte   $44,$FF,$FE,$B7,$FF,$FE,$77,$00 ; 8B4A 44 FF FE B7 FF FE 77 00  D.....w.
        .byte   $44,$FF,$07,$F5,$35,$CF,$77,$00 ; 8B52 44 FF 07 F5 35 CF 77 00  D...5.w.
        .byte   $00,$CF,$F9,$FA,$FA,$FD,$03,$00 ; 8B5A 00 CF F9 FA FA FD 03 00  ........
        .byte   $00,$00,$0F,$0F,$0F,$03,$00,$00 ; 8B62 00 00 0F 0F 0F 03 00 00  ........
; --- collision chr indices ---
collisionchr:
        .byte   $0E,$00,$80                     ; 8B6A 0E 00 80                 ...
solidcollisionchr:
        .byte   $0F,$FF                         ; 8B6D 0F FF                    ..
; --- PP1 compressed character sets (hiscore, title, robin, map tiles) ---
hiscorechrs:
        .byte   $C8,$20,$A0,$FF,$7F,$DD,$D6,$A8 ; 8B6F C8 20 A0 FF 7F DD D6 A8  . ......
        .byte   $DA,$3F,$8D,$A3,$55,$FF,$CC,$D3 ; 8B77 DA 3F 8D A3 55 FF CC D3  .?..U...
        .byte   $A8,$DA,$33,$4D,$A3,$F5,$FF,$DD ; 8B7F A8 DA 33 4D A3 F5 FF DD  ..3M....
        .byte   $D6,$A8,$DF,$9B,$4D,$EB,$FF,$99 ; 8B87 D6 A8 DF 9B 4D EB FF 99  ....M...
        .byte   $A7,$51,$B5,$9F,$AF,$FE,$EE,$B5 ; 8B8F A7 51 B5 9F AF FE EE B5  .Q......
        .byte   $47,$B9,$BE,$6D,$37,$AF,$FE,$DF ; 8B97 47 B9 BE 6D 37 AF FE DF  G..m7...
        .byte   $3A,$8E,$B9,$FA,$D7,$DF,$FD,$DD ; 8B9F 3A 8E B9 FA D7 DF FD DD  :.......
        .byte   $6B,$CD,$53,$08,$DA,$6F,$5F,$FC ; 8BA7 6B CD 53 08 DA 6F 5F FC  k.S..o_.
        .byte   $D5,$36,$8C,$E3,$A8,$D5,$35,$9F ; 8BAF D5 36 8C E3 A8 D5 35 9F  .6....5.
        .byte   $FD,$DB,$6D,$DD,$7D,$BB,$7F,$F6 ; 8BB7 FD DB 6D DD 7D BB 7F F6  ..m.}...
        .byte   $F8,$AB,$7A,$E5,$5B,$6E,$FF,$E6 ; 8BBF F8 AB 7A E5 5B 6E FF E6  ..z.[n..
        .byte   $A9,$96,$7B,$9F,$66,$41,$AA,$FF ; 8BC7 A9 96 7B 9F 66 41 AA FF  ..{.fA..
        .byte   $E7,$7B,$5F,$B5,$47,$EB,$FF,$9C ; 8BCF E7 7B 5F B5 47 EB FF 9C  .{_.G...
        .byte   $A6,$16,$6C,$9A,$CF,$FE,$66,$9D ; 8BD7 A6 16 6C 9A CF FE 66 9D  ..l...f.
        .byte   $46,$D4,$D5,$33,$9F,$FD,$DD,$6A ; 8BDF 46 D4 D5 33 9F FD DD 6A  F..3...j
        .byte   $8D,$A9,$AA,$DD,$BF,$F9,$9A,$75 ; 8BE7 8D A9 AA DD BF F9 9A 75  .......u
        .byte   $1B,$46,$A9,$F6,$6F,$BF,$FB,$BA ; 8BEF 1B 46 A9 F6 6F BF FB BA  .F..o...
        .byte   $D5,$1B,$46,$E1,$AA,$D9,$3F,$F9 ; 8BF7 D5 1B 46 E1 AA D9 3F F9  ..F...?.
        .byte   $9A,$75,$1B,$47,$E9,$AA,$6D,$3F ; 8BFF 9A 75 1B 47 E9 AA 6D 3F  .u.G..m?
        .byte   $FB,$7A,$6D,$36,$EF,$69,$B4,$DE ; 8C07 FB 7A 6D 36 EF 69 B4 DE  .zm6.i..
        .byte   $BF,$F9,$FC,$54,$3D,$7B,$AE,$FF ; 8C0F BF F9 FC 54 3D 7B AE FF  ...T={..
        .byte   $E7,$53,$55,$B4,$CE,$93,$FF,$9C ; 8C17 E7 53 55 B4 CE 93 FF 9C  .SU.....
        .byte   $AD,$56,$D2,$BB,$6F,$FE,$75,$33 ; 8C1F AD 56 D2 BB 6F FE 75 33  .V..o.u3
        .byte   $46,$16,$D3,$3F,$F9,$D4,$4E,$BB ; 8C27 46 16 D3 3F F9 D4 4E BB  F..?..N.
        .byte   $76,$80,$D6,$7F,$F3,$A8,$92,$7B ; 8C2F 76 80 D6 7F F3 A8 92 7B  v......{
        .byte   $5E,$B7,$5E,$FF,$ED,$F1,$6C,$F6 ; 8C37 5E B7 5E FF ED F1 6C F6  ^.^...l.
        .byte   $B6,$E7,$61,$FA,$FF,$EF,$5D,$D7 ; 8C3F B6 E7 61 FA FF EF 5D D7  ..a...].
        .byte   $BF,$ED,$7E,$FF,$BB,$6D,$2B,$EA ; 8C47 BF ED 7E FF BB 6D 2B EA  ..~..m+.
        .byte   $F5,$BF,$EE,$BE,$FF,$FB,$AE,$F3 ; 8C4F F5 BF EE BE FF FB AE F3  ........
        .byte   $B9,$F7,$FF,$DD,$7B,$FF,$DE,$BB ; 8C57 B9 F7 FF DD 7B FF DE BB  ....{...
        .byte   $FE,$EB,$DF,$FF,$FE,$F6,$BA,$4D ; 8C5F FE EB DF FF FE F6 BA 4D  .......M
        .byte   $55,$A5,$76,$DF,$FD,$EB,$76,$DE ; 8C67 55 A5 76 DF FD EB 76 DE  U.v...v.
        .byte   $BD,$DD,$7F,$F7,$75,$9A,$7E,$9D ; 8C6F BD DD 7F F7 75 9A 7E 9D  ....u.~.
        .byte   $D6,$B1,$BE,$7F,$F7,$75,$9A,$7B ; 8C77 D6 B1 BE 7F F7 75 9A 7B  .....u.{
        .byte   $5F,$A6,$A9,$DD,$7F,$F7,$5D,$AF ; 8C7F 5F A6 A9 DD 7F F7 5D AF  _.....].
        .byte   $69,$5B,$E7,$D5,$EB,$7F,$F7,$79 ; 8C87 69 5B E7 D5 EB 7F F7 79  i[.....y
        .byte   $AC,$6E,$DF,$56,$55,$DB,$7F,$F7 ; 8C8F AC 6E DF 56 55 DB 7F F7  .n.VU...
        .byte   $B5,$D7,$6F,$5A,$AB,$BA,$FF,$EE ; 8C97 B5 D7 6F 5A AB BA FF EE  ..oZ....
        .byte   $F3,$54,$FA,$DE,$BB,$FF,$BB,$AD ; 8C9F F3 54 FA DE BB FF BB AD  .T......
        .byte   $53,$BA,$D5,$5D,$D7,$FF,$77,$5A ; 8CA7 53 BA D5 5D D7 FF 77 5A  S..]..wZ
        .byte   $AB,$BC,$FA,$BB,$6F,$F9,$60,$80 ; 8CAF AB BC FA BB 6F F9 60 80  ....o.`.
        .byte   $F5,$D3,$DC,$FF,$8F,$D7,$67,$FE ; 8CB7 F5 D3 DC FF 8F D7 67 FE  ......g.
        .byte   $BC,$DF,$B7,$FF,$9E,$E7,$FE,$B3 ; 8CBF BC DF B7 FF 9E E7 FE B3  ........
        .byte   $DE,$F7,$FF,$49,$7A,$7E,$9F,$F4 ; 8CC7 DE F7 FF 49 7A 7E 9F F4  ...Iz~..
        .byte   $7E,$DF,$1F,$E8,$AE,$9E,$E7,$FE ; 8CCF 7E DF 1F E8 AE 9E E7 FE  ~.......
        .byte   $BF,$2F,$F3,$FF,$FA,$30,$C8,$0F ; 8CD7 BF 2F F3 FF FA 30 C8 0F  ./...0..
        .byte   $F8,$C7,$C6,$8F,$10,$5E,$3F,$C7 ; 8CDF F8 C7 C6 8F 10 5E 3F C7  .....^?.
        .byte   $E2,$E7,$37,$E7,$FF,$10,$5C,$06 ; 8CE7 E2 E7 37 E7 FF 10 5C 06  ..7...\.
        .byte   $B4,$7B,$3F,$D1,$ED,$9E,$56,$79 ; 8CEF B4 7B 3F D1 ED 9E 56 79  .{?...Vy
        .byte   $18,$88,$40,$D0,$19,$D0,$AF,$E7 ; 8CF7 18 88 40 D0 19 D0 AF E7  ..@.....
        .byte   $FC,$7D,$46,$FD,$7F,$7F,$A3,$38 ; 8CFF FC 7D 46 FD 7F 7F A3 38  .}F....8
        .byte   $8D,$A4,$1E,$38,$F4,$C7,$A6,$BF ; 8D07 8D A4 1E 38 F4 C7 A6 BF  ...8....
        .byte   $FC,$00,$74,$FC,$7E,$91,$C9,$A0 ; 8D0F FC 00 74 FC 7E 91 C9 A0  ..t.~...
        .byte   $FF,$E3,$B0,$33,$AA,$4F,$8F,$FF ; 8D17 FF E3 B0 33 AA 4F 8F FF  ...3.O..
        .byte   $B7,$F9,$87,$98,$3A,$63,$EA,$5F ; 8D1F B7 F9 87 98 3A 63 EA 5F  ....:c._
        .byte   $7F,$FA,$60,$37,$63,$FF,$FF,$DC ; 8D27 7F FA 60 37 63 FF FF DC  ..`7c...
        .byte   $BF,$FE,$FE,$2D,$FF,$EF,$C5,$DF ; 8D2F BF FE FE 2D FF EF C5 DF  ...-....
        .byte   $FD,$F8,$B8,$50,$F5,$E7,$96,$C1 ; 8D37 FD F8 B8 50 F5 E7 96 C1  ...P....
        .byte   $7F,$AF,$74,$FE,$FF,$EF,$BD,$7F ; 8D3F 7F AF 74 FE FF EF BD 7F  ..t.....
        .byte   $5B,$EF,$FE,$FE,$B7,$88,$A7,$F7 ; 8D47 5B EF FE FE B7 88 A7 F7  [.......
        .byte   $FF,$7D,$D7,$06,$FF,$BE,$EB,$83 ; 8D4F FF 7D D7 06 FF BE EB 83  .}......
        .byte   $CB,$A8,$8B,$8E,$3F,$F1,$F8,$7D ; 8D57 CB A8 8B 8E 3F F1 F8 7D  ....?..}
        .byte   $1E,$E3,$FF,$0C,$74,$6C,$4F,$69 ; 8D5F 1E E3 FF 0C 74 6C 4F 69  ....tlOi
        .byte   $E4,$C7,$FF,$08,$F5,$D7,$8E,$E3 ; 8D67 E4 C7 FF 08 F5 D7 8E E3  ........
        .byte   $C8,$7C,$8F,$C3,$FF,$A3,$52,$BB ; 8D6F C8 7C 8F C3 FF A3 52 BB  .|....R.
        .byte   $2F,$E5,$3A,$21,$8E,$3F,$F7,$FE ; 8D77 2F E5 3A 21 8E 3F F7 FE  /.:!.?..
        .byte   $BA,$C2,$3C,$7F,$E0,$07,$AE,$CA ; 8D7F BA C2 3C 7F E0 07 AE CA  ..<.....
        .byte   $A1,$7F,$9B,$CE,$DE,$BF,$E0,$0A ; 8D87 A1 7F 9B CE DE BF E0 0A  ........
        .byte   $F7,$2B,$0E,$EF,$A8,$6D,$54,$57 ; 8D8F F7 2B 0E EF A8 6D 54 57  .+...mTW
        .byte   $FE,$FF,$40,$C1,$65,$C1,$91,$85 ; 8D97 FE FF 40 C1 65 C1 91 85  ..@.e...
        .byte   $B3,$00,$03,$43,$E5,$60,$EF,$A8 ; 8D9F B3 00 03 43 E5 60 EF A8  ...C.`..
        .byte   $7D,$D6,$6E,$DF,$ED,$87,$6A,$98 ; 8DA7 7D D6 6E DF ED 87 6A 98  }.n...j.
        .byte   $82,$67,$91,$3D,$42,$02,$A8,$19 ; 8DAF 82 67 91 3D 42 02 A8 19  .g.=B...
        .byte   $B3,$CB,$22,$70,$33,$3F,$F1,$FF ; 8DB7 B3 CB 22 70 33 3F F1 FF  .."p3?..
        .byte   $BF,$EF,$9D,$9D,$9D,$C7,$59,$DB ; 8DBF BF EF 9D 9D 9D C7 59 DB  ......Y.
        .byte   $C2,$DC,$05,$9E,$71,$29,$46,$26 ; 8DC7 C2 DC 05 9E 71 29 46 26  ....q)F&
        .byte   $20,$48,$24,$60,$98,$8A,$14,$7F ; 8DCF 20 48 24 60 98 8A 14 7F   H$`....
        .byte   $E7,$FB,$CC,$82,$92,$EE,$F7,$8F ; 8DD7 E7 FB CC 82 92 EE F7 8F  ........
        .byte   $77,$FF,$E8,$7E,$9A,$A2,$BC,$F5 ; 8DDF 77 FF E8 7E 9A A2 BC F5  w..~....
        .byte   $1F,$EF,$FF,$67,$FE,$FF,$EA,$F8 ; 8DE7 1F EF FF 67 FE FF EA F8  ...g....
        .byte   $8F,$18,$C3,$28,$4B,$89,$0C,$44 ; 8DEF 8F 18 C3 28 4B 89 0C 44  ...(K..D
        .byte   $52,$01,$83,$6F,$20,$B2,$18,$C2 ; 8DF7 52 01 83 6F 20 B2 18 C2  R..o ...
        .byte   $3C,$44,$E3,$18,$3F,$E0,$FE,$1F ; 8DFF 3C 44 E3 18 3F E0 FE 1F  <D..?...
        .byte   $C7,$98,$F9,$1E,$A3,$DA,$EB,$16 ; 8E07 C7 98 F9 1E A3 DA EB 16  ........
        .byte   $F0,$37,$09,$67,$BD,$A8,$6D,$83 ; 8E0F F0 37 09 67 BD A8 6D 83  .7.g..m.
        .byte   $69,$26,$2A,$ED,$43,$2E,$42,$03 ; 8E17 69 26 2A ED 43 2E 42 03  i&*.C.B.
        .byte   $FF,$8F,$21,$65,$F1,$E0,$8F,$5C ; 8E1F FF 8F 21 65 F1 E0 8F 5C  ..!e...\
        .byte   $71,$04,$4B,$89,$FD,$AF,$0B,$68 ; 8E27 71 04 4B 89 FD AF 0B 68  q.K....h
        .byte   $0F,$41,$09,$09,$EC,$51,$FF,$AD ; 8E2F 0F 41 09 09 EC 51 FF AD  .A...Q..
        .byte   $38,$F4,$0F,$FE,$CC,$CB,$12,$45 ; 8E37 38 F4 0F FE CC CB 12 45  8......E
        .byte   $96,$B1,$55,$07,$60,$7F,$CA,$C1 ; 8E3F 96 B1 55 07 60 7F CA C1  ..U.`...
        .byte   $E3,$8C,$41,$D6,$B1,$63,$02,$25 ; 8E47 E3 8C 41 D6 B1 63 02 25  ..A..c.%
        .byte   $01,$52,$14,$01,$81,$12,$80,$A9 ; 8E4F 01 52 14 01 81 12 80 A9  .R......
        .byte   $0A,$02,$D6,$21,$03,$41,$42,$0B ; 8E57 0A 02 D6 21 03 41 42 0B  ...!.AB.
        .byte   $41,$42,$04,$E3,$31,$FF,$9F,$34 ; 8E5F 41 42 04 E3 31 FF 9F 34  AB..1..4
        .byte   $6B,$B7,$3F,$BF,$F7,$EA,$BE,$E3 ; 8E67 6B B7 3F BF F7 EA BE E3  k.?.....
        .byte   $DA,$DD,$AE,$F1,$EF,$FD,$B9,$DB ; 8E6F DA DD AE F1 EF FD B9 DB  ........
        .byte   $96,$DD,$2B,$7D,$5B,$D6,$DE,$6D ; 8E77 96 DD 2B 7D 5B D6 DE 6D  ..+}[..m
        .byte   $D7,$6E,$79,$EB,$9F,$94,$C3,$1F ; 8E7F D7 6E 79 EB 9F 94 C3 1F  .ny.....
        .byte   $0A,$FD,$FD,$DE,$AE,$19,$7B,$9F ; 8E87 0A FD FD DE AE 19 7B 9F  ......{.
        .byte   $DF,$FD,$E3,$DC,$17,$61,$AD,$1E ; 8E8F DF FD E3 DC 17 61 AD 1E  .....a..
        .byte   $AC,$35,$DB,$9F,$D1,$AE,$7C,$DF ; 8E97 AC 35 DB 9F D1 AE 7C DF  .5....|.
        .byte   $FB,$F6,$BE,$11,$F6,$AF,$09,$7B ; 8E9F FB F6 BE 11 F6 AF 09 7B  .......{
        .byte   $37,$64,$11,$F1,$FF,$BD,$CF,$B8 ; 8EA7 37 64 11 F1 FF BD CF B8  7d......
        .byte   $6A,$EF,$8F,$FD,$C1,$77,$8F,$7F ; 8EAF 6A EF 8F FD C1 77 8F 7F  j....w..
        .byte   $FF,$7C,$37,$BA,$B8,$56,$EE,$77 ; 8EB7 FF 7C 37 BA B8 56 EE 77  .|7..V.w
        .byte   $79,$7B,$EF,$87,$3E,$B7,$86,$BE ; 8EBF 79 7B EF 87 3E B7 86 BE  y{..>...
        .byte   $1B,$F7,$BF,$E9,$FC,$F5,$EF,$E0 ; 8EC7 1B F7 BF E9 FC F5 EF E0  ........
        .byte   $F8,$6F,$0C,$7B,$97,$0A,$DD,$CF ; 8ECF F8 6F 0C 7B 97 0A DD CF  .o.{....
        .byte   $9F,$E9,$C2,$BF,$A3,$FF,$F7,$F8 ; 8ED7 9F E9 C2 BF A3 FF F7 F8  ........
        .byte   $FF,$BB,$9D,$DD,$6E,$1A,$BE,$1B ; 8EDF FF BB 9D DD 6E 1A BE 1B  ....n...
        .byte   $FF,$3F,$8F,$0E,$FD,$EF,$85,$78 ; 8EE7 FF 3F 8F 0E FD EF 85 78  .?.....x
        .byte   $61,$F5,$BF,$F7,$73,$B8,$56,$F7 ; 8EEF 61 F5 BF F7 73 B8 56 F7  a...s.V.
        .byte   $2F,$0C,$7C,$37,$F0,$7F,$FE,$FE ; 8EF7 2F 0C 7C 37 F0 7F FE FE  /.|7....
        .byte   $89,$C2,$9F,$EF,$FD,$F0,$DC,$35 ; 8EFF 89 C2 9F EF FD F0 DC 35  .......5
        .byte   $61,$9B,$73,$A2,$BC,$E7,$F3,$AF ; 8F07 61 9B 73 A2 BC E7 F3 AF  a.s.....
        .byte   $61,$AD,$EE,$AF,$B8,$F8,$57,$EF ; 8F0F 61 AD EE AF B8 F8 57 EF  a.....W.
        .byte   $DB,$C6,$C3,$C7,$79,$77,$5B,$B9 ; 8F17 DB C6 C3 C7 79 77 5B B9  ....yw[.
        .byte   $F9,$E7,$70,$AD,$E1,$57,$DC,$DE ; 8F1F F9 E7 70 AD E1 57 DC DE  ..p..W..
        .byte   $15,$70,$CC,$E7,$D1,$5E,$DC,$EC ; 8F27 15 70 CC E7 D1 5E DC EC  .p...^..
        .byte   $33,$70,$D5,$F0,$DF,$FB,$F7,$BE ; 8F2F 33 70 D5 F0 DF FB F7 BE  3p......
        .byte   $15,$F7,$1E,$EA,$C3,$59,$D7,$BF ; 8F37 15 F7 1E EA C3 59 D7 BF  .....Y..
        .byte   $F7,$73,$77,$EE,$E0,$3B,$9D,$86 ; 8F3F F7 73 77 EE E0 3B 9D 86  .sw..;..
        .byte   $B6,$F9,$7F,$E8,$E6,$75,$E6,$7C ; 8F47 B6 F9 7F E8 E6 75 E6 7C  .....u.|
        .byte   $EB,$D8,$66,$E1,$AB,$C3,$BF,$F7 ; 8F4F EB D8 66 E1 AB C3 BF F7  ..f.....
        .byte   $E1,$78,$6B,$86,$5D,$CD,$85,$76 ; 8F57 E1 78 6B 86 5D CD 85 76  .xk.]..v
        .byte   $E7,$E6,$BE,$C2,$BB,$85,$6F,$73 ; 8F5F E7 E6 BE C2 BB 85 6F 73  ......os
        .byte   $B8,$56,$C3,$3B,$73,$1B,$FB,$0A ; 8F67 B8 56 C3 3B 73 1B FB 0A  .V.;s...
        .byte   $EE,$E6,$E1,$97,$86,$BF,$0B,$FF ; 8F6F EE E6 E1 97 86 BF 0B FF  ........
        .byte   $3C,$81,$FC,$7F,$EF,$D2,$F0,$A9 ; 8F77 3C 81 FC 7F EF D2 F0 A9  <.......
        .byte   $FC,$7F,$D6,$B1,$63,$E0,$79,$47 ; 8F7F FC 7F D6 B1 63 E0 79 47  ....c.yG
        .byte   $A8,$F4,$1F,$03,$CA,$3D,$47,$A5 ; 8F87 A8 F4 1F 03 CA 3D 47 A5  .....=G.
        .byte   $90,$2C,$28,$8A,$9B,$10,$59,$02 ; 8F8F 90 2C 28 8A 9B 10 59 02  .,(...Y.
        .byte   $C2,$88,$A9,$B1,$05,$19,$CC,$7F ; 8F97 C2 88 A9 B1 05 19 CC 7F  ........
        .byte   $F7,$FA,$FF,$1F,$D5,$FC,$EF,$FB ; 8F9F F7 FA FF 1F D5 FC EF FB  ........
        .byte   $4F,$A5,$3C,$82,$72,$43,$92,$26 ; 8FA7 4F A5 3C 82 72 43 92 26  O.<.rC.&
        .byte   $4C,$3C,$7F,$20,$AF,$FF,$FF,$FF ; 8FAF 4C 3C 7F 20 AF FF FF FF  L<. ....
        .byte   $FF,$FF,$F1,$F8,$7D,$E3,$DE,$37 ; 8FB7 FF FF F1 F8 7D E3 DE 37  ....}..7
        .byte   $88,$E2,$98,$BE,$35,$88,$E2,$FD ; 8FBF 88 E2 98 BE 35 88 E2 FD  ....5...
        .byte   $73,$41,$22,$77,$F0,$A2,$06,$88 ; 8FC7 73 41 22 77 F0 A2 06 88  sA"w....
        .byte   $40,$31,$85,$9E,$D9,$A0,$68,$80 ; 8FCF 40 31 85 9E D9 A0 68 80  @1....h.
        .byte   $E1,$01,$D1,$3C,$D8,$97,$3F,$33 ; 8FD7 E1 01 D1 3C D8 97 3F 33  ...<..?3
        .byte   $E7,$3C,$FB,$3F,$07,$D0,$FB,$3F ; 8FDF E7 3C FB 3F 07 D0 FB 3F  .<.?...?
        .byte   $66,$8C,$28,$C0,$B9,$08,$C2,$05 ; 8FE7 66 8C 28 C0 B9 08 C2 05  f.(.....
        .byte   $A0,$80,$56,$1F,$11,$80,$FF,$FE ; 8FEF A0 80 56 1F 11 80 FF FE  ..V.....
        .byte   $FF,$23,$19,$8F,$E5,$A5,$51,$04 ; 8FF7 FF 23 19 8F E5 A5 51 04  .#....Q.
        .byte   $50                             ; 8FFF 50                       P
bank2_page_9000:  .byte   $90,$10,$86,$13,$89,$A2,$52,$CA ; 9000 90 10 86 13 89 A2 52 CA  ......R.
        .byte   $CC,$98,$64,$8A,$84,$82,$04,$28 ; 9008 CC 98 64 8A 84 82 04 28  ..d....(
        .byte   $04,$30,$90,$82,$90,$05,$93,$0B ; 9010 04 30 90 82 90 05 93 0B  .0......
        .byte   $7F,$CA,$FD,$8B,$EE,$1E,$40,$F9 ; 9018 7F CA FD 8B EE 1E 40 F9  ......@.
        .byte   $AF,$99,$FB,$49,$47,$26,$34,$98 ; 9020 AF 99 FB 49 47 26 34 98  ...IG&4.
        .byte   $8A,$E9,$CF,$42,$FB,$FC,$C9,$16 ; 9028 8A E9 CF 42 FB FC C9 16  ...B....
        .byte   $12,$18,$42,$61,$D7,$5F,$F3,$9E ; 9030 12 18 42 61 D7 5F F3 9E  ..Ba._..
        .byte   $C0,$3C,$4E,$21,$02,$90,$30,$3A ; 9038 C0 3C 4E 21 02 90 30 3A  .<N!..0:
        .byte   $90,$72,$0B,$6F,$F3,$F8,$FF,$FE ; 9040 90 72 0B 6F F3 F8 FF FE  .r.o....
        .byte   $C3,$90,$6C,$FB,$FF,$F1,$FF,$FF ; 9048 C3 90 6C FB FF F1 FF FF  ..l.....
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF ; 9050 FF FF FF FF FF FF FF FF  ........
        .byte   $FF,$FF,$FF,$FF,$FF,$FF,$E3,$33 ; 9058 FF FF FF FF FF FF E3 33  .......3
        .byte   $8D,$F1,$3E,$0F,$EE,$B1,$12,$02 ; 9060 8D F1 3E 0F EE B1 12 02  ..>.....
        .byte   $99,$29,$0A,$90,$17,$C9,$42,$25 ; 9068 99 29 0A 90 17 C9 42 25  .)....B%
        .byte   $44,$A8,$A8,$06,$07,$F4,$95,$29 ; 9070 44 A8 A8 06 07 F4 95 29  D......)
        .byte   $42,$C8,$2C,$A0,$E5,$0F,$58,$73 ; 9078 42 C8 2C A0 E5 0F 58 73  B.,...Xs
        .byte   $FC,$1F,$09,$D1,$DE,$3E,$63,$CE ; 9080 FC 1F 09 D1 DE 3E 63 CE  .....>c.
        .byte   $D5,$41,$4D,$A3,$25,$57,$39,$D1 ; 9088 D5 41 4D A3 25 57 39 D1  .AM.%W9.
        .byte   $F5,$3F,$70,$C2,$0E,$D0,$80,$63 ; 9090 F5 3F 70 C2 0E D0 80 63  .?p....c
        .byte   $DF,$1F,$0F,$CB,$54,$1A,$3A,$84 ; 9098 DF 1F 0F CB 54 1A 3A 84  ....T.:.
        .byte   $18,$27,$EF,$3E,$CF,$A3,$D2,$77 ; 90A0 18 27 EF 3E CF A3 D2 77  .'.>...w
        .byte   $5A,$3D,$42,$0C,$2A,$0A,$2F,$8B ; 90A8 5A 3D 42 0C 2A 0A 2F 8B  Z=B.*./.
        .byte   $C2,$E0,$B0,$6C,$1B,$86,$F9,$AA ; 90B0 C2 E0 B0 6C 1B 86 F9 AA  ...l....
        .byte   $22,$7C,$4F,$19,$C7,$31,$9A,$4E ; 90B8 22 7C 4F 19 C7 31 9A 4E  "|O..1.N
        .byte   $A7,$AF,$EC,$36,$1F,$FF,$00,$A3 ; 90C0 A7 AF EC 36 1F FF 00 A3  ...6....
        .byte   $A3,$D1,$F4,$7E,$1F,$CC,$07,$ED ; 90C8 A3 D1 F4 7E 1F CC 07 ED  ...~....
        .byte   $F5,$E7,$04,$95,$28,$79,$F8,$F9 ; 90D0 F5 E7 04 95 28 79 F8 F9  ....(y..
        .byte   $1F,$83,$FC,$FD,$CF,$B3,$E8,$F4 ; 90D8 1F 83 FC FD CF B3 E8 F4  ........
        .byte   $1D,$C1,$DB,$1F,$FF,$FF,$FF,$FF ; 90E0 1D C1 DB 1F FF FF FF FF  ........
        .byte   $F0                             ; 90E8 F0                       .
topchrs:.byte   $F5,$03,$63,$FF,$FE,$3F,$46,$51 ; 90E9 F5 03 63 FF FE 3F 46 51  ..c..?FQ
        .byte   $F4,$B6,$C7,$51,$E4,$7D,$13,$CF ; 90F1 F4 B6 C7 51 E4 7D 13 CF  ...Q.}..
        .byte   $71,$5C,$65,$28,$E3,$F8,$AE,$34 ; 90F9 71 5C 65 28 E3 F8 AE 34  q\e(...4
        .byte   $0E,$60,$F8,$9E,$3F,$E2,$F8,$DE ; 9101 0E 60 F8 9E 3F E2 F8 DE  .`..?...
        .byte   $3A,$0F,$26,$C9,$78,$27,$8A,$F1 ; 9109 3A 0F 26 C9 78 27 8A F1  :.&.x'..
        .byte   $D4,$79,$1F,$44,$F3,$DC,$57,$1F ; 9111 D4 79 1F 44 F3 DC 57 1F  .y.D..W.
        .byte   $8B,$D8,$FF,$1F,$A3,$28,$D2,$5B ; 9119 8B D8 FF 1F A3 28 D2 5B  .....(.[
        .byte   $17,$53,$4C,$B3,$2A,$CA,$72,$FC ; 9121 17 53 4C B3 2A CA 72 FC  .SL.*.r.
        .byte   $7F,$1F,$07,$B8,$EA,$3C,$89,$A1 ; 9129 7F 1F 07 B8 EA 3C 89 A1  .....<..
        .byte   $B1,$EC,$2B,$0C,$A5,$1C,$DF,$2F ; 9131 B1 EC 2B 0C A5 1C DF 2F  ..+..../
        .byte   $E5,$F1,$7A,$3E,$8F,$43,$FC,$6F ; 9139 E5 F1 7A 3E 8F 43 FC 6F  ..z>.C.o
        .byte   $1C,$4D,$D2,$90,$BC,$1F,$E3,$5C ; 9141 1C 4D D2 90 BC 1F E3 5C  .M.....\
        .byte   $CA,$3F,$05,$F1,$98,$7F,$0B,$0E ; 9149 CA 3F 05 F1 98 7F 0B 0E  .?......
        .byte   $B1,$F6,$3F,$C7,$E1,$F4,$7C,$1F ; 9151 B1 F6 3F C7 E1 F4 7C 1F  ..?...|.
        .byte   $F8,$AE,$5F,$C1,$F1,$FC,$7D,$83 ; 9159 F8 AE 5F C1 F1 FC 7D 83  .._...}.
        .byte   $C9,$2B,$B1,$F8,$68,$C1,$14,$4F ; 9161 C9 2B B1 F8 68 C1 14 4F  .+..h..O
        .byte   $0C,$E2,$FC,$ED,$9D,$4C,$78,$8E ; 9169 0C E2 FC ED 9D 4C 78 8E  .....Lx.
        .byte   $52,$FC,$A3,$47,$D1,$ED,$2B,$29 ; 9171 52 FC A3 47 D1 ED 2B 29  R..G..+)
        .byte   $5C,$A4,$D4,$E0,$26,$1A,$78,$E9 ; 9179 5C A4 D4 E0 26 1A 78 E9  \...&.x.
        .byte   $8F,$60,$FD,$AE,$51,$C3,$41,$5D ; 9181 8F 60 FD AE 51 C3 41 5D  .`..Q.A]
        .byte   $1D,$D2,$AA,$95,$D2,$BC,$71,$3E ; 9189 1D D2 AA 95 D2 BC 71 3E  ......q>
        .byte   $53,$C7,$20,$0C,$4D,$89,$DF,$2F ; 9191 53 C7 20 0C 4D 89 DF 2F  S. .M../
        .byte   $E3,$3C,$70,$4D,$C9,$44,$17,$81 ; 9199 E3 3C 70 4D C9 44 17 81  .<pM.D..
        .byte   $FC,$7E,$8F,$64,$C5,$0F,$C0,$9F ; 91A1 FC 7E 8F 64 C5 0F C0 9F  .~.d....
        .byte   $18,$E3,$F4,$7D,$1D,$E8,$A6,$94 ; 91A9 18 E3 F4 7D 1D E8 A6 94  ...}....
        .byte   $94,$51,$FE,$2E,$9C,$EA,$FC,$B1 ; 91B1 94 51 FE 2E 9C EA FC B1  .Q......
        .byte   $95,$32,$8C,$C7,$F1,$F2,$3C,$1D ; 91B9 95 32 8C C7 F1 F2 3C 1D  .2....<.
        .byte   $8D,$48,$D5,$3A,$A6,$51,$98,$91 ; 91C1 8D 48 D5 3A A6 51 98 91  .H.:.Q..
        .byte   $80,$3B,$3D,$67,$96,$73,$79,$31 ; 91C9 80 3B 3D 67 96 73 79 31  .;=g.sy1
        .byte   $1A,$07,$EB,$22,$BA,$57,$1B,$31 ; 91D1 1A 07 EB 22 BA 57 1B 31  ...".W.1
        .byte   $EB,$4D,$64,$68,$75,$24,$9B,$50 ; 91D9 EB 4D 64 68 75 24 9B 50  .Mdhu$.P
        .byte   $D1,$47,$3A,$BE,$57,$5A,$AF,$A8 ; 91E1 D1 47 3A BE 57 5A AF A8  .G:.WZ..
        .byte   $CA,$4C,$A4,$E4,$47,$4C,$E8,$7D ; 91E9 CA 4C A4 E4 47 4C E8 7D  .L..GL.}
        .byte   $78,$2E,$4A,$E4,$44,$2F,$C2,$F2 ; 91F1 78 2E 4A E4 44 2F C2 F2  x.J.D/..
        .byte   $EE,$14,$38,$6D,$E0,$37,$09,$A2 ; 91F9 EE 14 38 6D E0 37 09 A2  ..8m.7..
        .byte   $6D,$9F,$8C,$D8,$86,$D4,$FB,$FF ; 9201 6D 9F 8C D8 86 D4 FB FF  m.......
        .byte   $DC,$F8,$E3,$89,$0D,$4C,$DF,$91 ; 9209 DC F8 E3 89 0D 4C DF 91  .....L..
        .byte   $F5,$AF,$9B,$03,$B3,$14,$3F,$02 ; 9211 F5 AF 9B 03 B3 14 3F 02  ......?.
        .byte   $7C,$63,$07,$F0,$58,$3B,$C7,$B3 ; 9219 7C 63 07 F0 58 3B C7 B3  |c..X;..
        .byte   $FF,$E5,$3C,$73,$A4,$A2,$9F,$F0 ; 9221 FF E5 3C 73 A4 A2 9F F0  ..<s....
        .byte   $A3,$64,$75,$FD,$78,$A1,$8B,$32 ; 9229 A3 64 75 FD 78 A1 8B 32  .du.x..2
        .byte   $B3,$3C,$D5,$D3,$67,$44,$E8,$3E ; 9231 B3 3C D5 D3 67 44 E8 3E  .<..gD.>
        .byte   $D9,$C7,$9C,$18,$EB,$9A,$C9,$AC ; 9239 D9 C7 9C 18 EB 9A C9 AC  ........
        .byte   $EA,$6D,$DA,$8E,$B0,$EE,$95,$9C ; 9241 EA 6D DA 8E B0 EE 95 9C  .m......
        .byte   $F1,$AB,$17,$82,$F8,$30,$7F,$13 ; 9249 F1 AB 17 82 F8 30 7F 13  .....0..
        .byte   $F1,$E7,$77,$CB,$EF,$7E,$F7,$C3 ; 9251 F1 E7 77 CB EF 7E F7 C3  ..w..~..
        .byte   $BE,$0B,$E1,$BE,$02,$F0,$0D,$E5 ; 9259 BE 0B E1 BE 02 F0 0D E5  ........
        .byte   $DF,$F7,$F8,$FD,$E3,$AB,$9A,$F9 ; 9261 DF F7 F8 FD E3 AB 9A F9  ........
        .byte   $8F,$F1,$FF,$8C,$F8,$F3,$CC,$28 ; 9269 8F F1 FF 8C F8 F3 CC 28  .......(
        .byte   $EB,$39,$BF,$37,$FF,$3E,$3A,$B9 ; 9271 EB 39 BF 37 FF 3E 3A B9  .9.7.>:.
        .byte   $DF,$3C,$FC,$28,$F4,$C1,$47,$FE ; 9279 DF 3C FC 28 F4 C1 47 FE  .<.(..G.
        .byte   $3F,$0F,$63,$B8,$E9,$1F,$E3,$D0 ; 9281 3F 0F 63 B8 E9 1F E3 D0  ?.c.....
        .byte   $EA,$33,$B7,$E3,$E0,$FA,$92,$B9 ; 9289 EA 33 B7 E3 E0 FA 92 B9  .3......
        .byte   $0F,$28,$E1,$0C,$3C,$B0,$C7,$98 ; 9291 0F 28 E1 0C 3C B0 C7 98  .(..<...
        .byte   $FE,$5F,$D9,$D1,$73,$16,$7A,$9F ; 9299 FE 5F D9 D1 73 16 7A 9F  ._..s.z.
        .byte   $77,$E3,$F8,$FD,$81,$B1,$CC,$79 ; 92A1 77 E3 F8 FD 81 B1 CC 79  w......y
        .byte   $1F,$44,$F3,$DC,$57,$1F,$8B,$D8 ; 92A9 1F 44 F3 DC 57 1F 8B D8  .D..W...
        .byte   $F2,$3A,$97,$E5,$38,$9E,$3F,$8F ; 92B1 F2 3A 97 E5 38 9E 3F 8F  .:..8.?.
        .byte   $D8,$FE,$17,$8A,$E3,$F9,$7E,$3C ; 92B9 D8 FE 17 8A E3 F9 7E 3C  ......~<
        .byte   $89,$23,$FA,$E4,$F5,$49,$DC,$F8 ; 92C1 89 23 FA E4 F5 49 DC F8  .#...I..
        .byte   $FD,$8C,$34,$7E,$96,$14,$B0,$ED ; 92C9 FD 8C 34 7E 96 14 B0 ED  ..4~....
        .byte   $C3,$6E,$04,$5C,$08,$B8,$6B,$81 ; 92D1 C3 6E 04 5C 08 B8 6B 81  .n.\..k.
        .byte   $2A,$49,$1C,$E5,$BF,$FF,$EF,$92 ; 92D9 2A 49 1C E5 BF FF EF 92  *I......
        .byte   $3D,$6D,$E6,$8F,$36,$EB,$25,$CD ; 92E1 3D 6D E6 8F 36 EB 25 CD  =m..6.%.
        .byte   $E3,$DC,$0D,$8E,$63,$C8,$F8,$27 ; 92E9 E3 DC 0D 8E 63 C8 F8 27  ....c..'
        .byte   $9E,$E2,$B8,$FC,$5E,$9D,$93,$1F ; 92F1 9E E2 B8 FC 5E 9D 93 1F  ....^...
        .byte   $83,$EA,$34,$B1,$2A,$09,$60,$95 ; 92F9 83 EA 34 B1 2A 09 60 95  ..4.*.`.
        .byte   $44,$AC,$4A,$91,$F2,$0D,$2F,$FD ; 9301 44 AC 4A 91 F2 0D 2F FD  D.J.../.
        .byte   $FD,$BF,$D0,$36,$3F,$46,$B1,$B4 ; 9309 FD BF D0 36 3F 46 B1 B4  ...6?F..
        .byte   $79,$1F,$E1,$BA,$ED,$CC,$89,$84 ; 9311 79 1F E1 BA ED CC 89 84  y.......
        .byte   $4A,$91,$28,$24,$C1,$25,$44,$8D ; 9319 4A 91 28 24 C1 25 44 8D  J.($.%D.
        .byte   $0A,$89,$0A,$66,$FF,$2F,$E8,$FE ; 9321 0A 89 0A 66 FF 2F E8 FE  ...f./..
        .byte   $77,$E9,$7E,$60,$7C,$DE,$8E,$D8 ; 9329 77 E9 7E 60 7C DE 8E D8  w.~`|...
        .byte   $FA,$0D,$E2,$E8,$14,$A4,$35,$57 ; 9331 FA 0D E2 E8 14 A4 35 57  ......5W
        .byte   $27,$30,$4A,$41,$38,$05,$A2,$82 ; 9339 27 30 4A 41 38 05 A2 82  '0JA8...
        .byte   $EB,$95,$DE,$76,$0C,$F7,$FE,$B9 ; 9341 EB 95 DE 76 0C F7 FE B9  ...v....
        .byte   $C7,$65,$61,$45,$38,$A9,$E6,$FC ; 9349 C7 65 61 45 38 A9 E6 FC  .eaE8...
        .byte   $AF,$AD,$7C,$CB,$9F,$41,$30,$27 ; 9351 AF AD 7C CB 9F 41 30 27  ..|..A0'
        .byte   $C9,$9E,$F9,$AE,$BC,$1F,$23,$9C ; 9359 C9 9E F9 AE BC 1F 23 9C  ......#.
        .byte   $67,$D9,$4E,$CC,$F7,$CE,$F3,$AE ; 9361 67 D9 4E CC F7 CE F3 AE  g.N.....
        .byte   $B9,$73,$4B,$99,$B5,$A6,$CC,$F8 ; 9369 B9 73 4B 99 B5 A6 CC F8  .sK.....
        .byte   $F9,$79,$C7,$D6,$3F,$3F,$B9,$3B ; 9371 F9 79 C7 D6 3F 3F B9 3B  .y..??.;
        .byte   $9C,$BC,$F7,$CE,$F9,$47,$AD,$1E ; 9379 9C BC F7 CE F9 47 AD 1E  .....G..
        .byte   $B2,$F3,$26,$0A,$DB,$B7,$63,$E8 ; 9381 B2 F3 26 0A DB B7 63 E8  ..&...c.
        .byte   $AA,$FF,$87,$E3,$78,$DA,$B9,$13 ; 9389 AA FF 87 E3 78 DA B9 13  ....x...
        .byte   $66,$7B,$94,$DC,$CD,$E6,$5E,$BD ; 9391 66 7B 94 DC CD E6 5E BD  f{....^.
        .byte   $F9,$BF,$CB,$F3,$7D,$63,$E6,$3C ; 9399 F9 BF CB F3 7D 63 E6 3C  ....}c.<
        .byte   $CB,$9C,$8F,$31,$CE,$27,$EF,$29 ; 93A1 CB 9C 8F 31 CE 27 EF 29  ...1.'.)
        .byte   $75,$A5,$D6,$47,$33,$72,$9B,$5A ; 93A9 75 A5 D6 47 33 72 9B 5A  u..G3r.Z
        .byte   $6D,$67,$66,$78,$9C,$84,$F0,$1F ; 93B1 6D 67 66 78 9C 84 F0 1F  mgfx....
        .byte   $28,$F5,$47,$96,$52,$5C,$FC,$1F ; 93B9 28 F5 47 96 52 5C FC 1F  (.G.R\..
        .byte   $8E,$78,$9F,$07,$E0,$F8,$8F,$28 ; 93C1 8E 78 9F 07 E0 F8 8F 28  .x.....(
        .byte   $E7,$7F,$EF,$F2,$D7,$31,$F8,$3F ; 93C9 E7 7F EF F2 D7 31 F8 3F  .....1.?
        .byte   $84,$CE,$CC,$E3,$D2,$21,$E0,$EB ; 93D1 84 CE CC E3 D2 21 E0 EB  .....!..
        .byte   $7F,$F0,$7F,$7C,$EF,$CD,$F9,$5F ; 93D9 7F F0 7F 7C EF CD F9 5F  ...|..._
        .byte   $5A,$0C,$CB,$9E,$6F,$AE,$F9,$AF ; 93E1 5A 0C CB 9E 6F AE F9 AF  Z...o...
        .byte   $98,$F5,$A3,$CC,$FB,$FA,$BF,$CF ; 93E9 98 F5 A3 CC FB FA BF CF  ........
        .byte   $BF,$AC,$1F,$89,$F1,$3C,$13,$91 ; 93F1 BF AC 1F 89 F1 3C 13 91  .....<..
        .byte   $35,$89,$9C,$1A,$DB,$FF,$47,$E3 ; 93F9 35 89 9C 1A DB FF 47 E3  5.....G.
        .byte   $4E,$3D,$2E,$72,$F3,$34,$99,$26 ; 9401 4E 3D 2E 72 F3 34 99 26  N=.r.4.&
        .byte   $7A,$FE,$5F,$FB,$B3,$BB,$CB,$C6 ; 9409 7A FE 5F FB B3 BB CB C6  z._.....
        .byte   $3E,$E4,$6A,$DE,$F3,$DF,$FD,$F6 ; 9411 3E E4 6A DE F3 DF FD F6  >.j.....
        .byte   $5F,$72,$42,$9F,$B3,$F7,$FF,$AE ; 9419 5F 72 42 9F B3 F7 FF AE  _rB.....
        .byte   $44,$DD,$69,$6B,$98,$E7,$19,$EC ; 9421 44 DD 69 6B 98 E7 19 EC  D.ik....
        .byte   $CE,$E5,$37,$33,$6B,$9D,$F3,$2F ; 9429 CE E5 37 33 6B 9D F3 2F  ..73k../
        .byte   $94,$7A,$D1,$EB,$2F,$32,$F2,$97 ; 9431 94 7A D1 EB 2F 32 F2 97  .z../2..
        .byte   $5A,$6F,$CF,$BE,$BD,$F2,$8F,$93 ; 9439 5A 6F CF BE BD F2 8F 93  Zo......
        .byte   $07,$98,$3E,$84,$F8,$9E,$89,$E0 ; 9441 07 98 3E 84 F8 9E 89 E0  ..>.....
        .byte   $CE,$0C,$D6,$CD,$31,$CE,$33,$C2 ; 9449 CE 0C D6 CD 31 CE 33 C2  ....1.3.
        .byte   $7D,$FF,$7F,$97,$FE,$EB,$37,$33 ; 9451 7D FF 7F 97 FE EB 37 33  }.....73
        .byte   $B5,$CC,$7C,$84,$92,$0F,$DF,$FB ; 9459 B5 CC 7C 84 92 0F DF FB  ..|.....
        .byte   $D6,$6F,$29,$79,$3B,$99,$8F,$C1 ; 9461 D6 6F 29 79 3B 99 8F C1  .o)y;...
        .byte   $32,$53,$92,$CC,$96,$B8,$5C,$F5 ; 9469 32 53 92 CC 96 B8 5C F5  2S....\.
        .byte   $D7,$8F,$38,$F3,$47,$C9,$BA,$E4 ; 9471 D7 8F 38 F3 47 C9 BA E4  ..8.G...
        .byte   $7F,$8A,$64,$1F,$51,$FB,$FF,$DF ; 9479 7F 8A 64 1F 51 FB FF DF  ..d.Q...
        .byte   $C8,$3C,$89,$F8,$CF,$8C,$ED,$FF ; 9481 C8 3C 89 F8 CF 8C ED FF  .<......
        .byte   $89,$F1,$F4,$1F,$C6,$64,$67,$05 ; 9489 89 F1 F4 1F C6 64 67 05  .....dg.
        .byte   $3B,$7C,$9B,$FF,$47,$E2,$7E,$33 ; 9491 3B 7C 9B FF 47 E2 7E 33  ;|..G.~3
        .byte   $CB,$27,$03,$FE,$7B,$8A,$3A,$A1 ; 9499 CB 27 03 FE 7B 8A 3A A1  .'..{.:.
        .byte   $DC,$7B,$FF,$2B,$19,$82,$66,$D3 ; 94A1 DC 7B FF 2B 19 82 66 D3  .{.+..f.
        .byte   $E8,$FE,$56,$13,$7F,$C1,$26,$3C ; 94A9 E8 FE 56 13 7F C1 26 3C  ..V...&<
        .byte   $C6,$78,$9F,$83,$FD,$FE,$BF,$97 ; 94B1 C6 78 9F 83 FD FE BF 97  .x......
        .byte   $FB,$7E,$57,$F8,$FF,$5F,$22,$2C ; 94B9 FB 7E 57 F8 FF 5F 22 2C  .~W.._",
        .byte   $61,$A1,$88,$75,$2F,$F4,$AC,$EF ; 94C1 61 A1 88 75 2F F4 AC EF  a..u/...
        .byte   $E8,$7F,$07,$B2,$0F,$D0,$3F,$0D ; 94C9 E8 7F 07 B2 0F D0 3F 0D  ......?.
        .byte   $D8,$97,$D0,$60,$62,$0E,$08,$98 ; 94D1 D8 97 D0 60 62 0E 08 98  ...`b...
        .byte   $30,$10,$41,$82,$90,$5C,$1B,$E1 ; 94D9 30 10 41 82 90 5C 1B E1  0.A..\..
        .byte   $BE,$10,$EC,$12,$F0,$CB,$C2,$17 ; 94E1 BE 10 EC 12 F0 CB C2 17  ........
        .byte   $24,$8D,$F2,$38,$42,$58,$34,$38 ; 94E9 24 8D F2 38 42 58 34 38  $..8BX48
        .byte   $73,$05,$76,$5B,$F1,$24,$32,$0D ; 94F1 73 05 76 5B F1 24 32 0D  s.v[.$2.
        .byte   $45,$51,$91,$A4,$8F,$E2,$B0,$6C ; 94F9 45 51 91 A4 8F E2 B0 6C  EQ.....l
        .byte   $0E,$8F,$E3,$98,$FE,$3D,$C1,$71 ; 9501 0E 8F E3 98 FE 3D C1 71  .....=.q
        .byte   $C4,$73,$1E,$45,$41,$9E,$35,$C4 ; 9509 C4 73 1E 45 41 9E 35 C4  .s.EA.5.
        .byte   $F1,$9C,$7F,$8E,$71,$EC,$7E,$B7 ; 9511 F1 9C 7F 8E 71 EC 7E B7  ....q.~.
        .byte   $6D,$E8,$12,$0B,$BA,$CE,$6B,$66 ; 9519 6D E8 12 0B BA CE 6B 66  m.....kf
        .byte   $DF,$C6,$B8,$E6,$39,$0F,$C3,$F8 ; 9521 DF C6 B8 E6 39 0F C3 F8  ....9...
        .byte   $3E,$F1,$5D,$86,$FC,$49,$0A,$83 ; 9529 3E F1 5D 86 FC 49 0A 83  >.]..I..
        .byte   $41,$58,$66,$6A,$63,$FB,$7F,$15 ; 9531 41 58 66 6A 63 FB 7F 15  AXfjc...
        .byte   $C4,$F0,$7C,$25,$0F,$4C,$72,$3A ; 9539 C4 F0 7C 25 0F 4C 72 3A  ..|%.Lr:
        .byte   $C7,$54,$3B,$86,$F1,$FF,$DE,$1B ; 9541 C7 54 3B 86 F1 FF DE 1B  .T;.....
        .byte   $A3,$02,$30,$3E,$EF,$B7,$E3,$FB ; 9549 A3 02 30 3E EF B7 E3 FB  ..0>....
        .byte   $7F,$1F,$F8,$F5,$1F,$63,$16,$26 ; 9551 7F 1F F8 F5 1F 63 16 26  .....c.&
        .byte   $B6,$9F,$00,$F0,$27,$74,$CE,$35 ; 9559 B6 9F 00 F0 27 74 CE 35  ....'t.5
        .byte   $B1,$B7,$FC,$7F,$FC,$4E,$41,$D8 ; 9561 B1 B7 FC 7F FC 4E 41 D8  .....NA.
        .byte   $97,$06,$97,$C4,$F7,$BB,$E3,$FC ; 9569 97 06 97 C4 F7 BB E3 FC  ........
        .byte   $0C,$C0,$C9,$DF,$B7,$E3,$FF,$17 ; 9571 0C C0 C9 DF B7 E3 FF 17  ........
        .byte   $64,$DC,$EF,$1F,$FE,$3F,$4D,$58 ; 9579 64 DC EF 1F FE 3F 4D 58  d....?MX
        .byte   $66,$8B,$E1,$BE,$5D,$CE,$E9,$EF ; 9581 66 8B E1 BE 5D CE E9 EF  f...]...
        .byte   $1F,$E3,$F4,$7D,$8C,$58,$87,$88 ; 9589 1F E3 F4 7D 8C 58 87 88  ...}.X..
        .byte   $B8,$F7,$39,$3E,$75,$4F,$29,$D6 ; 9591 B8 F7 39 3E 75 4F 29 D6  ..9>uO).
        .byte   $3A,$E7,$3C,$FF,$E7,$54,$DA,$9B ; 9599 3A E7 3C FF E7 54 DA 9B  :.<..T..
        .byte   $63,$AE,$73,$CF,$FE,$1B,$C7,$F1 ; 95A1 63 AE 73 CF FE 1B C7 F1  c.s.....
        .byte   $5E,$1D,$CF,$D0,$F1,$87,$1C,$FB ; 95A9 5E 1D CF D0 F1 87 1C FB  ^.......
        .byte   $89,$B8,$09,$B0,$29,$CA,$47,$52 ; 95B1 89 B8 09 B0 29 CA 47 52  ....).GR
        .byte   $C8,$01,$CD,$7C,$3F,$C0,$9C,$3E ; 95B9 C8 01 CD 7C 3F C0 9C 3E  ...|?..>
        .byte   $43,$3A,$FF,$62,$79,$37,$73,$44 ; 95C1 43 3A FF 62 79 37 73 44  C:.by7sD
        .byte   $9E,$89,$FA,$7F,$FC,$77,$85,$79 ; 95C9 9E 89 FA 7F FC 77 85 79  .....w.y
        .byte   $FE,$37,$C7,$78,$F7,$36,$E7,$9D ; 95D1 FE 37 C7 78 F7 36 E7 9D  .7.x.6..
        .byte   $72,$73,$7E,$6F,$E5,$4F,$8B,$99 ; 95D9 72 73 7E 6F E5 4F 8B 99  rs~o.O..
        .byte   $B6,$1F,$53,$F8,$FF,$BE,$51,$F3 ; 95E1 B6 1F 53 F8 FF BE 51 F3  ..S...Q.
        .byte   $1F,$9B,$F5,$BF,$C5,$9E,$37,$CE ; 95E9 1F 9B F5 BF C5 9E 37 CE  ......7.
        .byte   $FB,$F9,$7E,$6F,$9C,$7E,$0F,$96 ; 95F1 FB F9 7E 6F 9C 7E 0F 96  ..~o.~..
        .byte   $67,$7F,$D6,$7C,$19,$8F,$99,$BF ; 95F9 67 7F D6 7C 19 8F 99 BF  g..|....
        .byte   $2B,$F3,$7F,$2F,$EA,$15,$C0,$FF ; 9601 2B F3 7F 2F EA 15 C0 FF  +../....
        .byte   $F2,$4F,$33,$E7,$FC,$64,$74,$CF ; 9609 F2 4F 33 E7 FC 64 74 CF  .O3..dt.
        .byte   $B3,$FF,$ED,$01,$E2,$F2,$7E,$9F ; 9611 B3 FF ED 01 E2 F2 7E 9F  ......~.
        .byte   $FF,$9F,$D9,$FB,$4B,$9A,$40,$82 ; 9619 FF 9F D9 FB 4B 9A 40 82  ....K.@.
        .byte   $31,$23,$7F,$F7,$F8,$FF,$5F,$D8 ; 9621 31 23 7F F7 F8 FF 5F D8  1#...._.
        .byte   $7B,$8F,$F1,$BC,$1B,$D8,$BC,$61 ; 9629 7B 8F F1 BC 1B D8 BC 61  {......a
        .byte   $F7,$7E,$38,$BF,$C1,$3F,$0F,$E1 ; 9631 F7 7E 38 BF C1 3F 0F E1  .~8..?..
        .byte   $F8,$1F,$A8,$F8,$85,$26,$30,$6B ; 9639 F8 1F A8 F8 85 26 30 6B  .....&0k
        .byte   $8C,$88,$6A,$E6,$3F,$1D,$9B,$FE ; 9641 8C 88 6A E6 3F 1D 9B FE  ..j.?...
        .byte   $BB,$8E,$F3,$DC,$FF,$DF,$BB,$DE ; 9649 BB 8E F3 DC FF DF BB DE  ........
        .byte   $F6,$5F,$F5,$FC,$7F,$3F,$EF,$D8 ; 9651 F6 5F F5 FC 7F 3F EF D8  ._...?..
        .byte   $FF,$76,$AF,$FD,$7F,$1F,$C2,$91 ; 9659 FF 76 AF FD 7F 1F C2 91  .v......
        .byte   $00,$2F,$AF,$E3,$FA,$56,$6B,$85 ; 9661 00 2F AF E3 FA 56 6B 85  ./...Vk.
        .byte   $01,$25,$06,$1A,$0C,$25,$43,$0A ; 9669 01 25 06 1A 0C 25 43 0A  .%...%C.
        .byte   $00,$74,$03,$0A,$02,$00,$7F,$A4 ; 9671 00 74 03 0A 02 00 7F A4  .t......
        .byte   $AD,$EB,$0A,$00,$74,$03,$0A,$01 ; 9679 AD EB 0A 00 74 03 0A 01  ....t...
        .byte   $C1,$00,$E0,$C1,$B9,$41,$C2,$82 ; 9681 C1 00 E0 C1 B9 41 C2 82  .....A..
        .byte   $A0,$84,$7F,$33,$92,$79,$2D,$20 ; 9689 A0 84 7F 33 92 79 2D 20  ...3.y- 
        .byte   $77,$87,$D8,$7F,$C4,$C6,$22,$46 ; 9691 77 87 D8 7F C4 C6 22 46  w....."F
        .byte   $0F,$60,$F7,$1D,$E2,$F6,$F7,$23 ; 9699 0F 60 F7 1D E2 F6 F7 23  .`.....#
        .byte   $76,$01,$8C,$34,$45,$05,$B7,$22 ; 96A1 76 01 8C 34 45 05 B7 22  v..4E.."
        .byte   $39,$37,$67,$FF,$E1,$85,$31,$32 ; 96A9 39 37 67 FF E1 85 31 32  97g...12
        .byte   $E4,$07,$8C,$8E,$26,$C8,$7D,$4B ; 96B1 E4 07 8C 8E 26 C8 7D 4B  ....&.}K
        .byte   $62,$0F,$F1,$FB,$18,$81,$8C,$20 ; 96B9 62 0F F1 FB 18 81 8C 20  b...... 
        .byte   $08,$FF,$1B,$28,$A4,$05,$D0,$F4 ; 96C1 08 FF 1B 28 A4 05 D0 F4  ...(....
        .byte   $06,$90,$F6,$3F,$8C,$65,$9A,$91 ; 96C9 06 90 F6 3F 8C 65 9A 91  ...?.e..
        .byte   $AF,$19,$3B,$BF,$F8,$FE,$8F,$D4 ; 96D1 AF 19 3B BF F8 FE 8F D4  ..;.....
        .byte   $FA,$36,$23,$4A,$98,$BB,$EF,$FC ; 96D9 FA 36 23 4A 98 BB EF FC  .6#J....
        .byte   $7F,$F8,$F8,$18,$71,$F8,$7D,$1E ; 96E1 7F F8 F8 18 71 F8 7D 1E  ....q.}.
        .byte   $83,$4C,$7E,$1E,$C7,$70,$36,$19 ; 96E9 83 4C 7E 1E C7 70 36 19  .L~..p6.
        .byte   $42,$FC,$5F,$07,$C0,$78,$5E,$17 ; 96F1 42 FC 5F 07 C0 78 5E 17  B._..x^.
        .byte   $0A,$82,$1D,$91,$1F,$C6,$1C,$45 ; 96F9 0A 82 1D 91 1F C6 1C 45  .......E
        .byte   $E0,$76,$9E,$07,$30,$3F,$61,$90 ; 9701 E0 76 9E 07 30 3F 61 90  .v..0?a.
        .byte   $1F,$E2,$22,$0A,$63,$9C,$0C,$C1 ; 9709 1F E2 22 0A 63 9C 0C C1  ..".c...
        .byte   $4D,$63,$C1,$89,$7C,$89,$91,$25 ; 9711 4D 63 C1 89 7C 89 91 25  Mc..|..%
        .byte   $09,$59,$A9,$30,$51,$FC,$7E,$1F ; 9719 09 59 A9 30 51 FC 7E 1F  .Y.0Q.~.
        .byte   $E3,$EC,$7B,$1C,$63,$FF,$8F,$A3 ; 9721 E3 EC 7B 1C 63 FF 8F A3  ..{.c...
        .byte   $D8,$EF,$1F,$A2,$58,$5A,$FA,$BF ; 9729 D8 EF 1F A2 58 5A FA BF  ....XZ..
        .byte   $FD,$FE,$7F,$FF,$BA,$AD,$5B,$4C ; 9731 FD FE 7F FF BA AD 5B 4C  ......[L
        .byte   $CB,$3E,$B7,$E1,$FE,$0A,$D0,$68 ; 9739 CB 3E B7 E1 FE 0A D0 68  .>.....h
        .byte   $E5,$32,$33,$8E,$73,$D8,$FE,$2C ; 9741 E5 32 33 8E 73 D8 FE 2C  .23.s..,
        .byte   $9C,$1F,$FE,$FF,$3F,$A8,$F5,$4D ; 9749 9C 1F FE FF 3F A8 F5 4D  ....?..M
        .byte   $DF,$FD,$8F,$A3,$FB,$FF,$FD,$FE ; 9751 DF FD 8F A3 FB FF FD FE  ........
        .byte   $E0,$FC,$1D,$85,$D8,$FF,$FB,$FE ; 9759 E0 FC 1D 85 D8 FF FB FE  ........
        .byte   $8F,$D6,$68,$3F,$29,$B3,$B6,$7F ; 9761 8F D6 68 3F 29 B3 B6 7F  ..h?)...
        .byte   $EF,$EA,$3B,$5F,$C1,$DC,$BB,$9F ; 9769 EF EA 3B 5F C1 DC BB 9F  ..;_....
        .byte   $F9,$8E,$DB,$3B,$7C,$61,$EE,$AC ; 9771 F9 8E DB 3B 7C 61 EE AC  ...;|a..
        .byte   $2A,$23,$62,$2C,$6C,$8E,$06,$A7 ; 9779 2A 23 62 2C 6C 8E 06 A7  *#b,l...
        .byte   $F1,$EC,$70,$CC,$93,$1C,$9D,$81 ; 9781 F1 EC 70 CC 93 1C 9D 81  ..p.....
        .byte   $DF,$6E,$2C,$24,$31,$03,$19,$13 ; 9789 DF 6E 2C 24 31 03 19 13  .n,$1...
        .byte   $18,$DF,$B6,$FB,$BD,$78,$CF,$FE ; 9791 18 DF B6 FB BD 78 CF FE  .....x..
        .byte   $7F,$9D,$B3,$1A,$63,$C8,$F8,$3F ; 9799 7F 9D B3 1A 63 C8 F8 3F  ....c..?
        .byte   $7F,$E1,$5C,$43,$7F,$FF,$4A,$CB ; 97A1 7F E1 5C 43 7F FF 4A CB  ..\C..J.
        .byte   $86,$63,$8E,$7A,$4F,$D3,$FF,$7A ; 97A9 86 63 8E 7A 4F D3 FF 7A  .c.zO..z
        .byte   $CB,$C3,$3C,$E9,$9F,$65,$93,$83 ; 97B1 CB C3 3C E9 9F 65 93 83  ..<..e..
        .byte   $8F,$B4,$FA,$CF,$5C,$E9,$27,$08 ; 97B9 8F B4 FA CF 5C E9 27 08  ....\.'.
        .byte   $99,$8E,$C1,$FB,$1F,$71,$CF,$75 ; 97C1 99 8E C1 FB 1F 71 CF 75  .....q.u
        .byte   $FF,$F3,$FC,$B3,$87,$1B,$F1,$7F ; 97C9 FF F3 FC B3 87 1B F1 7F  ........
        .byte   $17,$E3,$9F,$FF,$12,$9D,$FD,$7F ; 97D1 17 E3 9F FF 12 9D FD 7F  ........
        .byte   $FF,$83,$F6,$3E,$E3,$DC,$5B,$D7 ; 97D9 FF 83 F6 3E E3 DC 5B D7  ...>..[.
        .byte   $79,$EF,$FE,$3F,$E3,$6A,$D6,$AD ; 97E1 79 EF FE 3F E3 6A D6 AD  y..?.j..
        .byte   $FB,$BF,$BF,$CF,$EB,$FD,$BF,$FC ; 97E9 FB BF BF CF EB FD BF FC  ........
        .byte   $2F,$8F,$E1,$7E,$3F,$DE,$F7,$F4 ; 97F1 2F 8F E1 7E 3F DE F7 F4  /..~?...
        .byte   $B2,$07,$FF,$DF,$E7,$ED,$EE,$DF ; 97F9 B2 07 FF DF E7 ED EE DF  ........
        .byte   $FB,$1F,$A9,$FA,$CE,$5F,$CD,$5C ; 9801 FB 1F A9 FA CE 5F CD 5C  ....._.\
        .byte   $9F,$FD,$FC,$3F,$6F,$BA,$B6,$B9 ; 9809 9F FD FC 3F 6F BA B6 B9  ...?o...
        .byte   $DC,$6B,$65,$1E,$2D,$96,$3F,$B7 ; 9811 DC 6B 65 1E 2D 96 3F B7  .ke.-.?.
        .byte   $F9,$FA,$7D,$CF,$DC,$5B,$C4,$04 ; 9819 F9 FA 7D CF DC 5B C4 04  ..}..[..
        .byte   $08,$94,$84,$11,$0C,$18,$38,$3C ; 9821 08 94 84 11 0C 18 38 3C  ......8<
        .byte   $3E,$49,$F7,$3F,$7C,$92,$48,$FF ; 9829 3E 49 F7 3F 7C 92 48 FF  >I.?|.H.
        .byte   $30,$86,$3D,$5C,$7F,$DA,$6E,$3F ; 9831 30 86 3D 5C 7F DA 6E 3F  0.=\..n?
        .byte   $E3,$1A,$0C,$F1,$6C,$39,$87,$FC ; 9839 E3 1A 0C F1 6C 39 87 FC  ....l9..
        .byte   $63,$9F,$A9,$8D,$1F,$F4,$3F,$C7 ; 9841 63 9F A9 8D 1F F4 3F C7  c.....?.
        .byte   $D8,$F0,$47,$B4,$1C,$8E,$91,$80 ; 9849 D8 F0 47 B4 1C 8E 91 80  ..G.....
        .byte   $9E,$BC,$8D,$BC,$50,$BD,$07,$51 ; 9851 9E BC 8D BC 50 BD 07 51  ....P..Q
        .byte   $A0,$A3,$FC,$93,$F1,$4F,$C2,$68 ; 9859 A0 A3 FC 93 F1 4F C2 68  .....O.h
        .byte   $84,$4C,$02,$F8,$2F,$CC,$19,$F1 ; 9861 84 4C 02 F8 2F CC 19 F1  .L../...
        .byte   $9E,$9F,$97,$F2,$FF,$3F,$FE,$B5 ; 9869 9E 9F 97 F2 FF 3F FE B5  .....?..
        .byte   $12,$EB,$D9,$38,$E6,$C9,$D9,$35 ; 9871 12 EB D9 38 E6 C9 D9 35  ...8...5
        .byte   $92,$46,$18,$90,$8F,$D0,$02,$41 ; 9879 92 46 18 90 8F D0 02 41  .F.....A
        .byte   $A9,$C2,$D5,$E5,$F2,$FD,$5F,$E7 ; 9881 A9 C2 D5 E5 F2 FD 5F E7  ......_.
        .byte   $FF,$18,$5B,$7C,$47,$34,$7F,$1F ; 9889 FF 18 5B 7C 47 34 7F 1F  ..[|G4..
        .byte   $89,$7B,$A5,$3F,$84,$F4,$25,$D5 ; 9891 89 7B A5 3F 84 F4 25 D5  .{.?..%.
        .byte   $BC,$54,$F0,$8F,$EF,$FB,$4E,$55 ; 9899 BC 54 F0 8F EF FB 4E 55  .T....NU
        .byte   $7A,$23,$87,$FF,$00,$FF,$0E,$7F ; 98A1 7A 23 87 FF 00 FF 0E 7F  z#......
        .byte   $08,$8C,$7D,$1D,$46,$51,$14,$0B ; 98A9 08 8C 7D 1D 46 51 14 0B  ..}.FQ..
        .byte   $01,$89,$5C,$FF,$5F,$CF,$F5,$71 ; 98B1 01 89 5C FF 5F CF F5 71  ..\._..q
        .byte   $5B,$3E,$CF,$4C,$FF,$5F,$CF,$F3 ; 98B9 5B 3E CF 4C FF 5F CF F3  [>.L._..
        .byte   $9C,$EB,$3B,$12,$FC,$FF,$5F,$CF ; 98C1 9C EB 3B 12 FC FF 5F CF  ..;..._.
        .byte   $F2,$3D,$4F,$52,$D4,$FC,$FF,$5F ; 98C9 F2 3D 4F 52 D4 FC FF 5F  .=OR..._
        .byte   $CF,$F2,$F4,$BE,$2A,$A5,$EC,$FF ; 98D1 CF F2 F4 BE 2A A5 EC FF  ....*...
        .byte   $5F,$CF,$F5,$6D,$57,$53,$54,$BC ; 98D9 5F CF F5 6D 57 53 54 BC  _..mWST.
        .byte   $FF,$5F,$CF,$E4,$E5,$36,$3D,$8E ; 98E1 FF 5F CF E4 E5 36 3D 8E  ._...6=.
        .byte   $98,$4A,$01,$28,$4A,$26,$80,$88 ; 98E9 98 4A 01 28 4A 26 80 88  .J.(J&..
        .byte   $C9,$62,$6C,$0D,$03,$C4,$61,$94 ; 98F1 C9 62 6C 0D 03 C4 61 94  .bl...a.
        .byte   $75,$1E,$E7,$7A,$97,$3F,$D7,$F3 ; 98F9 75 1E E7 7A 97 3F D7 F3  u..z.?..
        .byte   $FD,$7F,$3F,$EA,$42,$97,$3F,$D7 ; 9901 FD 7F 3F EA 42 97 3F D7  ..?.B.?.
        .byte   $F3,$FD,$7F,$3F,$EA,$5A,$9F,$3F ; 9909 F3 FD 7F 3F EA 5A 9F 3F  ...?.Z.?
        .byte   $D7,$F3,$FD,$7F,$3F,$E5,$E9,$4C ; 9911 D7 F3 FD 7F 3F E5 E9 4C  ....?..L
        .byte   $55,$1F,$EB,$F9,$FE,$BF,$9F,$F5 ; 9919 55 1F EB F9 FE BF 9F F5  U.......
        .byte   $35,$57,$56,$CF,$F5,$FC,$FF,$5F ; 9921 35 57 56 CF F5 FC FF 5F  5WV...._
        .byte   $CF,$F9,$BE,$8B,$4F,$F5,$FC,$FE ; 9929 CF F9 BE 8B 4F F5 FC FE  ....O...
        .byte   $5F,$CD,$70,$94,$22,$12,$89,$E8 ; 9931 5F CD 70 94 22 12 89 E8  _.p."...
        .byte   $5E,$13,$E2,$83,$80,$46,$41,$F8 ; 9939 5E 13 E2 83 80 46 41 F8  ^....FA.
        .byte   $FF,$F0,$80,$BF,$91,$FA,$FC,$47 ; 9941 FF F0 80 BF 91 FA FC 47  .......G
        .byte   $C0,$DC,$5E,$0B,$78,$7C,$17,$C7 ; 9949 C0 DC 5E 0B 78 7C 17 C7  ..^.x|..
        .byte   $F0,$98,$35,$0B,$43,$E0,$A8,$2D ; 9951 F0 98 35 0B 43 E0 A8 2D  ..5.C..-
        .byte   $1F,$F1,$78,$2D,$87,$C1,$70,$BC ; 9959 1F F1 78 2D 87 C1 70 BC  ..x-..p.
        .byte   $3F,$E2,$F0,$5C,$1F,$0B,$E0,$E8 ; 9961 3F E2 F0 5C 1F 0B E0 E8  ?..\....
        .byte   $BC,$3F,$C7,$50,$FC,$6B,$15,$E2 ; 9969 BC 3F C7 50 FC 6B 15 E2  .?.P.k..
        .byte   $B0,$DC,$3F,$E2,$E8,$5B,$C5,$C1 ; 9971 B0 DC 3F E2 E8 5B C5 C1  ..?..[..
        .byte   $FC                             ; 9979 FC                       .
botchrs:.byte   $F5,$0C,$41,$FF,$FC,$66,$40,$00 ; 997A F5 0C 41 FF FC 66 40 00  ..A..f@.
        .byte   $64,$00,$06,$40,$00,$64,$01,$76 ; 9982 64 00 06 40 00 64 01 76  d..@.d.v
        .byte   $44,$1E,$C4,$29,$06,$08,$0C,$50 ; 998A 44 1E C4 29 06 08 0C 50  D..)...P
        .byte   $00,$08,$80,$12,$0D,$5A,$D5,$CC ; 9992 00 08 80 12 0D 5A D5 CC  .....Z..
        .byte   $15,$FF,$08,$98,$81,$09,$82,$61 ; 999A 15 FF 08 98 81 09 82 61  .......a
        .byte   $1F,$F7,$76,$FF,$8C,$EC,$CB,$34 ; 99A2 1F F7 76 FF 8C EC CB 34  ..v....4
        .byte   $CC,$B2,$EF,$FC,$31,$00,$64,$00 ; 99AA CC B2 EF FC 31 00 64 00  ....1.d.
        .byte   $06,$40,$00,$64,$04,$06,$40,$57 ; 99B2 06 40 00 64 04 06 40 57  .@.d..@W
        .byte   $27,$C0,$13,$AC,$F5,$17,$28,$51 ; 99BA 27 C0 13 AC F5 17 28 51  '.....(Q
        .byte   $AA,$FD,$53,$C5,$38,$A1,$31,$B1 ; 99C2 AA FD 53 C5 38 A1 31 B1  ..S.8.1.
        .byte   $E8,$75,$85,$78,$BD,$0E,$99,$B9 ; 99CA E8 75 85 78 BD 0E 99 B9  .u.x....
        .byte   $0B,$98,$3C,$E6,$DC,$C1,$F9,$79 ; 99D2 0B 98 3C E6 DC C1 F9 79  ..<....y
        .byte   $3E,$23,$CD,$8F,$81,$38,$31,$BE ; 99DA 3E 23 CD 8F 81 38 31 BE  >#...81.
        .byte   $3B,$F3,$69,$36,$01,$ED,$26,$FC ; 99E2 3B F3 69 36 01 ED 26 FC  ;.i6..&.
        .byte   $F5,$FD,$7E,$FA,$F9,$03,$62,$F9 ; 99EA F5 FD 7E FA F9 03 62 F9  ..~...b.
        .byte   $FF,$CA,$F3,$58,$19,$9F,$FF,$0F ; 99F2 FF CA F3 58 19 9F FF 0F  ...X....
        .byte   $CD,$73,$62,$3F,$3F,$EB,$CE,$BE ; 99FA CD 73 62 3F 3F EB CE BE  .sb??...
        .byte   $2F,$DC,$D5,$D8,$B0,$86,$E8,$75 ; 9A02 2F DC D5 D8 B0 86 E8 75  /......u
        .byte   $07,$E7,$FE,$B7,$AF,$F2,$3E,$22 ; 9A0A 07 E7 FE B7 AF F2 3E 22  ......>"
        .byte   $4D,$92,$14,$37,$B6,$F9,$DF,$FC ; 9A12 4D 92 14 37 B6 F9 DF FC  M..7....
        .byte   $FF,$FF,$89,$F0,$7E,$0A,$40,$20 ; 9A1A FF FF 89 F0 7E 0A 40 20  ....~.@ 
        .byte   $B3,$83,$F9,$7F,$E7,$F9,$FC,$47 ; 9A22 B3 83 F9 7F E7 F9 FC 47  .......G
        .byte   $21,$13,$78,$37,$CE,$FF,$E7,$F8 ; 9A2A 21 13 78 37 CE FF E7 F8  !.x7....
        .byte   $9F,$07,$E0,$A4,$02,$03,$3A,$3F ; 9A32 9F 07 E0 A4 02 03 3A 3F  ......:?
        .byte   $AF,$F8,$06,$7F,$11,$6D,$C0,$C6 ; 9A3A AF F8 06 7F 11 6D C0 C6  .....m..
        .byte   $CE,$39,$E9,$3F,$4F,$FF,$7F,$D3 ; 9A42 CE 39 E9 3F 4F FF 7F D3  .9.?O...
        .byte   $DA,$FE,$0E,$65,$DC,$FF,$ED,$C8 ; 9A4A DA FE 0E 65 DC FF ED C8  ...e....
        .byte   $B3,$28,$B8,$0F,$C7,$FF,$0C,$6B ; 9A52 B3 28 B8 0F C7 FF 0C 6B  .(.....k
        .byte   $FA,$EE,$B0,$63,$C5,$38,$0E,$19 ; 9A5A FA EE B0 63 C5 38 0E 19  ...c.8..
        .byte   $A1,$9B,$E7,$79,$F7,$3E,$B9,$F7 ; 9A62 A1 9B E7 79 F7 3E B9 F7  ...y.>..
        .byte   $E7,$BF,$1F,$C7,$02,$3F,$FE,$AC ; 9A6A E7 BF 1F C7 02 3F FE AC  .....?..
        .byte   $38,$FF,$86,$B4,$7F,$08,$20,$34 ; 9A72 38 FF 86 B4 7F 08 20 34  8..... 4
        .byte   $F0,$C4,$1F,$47,$88,$FB,$1E,$22 ; 9A7A F0 C4 1F 47 88 FB 1E 22  ...G..."
        .byte   $3C,$06,$43,$40,$04,$34,$00,$43 ; 9A82 3C 06 43 40 04 34 00 43  <.C@.4.C
        .byte   $40,$34,$31,$6A,$2A,$B9,$4F,$2D ; 9A8A 40 34 31 6A 2A B9 4F 2D  @41j*.O-
        .byte   $66,$9C,$DA,$FA,$7E,$D7,$C6,$CC ; 9A92 66 9C DA FA 7E D7 C6 CC  f...~...
        .byte   $7B,$1D,$83,$B8,$F6,$34,$DF,$FB ; 9A9A 7B 1D 83 B8 F6 34 DF FB  {....4..
        .byte   $9D,$5B,$35,$CB,$DC,$66,$34,$77 ; 9AA2 9D 5B 35 CB DC 66 34 77  .[5..f4w
        .byte   $2B,$8C,$BB,$96,$5F,$80,$53,$01 ; 9AAA 2B 8C BB 96 5F 80 53 01  +..._.S.
        .byte   $88,$01,$A1,$60,$1A,$16,$01,$21 ; 9AB2 88 01 A1 60 1A 16 01 21  ...`...!
        .byte   $60,$12,$26,$72,$7A,$19,$38,$D9 ; 9ABA 60 12 26 72 7A 19 38 D9  `.&rz.8.
        .byte   $86,$4C,$2B,$51,$F8,$2D,$A1,$93 ; 9AC2 86 4C 2B 51 F8 2D A1 93  .L+Q.-..
        .byte   $86,$64,$32,$61,$99,$BB,$B7,$F5 ; 9ACA 86 64 32 61 99 BB B7 F5  .d2a....
        .byte   $EE,$02,$51,$B3,$46,$CB,$06,$86 ; 9AD2 EE 02 51 B3 46 CB 06 86  ..Q.F...
        .byte   $44,$69,$03,$A4,$F8,$CF,$4E,$F7 ; 9ADA 44 69 03 A4 F8 CF 4E F7  Di....N.
        .byte   $84,$3D,$87,$D0,$1E,$A0,$71,$43 ; 9AE2 84 3D 87 D0 1E A0 71 43  .=....qC
        .byte   $8E,$39,$D1,$A0,$EF,$81,$F1,$23 ; 9AEA 8E 39 D1 A0 EF 81 F1 23  .9.....#
        .byte   $8E,$0C,$78,$02,$C4,$30,$51,$52 ; 9AF2 8E 0C 78 02 C4 30 51 52  ..x..0QR
        .byte   $69,$2C,$FF,$C3,$FC,$3E,$22,$E1 ; 9AFA 69 2C FF C3 FC 3E 22 E1  i,...>".
        .byte   $4C,$E5,$30,$67,$C1,$92,$DB,$A3 ; 9B02 4C E5 30 67 C1 92 DB A3  L.0g....
        .byte   $E2,$7E,$89,$F5,$27,$5C,$94,$A2 ; 9B0A E2 7E 89 F5 27 5C 94 A2  .~..'\..
        .byte   $55,$0E,$90,$D2,$0E,$EC,$A2,$0A ; 9B12 55 0E 90 D2 0E EC A2 0A  U.......
        .byte   $69,$14,$18,$09,$32,$26,$18,$9C ; 9B1A 69 14 18 09 32 26 18 9C  i...2&..
        .byte   $30,$18,$44,$90,$16,$DE,$1E,$4C ; 9B22 30 18 44 90 16 DE 1E 4C  0.D....L
        .byte   $09,$28,$04,$96,$52,$58,$92,$61 ; 9B2A 09 28 04 96 52 58 92 61  .(..RX.a
        .byte   $A4,$6C,$E0,$9A,$13,$00,$D2,$C2 ; 9B32 A4 6C E0 9A 13 00 D2 C2  .l......
        .byte   $82,$2E,$5F,$FF,$75,$97,$E5,$FF ; 9B3A 82 2E 5F FF 75 97 E5 FF  .._.u...
        .byte   $DF,$5C,$BF,$EB,$57,$6E,$02,$78 ; 9B42 DF 5C BF EB 57 6E 02 78  .\..Wn.x
        .byte   $85,$FC,$BF,$F7,$AE,$BD,$AF,$E6 ; 9B4A 85 FC BF F7 AE BD AF E6  ........
        .byte   $3B,$FF,$B8,$F0,$C7,$78,$87,$82 ; 9B52 3B FF B8 F0 C7 78 87 82  ;....x..
        .byte   $7C,$EF,$FF,$3F,$E7,$A4,$E6,$00 ; 9B5A 7C EF FF 3F E7 A4 E6 00  |..?....
        .byte   $64,$02,$0B,$31,$3E,$13,$0B,$3E ; 9B62 64 02 0B 31 3E 13 0B 3E  d..1>..>
        .byte   $20,$51,$F4,$35,$72,$5B,$D7,$BA ; 9B6A 20 51 F4 35 72 5B D7 BA   Q.5r[..
        .byte   $FC,$BF,$FB,$E4,$3E,$C7,$E2,$FF ; 9B72 FC BF FB E4 3E C7 E2 FF  ....>...
        .byte   $A7,$EB,$DA,$FA,$BF,$5A,$65,$A4 ; 9B7A A7 EB DA FA BF 5A 65 A4  .....Ze.
        .byte   $04,$B4,$4A,$01,$85,$F0,$1F,$FC ; 9B82 04 B4 4A 01 85 F0 1F FC  ..J.....
        .byte   $FF,$9A,$F1,$27,$78,$27,$24,$39 ; 9B8A FF 9A F1 27 78 27 24 39  ...'x'$9
        .byte   $C3,$94,$CF,$B9,$EF,$F9,$FF,$9F ; 9B92 C3 94 CF B9 EF F9 FF 9F  ........
        .byte   $A1,$D2,$D9,$C0,$3C,$44,$C0,$D4 ; 9B9A A1 D2 D9 C0 3C 44 C0 D4  ....<D..
        .byte   $FE,$3B,$86,$7E,$60,$07,$BB,$B3 ; 9BA2 FE 3B 86 7E 60 07 BB B3  .;.~`...
        .byte   $1D,$8F,$C8,$FF,$1F,$31,$FF,$29 ; 9BAA 1D 8F C8 FF 1F 31 FF 29  .....1.)
        .byte   $F1,$9E,$27,$E3,$E4,$5E,$8B,$F3 ; 9BB2 F1 9E 27 E3 E4 5E 8B F3  ..'..^..
        .byte   $09,$1F,$8A,$ED,$89,$FF,$19,$B1 ; 9BBA 09 1F 8A ED 89 FF 19 B1  ........
        .byte   $FE,$FD,$BF,$EF,$EB,$D9,$19,$EF ; 9BC2 FE FD BF EF EB D9 19 EF  ........
        .byte   $F8,$3F,$03,$E0,$6A,$7F,$F3,$F8 ; 9BCA F8 3F 03 E0 6A 7F F3 F8  .?..j...
        .byte   $F6,$34,$29,$FF,$3E,$CE,$86,$7C ; 9BD2 F6 34 29 FF 3E CE 86 7C  .4).>..|
        .byte   $F7,$1C,$FF,$3D,$C7,$3F,$1F,$06 ; 9BDA F7 1C FF 3D C7 3F 1F 06  ...=.?..
        .byte   $23,$FF,$00,$D1,$30,$CD,$12,$0C ; 9BE2 23 FF 00 D1 30 CD 12 0C  #...0...
        .byte   $D7,$30,$CE,$B5,$26,$38,$10,$40 ; 9BEA D7 30 CE B5 26 38 10 40  .0..&8.@
        .byte   $21,$00,$40,$49,$6B,$E8,$B8,$D7 ; 9BF2 21 00 40 49 6B E8 B8 D7  !.@Ik...
        .byte   $88,$B8,$A2,$EC,$26,$61,$27,$19 ; 9BFA 88 B8 A2 EC 26 61 27 19  ....&a'.
        .byte   $EC,$3E,$26,$10,$4C,$40,$62,$80 ; 9C02 EC 3E 26 10 4C 40 62 80  .>&.L@b.
        .byte   $D5,$0D,$A1,$E6,$75,$9B,$72,$DF ; 9C0A D5 0D A1 E6 75 9B 72 DF  ....u.r.
        .byte   $03,$E1,$98,$72,$1D,$C3,$D0,$FF ; 9C12 03 E1 98 72 1D C3 D0 FF  ...r....
        .byte   $5D,$93,$44,$C8,$21,$29,$84,$85 ; 9C1A 5D 93 44 C8 21 29 84 85  ].D.!)..
        .byte   $0A,$0B,$01,$1F,$44,$3F,$91,$DB ; 9C22 0A 0B 01 1F 44 3F 91 DB  ....D?..
        .byte   $03,$21,$1A,$31,$46,$30,$E2,$4E ; 9C2A 03 21 1A 31 46 30 E2 4E  .!.1F0.N
        .byte   $23,$E1,$3E,$0D,$C0,$8F,$98,$19 ; 9C32 23 E1 3E 0D C0 8F 98 19  #.>.....
        .byte   $73,$20,$73,$18,$3B,$41,$F8,$5F ; 9C3A 73 20 73 18 3B 41 F8 5F  s s.;A._
        .byte   $06,$20,$7F,$FE,$97,$C6,$F4,$BC ; 9C42 06 20 7F FE 97 C6 F4 BC  . ......
        .byte   $0F,$4B,$C0,$F4,$BE,$0F,$A1,$EA ; 9C4A 0F 4B C0 F4 BE 0F A1 EA  .K......
        .byte   $FA,$1E,$A3,$AC,$6B,$8A,$F6,$06 ; 9C52 FA 1E A3 AC 6B 8A F6 06  ....k...
        .byte   $CA,$F0,$5C,$4B,$01,$81,$61,$3E ; 9C5A CA F0 5C 4B 01 81 61 3E  ..\K..a>
        .byte   $33,$80,$40,$C5,$E1,$88,$07,$A5 ; 9C62 33 80 40 C5 E1 88 07 A5  3.@.....
        .byte   $EA,$7A,$5E,$AB,$A0,$EA,$BA,$0F ; 9C6A EA 7A 5E AB A0 EA BA 0F  .z^.....
        .byte   $5C,$57,$85,$F5,$66,$59,$D6,$65 ; 9C72 5C 57 85 F5 66 59 D6 65  \W..fY.e
        .byte   $CE,$95,$BC,$1C,$51,$F0,$1F,$81 ; 9C7A CE 95 BC 1C 51 F0 1F 81  ....Q...
        .byte   $FE,$8F,$C2,$7D,$1F,$D8,$AA,$94 ; 9C82 FE 8F C2 7D 1F D8 AA 94  ...}....
        .byte   $82,$B6,$45,$A9,$05,$D8,$82,$D2 ; 9C8A 82 B6 45 A9 05 D8 82 D2  ..E.....
        .byte   $45,$B1,$22,$A4,$C5,$B2,$0A,$24 ; 9C92 45 B1 22 A4 C5 B2 0A 24  E."....$
        .byte   $04,$0C,$82,$F9,$0B,$4E,$A3,$B9 ; 9C9A 04 0C 82 F9 0B 4E A3 B9  .....N..
        .byte   $2F,$F1,$A7,$4B,$6B,$6A,$DB,$A3 ; 9CA2 2F F1 A7 4B 6B 6A DB A3  /..Kkj..
        .byte   $51,$D0,$C7,$85,$06,$06,$82,$07 ; 9CAA 51 D0 C7 85 06 06 82 07  Q.......
        .byte   $58,$5A,$28,$80,$1E,$23,$F9,$0F ; 9CB2 58 5A 28 80 1E 23 F9 0F  XZ(..#..
        .byte   $FA,$A6,$29,$13,$15,$12,$24,$4E ; 9CBA FA A6 29 13 15 12 24 4E  ..)...$N
        .byte   $A9,$2A,$F0,$14,$71,$52,$E5,$DC ; 9CC2 A9 2A F0 14 71 52 E5 DC  .*..qR..
        .byte   $D0,$7B,$51,$CC,$0B,$E2,$17,$01 ; 9CCA D0 7B 51 CC 0B E2 17 01  .{Q.....
        .byte   $B4,$00,$A8,$0F,$A1,$76,$F8,$1A ; 9CD2 B4 00 A8 0F A1 76 F8 1A  .....v..
        .byte   $88,$8C,$70,$24,$09,$50,$13,$C0 ; 9CDA 88 8C 70 24 09 50 13 C0  ..p$.P..
        .byte   $79,$3F,$0F,$FF,$C0,$9D,$2B,$E4 ; 9CE2 79 3F 0F FF C0 9D 2B E4  y?....+.
        .byte   $FC,$5F,$87,$F9,$FF,$9F,$93,$E4 ; 9CEA FC 5F 87 F9 FF 9F 93 E4  ._......
        .byte   $7F,$1F,$93,$FC,$FE,$3F,$F0,$BD ; 9CF2 7F 1F 93 FC FE 3F F0 BD  .....?..
        .byte   $31,$C4,$97,$43,$11,$84,$4B,$36 ; 9CFA 31 C4 97 43 11 84 4B 36  1..C..K6
        .byte   $E4,$07,$C8,$5D,$83,$F2,$1F,$90 ; 9D02 E4 07 C8 5D 83 F2 1F 90  ...]....
        .byte   $CC,$81,$73,$1A,$91,$78,$3F,$0D ; 9D0A CC 81 73 1A 91 78 3F 0D  ..s..x?.
        .byte   $D6,$27,$C8,$F8,$CF,$8E,$7C,$FF ; 9D12 D6 27 C8 F8 CF 8E 7C FF  .'....|.
        .byte   $9F,$C7,$E6,$7C,$8F,$20,$D4,$61 ; 9D1A 9F C7 E6 7C 8F 20 D4 61  ...|. .a
        .byte   $1C,$11,$84,$31,$07,$10,$62,$38 ; 9D22 1C 11 84 31 07 10 62 38  ...1..b8
        .byte   $C7,$14,$C5,$CF,$F3,$1E,$53,$C6 ; 9D2A C7 14 C5 CF F3 1E 53 C6  ......S.
        .byte   $7F,$1C,$CA,$59,$51,$FF,$89,$F7 ; 9D32 7F 1C CA 59 51 FF 89 F7  ...YQ...
        .byte   $27,$26,$1B,$4C,$24,$48,$6D,$10 ; 9D3A 27 26 1B 4C 24 48 6D 10  '&.L$Hm.
        .byte   $24,$4C,$1A,$24,$08,$C8,$1E,$40 ; 9D42 24 4C 1A 24 08 C8 1E 40  $L.$...@
        .byte   $F8,$07,$78,$35,$00,$A0,$8B,$96 ; 9D4A F8 07 78 35 00 A0 8B 96  ..x5....
        .byte   $5F,$2F,$CB,$FE,$B5,$15,$E0,$5F ; 9D52 5F 2F CB FE B5 15 E0 5F  _/....._
        .byte   $2B,$F1,$BF,$ED,$7D,$6F,$5F,$4C ; 9D5A 2B F1 BF ED 7D 6F 5F 4C  +...}o_L
        .byte   $14,$09,$00,$D9,$36,$14,$21,$08 ; 9D62 14 09 00 D9 36 14 21 08  ....6.!.
        .byte   $03,$26,$7E,$FF,$EF,$58,$12,$24 ; 9D6A 03 26 7E FF EF 58 12 24  .&~..X.$
        .byte   $04,$21,$21,$80,$EF,$6D,$6A,$2B ; 9D72 04 21 21 80 EF 6D 6A 2B  .!!..mj+
        .byte   $FE,$D7,$D1,$7A,$FA,$BF,$FB,$9C ; 9D7A FE D7 D1 7A FA BF FB 9C  ...z....
        .byte   $3C,$4B,$F2,$7F,$EB,$AD,$7F,$C7 ; 9D82 3C 4B F2 7F EB AD 7F C7  <K......
        .byte   $F7,$31,$66,$36,$58,$7F,$EB,$7A ; 9D8A F7 31 66 36 58 7F EB 7A  .1f6X..z
        .byte   $FD,$1E,$23,$88,$04,$80,$61,$C7 ; 9D92 FD 1E 23 88 04 80 61 C7  ..#...a.
        .byte   $BF,$FD,$67,$AF,$FF,$98,$2B,$48 ; 9D9A BF FD 67 AF FF 98 2B 48  ..g...+H
        .byte   $29,$59,$97,$3D,$FF,$E3,$C8,$46 ; 9DA2 29 59 97 3D FF E3 C8 46  )Y.=...F
        .byte   $E5,$B5,$8D,$7B,$3E,$FF,$E3,$FD ; 9DAA E5 B5 8D 7B 3E FF E3 FD  ...{>...
        .byte   $DF,$6F,$C7,$F7,$BD,$C7,$76,$56 ; 9DB2 DF 6F C7 F7 BD C7 76 56  .o....vV
        .byte   $A4,$DA,$FA,$F6,$BF,$FE,$F6,$D7 ; 9DBA A4 DA FA F6 BF FE F6 D7  ........
        .byte   $FF,$EF,$CD,$FC,$BF,$E9,$FA,$F6 ; 9DC2 FF EF CD FC BF E9 FA F6  ........
        .byte   $BF,$F1,$FD,$CC,$2C,$C3,$64,$C1 ; 9DCA BF F1 FD CC 2C C3 64 C1  ....,.d.
        .byte   $FF,$AF,$CB,$FC,$4F,$F8,$CF,$8E ; 9DD2 FF AF CB FC 4F F8 CF 8E  ....O...
        .byte   $5C,$77,$C7,$BE,$3E,$E3,$F4,$D4 ; 9DDA 5C 77 C7 BE 3E E3 F4 D4  \w..>...
        .byte   $50,$7D,$B3,$78,$9F,$FA,$FA,$BF ; 9DE2 50 7D B3 78 9F FA FA BF  P}.x....
        .byte   $E3,$FB,$B2,$D9,$B5,$8F,$FA,$F6 ; 9DEA E3 FB B2 D9 B5 8F FA F6  ........
        .byte   $BF,$2F,$E1,$44,$1F,$A3,$FE,$EB ; 9DF2 BF 2F E1 44 1F A3 FE EB  ./.D....
        .byte   $24,$03,$FA,$FF,$F7,$8C,$46,$A2 ; 9DFA 24 03 FA FF F7 8C 46 A2  $.....F.
        .byte   $07,$CD,$7B,$D6,$FC,$BF,$8A,$F2 ; 9E02 07 CD 7B D6 FC BF 8A F2  ..{.....
        .byte   $EE,$BF,$5F,$F5,$BD,$7F,$E2,$FB ; 9E0A EE BF 5F F5 BD 7F E2 FB  .._.....
        .byte   $BC,$00,$7A,$F3,$51,$1F,$E5,$7D ; 9E12 BC 00 7A F3 51 1F E5 7D  ..z.Q..}
        .byte   $7D,$5F,$FE,$2F,$BB,$6F,$DA,$7E ; 9E1A 7D 5F FE 2F BB 6F DA 7E  }_./.o.~
        .byte   $BB,$AF,$CB,$FC,$C1,$3C,$1B,$F7 ; 9E22 BB AF CB FC C1 3C 1B F7  .....<..
        .byte   $FF,$5E,$3E,$7F,$5F,$FA,$F8,$F3 ; 9E2A FF 5E 3E 7F 5F FA F8 F3  .^>._...
        .byte   $F7,$5F,$88,$AA,$0B,$C2,$FF,$F8 ; 9E32 F7 5F 88 AA 0B C2 FF F8  ._......
        .byte   $50,$6B,$CB,$FF,$ED,$65,$FF,$E6 ; 9E3A 50 6B CB FF ED 65 FF E6  Pk...e..
        .byte   $A2,$3B,$CF,$F2,$7E,$BF,$F8,$62 ; 9E42 A2 3B CF F2 7E BF F8 62  .;..~..b
        .byte   $0B,$E1,$FF,$D1,$FA,$AE,$83,$AA ; 9E4A 0B E1 FF D1 FA AE 83 AA  ........
        .byte   $EA,$7A,$AE,$A7,$AA,$EA,$DD,$79 ; 9E52 EA 7A AE A7 AA EA DD 79  .z.....y
        .byte   $5F,$2B,$F6,$1F,$07,$F5,$7D,$0F ; 9E5A 5F 2B F6 1F 07 F5 7D 0F  _+....}.
        .byte   $51,$D6,$F5,$1D,$63,$5D,$C3,$B3 ; 9E62 51 D6 F5 1D 63 5D C3 B3  Q...c]..
        .byte   $51,$10,$F5,$1C,$07,$08,$D6,$38 ; 9E6A 51 10 F5 1C 07 08 D6 38  Q......8
        .byte   $47,$0C,$45,$5D,$5B,$55,$D6,$B5 ; 9E72 47 0C 45 5D 5B 55 D6 B5  G.E][U..
        .byte   $B5,$6B,$5B,$56,$BA,$3F,$A9,$FF ; 9E7A B5 6B 5B 56 BA 3F A9 FF  .k[V.?..
        .byte   $0C,$43,$B4,$75,$18,$47,$54,$E5 ; 9E82 0C 43 B4 75 18 47 54 E5  .C.u.GT.
        .byte   $31,$4E,$35,$22,$08,$71,$47,$8C ; 9E8A 31 4E 35 22 08 71 47 8C  1N5".qG.
        .byte   $F8,$9F,$07,$E1,$88,$B0,$AD,$6A ; 9E92 F8 9F 07 E1 88 B0 AD 6A  .......j
        .byte   $8A,$B6,$A8,$AB,$0A,$EA,$B1,$53 ; 9E9A 8A B6 A8 AB 0A EA B1 53  .......S
        .byte   $EA,$BD,$67,$AA,$FA,$98,$B3,$2C ; 9EA2 EA BD 67 AA FA 98 B3 2C  ..g....,
        .byte   $EB,$9A,$F3,$5F,$25,$B1,$11,$EA ; 9EAA EB 9A F3 5F 25 B1 11 EA  ..._%...
        .byte   $38,$23,$0A,$38,$0E,$11,$85,$1C ; 9EB2 38 23 0A 38 0E 11 85 1C  8#.8....
        .byte   $23,$0B,$53,$6B,$2D,$B1,$A5,$1B ; 9EBA 23 0B 53 6B 2D B1 A5 1B  #.Sk-...
        .byte   $65,$59,$AD,$3D,$67,$9D,$98,$BE ; 9EC2 65 59 AD 3D 67 9D 98 BE  eY.=g...
        .byte   $2B,$F2,$A5,$C4,$29,$C5,$09,$8A ; 9ECA 2B F2 A5 C4 29 C5 09 8A  +...)...
        .byte   $29,$1A,$CC,$78,$1F,$C7,$E8,$FF ; 9ED2 29 1A CC 78 1F C7 E8 FF  )..x....
        .byte   $E1,$B8,$11,$38,$17,$23,$A0,$71 ; 9EDA E1 B8 11 38 17 23 A0 71  ...8.#.q
        .byte   $1C,$60,$8C,$89,$C8,$39,$C5,$D8 ; 9EE2 1C 60 8C 89 C8 39 C5 D8  .`...9..
        .byte   $77,$0D,$E7,$79,$BF,$2F,$F1,$8C ; 9EEA 77 0D E7 79 BF 2F F1 8C  w..y./..
        .byte   $18,$9C,$63,$06,$38,$E3,$1C,$48 ; 9EF2 18 9C 63 06 38 E3 1C 48  ..c.8..H
        .byte   $99,$89,$38,$F7,$1A,$68,$EE,$1D ; 9EFA 99 89 38 F7 1A 68 EE 1D  ..8..h..
        .byte   $A3,$D4,$0C,$21,$F8,$6E,$03,$88 ; 9F02 A3 D4 0C 21 F8 6E 03 88  ...!.n..
        .byte   $38,$E3,$C7,$E3,$FA,$7E,$07,$D0 ; 9F0A 38 E3 C7 E3 FA 7E 07 D0  8....~..
        .byte   $78,$1F,$41,$EA,$1D,$61,$C7,$A8 ; 9F12 78 1F 41 EA 1D 61 C7 A8  x.A..a..
        .byte   $FA,$1F,$A3,$FF,$F2,$FC,$3F,$8F ; 9F1A FA 1F A3 FF F2 FC 3F 8F  ......?.
        .byte   $FE,$3A,$03,$50,$1B,$85,$F0,$7E ; 9F22 FE 3A 03 50 1B 85 F0 7E  .:.P...~
        .byte   $47,$F8,$62,$28,$2B,$02,$E0,$BA ; 9F2A 47 F8 62 28 2B 02 E0 BA  G.b(+...
        .byte   $07,$48,$DA,$3A,$A7,$C7,$F8,$3E ; 9F32 07 48 DA 3A A7 C7 F8 3E  .H.:...>
        .byte   $81,$80,$08,$00,$C0,$3E,$47,$FF ; 9F3A 81 80 08 00 C0 3E 47 FF  .....>G.
        .byte   $43,$C0,$24,$1D,$72,$7C,$7F,$F8 ; 9F42 43 C0 24 1D 72 7C 7F F8  C.$.r|..
        .byte   $FA,$6A,$93,$59,$8A,$89,$2B,$30 ; 9F4A FA 6A 93 59 8A 89 2B 30  .j.Y..+0
        .byte   $A8,$90,$AB,$E8,$C1,$08,$13,$15 ; 9F52 A8 90 AB E8 C1 08 13 15  ........
        .byte   $CC,$40,$56,$7F,$C6,$F7,$BA,$FE ; 9F5A CC 40 56 7F C6 F7 BA FE  .@V.....
        .byte   $C8,$79,$80,$9C,$02,$D4,$A3,$E2 ; 9F62 C8 79 80 9C 02 D4 A3 E2  .y......
        .byte   $39,$1F,$3D,$65,$17,$62,$CA,$2E ; 9F6A 39 1F 3D 65 17 62 CA 2E  9.=e.b..
        .byte   $C5,$96,$B9,$43,$D8,$72,$A1,$77 ; 9F72 C5 96 B9 43 D8 72 A1 77  ...C.r.w
        .byte   $87,$E8,$7F,$E3,$1E,$3E,$23,$FE ; 9F7A 87 E8 7F E3 1E 3E 23 FE  .....>#.
        .byte   $C6,$9C,$A0,$79,$C7,$4E,$3C,$C7 ; 9F82 C6 9C A0 79 C7 4E 3C C7  ...y.N<.
        .byte   $E6,$3C,$1B,$C4,$94,$E3,$5D,$D6 ; 9F8A E6 3C 1B C4 94 E3 5D D6  .<....].
        .byte   $9D,$C1,$1E,$00,$08,$10,$0B,$E1 ; 9F92 9D C1 1E 00 08 10 0B E1  ........
        .byte   $7F,$2C,$84,$0E,$00,$F2,$2C,$02 ; 9F9A 7F 2C 84 0E 00 F2 2C 02  .,....,.
        .byte   $E0,$6E,$0E,$E9,$DD,$3D,$A5,$26 ; 9FA2 E0 6E 0E E9 DD 3D A5 26  .n...=.&
        .byte   $DB,$FB,$57,$76,$CF,$1C,$80,$C5 ; 9FAA DB FB 57 76 CF 1C 80 C5  ..Wv....
        .byte   $80,$75,$80,$0B,$E0,$56,$E0,$20 ; 9FB2 80 75 80 0B E0 56 E0 20  .u...V. 
        .byte   $C2,$3E,$61,$C7,$38,$FE,$CF,$BE ; 9FBA C2 3E 61 C7 38 FE CF BE  .>a.8...
        .byte   $75,$FC,$1F,$8E,$71,$FD,$3F,$07 ; 9FC2 75 FC 1F 8E 71 FD 3F 07  u...q.?.
        .byte   $A3,$E4,$7F,$A7,$C0,$5E,$33,$C7 ; 9FCA A3 E4 7F A7 C0 5E 33 C7  .....^3.
        .byte   $F8,$49,$24,$9E,$7F,$A5,$22,$97 ; 9FD2 F8 49 24 9E 7F A5 22 97  .I$...".
        .byte   $F0,$FE,$9F,$C3,$F8,$FE,$03,$A0 ; 9FDA F0 FE 9F C3 F8 FE 03 A0  ........
        .byte   $36,$A0,$6A,$03,$63,$E1,$E5,$1D ; 9FE2 36 A0 6A 03 63 E1 E5 1D  6.j.c...
        .byte   $90,$04,$1F,$9F,$FF,$E7,$F1,$F9 ; 9FEA 90 04 1F 9F FF E7 F1 F9  ........
        .byte   $9F,$39,$E6,$4A,$43,$30,$6B,$4B ; 9FF2 9F 39 E6 4A 43 30 6B 4B  .9.JC0kK
        .byte   $30,$6F,$3F,$74,$7E,$C0         ; 9FFA 30 6F 3F 74 7E C0        0o?t~.
bank2_page_a000:  .byte   $00,$40,$01,$2B,$71,$39,$B3,$36 ; A000 00 40 01 2B 71 39 B3 36  .@.+q9.6
        .byte   $2E,$DF,$43,$D8,$6E,$0B,$A0,$32 ; A008 2E DF 43 D8 6E 0B A0 32  ..C.n..2
        .byte   $08,$E1,$CE,$BF,$D7,$C0,$3A,$0F ; A010 08 E1 CE BF D7 C0 3A 0F  ......:.
        .byte   $F5,$F4,$7C,$D6,$86,$AC,$2A,$85 ; A018 F5 F4 7C D6 86 AC 2A 85  ..|...*.
        .byte   $30,$8C,$22,$4A,$AD,$7F,$AF,$DF ; A020 30 8C 22 4A AD 7F AF DF  0."J....
        .byte   $2D,$88,$3A,$86,$14,$42,$86,$E8 ; A028 2D 88 3A 86 14 42 86 E8  -.:..B..
        .byte   $85,$0D,$D1,$74,$02,$9A,$9F,$D6 ; A030 85 0D D1 74 02 9A 9F D6  ...t....
        .byte   $72,$E5,$5C,$D5,$9F,$1F,$47,$B0 ; A038 72 E5 5C D5 9F 1F 47 B0  r.\...G.
        .byte   $FD,$7F,$AF,$C5,$D0,$5F,$81,$BA ; A040 FD 7F AF C5 D0 5F 81 BA  ....._..
        .byte   $5F,$75,$EA,$BD,$AE,$D5,$C2,$B8 ; A048 5F 75 EA BD AE D5 C2 B8  _u......
        .byte   $8B,$21,$12,$E0,$14,$09,$40,$0E ; A050 8B 21 12 E0 14 09 40 0E  .!....@.
        .byte   $04,$A0,$07,$02,$50,$01,$40,$5B ; A058 04 A0 07 02 50 01 40 5B  ....P.@[
        .byte   $6D,$67,$A9,$F5,$2A,$A3,$54,$72 ; A060 6D 67 A9 F5 2A A3 54 72  mg..*.Tr
        .byte   $8F,$61,$E9,$0E,$5B,$68,$82,$81 ; A068 8F 61 E9 0E 5B 68 82 81  .a..[h..
        .byte   $54,$12,$C1,$54,$16,$81,$54,$1A ; A070 54 12 C1 54 16 81 54 1A  T..T..T.
        .byte   $A5,$25,$58,$EB,$8E,$BC,$57,$CA ; A078 A5 25 58 EB 8E BC 57 CA  .%X...W.
        .byte   $1F,$01,$E8,$01,$3B,$70,$47,$C5 ; A080 1F 01 E8 01 3B 70 47 C5  ....;pG.
        .byte   $C1,$2C,$35,$64,$AB,$3C,$49,$8A ; A088 C1 2C 35 64 AB 3C 49 8A  .,5d.<I.
        .byte   $1E,$B2,$70,$7F,$1C,$C1,$FD,$17 ; A090 1E B2 70 7F 1C C1 FD 17  ..p.....
        .byte   $D6,$75,$7D,$2F,$DA,$CB,$AE,$AA ; A098 D6 75 7D 2F DA CB AE AA  .u}/....
        .byte   $F6,$19,$D3,$BA,$7F,$8D,$F7,$AF ; A0A0 F6 19 D3 BA 7F 8D F7 AF  ........
        .byte   $00,$00,$23,$00,$1F,$81,$DC,$FD ; A0A8 00 00 23 00 1F 81 DC FD  ..#.....
        .byte   $3F,$83,$FC,$B2,$68,$BD,$D7,$E8 ; A0B0 3F 83 FC B2 68 BD D7 E8  ?...h...
        .byte   $47,$4A,$00,$D0,$0D,$82,$D8,$6A ; A0B8 47 4A 00 D0 0D 82 D8 6A  GJ.....j
        .byte   $57,$DD,$2F,$E3,$DC,$7F,$07,$69 ; A0C0 57 DD 2F E3 DC 7F 07 69  W./....i
        .byte   $3E,$A9,$F6,$D3,$D6,$64,$5E,$60 ; A0C8 3E A9 F6 D3 D6 64 5E 60  >....d^`
        .byte   $7E,$47,$62,$6C,$CF,$FC,$03,$E0 ; A0D0 7E 47 62 6C CF FC 03 E0  ~Gbl....
        .byte   $79,$45,$63,$FC,$7E,$1F,$47,$71 ; A0D8 79 45 63 FC 7E 1F 47 71  yEc.~.Gq
        .byte   $B4,$58,$19,$1D,$C3,$F3,$EC,$D9 ; A0E0 B4 58 19 1D C3 F3 EC D9  .X......
        .byte   $CB,$45,$6C,$3E,$1F,$EF,$9D,$76 ; A0E8 CB 45 6C 3E 1F EF 9D 76  .El>...v
        .byte   $2F,$CB,$FA,$ED,$58,$B8,$98,$71 ; A0F0 2F CB FA ED 58 B8 98 71  /...X..q
        .byte   $9C,$49,$8B,$18,$B8,$D1,$55,$63 ; A0F8 9C 49 8B 18 B8 D1 55 63  .I....Uc
        .byte   $A4,$69,$8B,$31,$4E,$13,$C2,$71 ; A100 A4 69 8B 31 4E 13 C2 71  .i.1N..q
        .byte   $CE,$33,$8A,$FE,$AB,$D0,$5D,$9A ; A108 CE 33 8A FE AB D0 5D 9A  .3....].
        .byte   $D9,$D4,$D1,$4D,$D1,$5C,$57,$C5 ; A110 D9 D4 D1 4D D1 5C 57 C5  ...M.\W.
        .byte   $78,$D7,$4A,$C6,$51,$CD,$08,$95 ; A118 78 D7 4A C6 51 CD 08 95  x.J.Q...
        .byte   $F7,$57,$78,$B7,$35,$73,$AC,$8A ; A120 F7 57 78 B7 35 73 AC 8A  .Wx.5s..
        .byte   $CD,$2C,$48,$45,$6C,$64,$42,$21 ; A128 CD 2C 48 45 6C 64 42 21  .,HEldB!
        .byte   $8A,$23,$52,$14,$A0,$6C,$C7,$69 ; A130 8A 23 52 14 A0 6C C7 69  .#R..l.i
        .byte   $45,$55,$8F,$51,$D3,$FA,$C5,$51 ; A138 45 55 8F 51 D3 FA C5 51  EU.Q...Q
        .byte   $5A,$89,$A1,$52,$16,$21,$1B,$3D ; A140 5A 89 A1 52 16 21 1B 3D  Z..R.!.=
        .byte   $A8,$C2,$11,$A0,$CB,$23,$B3,$D3 ; A148 A8 C2 11 A0 CB 23 B3 D3  .....#..
        .byte   $BC,$BB,$BB,$F9,$41,$B9,$E3,$D8 ; A150 BC BB BB F9 41 B9 E3 D8  ....A...
        .byte   $5E,$5E,$09,$26,$10,$C5,$9A,$25 ; A158 5E 5E 09 26 10 C5 9A 25  ^^.&...%
        .byte   $ED,$8B,$49,$A1,$B1,$96,$2B,$60 ; A160 ED 8B 49 A1 B1 96 2B 60  ..I...+`
        .byte   $89,$08,$69,$D0,$5B,$10,$C6,$6A ; A168 89 08 69 D0 5B 10 C6 6A  ..i.[..j
        .byte   $6C,$0B,$21,$D0,$65,$03,$60,$F2 ; A170 6C 0B 21 D0 65 03 60 F2  l.!.e.`.
        .byte   $22,$AA,$C7,$4E,$3D,$47,$D8,$F5 ; A178 22 AA C7 4E 3D 47 D8 F5  "..N=G..
        .byte   $66,$EC,$69,$4B,$06,$E2,$24,$63 ; A180 66 EC 69 4B 06 E2 24 63  f.iK..$c
        .byte   $1C,$CC,$4C,$A5,$5F,$96,$E2,$60 ; A188 1C CC 4C A5 5F 96 E2 60  ..L._..`
        .byte   $B9,$8B,$3A,$32,$10,$D3,$98,$E4 ; A190 B9 8B 3A 32 10 D3 98 E4  ..:2....
        .byte   $45,$0C,$0C,$A0,$DC,$84,$81,$C8 ; A198 45 0C 0C A0 DC 84 81 C8  E.......
        .byte   $E9,$16,$3F,$27,$99,$98,$D7,$2D ; A1A0 E9 16 3F 27 99 98 D7 2D  ..?'...-
        .byte   $36,$BD,$25,$AA,$8A,$B1,$A2,$51 ; A1A8 36 BD 25 AA 8A B1 A2 51  6.%....Q
        .byte   $50,$B6,$66,$44,$25,$62,$16,$08 ; A1B0 50 B6 66 44 25 62 16 08  P.fD%b..
        .byte   $83,$28,$31,$12,$5C,$22,$D8,$FC ; A1B8 83 28 31 12 5C 22 D8 FC  .(1.\"..
        .byte   $1F,$D1,$14,$72,$37,$22,$22,$E4 ; A1C0 1F D1 14 72 37 22 22 E4  ...r7"".
        .byte   $52,$E7,$C8,$F1,$1B,$21,$B2,$C1 ; A1C8 52 E7 C8 F1 1B 21 B2 C1  R....!..
        .byte   $73,$C7,$D9,$85,$2E,$BA,$A5,$55 ; A1D0 73 C7 D9 85 2E BA A5 55  s......U
        .byte   $0A,$F7,$7D,$7F,$F5,$F4,$8A,$C5 ; A1D8 0A F7 7D 7F F5 F4 8A C5  ..}.....
        .byte   $E5,$72,$59,$96,$4A,$48,$CD,$8E ; A1E0 E5 72 59 96 4A 48 CD 8E  .rY.JH..
        .byte   $44,$56,$E2,$B3,$B1,$7C,$77,$1F ; A1E8 44 56 E2 B3 B1 7C 77 1F  DV...|w.
        .byte   $87,$FC,$8A,$C5,$FD,$7E,$7F,$8F ; A1F0 87 FC 8A C5 FD 7E 7F 8F  .....~..
        .byte   $F8,$EA,$BB,$B8,$F8,$E1,$C0,$D8 ; A1F8 F8 EA BB B8 F8 E1 C0 D8  ........
        .byte   $9F,$0B,$F3,$7E,$5F,$C7,$FF,$C4 ; A200 9F 0B F3 7E 5F C7 FF C4  ...~_...
        .byte   $F5,$0A,$A3,$FE,$E7,$06,$E9,$BF ; A208 F5 0A A3 FE E7 06 E9 BF  ........
        .byte   $9B,$A7,$38                     ; A210 9B A7 38                 ..8
robinchr:
        .byte   $00,$6A,$AA,$8F,$FF,$F1,$DC,$37 ; A213 00 6A AA 8F FF F1 DC 37  .j.....7
        .byte   $B3,$94,$C6,$6F,$BC,$1E,$83,$78 ; A21B B3 94 C6 6F BC 1E 83 78  ...o...x
        .byte   $FF,$71,$D7,$F4,$BE,$0F,$E2,$70 ; A223 FF 71 D7 F4 BE 0F E2 70  .q.....p
        .byte   $E5,$28,$DB,$72,$D7,$97,$F3,$DF ; A22B E5 28 DB 72 D7 97 F3 DF  .(.r....
        .byte   $E6,$1F,$A8,$50,$AE,$0F,$C1,$E8 ; A233 E6 1F A8 50 AE 0F C1 E8  ...P....
        .byte   $4C,$1B,$0F,$05,$8C,$6A,$AA,$8F ; A23B 4C 1B 0F 05 8C 6A AA 8F  L....j..
        .byte   $E3,$B8,$CF,$12,$B0,$46,$42,$79 ; A243 E3 B8 CF 12 B0 46 42 79  .....FBy
        .byte   $E6,$AD,$15,$C7,$FB,$8B,$09,$B0 ; A24B E6 AD 15 C7 FB 8B 09 B0  ........
        .byte   $6E,$8A,$D1,$A8,$86,$92,$8D,$B3 ; A253 6E 8A D1 A8 86 92 8D B3  n.......
        .byte   $DD,$EB,$FF,$E1,$FA,$85,$1E,$E1 ; A25B DD EB FF E1 FA 85 1E E1  ........
        .byte   $DE,$1D,$D1,$DC,$37,$13,$47,$1A ; A263 DE 1D D1 DC 37 13 47 1A  ....7.G.
        .byte   $AA,$A3,$F8,$FC,$28,$60,$65,$66 ; A26B AA A3 F8 FC 28 60 65 66  ....(`ef
        .byte   $4C,$3A,$89,$8C,$48,$AA,$55,$03 ; A273 4C 3A 89 8C 48 AA 55 03  L:..H.U.
        .byte   $C7,$C5,$C2,$F0,$FE,$1F,$0D,$71 ; A27B C7 C5 C2 F0 FE 1F 0D 71  .......q
        .byte   $15,$55,$05,$10,$E7,$0E,$41,$E4 ; A283 15 55 05 10 E7 0E 41 E4  .U....A.
        .byte   $3E,$07,$E2,$FA,$85,$0E,$C3,$90 ; A28B 3E 07 E2 FA 85 0E C3 90  >.......
        .byte   $56,$0E,$8F,$41,$C3,$C6,$3A,$AA ; A293 56 0E 8F 41 C3 C6 3A AA  V..A..:.
        .byte   $8F,$F1,$F4,$78,$C7,$1E,$29,$E0 ; A29B 8F F1 F4 78 C7 1E 29 E0  ...x..).
        .byte   $47,$C7,$FB,$7F,$44,$F5,$03,$A0 ; A2A3 47 C7 FB 7F 44 F5 03 A0  G...D...
        .byte   $CD,$00,$1A,$BB,$81,$B8,$4F,$87 ; A2AB CD 00 1A BB 81 B8 4F 87  ......O.
        .byte   $38,$7F,$C5,$FB,$CC,$D7,$5A,$BB ; A2B3 38 7F C5 FB CC D7 5A BB  8.....Z.
        .byte   $7F,$7D,$FB,$C7,$FF,$0F,$DC,$5D ; A2BB 7F 7D FB C7 FF 0F DC 5D  .}.....]
        .byte   $90,$11,$8F,$E3,$F4,$7C,$DB,$CD ; A2C3 90 11 8F E3 F4 7C DB CD  .....|..
        .byte   $1C,$D4,$9E,$EF,$C1,$F8,$5F,$E0 ; A2CB 1C D4 9E EF C1 F8 5F E0  ......_.
        .byte   $FD,$DF,$D9,$01,$16,$42,$90,$20 ; A2D3 FD DF D9 01 16 42 90 20  .....B. 
        .byte   $20,$20,$31,$10,$11,$8A,$47,$71 ; A2DB 20 20 31 10 11 8A 47 71    1...Gq
        .byte   $FE,$B7,$AF,$82,$FC,$E7,$CA,$FA ; A2E3 FE B7 AF 82 FC E7 CA FA  ........
        .byte   $95,$BF,$77,$BE,$62,$8E,$26,$C3 ; A2EB 95 BF 77 BE 62 8E 26 C3  ..w.b.&.
        .byte   $75,$55,$F8,$ED,$14,$50,$21,$63 ; A2F3 75 55 F8 ED 14 50 21 63  uU...P!c
        .byte   $FE,$3F,$47,$CB,$BC,$A6,$9C,$2F ; A2FB FE 3F 47 CB BC A6 9C 2F  .?G..../
        .byte   $B4,$FB,$57,$8A,$FC,$2F,$EC,$C2 ; A303 B4 FB 57 8A FC 2F EC C2  ..W../..
        .byte   $2C,$E1,$01,$84,$23,$08,$D8,$8F ; A30B 2C E1 01 84 23 08 D8 8F  ,...#...
        .byte   $63,$C6,$3E,$BA,$A8,$CE,$AC,$F6 ; A313 63 C6 3E BA A8 CE AC F6  c.>.....
        .byte   $CF,$EE,$7E,$CA,$7A,$DE,$A3,$57 ; A31B CF EE 7E CA 7A DE A3 57  ..~.z..W
        .byte   $F6,$C4,$A0,$2A,$AA,$5D,$1A,$6A ; A323 F6 C4 A0 2A AA 5D 1A 6A  ...*.].j
        .byte   $AB,$E3,$78,$96,$05,$4B,$0A,$4D ; A32B AB E3 78 96 05 4B 0A 4D  ..x..K.M
        .byte   $45,$1F,$C7,$E8,$F9,$6E,$51,$95 ; A333 45 1F C7 E8 F9 6E 51 95  E....nQ.
        .byte   $6A,$EF,$83,$E1,$7F,$77,$ED,$55 ; A33B 6A EF 83 E1 7F 77 ED 55  j....w.U
        .byte   $56,$8D,$41,$15,$14,$90,$D2,$47 ; A343 56 8D 41 15 14 90 D2 47  V.A....G
        .byte   $68,$F6,$3F,$EB,$B2,$BF,$37,$E4 ; A34B 68 F6 3F EB B2 BF 37 E4  h.?...7.
        .byte   $BC,$AF,$BC,$22,$1C,$6F,$1E,$62 ; A353 BC AF BC 22 1C 6F 1E 62  ...".o.b
        .byte   $84,$D8,$77,$55,$5E,$1F,$58,$4E ; A35B 84 D8 77 55 5E 1F 58 4E  ..wU^.XN
        .byte   $60,$79,$81,$F0,$03,$E3,$D4,$72 ; A363 60 79 81 F0 03 E3 D4 72  `y.....r
        .byte   $47,$28,$CD,$BD,$D6,$4E,$52,$D6 ; A36B 47 28 CD BD D6 4E 52 D6  G(...NR.
        .byte   $01,$38,$01,$18,$80,$88,$D3,$0E ; A373 01 38 01 18 80 88 D3 0E  .8......
        .byte   $E3,$E4,$7D,$1E,$EA,$F5,$61,$36 ; A37B E3 E4 7D 1E EA F5 61 36  ..}...a6
        .byte   $70,$2F,$EC,$2F,$BB,$F1,$FF,$0E ; A383 70 2F EC 2F BB F1 FF 0E  p/./....
        .byte   $E0,$76,$CF,$1B,$3C,$4C,$E3,$33 ; A38B E0 76 CF 1B 3C 4C E3 33  .v..<L.3
        .byte   $D2,$07,$8C,$2F,$DA,$7D,$AB,$D3 ; A393 D2 07 8C 2F DA 7D AB D3  .../.}..
        .byte   $7A,$7D,$4E,$27,$90,$A0,$7C,$23 ; A39B 7A 7D 4E 27 90 A0 7C 23  z}N'..|#
        .byte   $80,$D2,$03,$70,$33,$44,$D4,$5D ; A3A3 80 D2 03 70 33 44 D4 5D  ...p3D.]
        .byte   $86,$F7,$55,$0C,$42,$37,$A6,$49 ; A3AB 86 F7 55 0C 42 37 A6 49  ..U.B7.I
        .byte   $68,$DD,$55,$63,$F4,$6E,$8A,$68 ; A3B3 68 DD 55 63 F4 6E 8A 68  h.Uc.n.h
        .byte   $1B,$2C,$F8,$B3,$F5,$DF,$83,$F0 ; A3BB 1B 2C F8 B3 F5 DF 83 F0  .,......
        .byte   $BF,$7B,$E9,$7D,$37,$B9,$BC,$7F ; A3C3 BF 7B E9 7D 37 B9 BC 7F  .{.}7...
        .byte   $F0,$BE,$C4,$FC,$0F,$84,$70,$1A ; A3CB F0 BE C4 FC 0F 84 70 1A  ......p.
        .byte   $40,$4D,$C1,$B8,$77,$7B,$EE,$AA ; A3D3 40 4D C1 B8 77 7B EE AA  @M..w{..
        .byte   $18,$8F,$91,$BB,$39,$7D,$1B,$12 ; A3DB 18 8F 91 BB 39 7D 1B 12  ....9}..
        .byte   $95,$D1,$EE,$AA,$BC,$3D,$86,$65 ; A3E3 95 D1 EE AA BC 3D 86 65  .....=.e
        .byte   $81,$EB,$03,$8C,$6B,$89,$38,$95 ; A3EB 81 EB 03 8C 6B 89 38 95  ....k.8.
        .byte   $83,$5D,$DA,$D9,$27,$66,$BC,$27 ; A3F3 83 5D DA D9 27 66 BC 27  .]..'f.'
        .byte   $83,$3C,$53,$C7,$1C,$74,$C7,$28 ; A3FB 83 3C 53 C7 1C 74 C7 28  .<S..t.(
        .byte   $EE,$36,$EA,$F5,$C4,$24,$10,$98 ; A403 EE 36 EA F5 C4 24 10 98  .6...$..
        .byte   $C2,$70,$55,$EF,$B7,$F1,$FF,$F8 ; A40B C2 70 55 EF B7 F1 FF F8  .pU.....
        .byte   $EE,$30,$49,$A8,$0F,$B9,$47,$55 ; A413 EE 30 49 A8 0F B9 47 55  .0I...GU
        .byte   $51,$82,$46,$03,$F1,$D3,$1E,$9A ; A41B 51 82 46 03 F1 D3 1E 9A  Q.F.....
        .byte   $B7,$43,$3F,$A1,$95,$45,$51,$E9 ; A423 B7 43 3F A1 95 45 51 E9  .C?..EQ.
        .byte   $1F,$11,$F4,$75,$0A,$E7,$7A,$FF ; A42B 1F 11 F4 75 0A E7 7A FF  ...u..z.
        .byte   $47,$FA,$AD,$55,$57,$D3,$3A,$E6 ; A433 47 FA AD 55 57 D3 3A E6  G..UW.:.
        .byte   $BD,$EF,$8F,$F8,$C1,$31,$80,$A3 ; A43B BD EF 8F F8 C1 31 80 A3  .....1..
        .byte   $01,$C7,$1C,$7B,$AB,$75,$AE,$B9 ; A443 01 C7 1C 7B AB 75 AE B9  ...{.u..
        .byte   $D7,$AB,$3F,$21,$FA,$A7,$3F,$E6 ; A44B D7 AB 3F 21 FA A7 3F E6  ..?!..?.
        .byte   $0A,$39,$8C,$C2,$58,$7A,$3F,$FE ; A453 0A 39 8C C2 58 7A 3F FE  .9..Xz?.
        .byte   $3E,$0F,$03,$90,$C8,$26,$03,$4E ; A45B 3E 0F 03 90 C8 26 03 4E  >....&.N
        .byte   $AA,$AF,$56,$C5,$B3,$AE,$6B,$DE ; A463 AA AF 56 C5 B3 AE 6B DE  ..V...k.
        .byte   $FB,$BF,$1F,$F1,$3E,$2B,$C4,$9C ; A46B FB BF 1F F1 3E 2B C4 9C  ....>+..
        .byte   $4A,$C4,$CC,$4D,$78,$C0,$58,$C0 ; A473 4A C4 CC 4D 78 C0 58 C0  J..Mx.X.
        .byte   $78,$E3,$8F,$75,$76,$BE,$AF,$EE ; A47B 78 E3 8F 75 76 BE AF EE  x..uv...
        .byte   $7E,$AE,$6B,$8A,$BB,$5F,$7C,$4B ; A483 7E AE 6B 8A BB 5F 7C 4B  ~.k.._|K
        .byte   $5F,$12,$B0,$9A,$DD,$7B,$58,$9A ; A48B 5F 12 B0 9A DD 7B 58 9A  _....{X.
        .byte   $9A,$8A,$24,$88,$A2,$18,$AE,$27 ; A493 9A 8A 24 88 A2 18 AE 27  ..$....'
        .byte   $8F,$FF,$F7,$79,$4E,$8F,$E2,$78 ; A49B 8F FF F7 79 4E 8F E2 78  ...yN..x
        .byte   $0E,$05,$B6,$B1,$EA,$EA,$AA,$AF ; A4A3 0E 05 B6 B1 EA EA AA AF  ........
        .byte   $57,$D5,$FD,$CF,$D5,$CD,$70,$57 ; A4AB 57 D5 FD CF D5 CD 70 57  W.....pW
        .byte   $77,$DF,$1D,$AF,$89,$58,$4D,$6E ; A4B3 77 DF 1D AF 89 58 4D 6E  w....XMn
        .byte   $BD,$A8,$EB,$6E,$B3,$51,$5B,$30 ; A4BB BD A8 EB 6E B3 51 5B 30  ...n.Q[0
        .byte   $2C,$37,$13,$C7,$FF,$FD,$DE,$53 ; A4C3 2C 37 13 C7 FF FD DE 53  ,7.....S
        .byte   $23,$FE,$2B,$81,$6D,$A8,$EA,$3D ; A4CB 23 FE 2B 81 6D A8 EA 3D  #.+.m..=
        .byte   $3A,$AA,$AB,$B5,$F5,$7F,$73,$F5 ; A4D3 3A AA AB B5 F5 7F 73 F5  :.....s.
        .byte   $73,$5D,$D7,$25,$F7,$47,$6B,$E2 ; A4DB 73 5D D7 25 F7 47 6B E2  s].%.Gk.
        .byte   $56,$13,$5B,$AF,$6A,$3A,$EB,$51 ; A4E3 56 13 5B AF 6A 3A EB 51  V.[.j:.Q
        .byte   $59,$4C,$33,$88,$F1,$FF,$E3,$3E ; A4EB 59 4C 33 88 F1 FF E3 3E  YL3....>
        .byte   $27,$C4,$F0,$3E,$07,$87,$71,$7E ; A4F3 27 C4 F0 3E 07 87 71 7E  '..>..q~
        .byte   $76,$D3,$6F,$16,$F8,$6F,$C1,$78 ; A4FB 76 D3 6F 16 F8 6F C1 78  v.o..o.x
        .byte   $67,$0D,$CC,$3C,$BE,$77,$9F,$86 ; A503 67 0D CC 3C BE 77 9F 86  g..<.w..
        .byte   $78,$FF,$1D,$E3,$72,$3B,$8F,$A3 ; A50B 78 FF 1D E3 72 3B 8F A3  x...r;..
        .byte   $FE,$29,$C3,$C8,$7E,$FF,$5E,$35 ; A513 FE 29 C3 C8 7E FF 5E 35  .)..~.^5
        .byte   $CD,$5C,$F0,$FF,$07,$96,$F9,$5E ; A51B CD 5C F0 FF 07 96 F9 5E  .\.....^
        .byte   $6B,$82,$B1,$94,$7B,$9F,$1F,$D6 ; A523 6B 82 B1 94 7B 9F 1F D6  k...{...
        .byte   $A0,$E2,$85,$85,$C5,$B8,$7E,$56 ; A52B A0 E2 85 85 C5 B8 7E 56  ......~V
        .byte   $A2,$87,$30,$CF,$7C,$EF,$E5,$FE ; A533 A2 87 30 CF 7C EF E5 FE  ..0.|...
        .byte   $0F,$F8,$FD,$09,$97,$F7,$7F,$AF ; A53B 0F F8 FD 09 97 F7 7F AF  ........
        .byte   $1C,$26,$D7,$4D,$66,$35,$68,$7F ; A543 1C 26 D7 4D 66 35 68 7F  .&.Mf5h.
        .byte   $22,$E6,$19,$C5,$38,$FF,$F8,$79 ; A54B 22 E6 19 C5 38 FF F8 79  "...8..y
        .byte   $0E,$77,$CE,$FC,$C3,$C8,$DC,$1F ; A553 0E 77 CE FC C3 C8 DC 1F  .w......
        .byte   $CA,$0A,$39,$1E,$47,$06,$83,$CF ; A55B CA 0A 39 1E 47 06 83 CF  ..9.G...
        .byte   $F9,$A8,$29,$D1,$60,$92,$8A,$1F ; A563 F9 A8 29 D1 60 92 8A 1F  ..).`...
        .byte   $43,$D8,$77,$16,$F1,$B6,$3B,$47 ; A56B 43 D8 77 16 F1 B6 3B 47  C.w...;G
        .byte   $F8,$C7,$88,$18,$8B,$03,$C0,$72 ; A573 F8 C7 88 18 8B 03 C0 72  .......r
        .byte   $E6,$6F,$DE,$B5,$D7,$9A,$F9,$5F ; A57B E6 6F DE B5 D7 9A F9 5F  .o....._
        .byte   $9E,$70,$C6,$1B,$B8,$1F,$73,$EA ; A583 9E 70 C6 1B B8 1F 73 EA  .p....s.
        .byte   $3D,$6E,$2C,$E5,$3E,$EF,$C7,$FA ; A58B 3D 6E 2C E5 3E EF C7 FA  =n,.>...
        .byte   $E7,$5E,$6C,$F2,$87,$2A,$33,$4F ; A593 E7 5E 6C F2 87 2A 33 4F  .^l..*3O
        .byte   $6F,$EE,$CF,$2C,$F8,$0F,$8A,$71 ; A59B 6F EE CF 2C F8 0F 8A 71  o..,...q
        .byte   $03,$03,$1B,$FE,$6A,$02,$D4,$6E ; A5A3 03 03 1B FE 6A 02 D4 6E  ....j..n
        .byte   $30,$57,$FC,$39,$0D,$6F,$9B,$FF ; A5AB 30 57 FC 39 0D 6F 9B FF  0W.9.o..
        .byte   $1F,$CC,$07,$5B,$79,$F0,$5A,$8B ; A5B3 1F CC 07 5B 79 F0 5A 8B  ...[y.Z.
        .byte   $C7,$71,$9F,$B9,$5C,$7F,$DF,$E2 ; A5BB C7 71 9F B9 5C 7F DF E2  .q..\...
        .byte   $FD,$AB,$CB,$FF,$BC,$6B,$CD,$0C ; A5C3 FD AB CB FF BC 6B CD 0C  .....k..
        .byte   $E3,$FE,$FF,$AD,$C5,$73,$7F,$81 ; A5CB E3 FE FF AD C5 73 7F 81  .....s..
        .byte   $F8,$FF,$E3,$DC,$6A,$89,$D0,$F6 ; A5D3 F8 FF E3 DC 6A 89 D0 F6  ....j...
        .byte   $17,$D6,$A0,$2F,$1B,$0B,$8B,$71 ; A5DB 17 D6 A0 2F 1B 0B 8B 71  .../...q
        .byte   $49,$45,$1C,$61,$46,$FC,$DF,$F7 ; A5E3 49 45 1C 61 46 FC DF F7  IE.aF...
        .byte   $F8,$F5,$8F,$74,$37,$D7,$1A,$D9 ; A5EB F8 F5 8F 74 37 D7 1A D9  ...t7...
        .byte   $4F,$2C,$B8,$B7,$AB,$A7,$FC,$5F ; A5F3 4F 2C B8 B7 AB A7 FC 5F  O,....._
        .byte   $35,$51,$91,$51,$E3,$87,$67,$FD ; A5FB 35 51 91 51 E3 87 67 FD  5Q.Q..g.
        .byte   $25,$55,$1F,$C6,$B8,$BD,$17,$C3 ; A603 25 55 1F C6 B8 BD 17 C3  %U......
        .byte   $F0,$D6,$17,$42,$FC,$5F,$11,$E1 ; A60B F0 D6 17 42 FC 5F 11 E1  ...B._..
        .byte   $3D,$91,$D7,$75,$CE,$B3,$DE,$FE ; A613 3D 91 D7 75 CE B3 DE FE  =..u....
        .byte   $B6,$D7,$CA,$FC,$F3,$86,$30,$DE ; A61B B6 D7 CA FC F3 86 30 DE  ......0.
        .byte   $3B,$C7,$FE,$35,$C4,$58,$1E,$C6 ; A623 3B C7 FE 35 C4 58 1E C6  ;..5.X..
        .byte   $E8,$C4,$8C,$61,$C5,$7E,$4F,$98 ; A62B E8 C4 8C 61 C5 7E 4F 98  ...a.~O.
        .byte   $C7,$59,$F3,$31,$60,$44,$2C,$C7 ; A633 C7 59 F3 31 60 44 2C C7  .Y.1`D,.
        .byte   $48,$E1,$98,$E9,$8C,$98,$9D,$CC ; A63B 48 E1 98 E9 8C 98 9D CC  H.......
        .byte   $D7,$5B,$E1,$D9,$FD,$97,$B3,$2F ; A643 D7 5B E1 D9 FD 97 B3 2F  .[...../
        .byte   $9A,$82,$2D,$F5,$0A,$AF,$CE,$1C ; A64B 9A 82 2D F5 0A AF CE 1C  ..-.....
        .byte   $C3,$3F,$C7,$FD,$CE,$0D,$D3,$7F ; A653 C3 3F C7 FD CE 0D D3 7F  .?......
        .byte   $37,$4E,$70,$06,$CC,$E3,$FC,$ED ; A65B 37 4E 70 06 CC E3 FC ED  7Np.....
        .byte   $36,$CF,$E3,$EC,$DF,$C5,$E0,$FC ; A663 36 CF E3 EC DF C5 E0 FC  6.......
        .byte   $2D,$3B,$4F,$F9,$BB,$85,$B3,$B4 ; A66B 2D 3B 4F F9 BB 85 B3 B4  -;O.....
        .byte   $DD,$9D,$67,$F8,$73,$0F,$8F,$F3 ; A673 DD 9D 67 F8 73 0F 8F F3  ..g.s...
        .byte   $74,$3B,$1B,$8D,$D3,$FC,$3E,$8B ; A67B 74 3B 1B 8D D3 FC 3E 8B  t;....>.
        .byte   $C1,$F8,$5A,$7D,$CD,$D3,$FC,$3E ; A683 C1 F8 5A 7D CD D3 FC 3E  ..Z}...>
        .byte   $BF,$F1,$B8,$5F,$0B,$66,$D4,$FD ; A68B BF F1 B8 5F 0B 66 D4 FD  ..._.f..
        .byte   $0E,$E3,$B0,$DC,$2E,$8D,$B1,$6E ; A693 0E E3 B0 DC 2E 8D B1 6E  .......n
        .byte   $7E,$C5,$E0,$AC,$7B,$1D,$85,$B0 ; A69B 7E C5 E0 AC 7B 1D 85 B0  ~...{...
        .byte   $BC,$FE,$3F,$61,$F8,$7C,$3A,$8B ; A6A3 BC FE 3F 61 F8 7C 3A 8B  ..?a.|:.
        .byte   $C3,$B0,$DA,$2D,$9D,$F1,$5E,$19 ; A6AB C3 B0 DA 2D 9D F1 5E 19  ...-..^.
        .byte   $05,$47,$29,$FC,$35,$E2,$F8,$BC ; A6B3 05 47 29 FC 35 E2 F8 BC  .G).5...
        .byte   $17,$87,$A3,$B0,$DA,$2D,$9D,$F1 ; A6BB 17 87 A3 B0 DA 2D 9D F1  .....-..
        .byte   $EC,$6D,$16,$C3,$73,$94,$EA,$87 ; A6C3 EC 6D 16 C3 73 94 EA 87  .m..s...
        .byte   $B1,$7C,$3F,$1E,$C7,$61,$B4,$5B ; A6CB B1 7C 3F 1E C7 61 B4 5B  .|?..a.[
        .byte   $0D,$CE,$F8,$BC,$15,$85,$A1,$C9 ; A6D3 0D CE F8 BC 15 85 A1 C9  ........
        .byte   $9C,$6D,$1D,$41,$EC,$5E,$0A,$E2 ; A6DB 9C 6D 1D 41 EC 5E 0A E2  .m.A.^..
        .byte   $98,$EC,$36,$8B,$67,$7B,$AA,$28 ; A6E3 98 EC 36 8B 67 7B AA 28  ..6.g{.(
        .byte   $FF,$17,$62,$03,$11,$98,$D7,$1F ; A6EB FF 17 62 03 11 98 D7 1F  ..b.....
        .byte   $F8,$99,$81,$49,$01,$48,$06,$44 ; A6F3 F8 99 81 49 01 48 06 44  ...I.H.D
        .byte   $66,$35,$C7,$F8,$5A,$B3,$4C,$C5 ; A6FB 66 35 C7 F8 5A B3 4C C5  f5..Z.L.
        .byte   $D6,$7E,$03,$C8,$8C,$C6,$BB,$FC ; A703 D6 7E 03 C8 8C C6 BB FC  .~......
        .byte   $D1,$AF,$19,$78,$A4,$BB,$30,$CA ; A70B D1 AF 19 78 A4 BB 30 CA  ...x..0.
        .byte   $29,$2E,$32,$F1,$AF,$1F,$E3,$2F ; A713 29 2E 32 F1 AF 1F E3 2F  ).2..../
        .byte   $0A,$02,$C4,$85,$D0,$F5,$12,$17 ; A71B 0A 02 C4 85 D0 F5 12 17  ........
        .byte   $0A,$02,$C6,$5E,$3F,$DB,$2D,$41 ; A723 0A 02 C6 5E 3F DB 2D 41  ...^?.-A
        .byte   $20,$96,$11,$96,$87,$A8,$46,$58 ; A72B 20 96 11 96 87 A8 46 58   .....FX
        .byte   $24,$12,$DB,$2D,$47,$F6,$AC,$E5 ; A733 24 12 DB 2D 47 F6 AC E5  $..-G...
        .byte   $78,$30,$CC,$38,$CB,$C8,$1C,$D9 ; A73B 78 30 CC 38 CB C8 1C D9  x0.8....
        .byte   $65,$65,$38,$17,$E3,$F8,$EF,$63 ; A743 65 65 38 17 E3 F8 EF 63  ee8....c
        .byte   $BA,$08,$74,$01,$02,$A2,$0D,$B0 ; A74B BA 08 74 01 02 A2 0D B0  ..t.....
        .byte   $EB,$87,$03,$F0,$32,$81,$D8,$8F ; A753 EB 87 03 F0 32 81 D8 8F  ....2...
        .byte   $89,$B0,$17,$81,$C0,$07,$81,$6A ; A75B 89 B0 17 81 C0 07 81 6A  .......j
        .byte   $0B,$86,$A2,$44,$18,$91,$61,$F0 ; A763 0B 86 A2 44 18 91 61 F0  ...D..a.
        .byte   $52,$20,$C7,$FF,$1C,$60,$46,$02 ; A76B 52 20 C7 FF 1C 60 46 02  R ...`F.
        .byte   $05,$AC,$49,$88,$38,$83,$20,$4C ; A773 05 AC 49 88 38 83 20 4C  ..I.8. L
        .byte   $52,$9A,$28,$BB,$03,$8B,$1B,$18 ; A77B 52 9A 28 BB 03 8B 1B 18  R.(.....
        .byte   $C0,$33,$80,$CC,$20,$1C,$45,$D8 ; A783 C0 33 80 CC 20 1C 45 D8  .3.. .E.
        .byte   $1B,$19,$E2,$D9,$FC,$1E,$8B,$61 ; A78B 1B 19 E2 D9 FC 1E 8B 61  .......a
        .byte   $28,$32,$92,$8A,$20,$E0,$66,$C0 ; A793 28 32 92 8A 20 E0 66 C0  (2.. .f.
        .byte   $0B,$08,$36,$00,$40,$CC,$41,$C4 ; A79B 0B 08 36 00 40 CC 41 C4  ..6.@.A.
        .byte   $11,$07,$F1,$B6,$23,$20,$00,$40 ; A7A3 11 07 F1 B6 23 20 00 40  ....# .@
        .byte   $82,$23,$01,$A8,$B7,$40,$55,$1A ; A7AB 82 23 01 A8 B7 40 55 1A  .#...@U.
        .byte   $E2,$26,$31,$22,$04,$01,$06,$64 ; A7B3 E2 26 31 22 04 01 06 64  .&1"...d
        .byte   $80,$78,$9F,$78,$CD,$47,$F1,$F8 ; A7BB 80 78 9F 78 CD 47 F1 F8  .x.x.G..
        .byte   $7C,$23,$F0,$FE,$3F,$0F,$8D,$DF ; A7C3 7C 23 F0 FE 3F 0F 8D DF  |#..?...
        .byte   $98,$F9,$00,$F6,$80,$E4,$40,$6C ; A7CB 98 F9 00 F6 80 E4 40 6C  ......@l
        .byte   $08,$0A,$22,$01,$50,$09,$1E,$20 ; A7D3 08 0A 22 01 50 09 1E 20  ..".P.. 
        .byte   $E2,$23,$12,$08,$9C,$09,$C1,$0F ; A7DB E2 23 12 08 9C 09 C1 0F  .#......
        .byte   $18,$00,$1C,$9A,$50,$8B,$75,$8F ; A7E3 18 00 1C 9A 50 8B 75 8F  ....P.u.
        .byte   $ED,$FC,$7F,$6F,$E3,$FD,$25,$59 ; A7EB ED FC 7F 6F E3 FD 25 59  ...o..%Y
        .byte   $08,$E2,$0B,$C0,$06,$98,$10,$E6 ; A7F3 08 E2 0B C0 06 98 10 E6  ........
        .byte   $2D,$06,$36,$50,$18,$E4,$7C,$47 ; A7FB 2D 06 36 50 18 E4 7C 47  -.6P..|G
        .byte   $28,$32,$A1,$98,$12,$08,$9E,$08 ; A803 28 32 A1 98 12 08 9E 08  (2......
        .byte   $88,$0E,$30,$A8,$8A,$FF,$B6,$37 ; A80B 88 0E 30 A8 8A FF B6 37  ..0....7
        .byte   $FD,$B1,$DF,$FD,$B2,$BF,$E3,$BC ; A813 FD B1 DF FD B2 BF E3 BC  ........
        .byte   $76,$1B,$E3,$68,$D4,$34,$BF,$ED ; A81B 76 1B E3 68 D4 34 BF ED  v..h.4..
        .byte   $8E,$FF,$B7,$C6,$23,$1D,$11,$B4 ; A823 8E FF B7 C6 23 1D 11 B4  ....#...
        .byte   $45,$44,$42,$88,$21,$32,$90,$99 ; A82B 45 44 42 88 21 32 90 99  EDB.!2..
        .byte   $4C,$12,$04,$89,$63,$1D,$18,$8C ; A833 4C 12 04 89 63 1D 18 8C  L...c...
        .byte   $92,$06,$84,$2B,$50,$15,$AE,$54 ; A83B 92 06 84 2B 50 15 AE 54  ...+P..T
        .byte   $50,$58,$BD,$18,$89,$02,$64,$A0 ; A843 50 58 BD 18 89 02 64 A0  PX....d.
        .byte   $0E,$14,$4E,$48,$F0,$91,$C5,$8C ; A84B 0E 14 4E 48 F0 91 C5 8C  ..NH....
        .byte   $68,$D7,$46,$42,$D8,$8A,$E2,$8B ; A853 68 D7 46 42 D8 8A E2 8B  h.FB....
        .byte   $D9,$57,$DC,$0F,$08,$8F,$45,$55 ; A85B D9 57 DC 0F 08 8F 45 55  .W....EU
        .byte   $47,$B1,$A6,$22,$C0,$5C,$07,$B0 ; A863 47 B1 A6 22 C0 5C 07 B0  G..".\..
        .byte   $FB,$1F,$61,$F8,$F6,$34,$C4,$58 ; A86B FB 1F 61 F8 F6 34 C4 58  ..a..4.X
        .byte   $0A,$6C,$24,$F1,$EC,$69,$88,$B0 ; A873 0A 6C 24 F1 EC 69 88 B0  .l$..i..
        .byte   $1B,$00,$CB,$17,$30,$9D,$86,$6C ; A87B 1B 00 CB 17 30 9D 86 6C  ....0..l
        .byte   $55,$1E,$0E,$87,$B0,$66,$A0,$86 ; A883 55 1E 0E 87 B0 66 A0 86  U....f..
        .byte   $41,$46,$4C,$C4,$90,$D4,$59,$C4 ; A88B 41 46 4C C4 90 D4 59 C4  AFL...Y.
        .byte   $3F,$CF,$E1,$3E,$9F,$C2,$FC,$4F ; A893 3F CF E1 3E 9F C2 FC 4F  ?..>...O
        .byte   $84,$3E,$8F,$E7,$FA,$7E,$13,$EA ; A89B 84 3E 8F E7 FA 7E 13 EA  .>...~..
        .byte   $7E,$23,$E6,$F8,$FF,$E7,$F1,$3E ; A8A3 7E 23 E6 F8 FF E7 F1 3E  ~#.....>
        .byte   $04,$F8,$9F,$A8,$FD,$BE,$3F,$F2 ; A8AB 04 F8 9F A8 FD BE 3F F2  ......?.
        .byte   $A0,$A3,$D8,$D6,$24,$0A,$D9,$B9 ; A8B3 A0 A3 D8 D6 24 0A D9 B9  ....$...
        .byte   $BF,$5A,$A0,$F1,$68,$BC,$14,$C1 ; A8BB BF 5A A0 F1 68 BC 14 C1  .Z..h...
        .byte   $64,$16,$A5,$D5,$2A,$8A,$DF,$E0 ; A8C3 64 16 A5 D5 2A 8A DF E0  d...*...
        .byte   $F8,$26,$25,$8D,$63,$DA,$4A,$0B ; A8CB F8 26 25 8D 63 DA 4A 0B  .&%.c.J.
        .byte   $A1,$6C,$55,$85,$F8,$5E,$4A,$D5 ; A8D3 A1 6C 55 85 F8 5E 4A D5  .lU..^J.
        .byte   $EB,$12,$6A,$3F,$0F,$91,$61,$13 ; A8DB EB 12 6A 3F 0F 91 61 13  ..j?..a.
        .byte   $28,$90,$81,$8B,$89,$09,$6A,$C5 ; A8E3 28 90 81 8B 89 09 6A C5  (.....j.
        .byte   $5C,$7D,$43,$DE,$18,$54,$D0,$EC ; A8EB 5C 7D 43 DE 18 54 D0 EC  \}C..T..
        .byte   $81,$0C,$24,$90,$B6,$A1,$02,$18 ; A8F3 81 0C 24 90 B6 A1 02 18  ..$.....
        .byte   $45,$71,$9E,$33,$22,$2B,$08,$8A ; A8FB 45 71 9E 33 22 2B 08 8A  Eq.3"+..
        .byte   $2C,$43,$FC,$AA,$CD,$A8,$2A,$85 ; A903 2C 43 FC AA CD A8 2A 85  ,C....*.
        .byte   $34,$2E,$C8,$2A,$C1,$05,$86,$3F ; A90B 34 2E C8 2A C1 05 86 3F  4..*...?
        .byte   $4F,$77,$07,$A2,$39,$50,$61,$54 ; A913 4F 77 07 A2 39 50 61 54  Ow..9PaT
        .byte   $0D,$D0,$78,$D7,$44,$7F,$C1,$7F ; A91B 0D D0 78 D7 44 7F C1 7F  ..x.D...
        .byte   $08,$FB,$4F,$DB,$FB,$BF,$63,$F6 ; A923 08 FB 4F DB FB BF 63 F6  ..O...c.
        .byte   $7E,$FF,$9F,$F1,$E8,$AE,$A8,$7A ; A92B 7E FF 9F F1 E8 AE A8 7A  ~......z
        .byte   $AD,$FE,$AD,$8D,$F8,$85,$FE,$CF ; A933 AD FE AD 8D F8 85 FE CF  ........
        .byte   $D8,$B9,$B9,$C9,$66,$92,$CA,$A1 ; A93B D8 B9 B9 C9 66 92 CA A1  ....f...
        .byte   $66,$92,$E7,$28,$D9,$1A,$FE,$AB ; A943 66 92 E7 28 D9 1A FE AB  f..(....
        .byte   $9A,$4E,$4B,$34,$96,$55,$0B,$34 ; A94B 9A 4E 4B 34 96 55 0B 34  .NK4.U.4
        .byte   $97,$39,$23,$64,$68,$BE,$22,$34 ; A953 97 39 23 64 68 BE 22 34  .9#dh."4
        .byte   $51,$1F,$F1,$FD,$8A,$AA,$38,$63 ; A95B 51 1F F1 FD 8A AA 38 63  Q.....8c
        .byte   $21,$12,$20,$0C,$68,$91,$08,$31 ; A963 21 12 20 0C 68 91 08 31  !. .h..1
        .byte   $BC,$48,$84,$18,$D8,$44,$41,$F0 ; A96B BC 48 84 18 D8 44 41 F0  .H...DA.
        .byte   $79,$8E,$63,$08,$D6,$33,$C5,$20 ; A973 79 8E 63 08 D6 33 C5 20  y.c..3. 
        .byte   $44,$C1,$C1,$E2,$4C,$13,$81,$04 ; A97B 44 C1 C1 E2 4C 13 81 04  D...L...
        .byte   $41,$8E,$23,$40,$E0,$0C,$50,$21 ; A983 41 8E 23 40 E0 0C 50 21  A.#@..P!
        .byte   $40,$28,$42,$26,$26,$63,$26,$92 ; A98B 40 28 42 26 26 63 26 92  @(B&&c&.
        .byte   $71,$8E,$91,$E0,$C8,$C2,$21,$83 ; A993 71 8E 91 E0 C8 C2 21 83  q.....!.
        .byte   $08,$39,$03,$F4,$7F,$E5,$20,$91 ; A99B 08 39 03 F4 7F E5 20 91  .9.... .
        .byte   $04,$C2,$92,$0C,$A1,$D2,$0E,$33 ; A9A3 04 C2 92 0C A1 D2 0E 33  .......3
        .byte   $C7,$F2,$16,$E0,$7C,$27,$86,$70 ; A9AB C7 F2 16 E0 7C 27 86 70  ....|'.p
        .byte   $B1,$13,$81,$54,$1B,$31,$FC,$59 ; A9B3 B1 13 81 54 1B 31 FC 59  ...T.1.Y
        .byte   $83,$4C,$3C,$8B,$31,$FE,$60,$B8 ; A9BB 83 4C 3C 8B 31 FE 60 B8  .L<.1.`.
        .byte   $34,$2D,$8D,$61,$78,$FF,$6A,$F9 ; A9C3 34 2D 8D 61 78 FF 6A F9  4-.ax.j.
        .byte   $3C,$18,$66,$4E,$59,$1C,$81,$CD ; A9CB 3C 18 66 4E 59 1C 81 CD  <.fNY...
        .byte   $91,$3B,$20,$D0,$5E,$03,$F8,$FF ; A9D3 91 3B 20 D0 5E 03 F8 FF  .; .^...
        .byte   $62,$F5,$05,$D4,$01,$D5,$12,$15 ; A9DB 62 F5 05 D4 01 D5 12 15  b.......
        .byte   $B0,$EB,$87,$6F,$AD,$96,$DD,$A0 ; A9E3 B0 EB 87 6F AD 96 DD A0  ...o....
        .byte   $7A,$23,$40,$CF,$18,$E1,$9E,$6A ; A9EB 7A 23 40 CF 18 E1 9E 6A  z#@....j
        .byte   $0B,$8A,$94,$70,$EC,$9C,$D6,$1F ; A9F3 0B 8A 94 70 EC 9C D6 1F  ...p....
        .byte   $89,$F1,$93,$1D,$C6,$43,$12,$F0 ; A9FB 89 F1 93 1D C6 43 12 F0  .....C..
        .byte   $43,$91,$FD,$FE,$12,$E1,$1F,$F5 ; AA03 43 91 FD FE 12 E1 1F F5  C.......
        .byte   $3E,$B8,$95,$29,$B3,$4F,$6F,$ED ; AA0B 3E B8 95 29 B3 4F 6F ED  >..).Oo.
        .byte   $B2,$5A,$E1,$B5,$FE,$E7,$EF,$F9 ; AA13 B2 5A E1 B5 FE E7 EF F9  .Z......
        .byte   $AA,$87,$7A,$BE,$B7,$D6,$E5,$B2 ; AA1B AA 87 7A BE B7 D6 E5 B2  ..z.....
        .byte   $B3,$E6,$2C,$54,$7D,$08,$CB,$6F ; AA23 B3 E6 2C 54 7D 08 CB 6F  ..,T}..o
        .byte   $5A,$2E,$05,$48,$2F,$20,$80,$41 ; AA2B 5A 2E 05 48 2F 20 80 41  Z..H/ .A
        .byte   $1B,$71,$F2,$8D,$09,$DA,$B5,$0B ; AA33 1B 71 F2 8D 09 DA B5 0B  .q......
        .byte   $48,$27,$20,$80,$80,$9A,$04,$10 ; AA3B 48 27 20 80 80 9A 04 10  H' .....
        .byte   $C0,$66,$68,$32,$D5,$48,$B4,$1C ; AA43 C0 66 68 32 D5 48 B4 1C  .fh2.H..
        .byte   $D2,$E1,$F8,$BE,$D9,$CC,$54,$60 ; AA4B D2 E1 F8 BE D9 CC 54 60  ......T`
        .byte   $6D,$60,$43,$18,$84,$22,$37,$18 ; AA53 6D 60 43 18 84 22 37 18  m`C.."7.
        .byte   $FB,$8F,$F0,$FE,$08,$22,$8F,$63 ; AA5B FB 8F F0 FE 08 22 8F 63  .....".c
        .byte   $98,$C8,$4C,$0C,$0F,$89,$56,$B1 ; AA63 98 C8 4C 0C 0F 89 56 B1  ..L...V.
        .byte   $1E,$1D,$14,$85,$50,$B5,$06,$70 ; AA6B 1E 1D 14 85 50 B5 06 70  ....P..p
        .byte   $B6,$51,$11,$46,$28,$E0,$38,$87 ; AA73 B6 51 11 46 28 E0 38 87  .Q.F(.8.
        .byte   $84,$7C,$8F,$A6,$A0,$AD,$54,$99 ; AA7B 84 7C 8F A6 A0 AD 54 99  .|....T.
        .byte   $2A,$1C,$C9,$C5,$42,$38,$17,$A0 ; AA83 2A 1C C9 C5 42 38 17 A0  *...B8..
        .byte   $F8,$0B,$30,$15,$20,$24,$C1,$21 ; AA8B F8 0B 30 15 20 24 C1 21  ..0. $.!
        .byte   $82,$47,$63,$A0,$BD,$42,$7D,$0C ; AA93 82 47 63 A0 BD 42 7D 0C  .Gc..B}.
        .byte   $C9,$01,$22,$00,$B3,$81,$53,$01 ; AA9B C9 01 22 00 B3 81 53 01  .."...S.
        .byte   $CC,$11,$26,$46,$49,$1C,$80,$F2 ; AAA3 CC 11 26 46 49 1C 80 F2  ..&FI...
        .byte   $0F,$91,$F8,$D5,$02,$E4,$B2,$51 ; AAAB 0F 91 F8 D5 02 E4 B2 51  .......Q
        .byte   $44,$31,$15,$14,$3F,$06,$C1,$70 ; AAB3 44 31 15 14 3F 06 C1 70  D1..?..p
        .byte   $54,$14,$05,$C1,$B1,$2D,$B3,$8A ; AABB 54 14 05 C1 B1 2D B3 8A  T....-..
        .byte   $BF,$C3,$B1,$03,$24,$40,$CA,$54 ; AAC3 BF C3 B1 03 24 40 CA 54  ....$@.T
        .byte   $04,$6A,$06,$48,$82,$60,$83,$14 ; AACB 04 6A 06 48 82 60 83 14  .j.H.`..
        .byte   $E0,$EE,$3C,$83,$C4,$8B,$E0,$67 ; AAD3 E0 EE 3C 83 C4 8B E0 67  ..<....g
        .byte   $7F,$D6,$A0,$A5,$1F,$1E,$52,$3F ; AADB 7F D6 A0 A5 1F 1E 52 3F  ......R?
        .byte   $8B,$28,$FF,$91,$11,$47,$B1,$CC ; AAE3 8B 28 FF 91 11 47 B1 CC  .(...G..
        .byte   $65,$13,$41,$D6,$FD,$99,$BA,$4C ; AAEB 65 13 41 D6 FD 99 BA 4C  e.A....L
        .byte   $7A,$71,$54,$54,$85,$41,$09,$FC ; AAF3 7A 71 54 54 85 41 09 FC  zqTT.A..
        .byte   $51,$82,$48,$C5,$58,$C3,$6F,$C0 ; AAFB 51 82 48 C5 58 C3 6F C0  Q.H.X.o.
        .byte   $26,$20,$31,$96,$39,$8F,$68,$22 ; AB03 26 20 31 96 39 8F 68 22  & 1.9.h"
        .byte   $8A,$62,$7F,$38,$85,$C0,$5C,$93 ; AB0B 8A 62 7F 38 85 C0 5C 93  .b.8..\.
        .byte   $97,$A4,$05,$1F,$87,$B8,$EF,$1D ; AB13 97 A4 05 1F 87 B8 EF 1D  ........
        .byte   $A3,$65,$0A,$3C,$7C,$6C,$15,$06 ; AB1B A3 65 0A 3C 7C 6C 15 06  .e.<|l..
        .byte   $C3,$C1,$B0,$9C,$35,$55,$45,$68 ; AB23 C3 C1 B0 9C 35 55 45 68  ....5UEh
        .byte   $9E,$04,$E0,$64,$B7,$AB,$6D,$BD ; AB2B 9E 04 E0 64 B7 AB 6D BD  ...d..m.
        .byte   $3B,$7B,$9F,$0B,$F1,$AF,$0A,$9C ; AB33 3B 7B 9F 0B F1 AF 0A 9C  ;{......
        .byte   $16,$60,$AB,$93,$B3,$9B,$DB,$C6 ; AB3B 16 60 AB 93 B3 9B DB C6  .`......
        .byte   $14,$71,$BC,$73,$8C,$F8,$9E,$13 ; AB43 14 71 BC 73 8C F8 9E 13  .q.s....
        .byte   $84,$EE,$4F,$65,$9C,$CF,$AD,$78 ; AB4B 84 EE 4F 65 9C CF AD 78  ..Oe...x
        .byte   $5B,$C2,$0F,$0C,$4E,$1C,$66,$02 ; AB53 5B C2 0F 0C 4E 1C 66 02  [...N.f.
        .byte   $34,$01,$70,$1F,$11,$38,$03,$C0 ; AB5B 34 01 70 1F 11 38 03 C0  4.p..8..
        .byte   $1C,$2D,$E1,$6E,$8B,$E6,$01,$CC ; AB63 1C 2D E1 6E 8B E6 01 CC  .-.n....
        .byte   $1F,$DC,$0C,$0D,$F3,$71,$30,$F7 ; AB6B 1F DC 0C 0D F3 71 30 F7  .....q0.
        .byte   $1F,$1F,$F8,$5A,$5B,$DB,$71,$DB ; AB73 1F 1F F8 5A 5B DB 71 DB  ...Z[.q.
        .byte   $1E,$1F,$22,$78,$67,$6E,$70,$9B ; AB7B 1E 1F 22 78 67 6E 70 9B  .."xgnp.
        .byte   $E5,$F2,$6F,$26,$54,$DC,$ED,$9E ; AB83 E5 F2 6F 26 54 DC ED 9E  ..o&T...
        .byte   $8C,$F1,$9E,$39,$C7,$78,$CF,$89 ; AB8B 8C F1 9E 39 C7 78 CF 89  ...9.x..
        .byte   $E1,$38,$5B,$99,$BD,$0F,$E3,$5E ; AB93 E1 38 5B 99 BD 0F E3 5E  .8[....^
        .byte   $16,$F0,$83,$C3,$70,$30,$37,$CD ; AB9B 16 F0 83 C3 70 30 37 CD  ....p07.
        .byte   $C4,$C3,$DC,$7D,$07,$D8,$FE,$9D ; ABA3 C4 C3 DC 7D 07 D8 FE 9D  ...}....
        .byte   $24,$47,$E8,$85,$80,$28,$C0,$23 ; ABAB 24 47 E8 85 80 28 C0 23  $G...(.#
        .byte   $00,$5B,$12,$D4,$4B,$1F,$44,$6F ; ABB3 00 5B 12 D4 4B 1F 44 6F  .[..K.Do
        .byte   $D1,$A6,$52,$94,$22,$2A,$04,$57 ; ABBB D1 A6 52 94 22 2A 04 57  ..R."*.W
        .byte   $22,$A1,$B5,$EC,$DF,$18,$A7,$20 ; ABC3 22 A1 B5 EC DF 18 A7 20  "...... 
        .byte   $03,$0A,$04,$A1,$53,$92,$41,$A1 ; ABCB 03 0A 04 A1 53 92 41 A1  ....S.A.
        .byte   $23,$8B,$1C,$50,$38,$DA,$EE,$10 ; ABD3 23 8B 1C 50 38 DA EE 10  #..P8...
        .byte   $AC,$51,$52,$D1,$6E,$15,$4D,$70 ; ABDB AC 51 52 D1 6E 15 4D 70  .QR.n.Mp
        .byte   $3C,$20,$7B,$11,$E8,$0A,$A3,$6C ; ABE3 3C 20 7B 11 E8 0A A3 6C  < {....l
        .byte   $45,$40,$88,$08,$0C,$91,$64,$80 ; ABEB 45 40 88 08 0C 91 64 80  E@....d.
        .byte   $06,$2A,$14,$1B,$0A,$36,$0F,$06 ; ABF3 06 2A 14 1B 0A 36 0F 06  .*...6..
        .byte   $E3,$15,$55,$A0,$56,$84,$6D,$01 ; ABFB E3 15 55 A0 56 84 6D 01  ..U.V.m.
        .byte   $C8,$46,$62,$32,$31,$98,$8E,$6B ; AC03 C8 46 62 32 31 98 8E 6B  .Fb21..k
        .byte   $46,$A3,$0B,$A3,$03,$C4,$1D,$48 ; AC0B 46 A3 0B A3 03 C4 1D 48  F......H
        .byte   $3A,$98,$F1,$8A,$8D,$03,$C8,$1E ; AC13 3A 98 F1 8A 8D 03 C8 1E  :.......
        .byte   $8A,$64,$48,$D0,$75,$06,$7C,$C7 ; AC1B 8A 64 48 D0 75 06 7C C7  .dH.u.|.
        .byte   $07,$38,$48,$E1,$23,$0C,$D4,$27 ; AC23 07 38 48 E1 23 0C D4 27  .8H.#..'
        .byte   $C2,$73,$0C,$19,$C1,$B8,$99,$E3 ; AC2B C2 73 0C 19 C1 B8 99 E3  .s......
        .byte   $5C,$67,$89,$F9,$AC,$1E,$0C,$D0 ; AC33 5C 67 89 F9 AC 1E 0C D0  \g......
        .byte   $31,$2B,$12,$08,$24,$3B,$70,$E4 ; AC3B 31 2B 12 08 24 3B 70 E4  1+..$;p.
        .byte   $05,$18,$26,$0B,$3F,$E6,$28,$7C ; AC43 05 18 26 0B 3F E6 28 7C  ..&.?.(|
        .byte   $3F,$33,$FB,$7F,$80             ; AC4B 3F 33 FB 7F 80           ?3...
basechr:.byte   $9D,$5E,$C3,$07,$FF,$F1,$D2,$7E ; AC50 9D 5E C3 07 FF F1 D2 7E  .^.....~
        .byte   $3C,$11,$F0,$D5,$5C,$F4,$0A,$E0 ; AC58 3C 11 F0 D5 5C F4 0A E0  <...\...
        .byte   $D6,$47,$46,$B9,$C6,$87,$68,$0A ; AC60 D6 47 46 B9 C6 87 68 0A  .GF...h.
        .byte   $28,$00,$14,$80,$00,$C1,$40,$8E ; AC68 28 00 14 80 00 C1 40 8E  (.....@.
        .byte   $A6,$84,$49,$D4,$4C,$F1,$D4,$82 ; AC70 A6 84 49 D4 4C F1 D4 82  ..I.L...
        .byte   $81,$00,$01,$80,$05,$20,$A2,$83 ; AC78 81 00 01 80 05 20 A2 83  ..... ..
        .byte   $B4,$5C,$92,$4A,$26,$74,$22,$4F ; AC80 B4 5C 92 4A 26 74 22 4F  .\.J&t"O
        .byte   $0F,$C6,$F9,$47,$94,$D9,$1F,$94 ; AC88 0F C6 F9 47 94 D9 1F 94  ...G....
        .byte   $FC,$BE,$AF,$B6,$C9,$BF,$3B,$84 ; AC90 FC BE AF B6 C9 BF 3B 84  ......;.
        .byte   $DE,$86,$FE,$6A,$42,$11,$A5,$67 ; AC98 DE 86 FE 6A 42 11 A5 67  ...jB..g
        .byte   $D4,$C2,$A1,$94,$FE,$3F,$9C,$A1 ; ACA0 D4 C2 A1 94 FE 3F 9C A1  .....?..
        .byte   $6F,$EA,$3B,$7D,$EF,$E8,$DB,$1F ; ACA8 6F EA 3B 7D EF E8 DB 1F  o.;}....
        .byte   $F0,$7D,$33,$B2,$4B,$90,$DC,$98 ; ACB0 F0 7D 33 B2 4B 90 DC 98  .}3.K...
        .byte   $C9,$34,$E4,$82,$9C,$46,$58,$A9 ; ACB8 C9 34 E4 82 9C 46 58 A9  .4...FX.
        .byte   $CA,$64,$85,$AA,$69,$FE,$BF,$B6 ; ACC0 CA 64 85 AA 69 FE BF B6  .d..i...
        .byte   $D3,$F1,$BF,$A7,$1F,$7A,$EF,$FD ; ACC8 D3 F1 BF A7 1F 7A EF FD  .....z..
        .byte   $FE,$27,$EF,$8E,$FD,$5F,$F1,$B3 ; ACD0 FE 27 EF 8E FD 5F F1 B3  .'..._..
        .byte   $1F,$F7,$E6,$98,$27,$C1,$5F,$80 ; ACD8 1F F7 E6 98 27 C1 5F 80  ....'._.
        .byte   $36,$00,$F8,$62,$43,$10,$6A,$85 ; ACE0 36 00 F8 62 43 10 6A 85  6..bC.j.
        .byte   $E8,$6E,$CE,$EC,$F6,$CF,$EB,$94 ; ACE8 E8 6E CE EC F6 CF EB 94  .n......
        .byte   $38,$7A,$86,$6A,$12,$2A,$12,$44 ; ACF0 38 7A 86 6A 12 2A 12 44  8z.j.*.D
        .byte   $21,$C6,$49,$89,$26,$6C,$C6,$B3 ; ACF8 21 C6 49 89 26 6C C6 B3  !.I.&l..
        .byte   $16,$CC,$9C,$66,$71,$80,$C4,$F3 ; AD00 16 CC 9C 66 71 80 C4 F3  ...fq...
        .byte   $0F,$C3,$3D,$24,$6C,$93,$24,$33 ; AD08 0F C3 3D 24 6C 93 24 33  ..=$l.$3
        .byte   $92,$4E,$79,$14,$27,$C1,$3C,$52 ; AD10 92 4E 79 14 27 C1 3C 52  .Ny.'.<R
        .byte   $1B,$4B,$B0,$5B,$82,$16,$0B,$A7 ; AD18 1B 4B B0 5B 82 16 0B A7  .K.[....
        .byte   $24,$14,$88,$CB,$2A,$99,$42,$41 ; AD20 24 14 88 CB 2A 99 42 41  $...*.BA
        .byte   $A4,$90,$06,$80,$B0,$0F,$01,$A0 ; AD28 A4 90 06 80 B0 0F 01 A0  ........
        .byte   $2C,$0F,$DF,$36,$24,$F1,$AF,$1B ; AD30 2C 0F DF 36 24 F1 AF 1B  ,..6$...
        .byte   $33,$77,$EF,$75,$BB,$C9,$77,$EF ; AD38 33 77 EF 75 BB C9 77 EF  3w.u..w.
        .byte   $03,$E4,$09,$F0,$29,$E0,$5C,$C0 ; AD40 03 E4 09 F0 29 E0 5C C0  ....).\.
        .byte   $BF,$EF,$DD,$1E,$EF,$BE,$FD,$23 ; AD48 BF EF DD 1E EF BE FD 23  .......#
        .byte   $63,$1F,$F0,$2A,$D0,$2C,$98,$17 ; AD50 63 1F F0 2A D0 2C 98 17  c..*.,..
        .byte   $EA,$B5,$9C,$6D,$0F,$C7,$F1,$50 ; AD58 EA B5 9C 6D 0F C7 F1 50  ...m...P
        .byte   $80,$7F,$3F,$CE,$3C,$E6,$CC,$FC ; AD60 80 7F 3F CE 3C E6 CC FC  ..?.<...
        .byte   $E7,$E7,$F4,$FD,$A6,$4D,$79,$D4 ; AD68 E7 E7 F4 FD A6 4D 79 D4  .....My.
        .byte   $26,$B4,$35,$F3,$32,$10,$CD,$27 ; AD70 26 B4 35 F3 32 10 CD 27  &.5.2..'
        .byte   $3E,$66,$13,$0C,$97,$F1,$FE,$BE ; AD78 3E 66 13 0C 97 F1 FE BE  >f......
        .byte   $49,$CD,$73,$D7,$C8,$C9,$8F,$F9 ; AD80 49 CD 73 D7 C8 C9 8F F9  I.s.....
        .byte   $E0,$FE,$BC,$23,$F8,$10,$3F,$BE ; AD88 E0 FE BC 23 F8 10 3F BE  ...#..?.
        .byte   $80,$69,$44,$3F,$EA,$7C,$7F,$A1 ; AD90 80 69 44 3F EA 7C 7F A1  .iD?.|..
        .byte   $EF,$A3,$F1,$FC,$D7,$B3,$FA,$BE ; AD98 EF A3 F1 FC D7 B3 FA BE  ........
        .byte   $7B,$FC,$3F,$CF,$A9,$18,$1E,$4F ; ADA0 7B FC 3F CF A9 18 1E 4F  {.?....O
        .byte   $08,$FF,$2B,$EC,$1F,$EC,$3E,$3F ; ADA8 08 FF 2B EC 1F EC 3E 3F  ..+...>?
        .byte   $CD,$7A,$03,$FB,$87,$8F,$E7,$0F ; ADB0 CD 7A 03 FB 87 8F E7 0F  .z......
        .byte   $AF,$EF,$C7,$FD,$F5,$FC,$7F,$D9 ; ADB8 AF EF C7 FD F5 FC 7F D9  ........
        .byte   $FF,$C7,$FD,$AF,$FC,$7F,$CA,$3A ; ADC0 FF C7 FD AF FC 7F CA 3A  .......:
        .byte   $58,$0A,$56,$01,$5B,$05,$78,$EB ; ADC8 58 0A 56 01 5B 05 78 EB  X.V.[.x.
        .byte   $96,$3C,$B0,$3A,$10,$3C,$11,$3E ; ADD0 96 3C B0 3A 10 3C 11 3E  .<.:.<.>
        .byte   $08,$BC,$11,$F9,$D5,$AD,$5F,$BC ; ADD8 08 BC 11 F9 D5 AD 5F BC  ......_.
        .byte   $B1,$D7,$04,$42,$20,$8A,$03,$C1 ; ADE0 B1 D7 04 42 20 8A 03 C1  ...B ...
        .byte   $14,$08,$23,$F2,$85,$6C,$15,$FC ; ADE8 14 08 23 F2 85 6C 15 FC  ..#..l..
        .byte   $75,$C1,$11,$C1,$13,$FC,$11,$78 ; ADF0 75 C1 11 C1 13 FC 11 78  u......x
        .byte   $23,$EA,$6E,$67,$06,$B0,$7A,$C0 ; ADF8 23 EA 6E 67 06 B0 7A C0  #.ng..z.
        .byte   $D6,$1D,$E7,$8F,$E7,$1F,$C0,$15 ; AE00 D6 1D E7 8F E7 1F C0 15  ........
        .byte   $60,$09,$23,$51,$24,$1D,$24,$0E ; AE08 60 09 23 51 24 1D 24 0E  `.#Q$.$.
        .byte   $49,$1F,$E1,$F6,$7C,$C6,$36,$FC ; AE10 49 1F E1 F6 7C C6 36 FC  I...|.6.
        .byte   $3F,$9F,$E6,$3F,$F9,$8D,$BC,$9F ; AE18 3F 9F E6 3F F9 8D BC 9F  ?..?....
        .byte   $81,$F4,$7F,$04,$54,$CF,$28,$0F ; AE20 81 F4 7F 04 54 CF 28 0F  ....T.(.
        .byte   $E6,$BC,$3F,$4F,$99,$7A,$FF,$EF ; AE28 E6 BC 3F 4F 99 7A FF EF  ..?O.z..
        .byte   $F3,$F8,$4C,$7F,$FD,$7A,$FE,$00 ; AE30 F3 F8 4C 7F FD 7A FE 00  ..L..z..
        .byte   $35,$FF,$DC,$02,$36,$0F,$CF,$F3 ; AE38 35 FF DC 02 36 0F CF F3  5...6...
        .byte   $32,$84,$7F,$35,$B0,$FC,$3E,$CB ; AE40 32 84 7F 35 B0 FC 3E CB  2..5..>.
        .byte   $D6,$FF,$3F,$82,$D5,$14,$81,$C8 ; AE48 D6 FF 3F 82 D5 14 81 C8  ..?.....
        .byte   $2C,$83,$90,$FF,$7F,$0C,$5E,$03 ; AE50 2C 83 90 FF 7F 0C 5E 03  ,.....^.
        .byte   $7E,$02,$3C,$07,$E0,$65,$87,$1C ; AE58 7E 02 3C 07 E0 65 87 1C  ~.<..e..
        .byte   $77,$8F,$E3,$9B,$1D,$B1,$DA,$04 ; AE60 77 8F E3 9B 1D B1 DA 04  w.......
        .byte   $79,$16,$F3,$DE,$B8,$D1,$DD,$13 ; AE68 79 16 F3 DE B8 D1 DD 13  y.......
        .byte   $78,$B4,$53,$E5,$5E,$F1,$7D,$1F ; AE70 78 B4 53 E5 5E F1 7D 1F  x.S.^.}.
        .byte   $C7,$36,$3A,$30,$39,$87,$B8,$E6 ; AE78 C7 36 3A 30 39 87 B8 E6  .6:09...
        .byte   $C7,$6E,$3F,$89,$1D,$39,$D5,$BE ; AE80 C7 6E 3F 89 1D 39 D5 BE  .n?..9..
        .byte   $32,$F1,$25,$E2,$DF,$44,$9A,$8F ; AE88 32 F1 25 E2 DF 44 9A 8F  2.%..D..
        .byte   $11,$C0,$0E,$20,$E3,$1E,$11,$F2 ; AE90 11 C0 0E 20 E3 1E 11 F2  ... ....
        .byte   $3C,$03,$C5,$6A,$A1,$0A,$16,$1A ; AE98 3C 03 C5 6A A1 0A 16 1A  <..j....
        .byte   $89,$8A,$12,$3C,$52,$C5,$47,$D1 ; AEA0 89 8A 12 3C 52 C5 47 D1  ...<R.G.
        .byte   $E4,$1C,$E3,$92,$3C,$A3,$D0,$74 ; AEA8 E4 1C E3 92 3C A3 D0 74  ....<..t
        .byte   $8F,$0B,$9F,$49,$E9,$9D,$53,$DE ; AEB0 8F 0B 9F 49 E9 9D 53 DE  ...I..S.
        .byte   $7B,$07,$8A,$70,$36,$3F,$47,$B1 ; AEB8 7B 07 8A 70 36 3F 47 B1  {..p6?G.
        .byte   $DC,$74,$1D,$73,$55,$D2,$7E,$45 ; AEC0 DC 74 1D 73 55 D2 7E 45  .t.sU.~E
        .byte   $C8,$D9,$09,$8C,$1E,$06,$C7,$58 ; AEC8 C8 D9 09 8C 1E 06 C7 58  .......X
        .byte   $E8,$3B,$8F,$63,$F6,$62,$D8,$C3 ; AED0 E8 3B 8F 63 F6 62 D8 C3  .;.c.b..
        .byte   $90,$39,$17,$27,$F0,$53,$1A,$11 ; AED8 90 39 17 27 F0 53 1A 11  .9.'.S..
        .byte   $42,$3F,$87,$D1,$FC,$00,$C0,$06 ; AEE0 42 3F 87 D1 FC 00 C0 06  B?......
        .byte   $BB,$59,$A4,$13,$54,$12,$3F,$A7 ; AEE8 BB 59 A4 13 54 12 3F A7  .Y..T.?.
        .byte   $D0,$7F,$30,$08,$A8,$09,$07,$60 ; AEF0 D0 7F 30 08 A8 09 07 60  ..0....`
        .byte   $90,$04,$88,$FE,$1F,$03,$F8,$A8 ; AEF8 90 04 88 FE 1F 03 F8 A8  ........
        .byte   $0D,$40,$7F,$5D,$C2,$6A,$80,$8F ; AF00 0D 40 7F 5D C2 6A 80 8F  .@.].j..
        .byte   $01,$07,$F4,$FA,$0F,$EA,$82,$52 ; AF08 01 07 F4 FA 0F EA 82 52  .......R
        .byte   $09,$8F,$F3,$FC,$F9,$FF,$3F,$AB ; AF10 09 8F F3 FC F9 FF 3F AB  ......?.
        .byte   $E9,$FC,$F9,$F8,$78,$45,$E0,$37 ; AF18 E9 FC F9 F8 78 45 E0 37  ....xE.7
        .byte   $95,$F4,$F7,$F9,$94,$02,$DF,$9A ; AF20 95 F4 F7 F9 94 02 DF 9A  ........
        .byte   $B8,$FD,$FF,$E7,$1D,$47,$FE,$60 ; AF28 B8 FD FF E7 1D 47 FE 60  .....G.`
        .byte   $7D,$CC,$26,$B7,$FE,$0C,$4B,$1C ; AF30 7D CC 26 B7 FE 0C 4B 1C  }.&...K.
        .byte   $A3,$F8,$E8,$E3,$E4,$7E,$2D,$6C ; AF38 A3 F8 E8 E3 E4 7E 2D 6C  .....~-l
        .byte   $45,$21,$05,$0A,$92,$C9,$FC,$6F ; AF40 45 21 05 0A 92 C9 FC 6F  E!.....o
        .byte   $8D,$FE,$0D,$72,$4E,$13,$E1,$07 ; AF48 8D FE 0D 72 4E 13 E1 07  ...rN...
        .byte   $08,$0D,$08,$26,$10,$64,$20,$FC ; AF50 08 0D 08 26 10 64 20 FC  ...&.d .
        .byte   $69,$C6,$82,$AA,$0D,$C4,$11,$A0 ; AF58 69 C6 82 AA 0D C4 11 A0  i.......
        .byte   $F1,$01,$C5,$06,$2A,$1F,$C1,$F2 ; AF60 F1 01 C5 06 2A 1F C1 F2  ....*...
        .byte   $EE,$EE,$DE,$EB,$EE,$7D,$9F,$8F ; AF68 EE EE DE EB EE 7D 9F 8F  .....}..
        .byte   $F8,$3E,$44,$64,$18,$C8,$E3,$07 ; AF70 F8 3E 44 64 18 C8 E3 07  .>Dd....
        .byte   $88,$3E,$01,$F9,$1F,$E2,$A1,$FE ; AF78 88 3E 01 F9 1F E2 A1 FE  .>......
        .byte   $98,$2B,$40,$10,$37,$8F,$FC,$00 ; AF80 98 2B 40 10 37 8F FC 00  .+@.7...
        .byte   $55,$8E,$47,$97,$07,$E0,$7F,$03 ; AF88 55 8E 47 97 07 E0 7F 03  U.G.....
        .byte   $70,$33,$81,$94,$0C,$8C,$7F,$3F ; AF90 70 33 81 94 0C 8C 7F 3F  p3.....?
        .byte   $85,$FA,$38,$CF,$99,$C4,$D8,$19 ; AF98 85 FA 38 CF 99 C4 D8 19  ..8.....
        .byte   $E0,$66,$C0,$CF,$03,$35,$A4,$C6 ; AFA0 E0 66 C0 CF 03 35 A4 C6  .f...5..
        .byte   $66,$27,$36,$66,$69,$39,$A0,$65 ; AFA8 66 27 36 66 69 39 A0 65  f'6fi9.e
        .byte   $C0,$CC,$06,$7F,$7C,$D2,$73,$4C ; AFB0 C0 CC 06 7F 7C D2 73 4C  ....|.sL
        .byte   $CC,$C6,$63,$33,$13,$98,$95,$1B ; AFB8 CC C6 63 33 13 98 95 1B  ..c3....
        .byte   $01,$1A,$02,$24,$04,$70,$17,$80 ; AFC0 01 1A 02 24 04 70 17 80  ...$.p..
        .byte   $FC,$7F,$97,$11,$C8,$8D,$44,$7C ; AFC8 FC 7F 97 11 C8 8D 44 7C  ......D|
        .byte   $43,$E4,$5F,$91,$FD,$D2,$F4,$FC ; AFD0 43 E4 5F 91 FD D2 F4 FC  C._.....
        .byte   $84,$DD,$B9,$6D,$E5,$76,$92,$F8 ; AFD8 84 DD B9 6D E5 76 92 F8  ...m.v..
        .byte   $AB,$1B,$65,$DF,$1F,$C9,$F9,$CF ; AFE0 AB 1B 65 DF 1F C9 F9 CF  ..e.....
        .byte   $2C,$1D,$B4,$18,$D0,$62,$04,$10 ; AFE8 2C 1D B4 18 D0 62 04 10  ,....b..
        .byte   $F2,$1B,$E1,$8E,$37,$62,$CC,$A5 ; AFF0 F2 1B E1 8E 37 62 CC A5  ....7b..
        .byte   $22,$6E,$B5,$DE,$B4,$83,$F8,$9E ; AFF8 22 6E B5 DE B4 83 F8 9E  "n......
bank2_page_b000:  .byte   $31,$3D,$04,$39,$03,$30,$88,$79 ; B000 31 3D 04 39 03 30 88 79  1=.9.0.y
        .byte   $14,$09,$B0,$8C,$D6,$3A,$E3,$FA ; B008 14 09 B0 8C D6 3A E3 FA  .....:..
        .byte   $A5,$B7,$1F,$83,$CC,$71,$A3,$12 ; B010 A5 B7 1F 83 CC 71 A3 12  .....q..
        .byte   $8C,$4C,$44,$04,$04,$E4,$4F,$9E ; B018 8C 4C 44 04 04 E4 4F 9E  .LD...O.
        .byte   $60,$72,$E9,$97,$AD,$21,$61,$6F ; B020 60 72 E9 97 AD 21 61 6F  `r...!ao
        .byte   $16,$E8,$EE,$A5,$F3,$4A,$7B,$28 ; B028 16 E8 EE A5 F3 4A 7B 28  .....J{(
        .byte   $38,$08,$A0,$92,$A4,$1C,$06,$6C ; B030 38 08 A0 92 A4 1C 06 6C  8......l
        .byte   $49,$B8,$CB,$C7,$FA,$DD,$93,$2D ; B038 49 B8 CB C7 FA DD 93 2D  I......-
        .byte   $76,$89,$12,$C9,$D8,$C9,$DF,$E8 ; B040 76 89 12 C9 D8 C9 DF E8  v.......
        .byte   $BD,$C7,$F0,$FF,$0C,$F0,$C7,$86 ; B048 BD C7 F0 FF 0C F0 C7 86  ........
        .byte   $23,$0C,$40,$C0,$71,$FC,$18,$03 ; B050 23 0C 40 C0 71 FC 18 03  #.@.q...
        .byte   $F8,$47,$F9,$5B,$B8,$60,$FE,$18 ; B058 F8 47 F9 5B B8 60 FE 18  .G.[.`..
        .byte   $81,$F2,$38,$A4,$AD,$75,$25,$1C ; B060 81 F2 38 A4 AD 75 25 1C  ..8..u%.
        .byte   $0F,$8D,$5E,$0F,$E0,$FD,$0F,$43 ; B068 0F 8D 5E 0F E0 FD 0F 43  ..^....C
        .byte   $A8,$09,$42,$0A,$C7,$F1,$05,$7E ; B070 A8 09 42 0A C7 F1 05 7E  ..B....~
        .byte   $00,$12,$9C,$57,$EB,$5F,$8D,$9E ; B078 00 12 9C 57 EB 5F 8D 9E  ...W._..
        .byte   $89,$F2,$C9,$E0,$C7,$FB,$1B,$81 ; B080 89 F2 C9 E0 C7 FB 1B 81  ........
        .byte   $4F,$F8,$FF,$30,$4C,$68,$2E,$34 ; B088 4F F8 FF 30 4C 68 2E 34  O..0Lh.4
        .byte   $87,$1F,$0D,$FE,$0F,$FF,$C7,$1A ; B090 87 1F 0D FE 0F FF C7 1A  ........
        .byte   $89,$FD,$9F,$FA,$A2,$C8,$C1,$FE ; B098 89 FD 9F FA A2 C8 C1 FE  ........
        .byte   $3F,$DE,$C4,$1F,$FF,$9B,$20,$53 ; B0A0 3F DE C4 1F FF 9B 20 53  ?..... S
        .byte   $E1,$D9,$F1,$8F,$F4,$00,$CC,$65 ; B0A8 E1 D9 F1 8F F4 00 CC 65  .......e
        .byte   $F1,$A7,$E3,$FD,$9A,$81,$9F,$E3 ; B0B0 F1 A7 E3 FD 9A 81 9F E3  ........
        .byte   $FF,$9F,$19,$3D,$13,$E9,$B3,$D2 ; B0B8 FF 9F 19 3D 13 E9 B3 D2  ...=....
        .byte   $3F,$D8,$EC,$0A,$7F,$C7,$F0,$2B ; B0C0 3F D8 EC 0A 7F C7 F0 2B  ?......+
        .byte   $00,$7E,$2F,$8F,$E3,$07,$71,$F4 ; B0C8 00 7E 2F 8F E3 07 71 F4  .~/...q.
        .byte   $7F,$11,$41,$9B,$E7,$C0,$33,$DC ; B0D0 7F 11 41 9B E7 C0 33 DC  ..A...3.
        .byte   $FC,$09,$C3,$FF,$6B,$FA,$FD,$0D ; B0D8 FC 09 C3 FF 6B FA FD 0D  ....k...
        .byte   $7D,$5D,$0B,$51,$5F,$81,$38,$1F ; B0E0 7D 5D 0B 51 5F 81 38 1F  }].Q_.8.
        .byte   $04,$7F,$72,$36,$27,$03,$E3,$FD ; B0E8 04 7F 72 36 27 03 E3 FD  ..r6'...
        .byte   $4A,$3F,$88,$41,$9C,$1C,$E2,$99 ; B0F0 4A 3F 88 41 9C 1C E2 99  J?.A....
        .byte   $C1,$1F,$E7,$01,$67,$01,$AD,$49 ; B0F8 C1 1F E7 01 67 01 AD 49  ....g..I
        .byte   $88,$A0,$82,$82,$12,$08,$60,$33 ; B100 88 A0 82 82 12 08 60 33  ......`3
        .byte   $81,$EC,$C8,$71,$A8,$62,$28,$01 ; B108 81 EC C8 71 A8 62 28 01  ...q.b(.
        .byte   $58,$FE,$3E,$8E,$E3,$07,$F1,$7C ; B110 58 FE 3E 8E E3 07 F1 7C  X.>....|
        .byte   $3F,$00,$9A,$00,$FC,$9E,$EC,$1F ; B118 3F 00 9A 00 FC 9E EC 1F  ?.......
        .byte   $23,$7D,$C2,$E2,$F8,$C2,$FC,$5F ; B120 23 7D C2 E2 F8 C2 FC 5F  #}....._
        .byte   $D9,$C5,$14,$7F,$07,$D9,$77,$4C ; B128 D9 C5 14 7F 07 D9 77 4C  ......wL
        .byte   $7F,$7C,$53,$C3,$F1,$7E,$5B,$CF ; B130 7F 7C 53 C3 F1 7E 5B CF  .|S..~[.
        .byte   $8F,$F6,$7C,$4F,$F8,$FF,$73,$C6 ; B138 8F F6 7C 4F F8 FF 73 C6  ..|O..s.
        .byte   $7F,$8F,$F0,$F8,$7F,$FE,$07,$8C ; B140 7F 8F F0 F8 7F FE 07 8C  ........
        .byte   $F1,$FF,$FE,$33,$E3,$FC,$E1,$FC ; B148 F1 FF FE 33 E3 FC E1 FC  ...3....
        .byte   $C3,$C0                         ; B150 C3 C0                    ..
beadchr:.byte   $17,$2B,$4B,$07,$E0,$7E,$05,$E0 ; B152 17 2B 4B 07 E0 7E 05 E0  .+K..~..
        .byte   $57,$02,$A2,$A8,$15,$FE,$2F,$FA ; B15A 57 02 A2 A8 15 FE 2F FA  W...../.
        .byte   $66,$C0,$15,$A5,$81,$5E,$05,$40 ; B162 66 C0 15 A5 81 5E 05 40  f....^.@
        .byte   $57,$81,$52,$6A,$82,$0C,$30,$00 ; B16A 57 81 52 6A 82 0C 30 00  W.Rj..0.
        .byte   $80,$6F,$1D,$05,$D8,$D5,$05,$5E ; B172 80 6F 1D 05 D8 D5 05 5E  .o.....^
        .byte   $14,$AA,$0E,$63,$00,$99,$BF,$E5 ; B17A 14 AA 0E 63 00 99 BF E5  ...c....
        .byte   $7F,$84,$E5,$9A,$7F,$0B,$F6,$38 ; B182 7F 84 E5 9A 7F 0B F6 38  .......8
        .byte   $6D,$F5,$A8,$D6,$B0,$AD,$B8,$60 ; B18A 6D F5 A8 D6 B0 AD B8 60  m......`
        .byte   $C0,$00,$46,$00,$FC,$27,$38,$2D ; B192 C0 00 46 00 FC 27 38 2D  ..F..'8-
        .byte   $71,$6D,$02,$D9,$28,$C9,$26,$8C ; B19A 71 6D 02 D9 28 C9 26 8C  qm..(.&.
        .byte   $57,$C5,$46,$2B,$48,$A8,$C5,$7C ; B1A2 57 C5 46 2B 48 A8 C5 7C  W.F+H..|
        .byte   $54,$62,$B4,$8B,$42,$45,$A6,$28 ; B1AA 54 62 B4 8B 42 45 A6 28  Tb..BE.(
        .byte   $48,$BD,$05,$09,$16,$98,$A1,$22 ; B1B2 48 BD 05 09 16 98 A1 22  H......"
        .byte   $F4,$19,$58,$85,$65,$2B,$10,$AD ; B1BA F4 19 58 85 65 2B 10 AD  ..X.e+..
        .byte   $25,$62,$15,$94,$AC,$42,$B4,$C3 ; B1C2 25 62 15 94 AC 42 B4 C3  %b...B..
        .byte   $FF,$F3,$05,$5F,$F7,$FE,$3F,$ED ; B1CA FF F3 05 5F F7 FE 3F ED  ..._..?.
        .byte   $98,$01,$13,$00,$06,$CC,$7F,$4F ; B1D2 98 01 13 00 06 CC 7F 4F  .......O
        .byte   $FC,$7F,$5A,$93,$18,$43,$C6,$02 ; B1DA FC 7F 5A 93 18 43 C6 02  ..Z..C..
        .byte   $1A,$A7,$AA,$8F,$FE,$E7,$DC,$C2 ; B1E2 1A A7 AA 8F FE E7 DC C2  ........
        .byte   $E6,$05,$EA,$BF,$DC,$C0,$FE,$59 ; B1EA E6 05 EA BF DC C0 FE 59  .......Y
        .byte   $C4,$78,$87,$82,$3D,$A2,$D2,$95 ; B1F2 C4 78 87 82 3D A2 D2 95  .x..=...
        .byte   $A0,$16,$B0,$F1,$0B,$90,$AE,$60 ; B1FA A0 16 B0 F1 0B 90 AE 60  .......`
        .byte   $A4,$05,$35,$29,$A3,$72,$45,$CD ; B202 A4 05 35 29 A3 72 45 CD  ..5).rE.
        .byte   $5C,$C0,$B8,$83,$C6,$37,$89,$2D ; B20A 5C C0 B8 83 C6 37 89 2D  \....7.-
        .byte   $56,$B4,$02,$4A,$2B,$B9,$55,$49 ; B212 56 B4 02 4A 2B B9 55 49  V..J+.UI
        .byte   $58,$31,$C0,$1F,$CD,$83,$FC,$8A ; B21A 58 31 C0 1F CD 83 FC 8A  X1......
        .byte   $59,$72,$F3,$F8,$00             ; B222 59 72 F3 F8 00           Yr...
boxchr: .byte   $09,$04,$59,$FE,$4C,$A3,$FC,$40 ; B227 09 04 59 FE 4C A3 FC 40  ..Y.L..@
        .byte   $00,$AD,$8A,$0F,$24,$2B,$FF,$E7 ; B22F 00 AD 8A 0F 24 2B FF E7  ....$+..
        .byte   $F9,$FC,$9B,$C7,$31,$E1,$26,$A0 ; B237 F9 FC 9B C7 31 E1 26 A0  ....1.&.
        .byte   $57,$ED,$FF,$15,$E0,$22,$FF,$E2 ; B23F 57 ED FF 15 E0 22 FF E2  W...."..
        .byte   $27,$F9,$32,$8F,$E0,$05,$2B,$60 ; B247 27 F9 32 8F E0 05 2B 60  '.2...+`
        .byte   $D4,$17,$92,$BF,$6F,$F8         ; B24F D4 17 92 BF 6F F8        ....o.
archchr:.byte   $5A,$5C,$36,$CE,$05,$16,$8A,$7B ; B255 5A 5C 36 CE 05 16 8A 7B  Z\6....{
        .byte   $C1,$41,$C5,$2C,$4C,$B1,$30,$FB ; B25D C1 41 C5 2C 4C B1 30 FB  .A.,L.0.
        .byte   $13,$16,$27,$C8,$07,$B0,$02,$9B ; B265 13 16 27 C8 07 B0 02 9B  ..'.....
        .byte   $01,$EC,$00,$A4,$7F,$30,$D1,$E1 ; B26D 01 EC 00 A4 7F 30 D1 E1  .....0..
        .byte   $94,$E3,$CB,$29,$65,$71,$FD,$24 ; B275 94 E3 CB 29 65 71 FD 24  ...)eq.$
        .byte   $B6,$40,$43,$41,$1F,$1C,$83,$0D ; B27D B6 40 43 41 1F 1C 83 0D  .@CA....
        .byte   $65,$0C,$A7,$D9,$5D,$97,$A1,$88 ; B285 65 0C A7 D9 5D 97 A1 88  e...]...
        .byte   $81,$25,$0C,$8D,$06,$B5,$0A,$BA ; B28D 81 25 0C 8D 06 B5 0A BA  .%......
        .byte   $A8,$FE,$BF,$F5,$15,$71,$57,$95 ; B295 A8 FE BF F5 15 71 57 95  .....qW.
        .byte   $5C,$29,$78,$52,$E0,$09,$70,$11 ; B29D 5C 29 78 52 E0 09 70 11  \)xR..p.
        .byte   $FE,$50,$92,$86,$07,$D8,$12,$51 ; B2A5 FE 50 92 86 07 D8 12 51  .P.....Q
        .byte   $E3,$92,$83,$0D,$65,$03,$CB,$29 ; B2AD E3 92 83 0D 65 03 CB 29  ....e..)
        .byte   $EC,$AE,$CB,$D6,$C5,$76,$AD,$AD ; B2B5 EC AE CB D6 C5 76 AD AD  .....v..
        .byte   $57,$53,$D2,$E0,$BC,$0F,$21,$CC ; B2BD 57 53 D2 E0 BC 0F 21 CC  WS....!.
        .byte   $D7,$29,$E0,$17,$20,$B3,$04,$38 ; B2C5 D7 29 E0 17 20 B3 04 38  .).. ..8
        .byte   $25,$C1,$93,$C1,$1F,$EF,$8D,$F3 ; B2CD 25 C1 93 C1 1F EF 8D F3  %.......
        .byte   $BC,$FB,$9F,$61,$F6,$0F,$8F,$E9 ; B2D5 BC FB 9F 61 F6 0F 8F E9  ...a....
        .byte   $31,$78,$FC,$3E,$C7,$B1,$DE,$3F ; B2DD 31 78 FC 3E C7 B1 DE 3F  1x.>...?
        .byte   $BF,$E3,$FB,$FD,$7E,$2F,$8D,$CB ; B2E5 BF E3 FB FD 7E 2F 8D CB  ....~/..
        .byte   $B2,$E8,$EE,$37,$22,$E4,$59,$06 ; B2ED B2 E8 EE 37 22 E4 59 06  ...7".Y.
        .byte   $50,$96,$F2,$AA,$EA,$76,$9B,$8D ; B2F5 50 96 F2 AA EA 76 9B 8D  P....v..
        .byte   $E2,$F4,$3D,$BF,$77,$DE,$15,$06 ; B2FD E2 F4 3D BF 77 DE 15 06  ..=.w...
        .byte   $1A,$17,$EA,$37,$CE,$F3,$50,$7F ; B305 1A 17 EA 37 CE F3 50 7F  ...7..P.
        .byte   $07,$E7,$CB,$BB,$E5,$BD,$6E,$54 ; B30D 07 E7 CB BB E5 BD 6E 54  ......nT
        .byte   $E3,$43,$59,$65,$66,$82,$4C,$B0 ; B315 E3 43 59 65 66 82 4C B0  .CYef.L.
        .byte   $92,$01,$20,$06,$57,$21,$51,$3D ; B31D 92 01 20 06 57 21 51 3D  .. .W!Q=
        .byte   $13,$A8,$9A,$89,$94,$49,$D1,$0D ; B325 13 A8 9A 89 94 49 D1 0D  .....I..
        .byte   $42,$68,$C0,$14,$46,$B4,$6A,$16 ; B32D 42 68 C0 14 46 B4 6A 16  Bh..F.j.
        .byte   $D4,$35,$45,$56,$15,$2B,$73,$4D ; B335 D4 35 45 56 15 2B 73 4D  .5EV.+sM
        .byte   $08,$94,$25,$28,$41,$32,$1A,$48 ; B33D 08 94 25 28 41 32 1A 48  ..%(A2.H
        .byte   $74,$81,$E7,$9D,$78,$D7,$C5,$7D ; B345 74 81 E7 9D 78 D7 C5 7D  t...x..}
        .byte   $77,$FA,$3F,$A9,$61,$88,$4A,$14 ; B34D 77 FA 3F A9 61 88 4A 14  w.?.a.J.
        .byte   $41,$58,$28,$B1,$28,$71,$01,$E2 ; B355 41 58 28 B1 28 71 01 E2  AX(.(q..
        .byte   $57,$81,$B8,$39,$78,$1B,$31,$09 ; B35D 57 81 B8 39 78 1B 31 09  W..9x.1.
        .byte   $88,$29,$D0,$42,$50,$45,$1C,$98 ; B365 88 29 D0 42 50 45 1C 98  .).BPE..
        .byte   $1F,$DD,$52,$69,$BC,$7F,$72,$E8 ; B36D 1F DD 52 69 BC 7F 72 E8  ..Ri..r.
        .byte   $25,$C4,$91,$8C,$84,$72,$0D,$E4 ; B375 25 C4 91 8C 84 72 0D E4  %....r..
        .byte   $46,$66,$30,$F1,$DE,$3D,$DB,$DD ; B37D 46 66 30 F1 DE 3D DB DD  Ff0..=..
        .byte   $1E,$D4,$ED,$4F,$6E,$F0,$32,$72 ; B385 1E D4 ED 4F 6E F0 32 72  ...On.2r
        .byte   $B3,$8B,$9C,$3C,$C5,$E4,$6F,$0E ; B38D B3 8B 9C 3C C5 E4 6F 0E  ...<..o.
        .byte   $FA,$CE,$96,$76,$13,$B8,$4C,$01 ; B395 FA CE 96 76 13 B8 4C 01  ...v..L.
        .byte   $30,$42,$44,$81,$6C,$0A,$3F,$E3 ; B39D 30 42 44 81 6C 0A 3F E3  0BD.l.?.
        .byte   $E4,$73,$89,$F7,$FD,$FD,$C7,$C8 ; B3A5 E4 73 89 F7 FD FD C7 C8  .s......
        .byte   $FF,$77,$EF,$BD,$FD,$BF,$E2,$7C ; B3AD FF 77 EF BD FD BF E2 7C  .w.....|
        .byte   $C8,$D3,$E9,$75,$60,$10,$60,$B0 ; B3B5 C8 D3 E9 75 60 10 60 B0  ...u`.`.
        .byte   $F8,$FE,$72,$CB,$31,$7A,$00,$B4 ; B3BD F8 FE 72 CB 31 7A 00 B4  ..r.1z..
        .byte   $06,$A8,$0E,$A0,$3E,$E0,$F1,$FD ; B3C5 06 A8 0E A0 3E E0 F1 FD  ....>...
        .byte   $51,$4C,$3B,$D1,$7D,$1B,$D4,$BF ; B3CD 51 4C 3B D1 7D 1B D4 BF  QL;.}...
        .byte   $5B,$C5,$B9,$57,$9D,$5C,$FA,$9B ; B3D5 5B C5 B9 57 9D 5C FA 9B  [..W.\..
        .byte   $59,$70,$CB,$8A,$5F,$57,$35,$67 ; B3DD 59 70 CB 8A 5F 57 35 67  Yp.._W5g
        .byte   $FE,$3B,$A3,$CE,$3D,$C7,$D8,$F8 ; B3E5 FE 3B A3 CE 3D C7 D8 F8  .;..=...
        .byte   $8F,$D0,$7E,$8F,$9A,$D1,$6C,$70 ; B3ED 8F D0 7E 8F 9A D1 6C 70  ..~...lp
        .byte   $BF,$D8,$9F,$FE,$3F,$8E,$16,$3F ; B3F5 BF D8 9F FE 3F 8E 16 3F  ....?..?
        .byte   $8E,$14,$7F,$D8,$9F,$8F,$EC,$4F ; B3FD 8E 14 7F D8 9F 8F EC 4F  .......O
        .byte   $8F,$E4,$8A,$20,$55,$0D,$31,$63 ; B405 8F E4 8A 20 55 0D 31 63  ... U.1c
        .byte   $1A,$31,$FD,$7D,$64,$8A,$98,$A9 ; B40D 1A 31 FD 7D 64 8A 98 A9  .1.}d...
        .byte   $CA,$A6,$52,$72,$93,$38,$FF,$1D ; B415 CA A6 52 72 93 38 FF 1D  ..Rr.8..
        .byte   $20,$7F,$1D,$23,$F6,$07,$8F,$EC ; B41D 20 7F 1D 23 F6 07 8F EC   ..#....
        .byte   $0F,$F9,$80,$F3,$98,$7D,$F5,$EB ; B425 0F F9 80 F3 98 7D F5 EB  .....}..
        .byte   $9A,$14,$A9,$83,$DC,$7D,$8F,$D1 ; B42D 9A 14 A9 83 DC 7D 8F D1  .....}..
        .byte   $FF,$E8,$4A,$28,$85,$60,$A5,$89 ; B435 FF E8 4A 28 85 60 A5 89  ..J(.`..
        .byte   $43,$88,$0F,$11,$78,$1B,$88,$EE ; B43D 43 88 0F 11 78 1B 88 EE  C...x...
        .byte   $8F,$78,$FB,$1F,$B1,$FC,$C0,$7C ; B445 8F 78 FB 1F B1 FC C0 7C  .x.....|
        .byte   $E6,$1E,$6D,$E8,$EF,$1F,$63,$F4 ; B44D E6 1E 6D E8 EF 1F 63 F4  ..m...c.
        .byte   $7F,$FA,$F2,$5C,$15,$86,$50,$E4 ; B455 7F FA F2 5C 15 86 50 E4  ...\..P.
        .byte   $1E,$08,$73,$C3,$0F,$F3,$91,$1C ; B45D 1E 08 73 C3 0F F3 91 1C  ..s.....
        .byte   $D3,$9D,$02,$72,$03,$95,$70,$FF ; B465 D3 9D 02 72 03 95 70 FF  ...r..p.
        .byte   $39,$11,$9D,$27,$C1,$F9,$1F,$29 ; B46D 39 11 9D 27 C1 F9 1F 29  9..'...)
        .byte   $E5,$9C,$3F,$DE,$02,$7A,$67,$8E ; B475 E5 9C 3F DE 02 7A 67 8E  ..?..zg.
        .byte   $08,$F3,$1F,$00,$3C,$71,$C3,$FF ; B47D 08 F3 1F 00 3C 71 C3 FF  ....<q..
        .byte   $F1,$F0,$1F,$FC,$77,$01,$39,$01 ; B485 F1 F0 1F FC 77 01 39 01  ....w.9.
        .byte   $CA,$B8,$7F,$8E,$88,$6E,$8D,$E1 ; B48D CA B8 7F 8E 88 6E 8D E1  .....n..
        .byte   $7D,$1B,$C0,$CE,$1F,$FD,$5F,$41 ; B495 7D 1B C0 CE 1F FD 5F 41  }....._A
        .byte   $D0,$87,$3C,$30,$FE,$18,$7E,$81 ; B49D D0 87 3C 30 FE 18 7E 81  ..<0..~.
        .byte   $4E,$FB,$CF,$C1,$05,$B0,$6C,$20 ; B4A5 4E FB CF C1 05 B0 6C 20  N.....l 
        .byte   $B3,$82,$8F,$F1,$A6,$8D,$30,$25 ; B4AD B3 82 8F F1 A6 8D 30 25  ......0%
        .byte   $46,$25,$4C,$4A,$8C,$4A,$89,$9D ; B4B5 46 25 4C 4A 8C 4A 89 9D  F%LJ.J..
        .byte   $FF,$1A,$D0,$35,$24,$00,$92,$2C ; B4BD FF 1A D0 35 24 00 92 2C  ...5$..,
        .byte   $9A,$A1,$35,$22,$6E,$3F,$D2,$FA ; B4C5 9A A1 35 22 6E 3F D2 FA  ..5"n?..
        .byte   $AF,$10,$79,$07,$D0,$5F,$56,$EF ; B4CD AF 10 79 07 D0 5F 56 EF  ..y.._V.
        .byte   $49,$F4,$09,$E0,$E7,$6D,$81,$45 ; B4D5 49 F4 09 E0 E7 6D 81 45  I....m.E
        .byte   $8B,$54,$4B,$73,$58,$21,$17,$1F ; B4DD 8B 54 4B 73 58 21 17 1F  .TKsX!..
        .byte   $A3,$D4,$1C,$B2,$3B,$A3,$B4,$1D ; B4E5 A3 D4 1C B2 3B A3 B4 1D  ....;...
        .byte   $86,$39,$61,$FF,$D6,$D6,$23,$D4 ; B4ED 86 39 61 FF D6 D6 23 D4  .9a...#.
        .byte   $35,$15,$44,$42,$52,$80,$50,$95 ; B4F5 35 15 44 42 52 80 50 95  5.DBR.P.
        .byte   $B0,$82,$E2,$A2,$A8,$B6,$D4,$31 ; B4FD B0 82 E2 A2 A8 B6 D4 31  .......1
        .byte   $AD,$03,$52,$C2,$A9,$C1,$54,$D0 ; B505 AD 03 52 C2 A9 C1 54 D0  ..R...T.
        .byte   $15,$2A,$35,$2A,$82,$BE,$2D,$84 ; B50D 15 2A 35 2A 82 BE 2D 84  .*5*..-.
        .byte   $35,$68,$2D,$5B,$35,$5A,$01,$5D ; B515 35 68 2D 5B 35 5A 01 5D  5h-[5Z.]
        .byte   $6A,$90,$AD,$4D,$35,$CD,$BF,$E3 ; B51D 6A 90 AD 4D 35 CD BF E3  j..M5...
        .byte   $FA,$7F,$0B,$FB,$BF,$86,$EA,$DD ; B525 FA 7F 0B FB BF 86 EA DD  ........
        .byte   $58,$01,$5A,$61,$6A,$04,$2A,$B4 ; B52D 58 01 5A 61 6A 04 2A B4  X.Zaj.*.
        .byte   $05,$6D,$17,$47,$25,$6D,$FF,$FD ; B535 05 6D 17 47 25 6D FF FD  .m.G%m..
        .byte   $85,$49,$42,$A9,$2C,$6A,$5E,$15 ; B53D 85 49 42 A9 2C 6A 5E 15  .IB.,j^.
        .byte   $4B,$E3,$5F,$8D,$56,$35,$25,$01 ; B545 4B E3 5F 8D 56 35 25 01  K._.V5%.
        .byte   $50,$51,$FE,$12,$01,$56,$44,$DB ; B54D 50 51 FE 12 01 56 44 DB  PQ...VD.
        .byte   $76,$C1,$12,$E3,$AE,$08,$97,$6E ; B555 76 C1 12 E3 AE 08 97 6E  v......n
        .byte   $BB,$22,$5E,$C8,$BC,$10,$1F,$81 ; B55D BB 22 5E C8 BC 10 1F 81  ."^.....
        .byte   $BD,$06,$5C,$E5,$58,$FE,$6D,$C8 ; B565 BD 06 5C E5 58 FE 6D C8  ..\.X.m.
        .byte   $FD,$5D,$2B,$1D,$46,$A1,$B4,$2A ; B56D FD 5D 2B 1D 46 A1 B4 2A  .]+.F..*
        .byte   $05,$48,$2D,$A5,$0A,$E2,$E3,$63 ; B575 05 48 2D A5 0A E2 E3 63  .H-....c
        .byte   $2A,$AE,$D4,$44,$14,$60,$80,$24 ; B57D 2A AE D4 44 14 60 80 24  *..D.`.$
        .byte   $00,$22,$58,$66,$C3,$1D,$86,$9C ; B585 00 22 58 66 C3 1D 86 9C  ."Xf....
        .byte   $36,$43,$40,$1A,$50,$D0,$06,$CC ; B58D 36 43 40 1A 50 D0 06 CC  6C@.P...
        .byte   $E9,$4D,$91,$09,$02,$94,$84,$8D ; B595 E9 4D 91 09 02 94 84 8D  .M......
        .byte   $92,$C3,$43,$24,$33,$C3,$20,$30 ; B59D 92 C3 43 24 33 C3 20 30  ..C$3. 0
        .byte   $86,$78,$68,$51,$FC,$90,$76,$B6 ; B5A5 86 78 68 51 FC 90 76 B6  .xhQ..v.
        .byte   $43,$C8,$E9,$2E,$90,$F2,$5E,$4B ; B5AD 43 C8 E9 2E 90 F2 5E 4B  C.....^K
        .byte   $E0,$7F,$F1,$F9,$1F,$31,$F4,$6A ; B5B5 E0 7F F1 F9 1F 31 F4 6A  .....1.j
        .byte   $0F,$E4,$F2,$B9,$6C,$BA,$5E,$3F ; B5BD 0F E4 F2 B9 6C BA 5E 3F  ....l.^?
        .byte   $83,$CB,$24,$E9,$E9,$9E,$84,$FA ; B5C5 83 CB 24 E9 E9 9E 84 FA  ..$.....
        .byte   $14,$F4,$2A,$6E,$A6,$C7,$FB,$1F ; B5CD 14 F4 2A 6E A6 C7 FB 1F  ..*n....
        .byte   $0E,$78,$BC,$E2,$F9,$8B,$F2,$2F ; B5D5 0E 78 BC E2 F9 8B F2 2F  .x...../
        .byte   $F4,$7C,$47,$FB,$2B,$ED,$AF,$6C ; B5DD F4 7C 47 FB 2B ED AF 6C  .|G.+..l
        .byte   $3D,$B2,$76,$CC,$DB,$39,$1F,$83 ; B5E5 3D B2 76 CC DB 39 1F 83  =.v..9..
        .byte   $F8                             ; B5ED F8                       .
rockchr:.byte   $63,$40,$55,$5F,$E7,$FB,$FF,$7C ; B5EE 63 40 55 5F E7 FB FF 7C  c@U_...|
        .byte   $6F,$D5,$FF,$1F,$E6,$0A,$FF,$FF ; B5F6 6F D5 FF 1F E6 0A FF FF  o.......
        .byte   $B7,$C1,$73,$4C,$D9,$0E,$6D,$9B ; B5FE B7 C1 73 4C D9 0E 6D 9B  ..sL..m.
        .byte   $A6,$D9,$AE,$42,$A9,$2A,$93,$AE ; B606 A6 D9 AE 42 A9 2A 93 AE  ...B.*..
        .byte   $1A,$C8,$1B,$35,$6E,$30,$1E,$02 ; B60E 1A C8 1B 35 6E 30 1E 02  ...5n0..
        .byte   $70,$8E,$36,$46,$70,$67,$83,$50 ; B616 70 8E 36 46 70 67 83 50  p.6Fpg.P
        .byte   $1A,$08,$D9,$8D,$31,$EC,$B2,$89 ; B61E 1A 08 D9 8D 31 EC B2 89  ....1...
        .byte   $CB,$0C,$D8,$4B,$51,$9E,$30,$66 ; B626 CB 0C D8 4B 51 9E 30 66  ...KQ.0f
        .byte   $84,$C8,$92,$8A,$33,$9B,$D5,$B8 ; B62E 84 C8 92 8A 33 9B D5 B8  ....3...
        .byte   $2D,$85,$6D,$48,$F2,$1A,$C1,$DA ; B636 2D 85 6D 48 F2 1A C1 DA  -.mH....
        .byte   $CB,$6C,$7D,$81,$2C,$D8,$CB,$AA ; B63E CB 6C 7D 81 2C D8 CB AA  .l}.,...
        .byte   $E9,$58,$AD,$8B,$2B,$AB,$B4,$17 ; B646 E9 58 AD 8B 2B AB B4 17  .X..+...
        .byte   $5A,$EA,$B9,$EE,$07,$C3,$78,$D9 ; B64E 5A EA B9 EE 07 C3 78 D9  Z.....x.
        .byte   $48,$0E,$8A,$40,$E3,$6F,$14,$71 ; B656 48 0E 8A 40 E3 6F 14 71  H..@.o.q
        .byte   $BB,$C5,$EF,$8F,$E3,$74,$26,$81 ; B65E BB C5 EF 8F E3 74 26 81  .....t&.
        .byte   $98,$13,$B2,$0D,$58,$57,$21,$41 ; B666 98 13 B2 0D 58 57 21 41  ....XW!A
        .byte   $95,$06,$50,$18,$80,$9C,$B1,$62 ; B66E 95 06 50 18 80 9C B1 62  ..P....b
        .byte   $CC,$EC,$CC,$67,$4A,$9A,$96,$49 ; B676 CC EC CC 67 4A 9A 96 49  ...gJ..I
        .byte   $0C,$24,$70,$2C,$21,$A1,$10,$90 ; B67E 0C 24 70 2C 21 A1 10 90  .$p,!...
        .byte   $1A,$51,$A6,$16,$10,$78,$03,$31 ; B686 1A 51 A6 16 10 78 03 31  .Q...x.1
        .byte   $B2,$06,$E0,$17,$45,$60,$30,$93 ; B68E B2 06 E0 17 45 60 30 93  ....E`0.
        .byte   $18,$36,$44,$A0,$12,$89,$CC,$B0 ; B696 18 36 44 A0 12 89 CC B0  .6D.....
        .byte   $17,$06,$FC,$BC,$E4,$09,$BA,$C5 ; B69E 17 06 FC BC E4 09 BA C5  ........
        .byte   $19,$0A,$18,$6C,$20,$18,$01,$71 ; B6A6 19 0A 18 6C 20 18 01 71  ...l ..q
        .byte   $6E,$6B,$64,$C1,$0C,$2F,$07,$F1 ; B6AE 6E 6B 64 C1 0C 2F 07 F1  nkd../..
        .byte   $A6,$26,$01,$24,$59,$E7,$1F,$83 ; B6B6 A6 26 01 24 59 E7 1F 83  .&.$Y...
        .byte   $33,$64,$D7,$85,$65,$26,$0A,$3F ; B6BE 33 64 D7 85 65 26 0A 3F  3d..e&.?
        .byte   $63,$FC,$2F,$7E,$DE,$B8,$FF,$8F ; B6C6 63 FC 2F 7E DE B8 FF 8F  c./~....
        .byte   $23,$58,$AE,$11,$BB,$3B,$DE,$CB ; B6CE 23 58 AE 11 BB 3B DE CB  #X...;..
        .byte   $B7,$EF,$7B,$D2,$14,$0D,$4B,$90 ; B6D6 B7 EF 7B D2 14 0D 4B 90  ..{...K.
        .byte   $A3,$F8,$D3,$17,$22,$9C,$27,$B4 ; B6DE A3 F8 D3 17 22 9C 27 B4  ....".'.
        .byte   $9D,$74,$56,$03,$1B,$21,$F0,$33 ; B6E6 9D 74 56 03 1B 21 F0 33  .tV..!.3
        .byte   $04,$F1,$1E,$34,$C4,$C0,$24,$88 ; B6EE 04 F1 1E 34 C4 C0 24 88  ...4..$.
        .byte   $FD,$8F,$E1,$9D,$B2,$6B,$C2,$B2 ; B6F6 FD 8F E1 9D B2 6B C2 B2  .....k..
        .byte   $98,$FF,$1B,$82,$72,$0E,$10,$61 ; B6FE 98 FF 1B 82 72 0E 10 61  ....r..a
        .byte   $B6,$21,$69,$A0,$60,$0E,$DD,$72 ; B706 B6 21 69 A0 60 0E DD 72  .!i.`..r
        .byte   $26,$D3,$51,$B2,$47,$61,$1F,$80 ; B70E 26 D3 51 B2 47 61 1F 80  &.Q.Ga..
        .byte   $D8,$40,$12,$11,$08,$03,$24,$8F ; B716 D8 40 12 11 08 03 24 8F  .@....$.
        .byte   $FE,$33,$20,$B8,$37,$E5,$9F,$E3 ; B71E FE 33 20 B8 37 E5 9F E3  .3 .7...
        .byte   $F8,$33,$B6,$4D,$78,$56,$53,$04 ; B726 F8 33 B6 4D 78 56 53 04  .3.MxVS.
        .byte   $F0,$1C,$80,$0B,$06,$68,$27,$B9 ; B72E F0 1C 80 0B 06 68 27 B9  .....h'.
        .byte   $E3,$9A,$5E,$69,$04,$B0,$4B,$23 ; B736 E3 9A 5E 69 04 B0 4B 23  ..^i..K#
        .byte   $B1,$1E,$E3,$C6,$CE,$38,$F8,$C7 ; B73E B1 1E E3 C6 CE 38 F8 C7  .....8..
        .byte   $E3,$24,$C5,$61,$61,$20,$F3,$00 ; B746 E3 24 C5 61 61 20 F3 00  .$.aa ..
        .byte   $21,$01,$60,$03,$30,$5A,$8A,$3E ; B74E 21 01 60 03 30 5A 8A 3E  !.`.0Z.>
        .byte   $71,$FA,$13,$DF,$45,$E1,$6F,$12 ; B756 71 FA 13 DF 45 E1 6F 12  q...E.o.
        .byte   $05,$C0,$6C,$32,$42,$61,$CF,$39 ; B75E 05 C0 6C 32 42 61 CF 39  ..l2Ba.9
        .byte   $8B,$CC,$2D,$49,$82,$48,$27,$23 ; B766 8B CC 2D 49 82 48 27 23  ..-I.H'#
        .byte   $91,$1E,$51,$F1,$1F,$83,$FE,$A9 ; B76E 91 1E 51 F1 1F 83 FE A9  ..Q.....
        .byte   $05,$4C,$5C,$45,$A1,$6D,$A6,$E6 ; B776 05 4C 5C 45 A1 6D A6 E6  .L\E.m..
        .byte   $03,$C0,$8E,$0D,$45,$1C,$DA,$67 ; B77E 03 C0 8E 0D 45 1C DA 67  ....E..g
        .byte   $19,$E3,$50,$D1,$36,$9D,$EF,$5C ; B786 19 E3 50 D1 36 9D EF 5C  ..P.6..\
        .byte   $85,$65,$94,$4F,$58,$76,$C3,$B5 ; B78E 85 65 94 4F 58 76 C3 B5  .e.OXv..
        .byte   $1D,$E7,$8F,$F5,$A8,$36,$8A,$E2 ; B796 1D E7 8F F5 A8 36 8A E2  .....6..
        .byte   $28,$B4,$54,$78,$25,$51,$5A,$A0 ; B79E 28 B4 54 78 25 51 5A A0  (.Tx%QZ.
        .byte   $74,$54,$1C,$C7,$98,$F8,$3F,$2F ; B7A6 74 54 1C C7 98 F8 3F 2F  tT....?/
        .byte   $52,$47,$F9,$7F,$E5,$23,$67,$BA ; B7AE 52 47 F9 7F E5 23 67 BA  RG...#g.
        .byte   $C9,$FC,$A4,$DC,$A7,$E5,$FE,$17 ; B7B6 C9 FC A4 DC A7 E5 FE 17  ........
        .byte   $E2,$BE,$52,$6D,$64,$FF,$AF,$EF ; B7BE E2 BE 52 6D 64 FF AF EF  ..Rmd...
        .byte   $FF,$B6,$AF,$AF,$7B,$FF,$BF,$CB ; B7C6 FF B6 AF AF 7B FF BF CB  ....{...
        .byte   $F9,$B1,$78,$D7,$1D,$60,$8B,$03 ; B7CE F9 B1 78 D7 1D 60 8B 03  ..x..`..
        .byte   $0A,$06,$89,$B5,$45,$5D,$4A,$C9 ; B7D6 0A 06 89 B5 45 5D 4A C9  ....E]J.
        .byte   $FF,$29,$3C,$22,$60,$B2,$40,$21 ; B7DE FF 29 3C 22 60 B2 40 21  .)<"`.@!
        .byte   $81,$18,$36,$C0,$6E,$80,$B8,$0A ; B7E6 81 18 36 C0 6E 80 B8 0A  ..6.n...
        .byte   $D0,$37,$F2,$FC,$DF,$3D,$E7,$B9 ; B7EE D0 37 F2 FC DF 3D E7 B9  .7...=..
        .byte   $F6,$7E,$3F,$23,$FC,$7E,$09,$E0 ; B7F6 F6 7E 3F 23 FC 7E 09 E0  .~?#.~..
        .byte   $FE,$32,$62,$34,$04,$58,$3D,$EC ; B7FE FE 32 62 34 04 58 3D EC  .2b4.X=.
        .byte   $95,$A3,$25,$D0,$2D,$60,$58,$80 ; B806 95 A3 25 D0 2D 60 58 80  ..%.-`X.
        .byte   $A8,$A8,$14,$54,$A1,$6C,$15,$79 ; B80E A8 A8 14 54 A1 6C 15 79  ...T.l.y
        .byte   $B6,$A2,$E9,$56,$5F,$A7,$E5,$CB ; B816 B6 A2 E9 56 5F A7 E5 CB  ...V_...
        .byte   $6A,$DB,$0F,$47,$BB,$C8,$54,$90 ; B81E 6A DB 0F 47 BB C8 54 90  j..G..T.
        .byte   $57,$64,$AD,$CA,$DC,$96,$79,$B7 ; B826 57 64 AD CA DC 96 79 B7  Wd....y.
        .byte   $D6,$FE,$C4,$C1,$03,$94,$F2,$CE ; B82E D6 FE C4 C1 03 94 F2 CE  ........
        .byte   $05,$45,$B5,$FA,$5E,$CC,$73,$D7 ; B836 05 45 B5 FA 5E CC 73 D7  .E..^.s.
        .byte   $28,$30,$F4,$67,$44,$8B,$12,$0C ; B83E 28 30 F4 67 44 8B 12 0C  (0.gD...
        .byte   $80,$E4,$05,$92,$AE,$AB,$5C,$22 ; B846 80 E4 05 92 AE AB 5C 22  ......\"
        .byte   $E1,$1A,$48,$F9,$04,$E4,$19,$8D ; B84E E1 1A 48 F9 04 E4 19 8D  ..H.....
        .byte   $4C,$60,$6F,$46,$72,$A6,$A1,$25 ; B856 4C 60 6F 46 72 A6 A1 25  L`oFr..%
        .byte   $09,$5A,$95,$A8,$50,$EA,$2D,$3F ; B85E 09 5A 95 A8 50 EA 2D 3F  .Z..P.-?
        .byte   $0F,$CA,$55,$EF,$46,$94,$6F,$46 ; B866 0F CA 55 EF 46 94 6F 46  ..U.F.oF
        .byte   $42,$32,$00,$C8,$27,$23,$F7,$B9 ; B86E 42 32 00 C8 27 23 F7 B9  B2..'#..
        .byte   $B2,$F8,$5E,$4C,$D5,$BD,$40,$F4 ; B876 B2 F8 5E 4C D5 BD 40 F4  ..^L..@.
        .byte   $27,$61,$BD,$0E,$73,$9F,$22,$E9 ; B87E 27 61 BD 0E 73 9F 22 E9  'a..s.".
        .byte   $1C,$48,$2C,$10,$68,$20,$09,$1A ; B886 1C 48 2C 10 68 20 09 1A  .H,.h ..
        .byte   $24,$B4,$4E,$F2,$28,$91,$79,$17 ; B88E 24 B4 4E F2 28 91 79 17  $.N.(.y.
        .byte   $9E,$F9,$C6,$6A,$3F,$6F,$3D,$92 ; B896 9E F9 C6 6A 3F 6F 3D 92  ...j?o=.
        .byte   $81,$72,$40,$B1,$6A,$C2,$AA,$C2 ; B89E 81 72 40 B1 6A C2 AA C2  .r@.j...
        .byte   $A3,$85,$7C,$2B,$FC,$42,$3F,$FB ; B8A6 A3 85 7C 2B FC 42 3F FB  ..|+.B?.
        .byte   $FA,$A3,$B5,$F7,$6F,$EC,$65,$C7 ; B8AE FA A3 B5 F7 6F EC 65 C7  ....o.e.
        .byte   $E8,$FA,$12,$B7,$A6,$DA,$02,$8C ; B8B6 E8 FA 12 B7 A6 DA 02 8C  ........
        .byte   $05,$E6,$BC,$BD,$CD,$F1,$27,$BD ; B8BE 05 E6 BC BD CD F1 27 BD  ......'.
        .byte   $D5,$83,$01,$34,$05,$2C,$05,$CA ; B8C6 D5 83 01 34 05 2C 05 CA  ...4.,..
        .byte   $D0,$0A,$E9,$2D,$40,$B2,$2F,$10 ; B8CE D0 0A E9 2D 40 B2 2F 10  ...-@./.
        .byte   $5F,$98,$BC,$81,$E4,$87,$96,$00 ; B8D6 5F 98 BC 81 E4 87 96 00  _.......
        .byte   $28,$10,$2C,$85,$6A,$15,$B5,$AA ; B8DE 28 10 2C 85 6A 15 B5 AA  (.,.j...
        .byte   $ED,$1F,$8F,$F2,$7E,$42,$72,$20 ; B8E6 ED 1F 8F F2 7E 42 72 20  ....~Br 
        .byte   $E4,$93,$0A,$83,$1D,$04,$79,$07 ; B8EE E4 93 0A 83 1D 04 79 07  ......y.
        .byte   $A0,$2E,$7A,$53,$C9,$06,$75,$83 ; B8F6 A0 2E 7A 53 C9 06 75 83  ..zS..u.
        .byte   $A8,$56,$28,$1D,$50,$32,$85,$72 ; B8FE A8 56 28 1D 50 32 85 72  .V(.P2.r
        .byte   $3B,$57,$BF,$C8,$6F,$31,$5C,$E2 ; B906 3B 57 BF C8 6F 31 5C E2  ;W..o1\.
        .byte   $66,$C2,$C8,$30,$42,$08,$20,$81 ; B90E 66 C2 C8 30 42 08 20 81  f..0B. .
        .byte   $58,$A2,$72,$2C,$2A,$AB,$52,$15 ; B916 58 A2 72 2C 2A AB 52 15  X.r,*.R.
        .byte   $2A,$A3,$74,$36,$68,$4B,$30,$DF ; B91E 2A A3 74 36 68 4B 30 DF  *.t6hK0.
        .byte   $09,$7E,$16,$B8,$AF,$DD,$2F,$7F ; B926 09 7E 16 B8 AF DD 2F 7F  .~..../.
        .byte   $63,$37,$1F,$F0,$F4,$83,$1C,$48 ; B92E 63 37 1F F0 F4 83 1C 48  c7.....H
        .byte   $A7,$08,$BA,$90,$F5,$91,$7A,$45 ; B936 A7 08 BA 90 F5 91 7A 45  ......zE
        .byte   $F9,$44,$22,$68,$8C,$D3,$55,$AA ; B93E F9 44 22 68 8C D3 55 AA  .D"h..U.
        .byte   $5D,$D5,$D7,$5F,$25,$5D,$0D,$79 ; B946 5D D5 D7 5F 25 5D 0D 79  ].._%].y
        .byte   $EF,$E1,$96,$9D,$D9,$57,$63,$D0 ; B94E EF E1 96 9D D9 57 63 D0  .....Wc.
        .byte   $12,$A0,$4F,$A4,$95,$64,$C6,$6D ; B956 12 A0 4F A4 95 64 C6 6D  ..O..d.m
        .byte   $AD,$A9,$5E,$CD,$D7,$03,$D9,$BA ; B95E AD A9 5E CD D7 03 D9 BA  ..^.....
        .byte   $30,$78,$B6,$A3,$74,$D2,$9A,$62 ; B966 30 78 B6 A3 74 D2 9A 62  0x..t..b
        .byte   $B4,$B3,$18,$B5,$2C,$C1,$16,$8A ; B96E B4 B3 18 B5 2C C1 16 8A  ....,...
        .byte   $CC,$E4,$D9,$21,$89,$46,$30,$2B ; B976 CC E4 D9 21 89 46 30 2B  ...!.F0+
        .byte   $B1,$7B,$7F,$1C,$B1,$9D,$57,$CA ; B97E B1 7B 7F 1C B1 9D 57 CA  .{....W.
        .byte   $04,$79,$AA,$0C,$A9,$34,$AA,$0D ; B986 04 79 AA 0C A9 34 AA 0D  .y...4..
        .byte   $29,$21,$4A,$40,$04,$A9,$24,$A8 ; B98E 29 21 4A 40 04 A9 24 A8  )!J@..$.
        .byte   $92,$77,$F8,$83,$01,$68,$33,$6D ; B996 92 77 F8 83 01 68 33 6D  .w...h3m
        .byte   $9B,$41,$35,$79,$55,$71,$B2,$8D ; B99E 9B 41 35 79 55 71 B2 8D  .A5yUq..
        .byte   $0B,$54,$59,$02,$E5,$44,$13,$D1 ; B9A6 0B 54 59 02 E5 44 13 D1  .TY..D..
        .byte   $5E,$3F,$DE,$2D,$38,$AF,$25,$C7 ; B9AE 5E 3F DE 2D 38 AF 25 C7  ^?.-8.%.
        .byte   $4B,$C3,$52,$9A,$B0,$10,$32,$C8 ; B9B6 4B C3 52 9A B0 10 32 C8  K.R...2.
        .byte   $13,$48,$14,$BD,$45,$29,$02,$95 ; B9BE 13 48 14 BD 45 29 02 95  .H..E)..
        .byte   $45,$2A,$89,$AA,$32,$A8,$DD,$1C ; B9C6 45 2A 89 AA 32 A8 DD 1C  E*..2...
        .byte   $A3,$4D,$5B,$D6,$48,$CA,$94,$B4 ; B9CE A3 4D 5B D6 48 CA 94 B4  .M[.H...
        .byte   $A5,$C4,$6E,$13,$70,$3B,$CF,$7E ; B9D6 A5 C4 6E 13 70 3B CF 7E  ..n.p;.~
        .byte   $6F,$99,$A3,$FC,$5B,$C2,$19,$C5 ; B9DE 6F 99 A3 FC 5B C2 19 C5  o...[...
        .byte   $1B,$14,$BC,$25,$F0,$5F,$C7,$F8 ; B9E6 1B 14 BC 25 F0 5F C7 F8  ...%._..
        .byte   $DB,$B9,$A5,$A7,$2E,$74,$B9,$E9 ; B9EE DB B9 A5 A7 2E 74 B9 E9  .....t..
        .byte   $67,$D1,$A7,$31,$23,$07,$04,$60 ; B9F6 67 D1 A7 31 23 07 04 60  g..1#..`
        .byte   $47,$DB,$4A,$12,$A1,$A5,$B0,$29 ; B9FE 47 DB 4A 12 A1 A5 B0 29  G.J....)
        .byte   $6C,$A4,$79,$31,$A1,$C0,$C0,$00 ; BA06 6C A4 79 31 A1 C0 C0 00  l.y1....
        .byte   $64,$5B,$FA,$28,$42,$94,$B9,$05 ; BA0E 64 5B FA 28 42 94 B9 05  d[.(B...
        .byte   $2C,$14,$E4,$25,$5E,$D6,$85,$32 ; BA16 2C 14 E4 25 5E D6 85 32  ,..%^..2
        .byte   $02,$C9,$8A,$EC,$56,$91,$94,$C6 ; BA1E 02 C9 8A EC 56 91 94 C6  ....V...
        .byte   $47,$1A,$7C,$45,$48,$86,$96,$E9 ; BA26 47 1A 7C 45 48 86 96 E9  G.|EH...
        .byte   $85,$A6,$2A,$38,$C8,$E3,$4F,$8D ; BA2E 85 A6 2A 38 C8 E3 4F 8D  ..*8..O.
        .byte   $08,$8D,$01,$18,$01,$19,$2E,$35 ; BA36 08 8D 01 18 01 19 2E 35  .......5
        .byte   $71,$D9,$1E,$91,$FE,$08,$4E,$00 ; BA3E 71 D9 1E 91 FE 08 4E 00  q.....N.
        .byte   $9C,$00,$1D,$4A,$3B,$A9,$C3,$3C ; BA46 9C 00 1D 4A 3B A9 C3 3C  ...J;..<
        .byte   $27,$C7,$F4,$55,$45,$F9,$6B,$AB ; BA4E 27 C7 F4 55 45 F9 6B AB  '..UE.k.
        .byte   $A5,$0A,$49,$47,$34,$73,$19,$B2 ; BA56 A5 0A 49 47 34 73 19 B2  ..IG4s..
        .byte   $2A,$F1,$74,$AF,$FF,$BB,$D7,$D6 ; BA5E 2A F1 74 AF FF BB D7 D6  *.t.....
        .byte   $FF,$FC                         ; BA66 FF FC                    ..
bedchr: .byte   $42,$31,$58,$3E,$C7,$B8,$EF,$1B ; BA68 42 31 58 3E C7 B8 EF 1B  B1X>....
        .byte   $E2,$FC,$3F,$8F,$F6,$FE,$3F,$0F ; BA70 E2 FC 3F 8F F6 FE 3F 0F  ..?...?.
        .byte   $8B,$C6,$E3,$B1,$E0,$F9,$82,$8F ; BA78 8B C6 E3 B1 E0 F9 82 8F  ........
        .byte   $E3,$F0,$F8,$3C,$8E,$63,$38,$9E ; BA80 E3 F0 F8 3C 8E 63 38 9E  ...<.c8.
        .byte   $0F,$E2,$78,$CE,$39,$8F,$23,$E0 ; BA88 0F E2 78 CE 39 8F 23 E0  ..x.9.#.
        .byte   $FC,$3F,$81,$58,$04,$18,$38,$3C ; BA90 FC 3F 81 58 04 18 38 3C  .?.X..8<
        .byte   $1F,$07,$E1,$FC,$C1,$41,$F6,$3D ; BA98 1F 07 E1 FC C1 41 F6 3D  .....A.=
        .byte   $C7,$78,$DF,$17,$E1,$FC,$7F,$8F ; BAA0 C7 78 DF 17 E1 FC 7F 8F  .x......
        .byte   $E4,$0F,$F2,$BF,$2A,$62,$54,$C0 ; BAA8 E4 0F F2 BF 2A 62 54 C0  ....*bT.
        .byte   $2B,$F2,$FE,$57,$E5,$4F,$9F,$C0 ; BAB0 2B F2 FE 57 E5 4F 9F C0  +..W.O..
        .byte   $F0,$97,$42,$8F,$09,$7C,$87,$84 ; BAB8 F0 97 42 8F 09 7C 87 84  ..B..|..
        .byte   $BA,$14,$A9,$F9,$5F,$97,$F2,$97 ; BAC0 BA 14 A9 F9 5F 97 F2 97  ...._...
        .byte   $C9,$BE,$85,$42,$40,$08,$4B,$A1 ; BAC8 C9 BE 85 42 40 08 4B A1  ...B@.K.
        .byte   $0F,$09,$7C,$87,$52,$8E,$98,$A0 ; BAD0 0F 09 7C 87 52 8E 98 A0  ..|.R...
        .byte   $26,$73,$CF,$9F,$9F,$CF,$F2,$BD ; BAD8 26 73 CF 9F 9F CF F2 BD  &s......
        .byte   $45,$FF,$FF,$39,$E6,$12,$48,$0A ; BAE0 45 FF FF 39 E6 12 48 0A  E..9..H.
        .byte   $40,$45,$50,$76,$D8,$5A,$34,$D2 ; BAE8 40 45 50 76 D8 5A 34 D2  @EPv.Z4.
        .byte   $6E,$16,$7F,$83,$F1,$3C,$89,$CC ; BAF0 6E 16 7F 83 F1 3C 89 CC  n....<..
        .byte   $1E,$73,$40,$A5,$09,$14,$0B,$34 ; BAF8 1E 73 40 A5 09 14 0B 34  .s@....4
        .byte   $0B,$54,$D1,$B7,$D0,$E9,$8B,$04 ; BB00 0B 54 D1 B7 D0 E9 8B 04  .T......
        .byte   $54,$06,$06,$7F,$CF,$E9,$FA,$9F ; BB08 54 06 06 7F CF E9 FA 9F  T.......
        .byte   $5B,$EC,$DA,$58,$C1,$44,$48,$41 ; BB10 5B EC DA 58 C1 44 48 41  [..X.DHA
        .byte   $63,$05,$95,$49,$8F,$F1,$CA,$23 ; BB18 63 05 95 49 8F F1 CA 23  c..I...#
        .byte   $C3,$FA,$FA,$B7,$B3,$EB,$50,$15 ; BB20 C3 FA FA B7 B3 EB 50 15  ......P.
        .byte   $45,$D1,$7C,$29,$E7,$D6,$FF,$9B ; BB28 45 D1 7C 29 E7 D6 FF 9B  E.|)....
        .byte   $7A,$7F,$8F,$E7,$F9,$FC,$3F,$57 ; BB30 7A 7F 8F E7 F9 FC 3F 57  z.....?W
        .byte   $99,$E6,$1D,$B3,$30,$8B,$70,$C3 ; BB38 99 E6 1D B3 30 8B 70 C3  ....0.p.
        .byte   $B8,$7B,$7E,$0F,$E7,$F8,$FF,$53 ; BB40 B8 7B 7E 0F E7 F8 FF 53  .{~....S
        .byte   $1A,$31,$C3,$3D,$DF,$63,$F0,$FE ; BB48 1A 31 C3 3D DF 63 F0 FE  .1.=.c..
        .byte   $3F,$BF,$F5,$FE,$FF,$8F,$EB,$E5 ; BB50 3F BF F5 FE FF 8F EB E5  ?.......
        .byte   $F9,$8F,$67,$99,$5F,$CA,$1F,$C1 ; BB58 F9 8F 67 99 5F CA 1F C1  ..g._...
        .byte   $FF,$81,$F8,$FF,$9F,$C2,$14,$37 ; BB60 FF 81 F8 FF 9F C2 14 37  .......7
        .byte   $AF,$D1,$FE,$08,$20,$F8,$6B,$51 ; BB68 AF D1 FE 08 20 F8 6B 51  .... .kQ
        .byte   $FE,$70,$60,$B4,$AF,$AD,$4C,$1F ; BB70 FE 70 60 B4 AF AD 4C 1F  .p`...L.
        .byte   $F0,$7B,$03,$CB,$C0,$3E,$3F,$ED ; BB78 F0 7B 03 CB C0 3E 3F ED  .{...>?.
        .byte   $3C,$BF,$9E,$3F,$E2,$40,$91,$08 ; BB80 3C BF 9E 3F E2 40 91 08  <..?.@..
        .byte   $9F,$C7,$F3,$69,$68,$CC,$CC,$DF ; BB88 9F C7 F3 69 68 CC CC DF  ...ih...
        .byte   $1F,$F0,$7E,$07,$E0,$78,$0E,$EB ; BB90 1F F0 7E 07 E0 78 0E EB  ..~..x..
        .byte   $93,$41,$FC,$FE,$5F,$B8,$7D,$E0 ; BB98 93 41 FC FE 5F B8 7D E0  .A.._.}.
        .byte   $72,$13,$30,$39,$02,$DC,$0E,$70 ; BBA0 72 13 30 39 02 DC 0E 70  r.09...p
        .byte   $3C,$03,$6C,$0F,$30,$19,$30,$39 ; BBA8 3C 03 6C 0F 30 19 30 39  <.l.0.09
        .byte   $53,$97,$64,$DF,$CD,$4E,$54,$DB ; BBB0 53 97 64 DF CD 4E 54 DB  S.d..NT.
        .byte   $03,$C0,$3D,$03,$F0,$CF,$03,$E8 ; BBB8 03 C0 3D 03 F0 CF 03 E8  ..=.....
        .byte   $FC,$AA,$0F,$D3,$FF,$75,$EF,$FF ; BBC0 FC AA 0F D3 FF 75 EF FF  .....u..
        .byte   $BE,$B7,$FE,$AF,$DF,$FB,$FB,$7F ; BBC8 BE B7 FE AF DF FB FB 7F  ........
        .byte   $EE,$BD,$FF,$F7,$56,$FF,$D5,$F5 ; BBD0 EE BD FF F7 56 FF D5 F5  ....V...
        .byte   $68,$E5,$D8,$FE,$1F,$80,$FF,$03 ; BBD8 68 E5 D8 FE 1F 80 FF 03  h.......
        .byte   $F1,$FF,$3F,$AB,$E3,$BF,$C3,$FC ; BBE0 F1 FF 3F AB E3 BF C3 FC  ..?.....
        .byte   $5F,$10,$FF,$11,$F1,$FE,$6B,$A8 ; BBE8 5F 10 FF 11 F1 FE 6B A8  _.....k.
        .byte   $06,$FB,$87,$0F,$E5,$50,$AF,$EE ; BBF0 06 FB 87 0F E5 50 AF EE  .....P..
        .byte   $AD,$FF,$AB,$EA,$D4,$2F,$EF,$FD ; BBF8 AD FF AB EA D4 2F EF FD  ...../..
        .byte   $D7,$BF,$F5,$C8,$50,$FC,$5F,$1B ; BC00 D7 BF F5 C8 50 FC 5F 1B  ....P._.
        .byte   $63,$AC,$7B,$1F,$5C,$F3,$9A,$47 ; BC08 63 AC 7B 1F 5C F3 9A 47  c.{.\..G
        .byte   $A0,$FF,$14,$F1,$FF,$87,$E2,$B2 ; BC10 A0 FF 14 F1 FF 87 E2 B2  ........
        .byte   $33,$23,$B8,$F6,$E7,$5C,$F0,$FF ; BC18 33 23 B8 F6 E7 5C F0 FF  3#...\..
        .byte   $67,$EE,$7D,$D7,$5D,$B5,$F9,$BF ; BC20 67 EE 7D D7 5D B5 F9 BF  g.}.]...
        .byte   $95,$3C,$53,$64,$7D,$8F,$F1,$4F ; BC28 95 3C 53 64 7D 8F F1 4F  .<Sd}..O
        .byte   $1F,$F6,$7E,$E5,$2F,$12,$F9,$DF ; BC30 1F F6 7E E5 2F 12 F9 DF  ..~./...
        .byte   $9A,$9C,$A9,$E3,$FE,$BB,$FC,$2B ; BC38 9A 9C A9 E3 FE BB FC 2B  .......+
        .byte   $5F,$C0,$04,$11,$FE,$87,$5A,$18 ; BC40 5F C0 04 11 FE 87 5A 18  _.....Z.
        .byte   $11,$E8,$44,$48,$FF,$3A,$F2,$23 ; BC48 11 E8 44 48 FF 3A F2 23  ..DH.:.#
        .byte   $1F,$58,$1C,$7F,$9A,$C0,$A4,$4C ; BC50 1F 58 1C 7F 9A C0 A4 4C  .X.....L
        .byte   $1E,$E2,$60,$1F,$ED,$02,$11,$C3 ; BC58 1E E2 60 1F ED 02 11 C3  ..`.....
        .byte   $09,$F1,$FE,$56,$A1,$62,$40,$FE ; BC60 09 F1 FE 56 A1 62 40 FE  ...V.b@.
        .byte   $3F,$84,$41,$7F,$FC,$57,$FF,$5D ; BC68 3F 84 41 7F FC 57 FF 5D  ?.A..W.]
        .byte   $96,$F5,$7C,$20,$2F,$CB,$E5,$E5 ; BC70 96 F5 7C 20 2F CB E5 E5  ..| /...
        .byte   $21,$45,$F0,$44,$09,$F3,$FF,$E7 ; BC78 21 45 F0 44 09 F3 FF E7  !E.D....
        .byte   $6C,$B6,$33,$CF,$FF,$3B,$40,$82 ; BC80 6C B6 33 CF FF 3B 40 82  l.3..;@.
        .byte   $91,$C7,$C7,$E2,$40             ; BC88 91 C7 C7 E2 40           ....@
doorchr:.byte   $49,$04,$58,$EE,$38,$FF,$F8,$E4 ; BC8D 49 04 58 EE 38 FF F8 E4  I.X.8...
        .byte   $7F,$35,$05,$F3,$EF,$F0,$02,$30 ; BC95 7F 35 05 F3 EF F0 02 30  .5.....0
        .byte   $FC,$1F,$85,$02,$BF,$7E,$04,$B0 ; BC9D FC 1F 85 02 BF 7E 04 B0  .....~..
        .byte   $3E,$11,$FC,$28,$2F,$DF,$61,$72 ; BCA5 3E 11 FC 28 2F DF 61 72  >..(/.ar
        .byte   $C6,$1F,$4D,$F9,$63,$65,$91,$29 ; BCAD C6 1F 4D F9 63 65 91 29  ..M.ce.)
        .byte   $0C,$A1,$32,$A2,$12,$A4,$12,$B7 ; BCB5 0C A1 32 A2 12 A4 12 B7  ..2.....
        .byte   $10,$39,$90,$EB,$03,$AE,$0A,$E1 ; BCBD 10 39 90 EB 03 AE 0A E1  .9......
        .byte   $AC,$3D,$27,$02,$0F,$01,$F8,$3E ; BCC5 AC 3D 27 02 0F 01 F8 3E  .='....>
        .byte   $17,$E1,$7C,$35,$CB,$24,$50,$F0 ; BCCD 17 E1 7C 35 CB 24 50 F0  ..|5.$P.
        .byte   $1F,$67,$E3,$FF,$CE,$2D,$50,$08 ; BCD5 1F 67 E3 FF CE 2D 50 08  .g...-P.
        .byte   $A0,$98,$81,$71,$02,$F2,$17,$C5 ; BCDD A0 98 81 71 02 F2 17 C5  ...q....
        .byte   $7C,$6B,$E5,$FA,$BE,$C0,$E1,$60 ; BCE5 7C 6B E5 FA BE C0 E1 60  |k.....`
        .byte   $92,$80,$9A,$80,$68,$02,$0C,$49 ; BCED 92 80 9A 80 68 02 0C 49  ....h..I
        .byte   $CD,$62,$C7,$10,$F2,$1F,$B1,$FF ; BCF5 CD 62 C7 10 F2 1F B1 FF  .b......
        .byte   $81,$32,$66,$BC,$D7,$C2,$79,$2F ; BCFD 81 32 66 BC D7 C2 79 2F  .2f...y/
        .byte   $D1,$FC,$FD,$13,$CF,$2F,$C1,$53 ; BD05 D1 FC FD 13 CF 2F C1 53  ...../.S
        .byte   $87,$F2,$FE,$08,$FE,$00,$2F,$C0 ; BD0D 87 F2 FE 08 FE 00 2F C0  ....../.
        .byte   $05,$58,$6A,$6A,$C3,$F9,$7E,$BF ; BD15 05 58 6A 6A C3 F9 7E BF  .Xjj..~.
        .byte   $C1,$FC,$BE,$40,$0B,$EC,$37,$C3 ; BD1D C1 FC BE 40 0B EC 37 C3  ...@..7.
        .byte   $0F,$3A,$E5,$D7,$21,$BF,$0C,$7D ; BD25 0F 3A E5 D7 21 BF 0C 7D  .:..!..}
        .byte   $BF,$B5,$FF,$5C,$75,$83,$D6,$7D ; BD2D BF B5 FF 5C 75 83 D6 7D  ...\u..}
        .byte   $77,$AF,$3A,$FF,$9F,$E4,$FE,$4B ; BD35 77 AF 3A FF 9F E4 FE 4B  w.:....K
        .byte   $F2,$59,$C9,$65,$E7,$F5,$7E,$C7 ; BD3D F2 59 C9 65 E7 F5 7E C7  .Y.e..~.
        .byte   $05,$BE,$4A,$B8,$2C,$B0,$45,$2B ; BD45 05 BE 4A B8 2C B0 45 2B  ..J.,.E+
        .byte   $3F,$EB,$8B,$FE,$56,$79,$4F,$2F ; BD4D 3F EB 8B FE 56 79 4F 2F  ?...VyO/
        .byte   $E3,$FD,$71,$79,$F5,$5F,$B1,$FE ; BD55 E3 FD 71 79 F5 5F B1 FE  ..qy._..
        .byte   $3C,$07,$0F,$1E,$03,$E4,$D5,$04 ; BD5D 3C 07 0F 1E 03 E4 D5 04  <.......
        .byte   $89,$74,$90,$E0,$45,$8E,$E3,$88 ; BD65 89 74 90 E0 45 8E E3 88  .t..E...
        .byte   $BE,$22,$24,$7F,$35,$61,$E5,$93 ; BD6D BE 22 24 7F 35 61 E5 93  ."$.5a..
        .byte   $F2,$F2,$FE,$05,$41,$63,$B8,$FA ; BD75 F2 F2 FE 05 41 63 B8 FA  ....Ac..
        .byte   $3E,$63,$C4,$D4,$03,$E7,$74,$A7 ; BD7D 3E 63 C4 D4 03 E7 74 A7  >c....t.
        .byte   $28,$32,$BE,$C3,$F6,$1B,$60,$D6 ; BD85 28 32 BE C3 F6 1B 60 D6  (2....`.
        .byte   $29,$18,$F3,$5E,$80,$B4,$3A,$36 ; BD8D 29 18 F3 5E 80 B4 3A 36  )..^..:6
        .byte   $07,$38,$BF,$F2,$FE,$2F,$00,$FE ; BD95 07 38 BF F2 FE 2F 00 FE  .8.../..
        .byte   $C3,$F3,$5C,$E3,$BD,$36,$17,$65 ; BD9D C3 F3 5C E3 BD 36 17 65  ..\..6.e
        .byte   $FA,$BE,$72,$1F,$B2,$FB,$47,$84 ; BDA5 FA BE 72 1F B2 FB 47 84  ..r...G.
        .byte   $B1,$0A,$D2,$FA,$5F,$F3,$0F,$A1 ; BDAD B1 0A D2 FA 5F F3 0F A1  ...._...
        .byte   $7E,$09,$7B,$57,$A5,$3A,$D6,$77 ; BDB5 7E 09 7B 57 A5 3A D6 77  ~.{W.:.w
        .byte   $8C,$F8,$4B,$A0,$2E,$A2,$E8,$97 ; BDBD 8C F8 4B A0 2E A2 E8 97  ..K.....
        .byte   $0C,$B0,$E4,$8F,$13,$F2,$1F,$63 ; BDC5 0C B0 E4 8F 13 F2 1F 63  .......c
        .byte   $CB,$1C,$31,$86,$C3,$11,$F8,$08 ; BDCD CB 1C 31 86 C3 11 F8 08  ..1.....
        .byte   $C0,$55,$C8,$D6,$16,$50,$F0,$1F ; BDD5 C0 55 C8 D6 16 50 F0 1F  .U...P..
        .byte   $60,$F4,$07,$A8,$1A,$C0,$AE,$05 ; BDDD 60 F4 07 A8 1A C0 AE 05  `.......
        .byte   $7F,$EB,$F2,$F4,$B5,$A5,$F5,$C0 ; BDE5 7F EB F2 F4 B5 A5 F5 C0  ........
        .byte   $5E,$2B,$CA,$E6,$B3,$A9,$E8,$FB ; BDED 5E 2B CA E6 B3 A9 E8 FB  ^+......
        .byte   $7F,$60,$FA,$03,$A1,$F7,$7C,$7F ; BDF5 7F 60 FA 03 A1 F7 7C 7F  .`....|.
        .byte   $EB,$E5,$78,$3F,$81,$FF,$81,$19 ; BDFD EB E5 78 3F 81 FF 81 19  ..x?....
        .byte   $54,$C2,$87,$43,$E9,$AC,$3A,$F2 ; BE05 54 C2 87 43 E9 AC 3A F2  T..C..:.
        .byte   $BE,$AF,$8B,$C6,$B8,$8B,$12,$A2 ; BE0D BE AF 8B C6 B8 8B 12 A2  ........
        .byte   $72,$09,$85,$4E,$34,$E3,$A6,$3D ; BE15 72 09 85 4E 34 E3 A6 3D  r..N4..=
        .byte   $23,$E8,$3F,$47,$F9,$FD,$03,$C2 ; BE1D 23 E8 3F 47 F9 FD 03 C2  #.?G....
        .byte   $8E,$20,$62,$82,$2C,$02,$E1,$2F ; BE25 8E 20 62 82 2C 02 E1 2F  . b.,../
        .byte   $35,$F1,$7E,$AF,$FC,$9F,$CD,$7C ; BE2D 35 F1 7E AF FC 9F CD 7C  5.~....|
        .byte   $12,$7B,$53,$A1,$3D,$43,$DD,$F3 ; BE35 12 7B 53 A1 3D 43 DD F3  .{S.=C..
        .byte   $96,$33,$81,$96,$98,$B4,$EA,$9F ; BE3D 96 33 81 96 98 B4 EA 9F  .3......
        .byte   $B1,$F1,$3F,$0B,$C6,$A8,$45,$0A ; BE45 B1 F1 3F 0B C6 A8 45 0A  ..?...E.
        .byte   $CB,$5E,$3A,$E3,$33,$19,$05,$88 ; BE4D CB 5E 3A E3 33 19 05 88  .^:.3...
        .byte   $3C,$0F,$C7,$F3,$50,$5C,$D6,$6F ; BE55 3C 0F C7 F3 50 5C D6 6F  <...P\.o
        .byte   $81,$AE,$72,$F4,$15,$51,$45,$A3 ; BE5D 81 AE 72 F4 15 51 45 A3  ..r..QE.
        .byte   $6E,$2B,$F8,$D7,$C3,$08,$65,$95 ; BE65 6E 2B F8 D7 C3 08 65 95  n+....e.
        .byte   $59,$55,$C5,$D7,$85,$79,$8D,$7E ; BE6D 59 55 C5 D7 85 79 8D 7E  YU...y.~
        .byte   $3A,$F8,$E9,$C7,$FA,$F1,$5E,$05 ; BE75 3A F8 E9 C7 FA F1 5E 05  :.....^.
        .byte   $F3,$BF,$C3,$FC,$E5,$D6,$7F,$C1 ; BE7D F3 BF C3 FC E5 D6 7F C1  ........
        .byte   $16,$07,$C1,$1F,$CD,$41,$67,$DF ; BE85 16 07 C1 1F CD 41 67 DF  .....Ag.
        .byte   $03,$95,$61,$7C,$07,$C1,$1D,$CC ; BE8D 03 95 61 7C 07 C1 1D CC  ..a|....
        .byte   $C4,$91,$DC,$3E,$0B,$E3,$FF,$C9 ; BE95 C4 91 DC 3E 0B E3 FF C9  ...>....
        .byte   $75,$02,$61,$92,$EA,$5F,$19,$6B ; BE9D 75 02 61 92 EA 5F 19 6B  u.a.._.k
        .byte   $12,$BA,$08,$E9,$65,$74,$17,$C1 ; BEA5 12 BA 08 E9 65 74 17 C1  ....et..
        .byte   $AE,$31,$FF,$1D,$21,$98,$27,$01 ; BEAD AE 31 FF 1D 21 98 27 01  .1..!.'.
        .byte   $E6,$37,$07,$70,$BE,$7C,$D6,$21 ; BEB5 E6 37 07 70 BE 7C D6 21  .7.p.|.!
        .byte   $71,$36,$27,$9F,$8C,$B1,$21,$30 ; BEBD 71 36 27 9F 8C B1 21 30  q6'...!0
        .byte   $9C,$80                         ; BEC5 9C 80                    ..
okchr:  .byte   $01,$20,$A3,$5E,$53,$94,$16,$A9 ; BEC7 01 20 A3 5E 53 94 16 A9  . .^S...
        .byte   $F8,$BF,$E0,$01,$2D,$FF,$FF,$FF ; BECF F8 BF E0 01 2D FF FF FF  ....-...
        .byte   $7F,$00,$FF,$FF,$FF,$FF,$FF,$FF ; BED7 7F 00 FF FF FF FF FF FF  ........
        .byte   $7F,$00,$FF,$FF,$FF,$FF,$FF,$FF ; BEDF 7F 00 FF FF FF FF FF FF  ........
        .byte   $7F,$00,$FF,$FF,$FF,$FF,$FF,$FF ; BEE7 7F 00 FF FF FF FF FF FF  ........
        .byte   $7F,$00,$FF,$FF,$FF,$FF,$FF,$FF ; BEEF 7F 00 FF FF FF FF FF FF  ........
        .byte   $7F,$00,$FF,$FF,$FF,$FF,$FF,$FF ; BEF7 7F 00 FF FF FF FF FF FF  ........
        .byte   $7F,$00,$00,$00,$00,$00,$00,$00 ; BEFF 7F 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF07 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF0F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF17 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF1F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF27 00 00 00 00 00 00 00 00  ........
        .byte   $00,$40,$00,$00,$00,$00,$00,$00 ; BF2F 00 40 00 00 00 00 00 00  .@......
        .byte   $00,$08,$00,$00,$00,$00,$00,$00 ; BF37 00 08 00 00 00 00 00 00  ........
        .byte   $00,$02,$00,$00,$00,$00,$00,$00 ; BF3F 00 02 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF47 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF4F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF57 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF5F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF67 00 00 00 00 00 00 00 00  ........
        .byte   $00,$20,$00,$00,$00,$00,$00,$00 ; BF6F 00 20 00 00 00 00 00 00  . ......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF77 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF7F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF87 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF8F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF97 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BF9F 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFA7 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFAF 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFB7 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFBF 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFC7 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFCF 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFD7 00 00 00 00 00 00 00 00  ........
        .byte   $00,$40,$00,$00,$00,$00,$00,$00 ; BFDF 00 40 00 00 00 00 00 00  .@......
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFE7 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFEF 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; BFF7 00 00 00 00 00 00 00 00  ........
        .byte   $00                             ; BFFF 00                       .

; End of "BANK_2" segment
; ----------------------------------------------------------------------------
.code

