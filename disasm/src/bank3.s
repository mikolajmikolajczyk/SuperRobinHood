; da65 V2.18 - N/A
; Created:    2026-04-12 21:16:35
; Input file: banks/bank3.bin
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
flyflag         := $000B
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
address1        := $001D
address2        := $001F
address3        := $0021
address4        := $0023
address5        := $0025
address6        := $0027
address7        := $0029
address8        := $002B
address9        := $002D
tempx           := $002F
tempy           := $0030
temp            := $0031
temp1           := $0032
temp2           := $0033
temp3           := $0034
temp4           := $0035
temp5           := $0036
temp6           := $0037
temp7           := $0038
temp8           := $0039
temp9           := $003A
scrxl           := $003B
scrxh           := $003C
mapstrip        := $003D
attripointer    := $003E
blockattri      := $003F
mappointer      := $0040
mapno           := $0042
solidfound      := $0043
pause           := $0044
dontpause       := $0045
palversion      := $0046
scrolldir       := $0047
lives           := $0048
hearts          := $0049
heartcounter    := $004A
noofparas       := $004B
extravarpointer := $004C
fadecounter     := $004D
fadetemp        := $004E
heartxl         := $004F
heartxh         := $0050
hearty          := $0051
changedblockspointer:= $0052
vrambuffer      := $0100
blockbuffer     := $0170
spriteblock     := $0200
finishedloop    := $0300
chrfound        := $0301
blockfound      := $0302
blockx          := $0303
blocky          := $0304
minmap          := $0305
maxmap          := $0306
robindx         := $0307
robinxl         := $0308
robinxh         := $0309
robiny          := $030A
robinonscrx     := $030B
leftright       := $030C
oleftright      := $030D
orobinxl        := $030E
orobinxh        := $030F
orobiny         := $0310
runcount        := $0311
robinanim       := $0313
robinfiring     := $0314
robincrouch     := $0315
robinheight     := $0316
robinjumping    := $0317
robingravity    := $0318
robinlook       := $0319
robinladder     := $031A
robinladdercounter:= $031B
robininvinc     := $031C
robinbehind     := $031D
robinjustjumped := $031E
oldxl           := $031F
oldxh           := $0320
oldy            := $0321
oldladder       := $0322
killed          := $0323
deadarrowx      := $0324
deadarrowy      := $0326
deadarrowcount  := $0327
animatedoor     := $0328
doorx           := $0329
doory           := $032A
juststartedlife := $032B
hipos           := $032C
ingame          := $032D
treasures       := $032E
coinnum         := $0334
coinnumx        := $0335
coinnumy        := $0336
coinnumcount    := $0337
attributes      := $0338
completedgame   := $03A8
extravars       := $03A9
arrowxl         := $0429
arrowxh         := $0431
arrowy          := $0439
arrowdir        := $0441
arrowcanon      := $0449
arrowcounter    := $0451
spitterxl       := $0459
spitterxh       := $045D
spittery        := $0461
spitterdir      := $0465
onscreenrou     := $0481
onscreenxl      := $0491
onscreenxh      := $04A1
onscreeny       := $04B1
onscreencount1  := $04C1
onscreencount2  := $04D1
heartstable     := $04E1
filledblockbuffer:= $0511
riseup          := $0512
fadecolours     := $0513
changedblocks   := $0533
score           := $0575
L0600           := $0600
cm_flags        := $07FE
cm_powerup      := $07FF
L0810           := $0810
_control0       := $2000
_control1       := $2001
_statusreg      := $2002
_spriteaddr     := $2003
_scrollcon      := $2005
_vramaddr       := $2006
_vramdata       := $2007
_dmafunc        := $4014
_kpreg1         := $4016
b2_cm_logo      := $8000
b1_START_MUSIC  := $8007
b1_PLAY_MUSIC   := $8066
b2_smiley       := $8906
b1_trytoentername:= $9818
b1_copyhiscorestoram:= $9C71
b1_titlescreen  := $9D8A
b1_pulsecolour  := $A1B3
b1_fx_setup     := $A47E
b1_fx_play      := $A52A
b1_restupdatecoin:= $A6DA
b1_putinheartbank:= $A7E8
b1_floatupnumber:= $A8EE
b1_print6treasures:= $AAE2
b1_redefinewater:= $AB6C
b1_updatehearts := $AD2D
b1_printrobin   := $AF95
b1_printrobin1  := $AFC5
; ----------------------------------------------------------------------------

.segment        "BANK_3": absolute

bank3_header:
        .byte   $FE,$FF                         ; C000 FE FF                    ..
lock_a:  .byte   $FF                             ; C002 FF                       .
lock_b:  .byte   $FF                             ; C003 FF                       .
; ----------------------------------------------------------------------------
bank3_entry:
        jmp     pastnops                        ; C004 4C F8 C2                 L..

; ----------------------------------------------------------------------------
cm_nmi_target:
        jmp     cm_nmi                          ; C007 4C 93 C4                 L..

; ----------------------------------------------------------------------------
bank_table:
        .byte   $00,$01,$02,$03,$04,$05,$06,$07 ; C00A 00 01 02 03 04 05 06 07  ........
        .byte   $08,$09,$0A,$0B                 ; C012 08 09 0A 0B              ....
banksel12:  .byte   $0C                             ; C016 0C                       .
banksel13:  .byte   $0D                             ; C017 0D                       .
banksel14:  .byte   $0E                             ; C018 0E                       .
banksel15:  .byte   $0F                             ; C019 0F                       .
; ==========================================================================
; TIMINGS.ROU
; ==========================================================================
times16lo:
; times16lo — lookup table: entry[i] = <(i * 16), 216 entries
.repeat 216, i
    .byte <(i * 16)
.endrepeat
times32tablelo:
; times32tablelo — lookup table: entry[i] = <(i * 64), 14 entries
.repeat 14, i
    .byte <(i * 64)
.endrepeat
times32tablehi:
; times32tablehi — lookup table: entry[i] = >(i * 64 + $2000), 14 entries
.repeat 14, i
    .byte >(i * 64 + $2000)
.endrepeat
waterchrs:
        .byte   $0C,$3F,$33,$FF,$C0,$F3,$33,$FF ; C10E 0C 3F 33 FF C0 F3 33 FF  .?3...3.
        .byte   $01,$A3,$00,$C3,$00,$3C,$18     ; C116 01 A3 00 C3 00 3C 18     .....<.
times16hi_m1:  .byte   $BD                             ; C11D BD                       .
times16hi:
; times16hi — lookup table: entry[i] = >(i * 16), 216 entries
.repeat 216, i
    .byte >(i * 16)
.endrepeat
; entry: A = strip number
; ----------------------------------------------------------------------------
multstripby16:
        tay                                     ; C1F6 A8                       .
        lda     times16hi,y                     ; C1F7 B9 1E C1                 ...
        sta     $2A                             ; C1FA 85 2A                    .*
        lda     times16lo,y                     ; C1FC B9 1A C0                 ...
        rts                                     ; C1FF 60                       `

; entry: A = strip number
; ----------------------------------------------------------------------------
multstripby16sub:
        tay                                     ; C200 A8                       .
        lda     times16lo,y                     ; C201 B9 1A C0                 ...
        sec                                     ; C204 38                       8
        sbc     scrxl                           ; C205 E5 3B                    .;
        sta     address8                        ; C207 85 2B                    .+
        lda     times16hi,y                     ; C209 B9 1E C1                 ...
        sbc     scrxh                           ; C20C E5 3C                    .<
        sta     a:temp7                         ; C20E 8D 38 00                 .8.
        rts                                     ; C211 60                       `

; ----------------------------------------------------------------------------
emptyblockbuffer:
        lda     ingame                          ; C212 AD 2D 03                 .-.
        beq     @n4                           ; C215 F0 5C                    .\
        lda     filledblockbuffer               ; C217 AD 11 05                 ...
        bne     @n4                           ; C21A D0 57                    .W
        lda     #$00                            ; C21C A9 00                    ..
        ldx     blockpointer                    ; C21E A6 0F                    ..
        sta     blockbuffer,x                   ; C220 9D 70 01                 .p.
        tax                                     ; C223 AA                       .
        stx     blockpointer                    ; C224 86 0F                    ..
@n2:  lda     blockbuffer,x                   ; C226 BD 70 01                 .p.
        beq     @n4                           ; C229 F0 48                    .H
        sta     _vramaddr                       ; C22B 8D 06 20                 .. 
        lda     $0171,x                         ; C22E BD 71 01                 .q.
        sta     _vramaddr                       ; C231 8D 06 20                 .. 
        lda     $0172,x                         ; C234 BD 72 01                 .r.
        sta     _vramdata                       ; C237 8D 07 20                 .. 
        lda     $0173,x                         ; C23A BD 73 01                 .s.
        sta     _vramdata                       ; C23D 8D 07 20                 .. 
        lda     $0174,x                         ; C240 BD 74 01                 .t.
        sta     _vramaddr                       ; C243 8D 06 20                 .. 
        lda     $0175,x                         ; C246 BD 75 01                 .u.
        sta     _vramaddr                       ; C249 8D 06 20                 .. 
        lda     $0176,x                         ; C24C BD 76 01                 .v.
        sta     _vramdata                       ; C24F 8D 07 20                 .. 
        lda     $0177,x                         ; C252 BD 77 01                 .w.
        sta     _vramdata                       ; C255 8D 07 20                 .. 
        lda     $0178,x                         ; C258 BD 78 01                 .x.
        sta     _vramaddr                       ; C25B 8D 06 20                 .. 
        lda     $0179,x                         ; C25E BD 79 01                 .y.
        sta     _vramaddr                       ; C261 8D 06 20                 .. 
        lda     $017A,x                         ; C264 BD 7A 01                 .z.
        sta     _vramdata                       ; C267 8D 07 20                 .. 
        txa                                     ; C26A 8A                       .
        clc                                     ; C26B 18                       .
        adc     #$0B                            ; C26C 69 0B                    i.
        tax                                     ; C26E AA                       .
        cpx     #$6E                            ; C26F E0 6E                    .n
        bne     @n2                           ; C271 D0 B3                    ..
@n4:  rts                                     ; C273 60                       `

; ----------------------------------------------------------------------------
changebank12rou:
        lda     #$0C                            ; C274 A9 0C                    ..
        sta     bankno                          ; C276 85 0D                    ..
        sta     banksel12                           ; C278 8D 16 C0                 ...
        rts                                     ; C27B 60                       `

; ----------------------------------------------------------------------------
changebank13rou:
        lda     #$0D                            ; C27C A9 0D                    ..
        sta     bankno                          ; C27E 85 0D                    ..
        sta     banksel13                           ; C280 8D 17 C0                 ...
        rts                                     ; C283 60                       `

; ----------------------------------------------------------------------------
; ==========================================================================
; START.ROU
; ==========================================================================
cm_reset:
        start := *
        sei                                     ; C284 78                       x
        cld                                     ; C285 D8                       .
        ldx     #$FF                            ; C286 A2 FF                    ..
        txs                                     ; C288 9A                       .
        ; TAIWAN LOCK CHIP SOFTWARE
        lda     #$00                            ; C289 A9 00                    ..
        sta     _control0                       ; C28B 8D 00 20                 .. 
        sta     _control1                       ; C28E 8D 01 20                 .. 
        sta     $4015                           ; C291 8D 15 40                 ..@
lock1           := * + 1
        sta     cm_flags                        ; C294 8D FE 07                 ...
        sta     cm_powerup                      ; C297 8D FF 07                 ...
ghfh:   lda     #$0C                            ; C29A A9 0C                    ..
        sta     banksel12                           ; C29C 8D 16 C0                 ...
        jmp     bank3_entry                     ; C29F 4C 04 C0                 L..

; ----------------------------------------------------------------------------
        .byte   $FF                             ; C2A2 FF                       .
        jsr     lock2                           ; C2A3 20 C0 C2                  ..
        dec     $07F0                           ; C2A6 CE F0 07                 ...
        bne     ghfh                            ; C2A9 D0 EF                    ..
        lda     $70                             ; C2AB A5 70                    .p
        sec                                     ; C2AD 38                       8
        sbc     #$80                            ; C2AE E9 80                    ..
        sta     $70                             ; C2B0 85 70                    .p
        bcs     @n1                           ; C2B2 B0 02                    ..
        dec     $71                             ; C2B4 C6 71                    .q
@n1:  dec     $72                             ; C2B6 C6 72                    .r
        bne     lock1                           ; C2B8 D0 DB                    ..
        sta     LFFF0                           ; C2BA 8D F0 FF                 ...
        jmp     pastlock                        ; C2BD 4C CD C2                 L..

; ----------------------------------------------------------------------------
lock2:  ldx     $70                             ; C2C0 A6 70                    .p
        ldy     $71                             ; C2C2 A4 71                    .q
        bit     $FF                             ; C2C4 24 FF                    $.
lock3:  dex                                     ; C2C6 CA                       .
        bne     lock3                           ; C2C7 D0 FD                    ..
        dey                                     ; C2C9 88                       .
        bne     lock3                           ; C2CA D0 FA                    ..
        rts                                     ; C2CC 60                       `

; ----------------------------------------------------------------------------
pastlock:
        ldy     #$14                            ; C2CD A0 14                    ..
@n1:  lda     LC2DA,y                         ; C2CF B9 DA C2                 ...
        sta     $05FF,y                         ; C2D2 99 FF 05                 ...
        dey                                     ; C2D5 88                       .
        bne     @n1                           ; C2D6 D0 F7                    ..
LC2DA           := * + 2
        jmp     L0600                           ; C2D8 4C 00 06                 L..

; ----------------------------------------------------------------------------
        lda     #$18                            ; C2DB A9 18                    ..
        sta     $9000                           ; C2DD 8D 00 90                 ...
        jmp     LFB50                           ; C2E0 4C 50 FB                 LP.

; ----------------------------------------------------------------------------
        nop                                     ; C2E3 EA                       .
        nop                                     ; C2E4 EA                       .
        nop                                     ; C2E5 EA                       .
        nop                                     ; C2E6 EA                       .
        nop                                     ; C2E7 EA                       .
        nop                                     ; C2E8 EA                       .
        nop                                     ; C2E9 EA                       .
        nop                                     ; C2EA EA                       .
        lda     #$0E                            ; C2EB A9 0E                    ..
        sta     bankno                          ; C2ED 85 0D                    ..
        sta     banksel14                           ; C2EF 8D 18 C0                 ...
        jsr     b2_smiley                       ; C2F2 20 06 89                  ..
        jsr     changebank12rou                 ; C2F5 20 74 C2                  t.
pastnops:
        lda     cm_powerup                      ; C2F8 AD FF 07                 ...
        pha                                     ; C2FB 48                       H
        lda     #$0E                            ; C2FC A9 0E                    ..
        sta     bankno                          ; C2FE 85 0D                    ..
        sta     banksel14                           ; C300 8D 18 C0                 ...
        jsr     b2_cm_logo                      ; C303 20 00 80                  ..
        jsr     changebank12rou                 ; C306 20 74 C2                  t.
        pla                                     ; C309 68                       h
        tax                                     ; C30A AA                       .
        ldy     #$00                            ; C30B A0 00                    ..
        sty     _control0                       ; C30D 8C 00 20                 .. 
        sty     _control1                       ; C310 8C 01 20                 .. 
        sty     address                         ; C313 84 1B                    ..
        sty     $1C                             ; C315 84 1C                    ..
clearram:
        lda     #$00                            ; C317 A9 00                    ..
@n1:  sta     (address),y                     ; C319 91 1B                    ..
        iny                                     ; C31B C8                       .
        bne     @n1                           ; C31C D0 FB                    ..
@n2:  inc     $1C                             ; C31E E6 1C                    ..
        lda     $1C                             ; C320 A5 1C                    ..
        cmp     #$01                            ; C322 C9 01                    ..
        beq     @n2                           ; C324 F0 F8                    ..
        cmp     #$07                            ; C326 C9 07                    ..
        bne     clearram                        ; C328 D0 ED                    ..
        jsr     changebank13rou                 ; C32A 20 7C C2                  |.
        jsr     b1_copyhiscorestoram            ; C32D 20 71 9C                  q.
        jsr     changebank12rou                 ; C330 20 74 C2                  t.
        lda     #$90                            ; C333 A9 90                    ..
        sta     control0                        ; C335 85 01                    ..
        sta     _control0                       ; C337 8D 00 20                 .. 
        sta     seed                            ; C33A 85 04                    ..
        lda     #$1E                            ; C33C A9 1E                    ..
        sta     control1                        ; C33E 85 02                    ..
        sta     $05                             ; C340 85 05                    ..
        jsr     turninteroff1                   ; C342 20 B2 F4                  ..
        jsr     changebank12rou                 ; C345 20 74 C2                  t.
        lda     #$0A                            ; C348 A9 0A                    ..
        jsr     starttune                       ; C34A 20 14 F4                  ..
; ==========================================================================
; MAINLOOP.ROU
; ==========================================================================
anewgame:
        jsr     changebank13rou                 ; C34D 20 7C C2                  |.
        jsr     b1_titlescreen                  ; C350 20 8A 9D                  ..
        jsr     changebank12rou                 ; C353 20 74 C2                  t.
        ; essentially blacken the screen
        jsr     clearfullspriteblock            ; C356 20 02 F4                  ..
        asl     flyflag                         ; C359 06 0B                    ..
@fly:  bit     flyflag                         ; C35B 24 0B                    $.
        bpl     @fly                           ; C35D 10 FC                    ..
        ; Make sure that the completedgame variable is cleared! We don't want someone to accidentally complete the game without even starting it :) ***
        lda     #$00                            ; C35F A9 00                    ..
        sta     completedgame                   ; C361 8D A8 03                 ...
startlives:
        ldx     #$03                            ; C364 A2 03                    ..
        lda     pad                             ; C366 A5 07                    ..
        and     #$82                            ; C368 29 82                    ).
        ; are we pressing Left + A?
        cmp     #$82                            ; C36A C9 82                    ..
        ; if not, skip the next part and begin with 3 lives
        bne     normal3lives                    ; C36C D0 02                    ..
        ; else load 4 lives into the x variable :O
        ldx     #$04                            ; C36E A2 04                    ..
; store the value that was at x into memory
normal3lives:
        stx     lives                           ; C370 86 48                    .H
        lda     #$00                            ; C372 A9 00                    ..
        ; load 0 into the hearts memory address
        sta     hearts                          ; C374 85 49                    .I
        ; resets the player score
        jsr     resetscore                      ; C376 20 6F F5                  o.
        jsr     resetextras                     ; C379 20 E4 D3                  ..
        lda     #$01                            ; C37C A9 01                    ..
        ; tells the game that robin should be controlled by the player now
        sta     ingame                          ; C37E 8D 2D 03                 .-.
        lda     #$0C                            ; C381 A9 0C                    ..
        ; copy robin's character data into memory
        jsr     copyblockofcompactedchrs        ; C383 20 E0 F1                  ..
        jsr     resetrobinvars                  ; C386 20 8F C5                  ..
        jsr     resetrobinvars1                 ; C389 20 A4 C5                  ..
        lda     #$05                            ; C38C A9 05                    ..
        sta     mapno                           ; C38E 85 42                    .B
        ; load the beginning level
        jsr     gointonewmap                    ; C390 20 FB FB                  ..
ingameloop:
        lda     #$00                            ; C393 A9 00                    ..
        sta     finishedloop                    ; C395 8D 00 03                 ...
        sta     filledblockbuffer               ; C398 8D 11 05                 ...
        asl     flyflag                         ; C39B 06 0B                    ..
@fly:  bit     flyflag                         ; C39D 24 0B                    $.
        bpl     @fly                           ; C39F 10 FC                    ..
        lda     #$01                            ; C3A1 A9 01                    ..
        sta     finishedloop                    ; C3A3 8D 00 03                 ...
        sta     filledblockbuffer               ; C3A6 8D 11 05                 ...
        lda     juststartedlife                 ; C3A9 AD 2B 03                 .+.
        beq     @n11                           ; C3AC F0 03                    ..
        jsr     zoominstars                     ; C3AE 20 7A C4                  z.
@n11:  lda     pause                           ; C3B1 A5 44                    .D
        beq     @n12                           ; C3B3 F0 1F                    ..
        lda     pad                             ; C3B5 A5 07                    ..
        and     #$10                            ; C3B7 29 10                    ).
        bne     @n21                           ; C3B9 D0 16                    ..
        lda     #$E8                            ; C3BB A9 E8                    ..
        sta     spriteblockpointer              ; C3BD 85 0E                    ..
        ldy     #$50                            ; C3BF A0 50                    .P
        lda     robiny                          ; C3C1 AD 0A 03                 ...
        cmp     #$7C                            ; C3C4 C9 7C                    .|
        bcs     @pause_y                           ; C3C6 B0 02                    ..
        ldy     #$80                            ; C3C8 A0 80                    ..
@pause_y:  ldx     #$63                            ; C3CA A2 63                    .c
        lda     #$41                            ; C3CC A9 41                    .A
        jsr     printsprite                           ; C3CE 20 F4 EC                  ..
@n21:  jmp     endofmainloop                   ; C3D1 4C 22 C4                 L".

; show the amount of lives on screen
; ----------------------------------------------------------------------------
@n12:  jsr     doorrou                         ; C3D4 20 33 D5                  3.
        jsr     printlives                      ; C3D7 20 DE F4                  ..
        ; show the score at the top of the screen
        jsr     printscore                      ; C3DA 20 09 F5                  ..
        ; print the hearts on the left of the screen
        jsr     printhearts                     ; C3DD 20 DE F5                  ..
        jsr     moveman                         ; C3E0 20 BD C6                  ..
        jsr     animatelegs                     ; C3E3 20 A2 CA                  ..
        jsr     setxscroll                      ; C3E6 20 7D F6                  }.
        jsr     updatearrows                    ; C3E9 20 8D D6                  ..
        jsr     changebank13rou                 ; C3EC 20 7C C2                  |.
        jsr     b1_printrobin                   ; C3EF 20 95 AF                  ..
        jsr     b1_floatupnumber                ; C3F2 20 EE A8                  ..
        jsr     changebank12rou                 ; C3F5 20 74 C2                  t.
        jsr     updatespitters                  ; C3F8 20 32 DB                  2.
        lda     counter                         ; C3FB A5 10                    ..
        and     #$01                            ; C3FD 29 01                    ).
        bne     ingameloop_n5                           ; C3FF D0 12                    ..
        jsr     updateonscreens                 ; C401 20 70 DF                  p.
        jsr     putextrason                     ; C404 20 9A CE                  ..
        jsr     changebank13rou                 ; C407 20 7C C2                  |.
        jsr     b1_updatehearts                 ; C40A 20 2D AD                  -.
        jsr     changebank12rou                 ; C40D 20 74 C2                  t.
        jmp     endofmainloop                   ; C410 4C 22 C4                 L".

; ----------------------------------------------------------------------------
ingameloop_n5:  jsr     changebank13rou                 ; C413 20 7C C2                  |.
        jsr     b1_updatehearts                 ; C416 20 2D AD                  -.
        jsr     changebank12rou                 ; C419 20 74 C2                  t.
        jsr     putextrason                     ; C41C 20 9A CE                  ..
        jsr     updateonscreens                 ; C41F 20 70 DF                  p.
endofmainloop:
        jsr     checkforpausekey                ; C422 20 DE F3                  ..
        jsr     checkoffscreen                  ; C425 20 CF FC                  ..
nearendofmainloop:
        lda     killed                          ; C428 AD 23 03                 .#.
        beq     @n5                           ; C42B F0 24                    .$
        cmp     #$01                            ; C42D C9 01                    ..
        bne     @n7                           ; C42F D0 05                    ..
        lda     #$FF                            ; C431 A9 FF                    ..
        sta     robiny                          ; C433 8D 0A 03                 ...
@n7:  lda     pause                           ; C436 A5 44                    .D
        bne     @n5                           ; C438 D0 17                    ..
        dec     killed                          ; C43A CE 23 03                 .#.
        bne     @n5                           ; C43D D0 12                    ..
        ; robin has died, and needs to respawn
        lda     lives                           ; C43F A5 48                    .H
        beq     theend                          ; C441 F0 17                    ..
        jsr     resetrobinvars1                 ; C443 20 A4 C5                  ..
        jsr     restoreoldrobin                 ; C446 20 50 CE                  P.
        lda     #$BE                            ; C449 A9 BE                    ..
        sta     robininvinc                     ; C44B 8D 1C 03                 ...
        jsr     gointonewmap                    ; C44E 20 FB FB                  ..
@n5:  lda     fadecounter                     ; C451 A5 4D                    .M
        cmp     #$FF                            ; C453 C9 FF                    ..
        beq     theend                          ; C455 F0 03                    ..
        jmp     ingameloop                      ; C457 4C 93 C3                 L..

; is the completedgame flag set to 0? If not, go ahead and jump to completedthegame
; ----------------------------------------------------------------------------
theend: lda     completedgame                   ; C45A AD A8 03                 ...
        bne     completedthegame                ; C45D D0 04                    ..
        lda     #$FF                            ; C45F A9 FF                    ..
        ; store the value 255 in the hearts address (have no idea why though)
        sta     hearts                          ; C461 85 49                    .I
; triggered when the player finishes reading the maid marion message
completedthegame:
        jsr     resetrobinvars1                 ; C463 20 A4 C5                  ..
        jsr     turninteroff                    ; C466 20 AC F4                  ..
        lda     #$00                            ; C469 A9 00                    ..
        ; put robin in the menu state
        sta     ingame                          ; C46B 8D 2D 03                 .-.
        jsr     changebank13rou                 ; C46E 20 7C C2                  |.
        ; allow the player to enter their name
        jsr     b1_trytoentername               ; C471 20 18 98                  ..
        jsr     changebank12rou                 ; C474 20 74 C2                  t.
        ; start a new game
        jmp     anewgame                        ; C477 4C 4D C3                 LM.

; ----------------------------------------------------------------------------
zoominstars:
        dec     juststartedlife                 ; C47A CE 2B 03                 .+.
        lda     juststartedlife                 ; C47D AD 2B 03                 .+.
        cmp     #$1E                            ; C480 C9 1E                    ..
        bcc     @n1                           ; C482 90 0E                    ..
        and     #$03                            ; C484 29 03                    ).
        bne     @n1                           ; C486 D0 0A                    ..
        lda     #$02                            ; C488 A9 02                    ..
        jsr     soundfx                         ; C48A 20 28 F4                  (.
        lda     #$02                            ; C48D A9 02                    ..
        jmp     startstars                      ; C48F 4C EF D4                 L..

; ----------------------------------------------------------------------------
@n1:  rts                                     ; C492 60                       `

; ----------------------------------------------------------------------------
; ==========================================================================
; INTERUPT.ROU
; ==========================================================================
cm_nmi: bit     cm_flags                        ; C493 2C FE 07                 ,..
        bmi     interupt                        ; C496 30 06                    0.
        inc     cm_frames                       ; C498 E6 00                    ..
        bit     _statusreg                      ; C49A 2C 02 20                 ,. 
        rti                                     ; C49D 40                       @

; do all sending of chrs etc 1st
; ----------------------------------------------------------------------------
interupt:
        pha                                     ; C49E 48                       H
        txa                                     ; C49F 8A                       .
        pha                                     ; C4A0 48                       H
        tya                                     ; C4A1 98                       .
        pha                                     ; C4A2 48                       H
        lda     interon                         ; C4A3 A5 03                    ..
        beq     dontdointerupt                  ; C4A5 F0 3D                    .=
        lda     finishedloop                    ; C4A7 AD 00 03                 ...
        bne     @n1                           ; C4AA D0 06                    ..
        jsr     fadeupcolours                   ; C4AC 20 2A C5                  *.
        jsr     emptyprintbuffer                ; C4AF 20 7B F1                  {.
@n1:  jsr     emptyblockbuffer                ; C4B2 20 12 C2                  ..
        lda     x_scroll                        ; C4B5 A5 0A                    ..
        sta     _scrollcon                      ; C4B7 8D 05 20                 .. 
        lda     y_scroll                        ; C4BA A5 09                    ..
        sta     _scrollcon                      ; C4BC 8D 05 20                 .. 
        lda     control0                        ; C4BF A5 01                    ..
        sta     _control0                       ; C4C1 8D 00 20                 .. 
        lda     control1                        ; C4C4 A5 02                    ..
        sta     _control1                       ; C4C6 8D 01 20                 .. 
        lda     finishedloop                    ; C4C9 AD 00 03                 ...
        bne     @n4                           ; C4CC D0 03                    ..
        jsr     sendspriteblock                 ; C4CE 20 07 F4                  ..
@n4:  jsr     dointerpause                    ; C4D1 20 FF C4                  ..
        jsr     readkeypads                     ; C4D4 20 93 F3                  ..
        lda     #$0D                            ; C4D7 A9 0D                    ..
        sta     banksel13                           ; C4D9 8D 17 C0                 ...
        jsr     b1_fx_play                      ; C4DC 20 2A A5                  *.
        lda     bankno                          ; C4DF A5 0D                    ..
        jsr     changebankrou1                  ; C4E1 20 44 F4                  D.
;; You can disable music by commenting up until pla
dontdointerupt:
        lda     pause                           ; C4E4 A5 44                    .D
        bne     @n1                           ; C4E6 D0 0D                    ..
        lda     #$0D                            ; C4E8 A9 0D                    ..
        sta     banksel13                           ; C4EA 8D 17 C0                 ...
        jsr     b1_PLAY_MUSIC                   ; C4ED 20 66 80                  f.
        lda     bankno                          ; C4F0 A5 0D                    ..
        jsr     changebankrou1                  ; C4F2 20 44 F4                  D.
;; Comment up until here to disable music
@n1:  pla                                     ; C4F5 68                       h
        tay                                     ; C4F6 A8                       .
        pla                                     ; C4F7 68                       h
        tax                                     ; C4F8 AA                       .
        lda     #$80                            ; C4F9 A9 80                    ..
        sta     flyflag                         ; C4FB 85 0B                    ..
        pla                                     ; C4FD 68                       h
        ; supposed exit from interupt service
        rti                                     ; C4FE 40                       @

; ----------------------------------------------------------------------------
dointerpause:
        lda     pause                           ; C4FF A5 44                    .D
        bne     inpausemode                     ; C501 D0 0D                    ..
        lda     finishedloop                    ; C503 AD 00 03                 ...
        bne     inpausemode                     ; C506 D0 08                    ..
        inc     counter                         ; C508 E6 10                    ..
        jsr     clearspriteblock                ; C50A 20 53 F4                  S.
        jsr     random                          ; C50D 20 AC F3                  ..
inpausemode:
        rts                                     ; C510 60                       `

; ----------------------------------------------------------------------------
setfade:stx     address                         ; C511 86 1B                    ..
        sty     $1C                             ; C513 84 1C                    ..
        lda     #$03                            ; C515 A9 03                    ..
        sta     fadecounter                     ; C517 85 4D                    .M
        ldy     #$00                            ; C519 A0 00                    ..
@n1:  lda     (address),y                     ; C51B B1 1B                    ..
        sta     fadecolours,y                   ; C51D 99 13 05                 ...
        iny                                     ; C520 C8                       .
        cpy     #$20                            ; C521 C0 20                    . 
        bne     @n1                           ; C523 D0 F6                    ..
        ldy     #$00                            ; C525 A0 00                    ..
        jmp     allblack                        ; C527 4C 6C C5                 Ll.

; ----------------------------------------------------------------------------
fadeupcolours:
        lda     fadecounter                     ; C52A A5 4D                    .M
        beq     endfade                         ; C52C F0 27                    .'
        ldx     #$3F                            ; C52E A2 3F                    .?
        stx     _vramaddr                       ; C530 8E 06 20                 .. 
        ldy     #$00                            ; C533 A0 00                    ..
        sty     _vramaddr                       ; C535 8C 06 20                 .. 
        cmp     #$00                            ; C538 C9 00                    ..
        bmi     backtoblack                     ; C53A 30 1A                    0.
        tax                                     ; C53C AA                       .
        lda     fademasks,x                     ; C53D BD 87 C5                 ...
        sta     fadetemp                        ; C540 85 4E                    .N
        lda     fadecounter                     ; C542 A5 4D                    .M
        beq     dofadelp                        ; C544 F0 02                    ..
        dec     fadecounter                     ; C546 C6 4D                    .M
dofadelp:
        lda     fadecolours,y                   ; C548 B9 13 05                 ...
        and     fadetemp                        ; C54B 25 4E                    %N
        sta     _vramdata                       ; C54D 8D 07 20                 .. 
        iny                                     ; C550 C8                       .
        cpy     #$20                            ; C551 C0 20                    . 
        bne     dofadelp                        ; C553 D0 F3                    ..
endfade:rts                                     ; C555 60                       `

; ----------------------------------------------------------------------------
backtoblack:
        inc     fadecounter                     ; C556 E6 4D                    .M
        lda     fadecounter                     ; C558 A5 4D                    .M
        cmp     #$FF                            ; C55A C9 FF                    ..
        beq     allblack1                       ; C55C F0 1E                    ..
        eor     #$FF                            ; C55E 49 FF                    I.
        clc                                     ; C560 18                       .
        adc     #$01                            ; C561 69 01                    i.
        tax                                     ; C563 AA                       .
        lda     fade1masks,x                    ; C564 BD 8B C5                 ...
        sta     fadetemp                        ; C567 85 4E                    .N
        jmp     dofadelp                        ; C569 4C 48 C5                 LH.

; ----------------------------------------------------------------------------
allblack:
        asl     flyflag                         ; C56C 06 0B                    ..
@fly:  bit     flyflag                         ; C56E 24 0B                    $.
        bpl     @fly                           ; C570 10 FC                    ..
        ldx     #$3F                            ; C572 A2 3F                    .?
        stx     _vramaddr                       ; C574 8E 06 20                 .. 
        ldy     #$00                            ; C577 A0 00                    ..
        sty     _vramaddr                       ; C579 8C 06 20                 .. 
allblack1:
        lda     #$0D                            ; C57C A9 0D                    ..
allblacklp:
        sta     _vramdata                       ; C57E 8D 07 20                 .. 
        iny                                     ; C581 C8                       .
        cpy     #$20                            ; C582 C0 20                    . 
        bne     allblacklp                      ; C584 D0 F8                    ..
        rts                                     ; C586 60                       `

; ----------------------------------------------------------------------------
fademasks:
        .byte   $FF,$3F,$1F,$0F                 ; C587 FF 3F 1F 0F              .?..
fade1masks:
        .byte   $00,$0F,$1F,$3F                 ; C58B 00 0F 1F 3F              ...?
; ----------------------------------------------------------------------------
; ==========================================================================
; CONTROL.ROU
; ==========================================================================
resetrobinvars:
        lda     #$22                            ; C58F A9 22                    ."
        sta     robinxl                         ; C591 8D 08 03                 ...
        lda     #$01                            ; C594 A9 01                    ..
        sta     robinxh                         ; C596 8D 09 03                 ...
        lda     #$D0                            ; C599 A9 D0                    ..
        sta     robiny                          ; C59B 8D 0A 03                 ...
        lda     #$00                            ; C59E A9 00                    ..
        sta     minmap                          ; C5A0 8D 05 03                 ...
        rts                                     ; C5A3 60                       `

; ----------------------------------------------------------------------------
resetrobinvars1:
        jsr     turninteroff                    ; C5A4 20 AC F4                  ..
        lda     $05F0                           ; C5A7 AD F0 05                 ...
        cmp     #$02                            ; C5AA C9 02                    ..
        beq     @n21                           ; C5AC F0 03                    ..
        jsr     turnofftune                     ; C5AE 20 12 F4                  ..
@n21:  lda     #$05                            ; C5B1 A9 05                    ..
        sta     hipos                           ; C5B3 8D 2C 03                 .,.
        lda     #$28                            ; C5B6 A9 28                    .(
        sta     juststartedlife                 ; C5B8 8D 2B 03                 .+.
        lda     #$00                            ; C5BB A9 00                    ..
        sta     robinjustjumped                 ; C5BD 8D 1E 03                 ...
        sta     robingravity                    ; C5C0 8D 18 03                 ...
        sta     robincrouch                     ; C5C3 8D 15 03                 ...
        sta     robinladder                     ; C5C6 8D 1A 03                 ...
        sta     robinjumping                    ; C5C9 8D 17 03                 ...
        sta     robinfiring                     ; C5CC 8D 14 03                 ...
        sta     robinlook                       ; C5CF 8D 19 03                 ...
        sta     killed                          ; C5D2 8D 23 03                 .#.
        sta     runcount                        ; C5D5 8D 11 03                 ...
        sta     robinbehind                     ; C5D8 8D 1D 03                 ...
        lda     #$01                            ; C5DB A9 01                    ..
        sta     robinanim                       ; C5DD 8D 13 03                 ...
        lda     #$BE                            ; C5E0 A9 BE                    ..
        sta     robininvinc                     ; C5E2 8D 1C 03                 ...
        lda     #$03                            ; C5E5 A9 03                    ..
        jsr     copyblockofcompactedchrs        ; C5E7 20 E0 F1                  ..
        jsr     changebank13rou                 ; C5EA 20 7C C2                  |.
        ldx     #$30                            ; C5ED A2 30                    .0
        ldy     #$A9                            ; C5EF A0 A9                    ..
        jsr     prtmessage                      ; C5F1 20 8B F0                  ..
        ldx     lives                           ; C5F4 A6 48                    .H
        lda     hearts                          ; C5F6 A5 49                    .I
        bne     bob1                            ; C5F8 D0 0D                    ..
infinate:
        dec     lives                           ; C5FA C6 48                    .H
        dex                                     ; C5FC CA                       .
        bpl     @n6                           ; C5FD 10 03                    ..
        jmp     bob1                            ; C5FF 4C 07 C6                 L..

; ----------------------------------------------------------------------------
@n6:  lda     #$03                            ; C602 A9 03                    ..
        sta     hearts                          ; C604 85 49                    .I
        inx                                     ; C606 E8                       .
bob1:   cpx     #$06                            ; C607 E0 06                    ..
        bcc     @n1                           ; C609 90 02                    ..
        ldx     #$06                            ; C60B A2 06                    ..
@n1:  cpx     #$00                            ; C60D E0 00                    ..
        bne     @n12                           ; C60F D0 05                    ..
        lda     #$04                            ; C611 A9 04                    ..
        sta     hipos                           ; C613 8D 2C 03                 .,.
@n12:  ldy     #$A9                            ; C616 A0 A9                    ..
        lda     $A966,x                         ; C618 BD 66 A9                 .f.
        clc                                     ; C61B 18                       .
        adc     #$6D                            ; C61C 69 6D                    im
        bcc     @n2                           ; C61E 90 01                    ..
        iny                                     ; C620 C8                       .
@n2:  tax                                     ; C621 AA                       .
        jsr     prtmessage                      ; C622 20 8B F0                  ..
        ldy     #$00                            ; C625 A0 00                    ..
        ldx     #$00                            ; C627 A2 00                    ..
copyintreasures:
        lda     #$00                            ; C629 A9 00                    ..
        sta     heartstable,y                   ; C62B 99 E1 04                 ...
        lda     $AACA,y                         ; C62E B9 CA AA                 ...
        sta     vrambuffer,y                    ; C631 99 00 01                 ...
        tya                                     ; C634 98                       .
        and     #$03                            ; C635 29 03                    ).
        cmp     #$03                            ; C637 C9 03                    ..
        bne     @n7                           ; C639 D0 0A                    ..
        lda     treasures,x                     ; C63B BD 2E 03                 ...
        clc                                     ; C63E 18                       .
        adc     #$21                            ; C63F 69 21                    i!
        sta     vrambuffer,y                    ; C641 99 00 01                 ...
        inx                                     ; C644 E8                       .
@n7:  iny                                     ; C645 C8                       .
        cpy     #$18                            ; C646 C0 18                    ..
        sty     vrampointer                     ; C648 84 0C                    ..
        bne     copyintreasures                 ; C64A D0 DD                    ..
        jsr     emptyprintbuffer                ; C64C 20 7B F1                  {.
        lda     completedgame                   ; C64F AD A8 03                 ...
        beq     @n3                           ; C652 F0 0F                    ..
        ldx     #$97                            ; C654 A2 97                    ..
        ldy     #$A9                            ; C656 A0 A9                    ..
        jsr     prtmessage                      ; C658 20 8B F0                  ..
        lda     #$FF                            ; C65B A9 FF                    ..
        sta     minmap                          ; C65D 8D 05 03                 ...
        sta     hipos                           ; C660 8D 2C 03                 .,.
@n3:  jsr     changebank12rou                 ; C663 20 74 C2                  t.
        ldx     #$86                            ; C666 A2 86                    ..
        ldy     #$86                            ; C668 A0 86                    ..
        jsr     setfade                         ; C66A 20 11 C5                  ..
        ; intro/game over/completed
        lda     hipos                           ; C66D AD 2C 03                 .,.
        bmi     @n11                           ; C670 30 03                    0.
        jsr     starttune                       ; C672 20 14 F4                  ..
@n11:  jsr     turninteron                     ; C675 20 77 F4                  w.
@n1:  asl     flyflag                         ; C678 06 0B                    ..
@fly:  bit     flyflag                         ; C67A 24 0B                    $.
        bpl     @fly                           ; C67C 10 FC                    ..
        jsr     printscore                      ; C67E 20 09 F5                  ..
        jsr     printhearts                     ; C681 20 DE F5                  ..
        jsr     printlives                      ; C684 20 DE F4                  ..
        lda     completedgame                   ; C687 AD A8 03                 ...
        beq     @n8                           ; C68A F0 14                    ..
        jsr     putextrason                     ; C68C 20 9A CE                  ..
        lda     #$00                            ; C68F A9 00                    ..
        sta     $03AB                           ; C691 8D AB 03                 ...
        jsr     changebank13rou                 ; C694 20 7C C2                  |.
        jsr     b1_updatehearts                 ; C697 20 2D AD                  -.
        jsr     changebank12rou                 ; C69A 20 74 C2                  t.
        jmp     @n6                           ; C69D 4C AE C6                 L..

; ----------------------------------------------------------------------------
@n8:  jsr     changebank13rou                 ; C6A0 20 7C C2                  |.
        jsr     b1_print6treasures              ; C6A3 20 E2 AA                  ..
        ldx     #$09                            ; C6A6 A2 09                    ..
        jsr     b1_pulsecolour                  ; C6A8 20 B3 A1                  ..
        jsr     changebank12rou                 ; C6AB 20 74 C2                  t.
@n6:  lda     pad                             ; C6AE A5 07                    ..
        and     #$10                            ; C6B0 29 10                    ).
        beq     @n1                           ; C6B2 F0 C4                    ..
        lda     debounce                        ; C6B4 A5 08                    ..
        and     #$10                            ; C6B6 29 10                    ).
        bne     @n1                           ; C6B8 D0 BE                    ..
        jmp     turninteroff                    ; C6BA 4C AC F4                 L..

; ----------------------------------------------------------------------------
moveman:lda     killed                          ; C6BD AD 23 03                 .#.
        beq     @n2                           ; C6C0 F0 01                    ..
@n3:  rts                                     ; C6C2 60                       `

; ----------------------------------------------------------------------------
@n2:  lda     juststartedlife                 ; C6C3 AD 2B 03                 .+.
        bne     @n3                           ; C6C6 D0 FA                    ..
        lda     robinxl                         ; C6C8 AD 08 03                 ...
        sta     orobinxl                        ; C6CB 8D 0E 03                 ...
        lda     robinxh                         ; C6CE AD 09 03                 ...
        sta     orobinxh                        ; C6D1 8D 0F 03                 ...
        lda     robiny                          ; C6D4 AD 0A 03                 ...
        sta     orobiny                         ; C6D7 8D 10 03                 ...
        lda     robinjustjumped                 ; C6DA AD 1E 03                 ...
        beq     @n4                           ; C6DD F0 0B                    ..
        lda     pad                             ; C6DF A5 07                    ..
        and     #$80                            ; C6E1 29 80                    ).
        bne     @n4                           ; C6E3 D0 05                    ..
        lda     #$00                            ; C6E5 A9 00                    ..
        sta     robinjustjumped                 ; C6E7 8D 1E 03                 ...
@n4:  lda     robinladdercounter              ; C6EA AD 1B 03                 ...
        beq     @n1                           ; C6ED F0 03                    ..
        dec     robinladdercounter              ; C6EF CE 1B 03                 ...
@n1:  lda     robinladder                     ; C6F2 AD 1A 03                 ...
        beq     notladder                       ; C6F5 F0 03                    ..
        jmp     onladder                        ; C6F7 4C 69 C8                 Li.

; ----------------------------------------------------------------------------
notladder:
        jsr     dofiring                        ; C6FA 20 6F CA                  o.
        jsr     dogravity                       ; C6FD 20 FB CA                  ..
        jsr     docrouchstuff                   ; C700 20 30 CA                  0.
        jsr     checkforladderup                ; C703 20 EF C9                  ..
        lda     robinjumping                    ; C706 AD 17 03                 ...
        beq     robinnotjumping                 ; C709 F0 03                    ..
        jmp     dorobinjumping                  ; C70B 4C A0 CB                 L..

; ----------------------------------------------------------------------------
robinnotjumping:
        jsr     checkleftrightkeys              ; C70E 20 1B C8                  ..
        jsr     addleftright                    ; C711 20 0D CC                  ..
        lda     runcount                        ; C714 AD 11 03                 ...
        bne     @n3                           ; C717 D0 0C                    ..
        lda     robingravity                    ; C719 AD 18 03                 ...
        cmp     #$80                            ; C71C C9 80                    ..
        bne     @n3                           ; C71E D0 05                    ..
        lda     #$FF                            ; C720 A9 FF                    ..
        sta     robinanim                       ; C722 8D 13 03                 ...
@n3:  lda     robincrouch                     ; C725 AD 15 03                 ...
        bne     nottryingtojump                 ; C728 D0 47                    .G
        lda     pad                             ; C72A A5 07                    ..
        and     #$80                            ; C72C 29 80                    ).
        beq     nottryingtojump                 ; C72E F0 41                    .A
        lda     debounce                        ; C730 A5 08                    ..
        and     #$80                            ; C732 29 80                    ).
        bne     nottryingtojump                 ; C734 D0 3B                    .;
        jsr     findroof                        ; C736 20 91 CD                  ..
        beq     nottryingtojump                 ; C739 F0 36                    .6
        inc     robiny                          ; C73B EE 0A 03                 ...
        jsr     findfloor                       ; C73E 20 4A CD                  J.
        php                                     ; C741 08                       .
        dec     robiny                          ; C742 CE 0A 03                 ...
        plp                                     ; C745 28                       (
        beq     nottryingtojump1                ; C746 F0 2F                    ./
jumpingok:
        lda     robinjustjumped                 ; C748 AD 1E 03                 ...
        bne     nottryingtojump                 ; C74B D0 24                    .$
        lda     #$01                            ; C74D A9 01                    ..
        sta     robinjumping                    ; C74F 8D 17 03                 ...
        sta     robinjustjumped                 ; C752 8D 1E 03                 ...
        lda     runcount                        ; C755 AD 11 03                 ...
        lsr     a                               ; C758 4A                       J
        lsr     a                               ; C759 4A                       J
        lsr     a                               ; C75A 4A                       J
        eor     #$FF                            ; C75B 49 FF                    I.
        clc                                     ; C75D 18                       .
        adc     #$F3                            ; C75E 69 F3                    i.
        sta     robingravity                    ; C760 8D 18 03                 ...
        jmp     dorobinjumping                  ; C763 4C A0 CB                 L..

; ----------------------------------------------------------------------------
hitwall:lda     #$00                            ; C766 A9 00                    ..
        sta     robinanim                       ; C768 8D 13 03                 ...
        jsr     restorex                        ; C76B 20 DD CA                  ..
        jmp     doneleftright                   ; C76E 4C 8D C7                 L..

; ----------------------------------------------------------------------------
nottryingtojump:
        lda     pad                             ; C771 A5 07                    ..
        and     #$7F                            ; C773 29 7F                    ).
        sta     pad                             ; C775 85 07                    ..
nottryingtojump1:
        lda     orobinxl                        ; C777 AD 0E 03                 ...
        cmp     robinxl                         ; C77A CD 08 03                 ...
        beq     doneleftright                   ; C77D F0 0E                    ..
        bcc     movingright                     ; C77F 90 07                    ..
        jsr     findwallleft                    ; C781 20 F9 CC                  ..
        bne     hitwall                         ; C784 D0 E0                    ..
        beq     doneleftright                   ; C786 F0 05                    ..
movingright:
        jsr     findwallright                   ; C788 20 3A CD                  :.
        bne     hitwall                         ; C78B D0 D9                    ..
doneleftright:
        jsr     findfloor                       ; C78D 20 4A CD                  J.
        lda     blockfound                      ; C790 AD 02 03                 ...
        sta     robinbehind                     ; C793 8D 1D 03                 ...
        lda     solidfound                      ; C796 A5 43                    .C
        cmp     #$02                            ; C798 C9 02                    ..
        bcc     @n2                           ; C79A 90 16                    ..
        dec     robiny                          ; C79C CE 0A 03                 ...
        inc     riseup                          ; C79F EE 12 05                 ...
        lda     riseup                          ; C7A2 AD 12 05                 ...
        cmp     #$0F                            ; C7A5 C9 0F                    ..
        bne     @n3                           ; C7A7 D0 0E                    ..
        dec     riseup                          ; C7A9 CE 12 05                 ...
        inc     robiny                          ; C7AC EE 0A 03                 ...
        jmp     @n3                           ; C7AF 4C B7 C7                 L..

; ----------------------------------------------------------------------------
@n2:  lda     #$00                            ; C7B2 A9 00                    ..
        sta     riseup                          ; C7B4 8D 12 05                 ...
@n3:  inc     robiny                          ; C7B7 EE 0A 03                 ...
        jsr     findfloor                       ; C7BA 20 4A CD                  J.
        dec     robiny                          ; C7BD CE 0A 03                 ...
        lda     solidfound                      ; C7C0 A5 43                    .C
        cmp     #$01                            ; C7C2 C9 01                    ..
        beq     ontopofladder                   ; C7C4 F0 48                    .H
        cmp     #$02                            ; C7C6 C9 02                    ..
        beq     semifloorfound                  ; C7C8 F0 3C                    .<
        and     #$01                            ; C7CA 29 01                    ).
        bne     floorfound                      ; C7CC D0 32                    .2
fallthru:
        lda     robingravity                    ; C7CE AD 18 03                 ...
        cmp     #$80                            ; C7D1 C9 80                    ..
        bne     @n1                           ; C7D3 D0 2A                    .*
        lda     #$00                            ; C7D5 A9 00                    ..
        sta     robingravity                    ; C7D7 8D 18 03                 ...
        lda     robiny                          ; C7DA AD 0A 03                 ...
        clc                                     ; C7DD 18                       .
        adc     #$06                            ; C7DE 69 06                    i.
        sta     robiny                          ; C7E0 8D 0A 03                 ...
        jsr     findfloor                       ; C7E3 20 4A CD                  J.
        lda     robiny                          ; C7E6 AD 0A 03                 ...
        clc                                     ; C7E9 18                       .
        adc     #$FA                            ; C7EA 69 FA                    i.
        sta     robiny                          ; C7EC 8D 0A 03                 ...
        lda     solidfound                      ; C7EF A5 43                    .C
        and     #$01                            ; C7F1 29 01                    ).
        beq     @n1                           ; C7F3 F0 0A                    ..
        lda     #$01                            ; C7F5 A9 01                    ..
        sta     robinjumping                    ; C7F7 8D 17 03                 ...
        lda     #$08                            ; C7FA A9 08                    ..
        sta     robingravity                    ; C7FC 8D 18 03                 ...
@n1:  rts                                     ; C7FF 60                       `

; ----------------------------------------------------------------------------
floorfound:
        lda     #$80                            ; C800 A9 80                    ..
        sta     robingravity                    ; C802 8D 18 03                 ...
        rts                                     ; C805 60                       `

; ----------------------------------------------------------------------------
semifloorfound:
        lda     robincrouch                     ; C806 AD 15 03                 ...
        bne     fallthru                        ; C809 D0 C3                    ..
        jmp     floorfound                      ; C80B 4C 00 C8                 L..

; ----------------------------------------------------------------------------
ontopofladder:
        lda     robingravity                    ; C80E AD 18 03                 ...
        cmp     #$80                            ; C811 C9 80                    ..
        bne     @n1                           ; C813 D0 05                    ..
        lda     robinjumping                    ; C815 AD 17 03                 ...
        beq     floorfound                      ; C818 F0 E6                    ..
@n1:  rts                                     ; C81A 60                       `

; ----------------------------------------------------------------------------
checkleftrightkeys:
        lda     #$00                            ; C81B A9 00                    ..
        sta     leftright                       ; C81D 8D 0C 03                 ...
        lda     robincrouch                     ; C820 AD 15 03                 ...
        bne     @n2                           ; C823 D0 25                    .%
        lda     pad                             ; C825 A5 07                    ..
        and     #$01                            ; C827 29 01                    ).
        beq     @n1                           ; C829 F0 07                    ..
        lda     #$01                            ; C82B A9 01                    ..
        sta     leftright                       ; C82D 8D 0C 03                 ...
        bne     @n3                           ; C830 D0 0B                    ..
@n1:  lda     pad                             ; C832 A5 07                    ..
        and     #$02                            ; C834 29 02                    ).
        beq     @n2                           ; C836 F0 12                    ..
        lda     #$FF                            ; C838 A9 FF                    ..
        sta     leftright                       ; C83A 8D 0C 03                 ...
@n3:  cmp     oleftright                      ; C83D CD 0D 03                 ...
        beq     @n4                           ; C840 F0 05                    ..
        ldx     #$01                            ; C842 A2 01                    ..
        sta     runcount                        ; C844 8D 11 03                 ...
@n4:  sta     oleftright                      ; C847 8D 0D 03                 ...
@n2:  rts                                     ; C84A 60                       `

; ----------------------------------------------------------------------------
walkoffladder:
        lda     #$80                            ; C84B A9 80                    ..
        bne     restoffladd                     ; C84D D0 0C                    ..
jumpoffladderright:
        lda     #$01                            ; C84F A9 01                    ..
        sta     robinjumping                    ; C851 8D 17 03                 ...
        lda     #$01                            ; C854 A9 01                    ..
        sta     runcount                        ; C856 8D 11 03                 ...
        lda     #$F3                            ; C859 A9 F3                    ..
restoffladd:
        sta     robingravity                    ; C85B 8D 18 03                 ...
        lda     #$00                            ; C85E A9 00                    ..
        sta     robinladder                     ; C860 8D 1A 03                 ...
        lda     #$0C                            ; C863 A9 0C                    ..
        sta     robinladdercounter              ; C865 8D 1B 03                 ...
        rts                                     ; C868 60                       `

; ----------------------------------------------------------------------------
onladder:
        lda     robinxl                         ; C869 AD 08 03                 ...
        and     #$0F                            ; C86C 29 0F                    ).
        cmp     #$08                            ; C86E C9 08                    ..
        beq     @n13                           ; C870 F0 32                    .2
        bcs     @n14                           ; C872 B0 06                    ..
        inc     robinxl                         ; C874 EE 08 03                 ...
        jmp     @bug                           ; C877 4C 7D C8                 L}.

; ----------------------------------------------------------------------------
@n14:  dec     robinxl                         ; C87A CE 08 03                 ...
@bug:  ldy     robiny                          ; C87D AC 0A 03                 ...
        lda     robinxl                         ; C880 AD 08 03                 ...
        ldx     robinxh                         ; C883 AE 09 03                 ...
        jsr     findsolid                       ; C886 20 2B F9                  +.
        cmp     #$01                            ; C889 C9 01                    ..
        beq     @bugok                           ; C88B F0 14                    ..
        lda     robinheight                     ; C88D AD 16 03                 ...
        clc                                     ; C890 18                       .
        adc     #$04                            ; C891 69 04                    i.
        tay                                     ; C893 A8                       .
        lda     robinxl                         ; C894 AD 08 03                 ...
        ldx     robinxh                         ; C897 AE 09 03                 ...
        jsr     findsolid                       ; C89A 20 2B F9                  +.
        cmp     #$01                            ; C89D C9 01                    ..
        bne     walkoffladder                   ; C89F D0 AA                    ..
@bugok:  jmp     onladder_n4                           ; C8A1 4C FF C8                 L..

; doneladdercentering
; ----------------------------------------------------------------------------
@n13:  jsr     checkleftrightkeys              ; C8A4 20 1B C8                  ..
        lda     pad                             ; C8A7 A5 07                    ..
        and     #$02                            ; C8A9 29 02                    ).
        beq     onladder_n3                           ; C8AB F0 2B                    .+
        lda     robinxl                         ; C8AD AD 08 03                 ...
        sec                                     ; C8B0 38                       8
        sbc     #$0E                            ; C8B1 E9 0E                    ..
        sta     temp8                           ; C8B3 85 39                    .9
        lda     robinxh                         ; C8B5 AD 09 03                 ...
        sbc     #$00                            ; C8B8 E9 00                    ..
        jsr     restwall                        ; C8BA 20 06 CD                  ..
        bne     onladder_n3                           ; C8BD D0 19                    ..
        lda     pad                             ; C8BF A5 07                    ..
        and     #$80                            ; C8C1 29 80                    ).
        bne     jumpoffladderright              ; C8C3 D0 8A                    ..
        lda     robiny                          ; C8C5 AD 0A 03                 ...
        clc                                     ; C8C8 18                       .
        adc     #$06                            ; C8C9 69 06                    i.
        tay                                     ; C8CB A8                       .
        lda     temp8                           ; C8CC A5 39                    .9
        ldx     temp9                           ; C8CE A6 3A                    .:
        jsr     findsolid                       ; C8D0 20 2B F9                  +.
        beq     onladder_n3                           ; C8D3 F0 03                    ..
        jmp     walkoffladder                   ; C8D5 4C 4B C8                 LK.

; ----------------------------------------------------------------------------
onladder_n3:  lda     pad                             ; C8D8 A5 07                    ..
        and     #$01                            ; C8DA 29 01                    ).
        beq     onladder_n4                           ; C8DC F0 21                    .!
        jsr     findwallright                   ; C8DE 20 3A CD                  :.
        bne     onladder_n4                           ; C8E1 D0 1C                    ..
        lda     pad                             ; C8E3 A5 07                    ..
        and     #$80                            ; C8E5 29 80                    ).
        beq     @n22                           ; C8E7 F0 03                    ..
        jmp     jumpoffladderright              ; C8E9 4C 4F C8                 LO.

; ----------------------------------------------------------------------------
@n22:  lda     robiny                          ; C8EC AD 0A 03                 ...
        clc                                     ; C8EF 18                       .
        adc     #$06                            ; C8F0 69 06                    i.
        tay                                     ; C8F2 A8                       .
        lda     temp8                           ; C8F3 A5 39                    .9
        ldx     temp9                           ; C8F5 A6 3A                    .:
        jsr     findsolid                       ; C8F7 20 2B F9                  +.
        beq     onladder_n4                           ; C8FA F0 03                    ..
        jmp     walkoffladder                   ; C8FC 4C 4B C8                 LK.

; ----------------------------------------------------------------------------
onladder_n4:  jsr     checkifstillonladderup          ; C8FF 20 6A C9                  j.
        lda     pad                             ; C902 A5 07                    ..
        and     #$04                            ; C904 29 04                    ).
        beq     @n2                           ; C906 F0 06                    ..
        inc     robiny                          ; C908 EE 0A 03                 ...
        jsr     checkifstillonladderdown        ; C90B 20 0F C9                  ..
@n2:  rts                                     ; C90E 60                       `

; ----------------------------------------------------------------------------
checkifstillonladderdown:
        ldy     robiny                          ; C90F AC 0A 03                 ...
        cpy     #$24                            ; C912 C0 24                    .$
        bcc     @n1                           ; C914 90 28                    .(
        iny                                     ; C916 C8                       .
        lda     robinxl                         ; C917 AD 08 03                 ...
        ldx     robinxh                         ; C91A AE 09 03                 ...
        jsr     findsolid                       ; C91D 20 2B F9                  +.
        sta     temp4                           ; C920 85 35                    .5
        cmp     #$01                            ; C922 C9 01                    ..
        beq     @n1                           ; C924 F0 18                    ..
        cmp     #$00                            ; C926 C9 00                    ..
        bne     stepoffladderdown               ; C928 D0 15                    ..
        lda     robinheight                     ; C92A AD 16 03                 ...
        clc                                     ; C92D 18                       .
        adc     #$04                            ; C92E 69 04                    i.
        tay                                     ; C930 A8                       .
        lda     robinxl                         ; C931 AD 08 03                 ...
        ldx     robinxh                         ; C934 AE 09 03                 ...
        jsr     findsolid                       ; C937 20 2B F9                  +.
        cmp     #$01                            ; C93A C9 01                    ..
        bne     stepoffladderdown               ; C93C D0 01                    ..
@n1:  rts                                     ; C93E 60                       `

; ----------------------------------------------------------------------------
stepoffladderdown:
        lda     temp4                           ; C93F A5 35                    .5
        cmp     #$03                            ; C941 C9 03                    ..
        beq     stepoff1                        ; C943 F0 14                    ..
        lda     #$01                            ; C945 A9 01                    ..
        sta     robingravity                    ; C947 8D 18 03                 ...
        sta     robinjumping                    ; C94A 8D 17 03                 ...
        bne     stepoff1                        ; C94D D0 0A                    ..
stepoffladderup:
        lda     #$80                            ; C94F A9 80                    ..
        sta     robingravity                    ; C951 8D 18 03                 ...
        lda     #$00                            ; C954 A9 00                    ..
        sta     robinjumping                    ; C956 8D 17 03                 ...
stepoff1:
        lda     #$00                            ; C959 A9 00                    ..
        sta     robinladder                     ; C95B 8D 1A 03                 ...
        sta     robinlook                       ; C95E 8D 19 03                 ...
        sta     runcount                        ; C961 8D 11 03                 ...
        lda     #$0C                            ; C964 A9 0C                    ..
        sta     robinladdercounter              ; C966 8D 1B 03                 ...
        rts                                     ; C969 60                       `

; ----------------------------------------------------------------------------
checkifstillonladderup:
        lda     robinheight                     ; C96A AD 16 03                 ...
        clc                                     ; C96D 18                       .
        adc     #$04                            ; C96E 69 04                    i.
        tay                                     ; C970 A8                       .
        lda     robinxl                         ; C971 AD 08 03                 ...
        ldx     robinxh                         ; C974 AE 09 03                 ...
        jsr     findsolid                       ; C977 20 2B F9                  +.
        lda     solidfound                      ; C97A A5 43                    .C
        sta     temp5                           ; C97C 85 36                    .6
        cmp     #$01                            ; C97E C9 01                    ..
        beq     @n1                           ; C980 F0 31                    .1
        cmp     #$00                            ; C982 C9 00                    ..
        bne     @n2                           ; C984 D0 36                    .6
        ldy     robiny                          ; C986 AC 0A 03                 ...
        cpy     #$24                            ; C989 C0 24                    .$
        bcc     @n1                           ; C98B 90 26                    .&
        dey                                     ; C98D 88                       .
        dey                                     ; C98E 88                       .
        lda     robinxl                         ; C98F AD 08 03                 ...
        ldx     robinxh                         ; C992 AE 09 03                 ...
        jsr     findsolid                       ; C995 20 2B F9                  +.
        lda     solidfound                      ; C998 A5 43                    .C
        cmp     #$01                            ; C99A C9 01                    ..
        beq     @n1                           ; C99C F0 15                    ..
        cmp     #$00                            ; C99E C9 00                    ..
        bne     stepoffladderup                 ; C9A0 D0 AD                    ..
        lda     temp5                           ; C9A2 A5 36                    .6
        lda     solidfound                      ; C9A4 A5 43                    .C
        cmp     #$01                            ; C9A6 C9 01                    ..
        beq     @n1                           ; C9A8 F0 09                    ..
        dec     robiny                          ; C9AA CE 0A 03                 ...
        dec     robiny                          ; C9AD CE 0A 03                 ...
        jmp     stepoffladderup                 ; C9B0 4C 4F C9                 LO.

; ----------------------------------------------------------------------------
@n1:  lda     pad                             ; C9B3 A5 07                    ..
        and     #$08                            ; C9B5 29 08                    ).
        beq     @n2                           ; C9B7 F0 03                    ..
        dec     robiny                          ; C9B9 CE 0A 03                 ...
@n2:  rts                                     ; C9BC 60                       `

; ----------------------------------------------------------------------------
checkforladderdown:
        lda     robinladdercounter              ; C9BD AD 1B 03                 ...
        bne     @n1                           ; C9C0 D0 22                    ."
        ldy     robiny                          ; C9C2 AC 0A 03                 ...
        iny                                     ; C9C5 C8                       .
        iny                                     ; C9C6 C8                       .
        iny                                     ; C9C7 C8                       .
        iny                                     ; C9C8 C8                       .
        lda     robinxl                         ; C9C9 AD 08 03                 ...
        ldx     robinxh                         ; C9CC AE 09 03                 ...
        jsr     findsolid                       ; C9CF 20 2B F9                  +.
        lda     solidfound                      ; C9D2 A5 43                    .C
        cmp     #$01                            ; C9D4 C9 01                    ..
        bne     @n1                           ; C9D6 D0 0C                    ..
        inc     robiny                          ; C9D8 EE 0A 03                 ...
        inc     robiny                          ; C9DB EE 0A 03                 ...
        inc     robiny                          ; C9DE EE 0A 03                 ...
        jmp     setonladder                     ; C9E1 4C 16 CA                 L..

; ----------------------------------------------------------------------------
@n1:  lda     robinjumping                    ; C9E4 AD 17 03                 ...
        bne     @n2                           ; C9E7 D0 05                    ..
        lda     #$F9                            ; C9E9 A9 F9                    ..
        sta     robincrouch                     ; C9EB 8D 15 03                 ...
@n2:  rts                                     ; C9EE 60                       `

; ----------------------------------------------------------------------------
checkforladderup:
        lda     pad                             ; C9EF A5 07                    ..
        and     #$08                            ; C9F1 29 08                    ).
        beq     checkladupend                   ; C9F3 F0 27                    .'
        lda     robinladdercounter              ; C9F5 AD 1B 03                 ...
        bne     checkladupend                   ; C9F8 D0 22                    ."
        lda     robincrouch                     ; C9FA AD 15 03                 ...
        bne     checkladupend                   ; C9FD D0 1D                    ..
        lda     robinheight                     ; C9FF AD 16 03                 ...
        clc                                     ; CA02 18                       .
        adc     #$04                            ; CA03 69 04                    i.
        tay                                     ; CA05 A8                       .
        lda     robinxl                         ; CA06 AD 08 03                 ...
        ldx     robinxh                         ; CA09 AE 09 03                 ...
        jsr     findsolid                       ; CA0C 20 2B F9                  +.
        cmp     #$01                            ; CA0F C9 01                    ..
        bne     checkladupend                   ; CA11 D0 09                    ..
        dec     robiny                          ; CA13 CE 0A 03                 ...
setonladder:
        jsr     setonladdervars                 ; CA16 20 1D CA                  ..
        jmp     onladder                        ; CA19 4C 69 C8                 Li.

; ----------------------------------------------------------------------------
checkladupend:
        rts                                     ; CA1C 60                       `

; ----------------------------------------------------------------------------
setonladdervars:
        lda     #$00                            ; CA1D A9 00                    ..
        sta     runcount                        ; CA1F 8D 11 03                 ...
        sta     robinjumping                    ; CA22 8D 17 03                 ...
        lda     #$04                            ; CA25 A9 04                    ..
        sta     robinladder                     ; CA27 8D 1A 03                 ...
        lda     #$01                            ; CA2A A9 01                    ..
        sta     robingravity                    ; CA2C 8D 18 03                 ...
        rts                                     ; CA2F 60                       `

; ----------------------------------------------------------------------------
docrouchstuff:
        lda     robinjumping                    ; CA30 AD 17 03                 ...
        bne     @n5                           ; CA33 D0 30                    .0
        lda     robincrouch                     ; CA35 AD 15 03                 ...
        beq     @n5                           ; CA38 F0 2B                    .+
        ldx     robincrouch                     ; CA3A AE 15 03                 ...
        cpx     #$FC                            ; CA3D E0 FC                    ..
        bne     @n6                           ; CA3F D0 06                    ..
        lda     pad                             ; CA41 A5 07                    ..
        and     #$04                            ; CA43 29 04                    ).
        bne     @n4                           ; CA45 D0 27                    .'
@n6:  lda     counter                         ; CA47 A5 10                    ..
        and     #$03                            ; CA49 29 03                    ).
        bne     @n1                           ; CA4B D0 03                    ..
        inc     robincrouch                     ; CA4D EE 15 03                 ...
@n1:  lda     robinheight                     ; CA50 AD 16 03                 ...
        pha                                     ; CA53 48                       H
        lda     robiny                          ; CA54 AD 0A 03                 ...
        clc                                     ; CA57 18                       .
        adc     #$F0                            ; CA58 69 F0                    i.
        sta     robinheight                     ; CA5A 8D 16 03                 ...
        jsr     movebackcrouchedunder           ; CA5D 20 C4 CD                  ..
        pla                                     ; CA60 68                       h
        sta     robinheight                     ; CA61 8D 16 03                 ...
        rts                                     ; CA64 60                       `

; ----------------------------------------------------------------------------
@n5:  lda     pad                             ; CA65 A5 07                    ..
        and     #$04                            ; CA67 29 04                    ).
        beq     @n4                           ; CA69 F0 03                    ..
        jsr     checkforladderdown              ; CA6B 20 BD C9                  ..
@n4:  rts                                     ; CA6E 60                       `

; ----------------------------------------------------------------------------
dofiring:
        lda     robincrouch                     ; CA6F AD 15 03                 ...
        bne     dofiring_n3                           ; CA72 D0 2D                    .-
        lda     robinfiring                     ; CA74 AD 14 03                 ...
        bne     dofiring_n1                           ; CA77 D0 0C                    ..
        lda     pad                             ; CA79 A5 07                    ..
        and     #$40                            ; CA7B 29 40                    )@
        beq     dofiring_n3                           ; CA7D F0 22                    ."
        lda     #$27                            ; CA7F A9 27                    .'
        sta     robinfiring                     ; CA81 8D 14 03                 ...
        rts                                     ; CA84 60                       `

; ----------------------------------------------------------------------------
dofiring_n1:  cmp     #$0C                            ; CA85 C9 0C                    ..
        bne     dofiring_n4                           ; CA87 D0 06                    ..
        lda     pad                             ; CA89 A5 07                    ..
dofiring_n2:  and     #$40                            ; CA8B 29 40                    )@
        bne     dofiring_n3                           ; CA8D D0 12                    ..
dofiring_n4:  dec     robinfiring                     ; CA8F CE 14 03                 ...
        lda     robinfiring                     ; CA92 AD 14 03                 ...
        cmp     #$0B                            ; CA95 C9 0B                    ..
        bne     dofiring_n3                           ; CA97 D0 08                    ..
        jsr     robinshootarrow                 ; CA99 20 F4 D5                  ..
        lda     #$0B                            ; CA9C A9 0B                    ..
        jsr     soundfx                         ; CA9E 20 28 F4                  (.
dofiring_n3:  rts                                     ; CAA1 60                       `

; ----------------------------------------------------------------------------
animatelegs:
        lda     robinjumping                    ; CAA2 AD 17 03                 ...
        bne     @n5                           ; CAA5 D0 21                    .!
        lda     orobinxl                        ; CAA7 AD 0E 03                 ...
        lsr     a                               ; CAAA 4A                       J
        lsr     a                               ; CAAB 4A                       J
        sta     temp                            ; CAAC 85 31                    .1
        lda     robinxl                         ; CAAE AD 08 03                 ...
        lsr     a                               ; CAB1 4A                       J
        lsr     a                               ; CAB2 4A                       J
        cmp     temp                            ; CAB3 C5 31                    .1
        beq     @n4                           ; CAB5 F0 10                    ..
        and     #$01                            ; CAB7 29 01                    ).
        bne     @n4                           ; CAB9 D0 0C                    ..
        inc     robinanim                       ; CABB EE 13 03                 ...
        lda     robinanim                       ; CABE AD 13 03                 ...
        and     #$07                            ; CAC1 29 07                    ).
        tax                                     ; CAC3 AA                       .
        stx     robinanim                       ; CAC4 8E 13 03                 ...
@n4:  rts                                     ; CAC7 60                       `

; ----------------------------------------------------------------------------
@n5:  ldx     #$02                            ; CAC8 A2 02                    ..
        lda     runcount                        ; CACA AD 11 03                 ...
        cmp     #$09                            ; CACD C9 09                    ..
        bcc     @n1                           ; CACF 90 08                    ..
        ldx     #$01                            ; CAD1 A2 01                    ..
        cmp     #$18                            ; CAD3 C9 18                    ..
        bcc     @n1                           ; CAD5 90 02                    ..
        ldx     #$0C                            ; CAD7 A2 0C                    ..
@n1:  stx     robinanim                       ; CAD9 8E 13 03                 ...
        rts                                     ; CADC 60                       `

; ----------------------------------------------------------------------------
restorex:
        lda     #$00                            ; CADD A9 00                    ..
        sta     leftright                       ; CADF 8D 0C 03                 ...
restorex1:
        lda     runcount                        ; CAE2 AD 11 03                 ...
        cmp     #$01                            ; CAE5 C9 01                    ..
        bcc     @n1                           ; CAE7 90 05                    ..
        lda     #$01                            ; CAE9 A9 01                    ..
        sta     runcount                        ; CAEB 8D 11 03                 ...
@n1:  lda     orobinxl                        ; CAEE AD 0E 03                 ...
        sta     robinxl                         ; CAF1 8D 08 03                 ...
        lda     orobinxh                        ; CAF4 AD 0F 03                 ...
        sta     robinxh                         ; CAF7 8D 09 03                 ...
        rts                                     ; CAFA 60                       `

; ----------------------------------------------------------------------------
dogravity:
        lda     robingravity                    ; CAFB AD 18 03                 ...
        cmp     #$80                            ; CAFE C9 80                    ..
        bne     @n9                           ; CB00 D0 01                    ..
        rts                                     ; CB02 60                       `

; ----------------------------------------------------------------------------
@n9:  lda     robingravity                    ; CB03 AD 18 03                 ...
        bmi     @n4                           ; CB06 30 04                    0.
        cmp     #$18                            ; CB08 C9 18                    ..
        bcs     @n3                           ; CB0A B0 03                    ..
@n4:  inc     robingravity                    ; CB0C EE 18 03                 ...
@n3:  lda     robingravity                    ; CB0F AD 18 03                 ...
        sta     temp                            ; CB12 85 31                    .1
        asl     temp                            ; CB14 06 31                    .1
        ror     a                               ; CB16 6A                       j
        asl     temp                            ; CB17 06 31                    .1
        ror     a                               ; CB19 6A                       j
        clc                                     ; CB1A 18                       .
        adc     robiny                          ; CB1B 6D 0A 03                 m..
        sta     robiny                          ; CB1E 8D 0A 03                 ...
        lda     robingravity                    ; CB21 AD 18 03                 ...
        bmi     @n1                           ; CB24 30 79                    0y
        lda     #$02                            ; CB26 A9 02                    ..
        ldx     robincrouch                     ; CB28 AE 15 03                 ...
        beq     @n10                           ; CB2B F0 02                    ..
        lda     #$03                            ; CB2D A9 03                    ..
@n10:  sta     temp5                           ; CB2F 85 36                    .6
        jsr     findfloor                       ; CB31 20 4A CD                  J.
        lda     blockfound                      ; CB34 AD 02 03                 ...
        sta     robinbehind                     ; CB37 8D 1D 03                 ...
        lda     solidfound                      ; CB3A A5 43                    .C
        cmp     temp5                           ; CB3C C5 36                    .6
        bcc     @n1                           ; CB3E 90 5F                    ._
        lda     robiny                          ; CB40 AD 0A 03                 ...
        clc                                     ; CB43 18                       .
        adc     #$F8                            ; CB44 69 F8                    i.
        sta     robiny                          ; CB46 8D 0A 03                 ...
        jsr     findfloor                       ; CB49 20 4A CD                  J.
        php                                     ; CB4C 08                       .
        lda     robiny                          ; CB4D AD 0A 03                 ...
        clc                                     ; CB50 18                       .
        adc     #$08                            ; CB51 69 08                    i.
        sta     robiny                          ; CB53 8D 0A 03                 ...
        plp                                     ; CB56 28                       (
        beq     @n2                           ; CB57 F0 06                    ..
        jsr     restorex1                       ; CB59 20 E2 CA                  ..
        jmp     @n6                           ; CB5C 4C 81 CB                 L..

; ----------------------------------------------------------------------------
@n2:  dec     robiny                          ; CB5F CE 0A 03                 ...
        jsr     findfloor                       ; CB62 20 4A CD                  J.
        beq     @n6                           ; CB65 F0 1A                    ..
        lda     leftright                       ; CB67 AD 0C 03                 ...
        beq     @n2                           ; CB6A F0 F3                    ..
        bmi     @n7                           ; CB6C 30 08                    0.
        jsr     findwallright                   ; CB6E 20 3A CD                  :.
        beq     @n2                           ; CB71 F0 EC                    ..
        jmp     @n8                           ; CB73 4C 7B CB                 L{.

; ----------------------------------------------------------------------------
@n7:  jsr     findwallleft                    ; CB76 20 F9 CC                  ..
        beq     @n2                           ; CB79 F0 E4                    ..
@n8:  jsr     restorex1                       ; CB7B 20 E2 CA                  ..
        jmp     @n2                           ; CB7E 4C 5F CB                 L_.

; ----------------------------------------------------------------------------
@n6:  lda     #$00                            ; CB81 A9 00                    ..
        sta     robinjumping                    ; CB83 8D 17 03                 ...
        lda     pad                             ; CB86 A5 07                    ..
        and     #$FB                            ; CB88 29 FB                    ).
        sta     pad                             ; CB8A 85 07                    ..
        lda     robingravity                    ; CB8C AD 18 03                 ...
        bmi     @n5                           ; CB8F 30 09                    0.
        cmp     #$16                            ; CB91 C9 16                    ..
        bcc     @n5                           ; CB93 90 05                    ..
        lda     #$F9                            ; CB95 A9 F9                    ..
        sta     robincrouch                     ; CB97 8D 15 03                 ...
@n5:  lda     #$80                            ; CB9A A9 80                    ..
        sta     robingravity                    ; CB9C 8D 18 03                 ...
@n1:  rts                                     ; CB9F 60                       `

; ----------------------------------------------------------------------------
dorobinjumping:
        lda     robingravity                    ; CBA0 AD 18 03                 ...
        cmp     #$80                            ; CBA3 C9 80                    ..
        bne     @bugwashere                           ; CBA5 D0 05                    ..
        lda     #$00                            ; CBA7 A9 00                    ..
        sta     robingravity                    ; CBA9 8D 18 03                 ...
@bugwashere:  lda     robincrouch                     ; CBAC AD 15 03                 ...
        beq     @n3                           ; CBAF F0 04                    ..
        inc     robincrouch                     ; CBB1 EE 15 03                 ...
        rts                                     ; CBB4 60                       `

; ----------------------------------------------------------------------------
@n3:  jsr     addleftright                    ; CBB5 20 0D CC                  ..
        bit     robingravity                    ; CBB8 2C 18 03                 ,..
        bpl     @n1                           ; CBBB 10 1F                    ..
        lda     robinbehind                     ; CBBD AD 1D 03                 ...
        beq     @n2                           ; CBC0 F0 0F                    ..
        ldy     robiny                          ; CBC2 AC 0A 03                 ...
        ldx     robinxh                         ; CBC5 AE 09 03                 ...
        lda     robinxl                         ; CBC8 AD 08 03                 ...
        jsr     findblock                       ; CBCB 20 72 F9                  r.
        sta     robinbehind                     ; CBCE 8D 1D 03                 ...
@n2:  jsr     findroof                        ; CBD1 20 91 CD                  ..
        bne     @n1                           ; CBD4 D0 06                    ..
        lda     orobiny                         ; CBD6 AD 10 03                 ...
        sta     robiny                          ; CBD9 8D 0A 03                 ...
; check if hit wall while jumping
@n1:  lda     runcount                        ; CBDC AD 11 03                 ...
        beq     notjumpingleftorright           ; CBDF F0 2B                    .+
        lda     leftright                       ; CBE1 AD 0C 03                 ...
        bpl     jumpingright                    ; CBE4 10 10                    ..
        jsr     findwallleft                    ; CBE6 20 F9 CC                  ..
        beq     notjumpingleftorright           ; CBE9 F0 21                    .!
        lda     orobinxl                        ; CBEB AD 0E 03                 ...
        and     #$F8                            ; CBEE 29 F8                    ).
        sta     orobinxl                        ; CBF0 8D 0E 03                 ...
        jmp     restorex1                       ; CBF3 4C E2 CA                 L..

; ----------------------------------------------------------------------------
jumpingright:
        jsr     findwallright                   ; CBF6 20 3A CD                  :.
        beq     notjumpingleftorright           ; CBF9 F0 11                    ..
        lda     orobinxl                        ; CBFB AD 0E 03                 ...
        sec                                     ; CBFE 38                       8
        sbc     #$01                            ; CBFF E9 01                    ..
        and     #$F8                            ; CC01 29 F8                    ).
        clc                                     ; CC03 18                       .
        adc     #$07                            ; CC04 69 07                    i.
        sta     orobinxl                        ; CC06 8D 0E 03                 ...
        jmp     restorex1                       ; CC09 4C E2 CA                 L..

; ----------------------------------------------------------------------------
notjumpingleftorright:
        rts                                     ; CC0C 60                       `

; ----------------------------------------------------------------------------
addleftright:
        lda     robinjumping                    ; CC0D AD 17 03                 ...
        bne     restleftright                   ; CC10 D0 35                    .5
addleftright1:
        lda     leftright                       ; CC12 AD 0C 03                 ...
        beq     @n2                           ; CC15 F0 17                    ..
        cmp     oleftright                      ; CC17 CD 0D 03                 ...
        bne     @n2                           ; CC1A D0 12                    ..
        inc     runcount                        ; CC1C EE 11 03                 ...
        lda     runcount                        ; CC1F AD 11 03                 ...
        cmp     #$30                            ; CC22 C9 30                    .0
        bne     restleftright                   ; CC24 D0 21                    .!
        lda     #$2F                            ; CC26 A9 2F                    ./
        sta     runcount                        ; CC28 8D 11 03                 ...
        jmp     restleftright                   ; CC2B 4C 47 CC                 LG.

; ----------------------------------------------------------------------------
@n2:  lda     runcount                        ; CC2E AD 11 03                 ...
        beq     restleftright                   ; CC31 F0 14                    ..
        lda     robincrouch                     ; CC33 AD 15 03                 ...
        bne     @n8                           ; CC36 D0 06                    ..
        lsr     runcount                        ; CC38 4E 11 03                 N..
        jmp     restleftright                   ; CC3B 4C 47 CC                 LG.

; ----------------------------------------------------------------------------
@n8:  lda     counter                         ; CC3E A5 10                    ..
        and     #$03                            ; CC40 29 03                    ).
        beq     restleftright                   ; CC42 F0 03                    ..
        dec     runcount                        ; CC44 CE 11 03                 ...
restleftright:
        ldx     runcount                        ; CC47 AE 11 03                 ...
        bne     @n11                           ; CC4A D0 01                    ..
        rts                                     ; CC4C 60                       `

; ----------------------------------------------------------------------------
@n11:  ldy     #$01                            ; CC4D A0 01                    ..
        cpx     #$2F                            ; CC4F E0 2F                    ./
        bne     @n9                           ; CC51 D0 01                    ..
        iny                                     ; CC53 C8                       .
@n9:  lda     oleftright                      ; CC54 AD 0D 03                 ...
        bmi     @n4                           ; CC57 30 17                    0.
        lda     runtablelo,x                    ; CC59 BD C9 CC                 ...
        clc                                     ; CC5C 18                       .
        adc     robindx                         ; CC5D 6D 07 03                 m..
        sta     robindx                         ; CC60 8D 07 03                 ...
        tya                                     ; CC63 98                       .
        adc     robinxl                         ; CC64 6D 08 03                 m..
        sta     robinxl                         ; CC67 8D 08 03                 ...
        bcc     @n5                           ; CC6A 90 03                    ..
        inc     robinxh                         ; CC6C EE 09 03                 ...
@n5:  rts                                     ; CC6F 60                       `

; ----------------------------------------------------------------------------
@n4:  sty     temp                            ; CC70 84 31                    .1
        lda     robindx                         ; CC72 AD 07 03                 ...
        sec                                     ; CC75 38                       8
        sbc     runtablelo,x                    ; CC76 FD C9 CC                 ...
        sta     robindx                         ; CC79 8D 07 03                 ...
        lda     robinxl                         ; CC7C AD 08 03                 ...
        sbc     temp                            ; CC7F E5 31                    .1
        sta     robinxl                         ; CC81 8D 08 03                 ...
        bcs     @n8b                           ; CC84 B0 04                    ..
        dec     robinxh                         ; CC86 CE 09 03                 ...
        rts                                     ; CC89 60                       `

; ----------------------------------------------------------------------------
@n8b:  lda     robinxh                         ; CC8A AD 09 03                 ...
        bne     @n7                           ; CC8D D0 39                    .9
        lda     #$0C                            ; CC8F A9 0C                    ..
        cmp     robinxl                         ; CC91 CD 08 03                 ...
        bcc     @n7                           ; CC94 90 32                    .2
        lda     mapno                           ; CC96 A5 42                    .B
        cmp     #$05                            ; CC98 C9 05                    ..
        bne     @n17                           ; CC9A D0 29                    .)
        lda     #$05                            ; CC9C A9 05                    ..
        sta     mapno                           ; CC9E 85 42                    .B
        lda     #$F4                            ; CCA0 A9 F4                    ..
        sta     robiny                          ; CCA2 8D 0A 03                 ...
        lda     #$08                            ; CCA5 A9 08                    ..
        sta     scrxh                           ; CCA7 85 3C                    .<
        sta     robinxh                         ; CCA9 8D 09 03                 ...
        sta     orobinxh                        ; CCAC 8D 0F 03                 ...
        lda     #$78                            ; CCAF A9 78                    .x
        sta     robinxl                         ; CCB1 8D 08 03                 ...
        sta     orobinxl                        ; CCB4 8D 0E 03                 ...
        lda     #$00                            ; CCB7 A9 00                    ..
        sta     scrxl                           ; CCB9 85 3B                    .;
        sta     treasures                       ; CCBB 8D 2E 03                 ...
        sta     $032F                           ; CCBE 8D 2F 03                 ./.
        sta     $0330                           ; CCC1 8D 30 03                 .0.
        rts                                     ; CCC4 60                       `

; ----------------------------------------------------------------------------
@n17:  jmp     restorex                        ; CCC5 4C DD CA                 L..

; ----------------------------------------------------------------------------
@n7:  rts                                     ; CCC8 60                       `

; ----------------------------------------------------------------------------
runtablelo:
; runtablelo — acceleration ramp: 47 entries of i * 5 (= 256/48), plus trailing 0
.repeat 47, i
    .byte (i * 5) & $FF
.endrepeat
    .byte $00
; ----------------------------------------------------------------------------
findwallleft:
        lda     robinxl                         ; CCF9 AD 08 03                 ...
        sec                                     ; CCFC 38                       8
        sbc     #$09                            ; CCFD E9 09                    ..
        sta     temp8                           ; CCFF 85 39                    .9
        lda     robinxh                         ; CD01 AD 09 03                 ...
        sbc     #$00                            ; CD04 E9 00                    ..
restwall:
        tax                                     ; CD06 AA                       .
        stx     temp9                           ; CD07 86 3A                    .:
        lda     robiny                          ; CD09 AD 0A 03                 ...
        sec                                     ; CD0C 38                       8
        sbc     #$06                            ; CD0D E9 06                    ..
        clc                                     ; CD0F 18                       .
        adc     robinladder                     ; CD10 6D 1A 03                 m..
        tay                                     ; CD13 A8                       .
        lda     temp8                           ; CD14 A5 39                    .9
        jsr     findsolid                       ; CD16 20 2B F9                  +.
        cmp     #$03                            ; CD19 C9 03                    ..
        beq     restwall_n2                           ; CD1B F0 17                    ..
        lda     robincrouch                     ; CD1D AD 15 03                 ...
        bne     restwall_n3                           ; CD20 D0 15                    ..
        ldx     temp9                           ; CD22 A6 3A                    .:
        lda     robiny                          ; CD24 AD 0A 03                 ...
        sec                                     ; CD27 38                       8
        sbc     #$15                            ; CD28 E9 15                    ..
        tay                                     ; CD2A A8                       .
        lda     temp8                           ; CD2B A5 39                    .9
        jsr     findsolid                       ; CD2D 20 2B F9                  +.
        cmp     #$03                            ; CD30 C9 03                    ..
        bne     restwall_n3                           ; CD32 D0 03                    ..
restwall_n2:  lda     #$01                            ; CD34 A9 01                    ..
        rts                                     ; CD36 60                       `

; ----------------------------------------------------------------------------
restwall_n3:  lda     #$00                            ; CD37 A9 00                    ..
        rts                                     ; CD39 60                       `

; ----------------------------------------------------------------------------
findwallright:
        lda     robinxl                         ; CD3A AD 08 03                 ...
        clc                                     ; CD3D 18                       .
        adc     #$09                            ; CD3E 69 09                    i.
        sta     temp8                           ; CD40 85 39                    .9
        lda     robinxh                         ; CD42 AD 09 03                 ...
        adc     #$00                            ; CD45 69 00                    i.
        jmp     restwall                        ; CD47 4C 06 CD                 L..

; ----------------------------------------------------------------------------
findfloor:
        ldy     robiny                          ; CD4A AC 0A 03                 ...
        ldx     robinxh                         ; CD4D AE 09 03                 ...
        lda     robinxl                         ; CD50 AD 08 03                 ...
        sec                                     ; CD53 38                       8
        sbc     #$04                            ; CD54 E9 04                    ..
        bcs     @n3                           ; CD56 B0 01                    ..
        dex                                     ; CD58 CA                       .
@n3:  jsr     findsolid                       ; CD59 20 2B F9                  +.
        lda     solidfound                      ; CD5C A5 43                    .C
        sta     temp9                           ; CD5E 85 3A                    .:
        ldy     robiny                          ; CD60 AC 0A 03                 ...
        ldx     robinxh                         ; CD63 AE 09 03                 ...
        lda     robinxl                         ; CD66 AD 08 03                 ...
        clc                                     ; CD69 18                       .
        adc     #$04                            ; CD6A 69 04                    i.
        bcc     @n4                           ; CD6C 90 01                    ..
        inx                                     ; CD6E E8                       .
@n4:  jsr     findsolid                       ; CD6F 20 2B F9                  +.
        lda     temp9                           ; CD72 A5 3A                    .:
        cmp     solidfound                      ; CD74 C5 43                    .C
        bcs     @n6                           ; CD76 B0 02                    ..
        lda     solidfound                      ; CD78 A5 43                    .C
@n6:  sta     solidfound                      ; CD7A 85 43                    .C
        and     #$02                            ; CD7C 29 02                    ).
        bne     @n1                           ; CD7E D0 10                    ..
        lda     robinjumping                    ; CD80 AD 17 03                 ...
        bne     @n2                           ; CD83 D0 09                    ..
        ; check for ladder
        lda     solidfound                      ; CD85 A5 43                    .C
        cmp     #$01                            ; CD87 C9 01                    ..
        bne     @n2                           ; CD89 D0 03                    ..
        lda     #$01                            ; CD8B A9 01                    ..
        rts                                     ; CD8D 60                       `

; ----------------------------------------------------------------------------
@n2:  lda     #$00                            ; CD8E A9 00                    ..
@n1:  rts                                     ; CD90 60                       `

; ----------------------------------------------------------------------------
findroof:
        lda     #$FB                            ; CD91 A9 FB                    ..
        jsr     findroofleft                    ; CD93 20 9E CD                  ..
        beq     @n2                           ; CD96 F0 05                    ..
        lda     #$05                            ; CD98 A9 05                    ..
        jmp     findroofright                   ; CD9A 4C B1 CD                 L..

; ----------------------------------------------------------------------------
@n2:  rts                                     ; CD9D 60                       `

; ----------------------------------------------------------------------------
findroofleft:
        clc                                     ; CD9E 18                       .
        adc     robinxl                         ; CD9F 6D 08 03                 m..
        ldy     robinheight                     ; CDA2 AC 16 03                 ...
        ldx     robinxh                         ; CDA5 AE 09 03                 ...
        bcs     @n1                           ; CDA8 B0 01                    ..
        dex                                     ; CDAA CA                       .
@n1:  jsr     findsolid                       ; CDAB 20 2B F9                  +.
        cmp     #$03                            ; CDAE C9 03                    ..
        rts                                     ; CDB0 60                       `

; ----------------------------------------------------------------------------
findroofright:
        clc                                     ; CDB1 18                       .
        adc     robinxl                         ; CDB2 6D 08 03                 m..
        ldy     robinheight                     ; CDB5 AC 16 03                 ...
        ldx     robinxh                         ; CDB8 AE 09 03                 ...
        bcc     @n2                           ; CDBB 90 01                    ..
        inx                                     ; CDBD E8                       .
@n2:  jsr     findsolid                       ; CDBE 20 2B F9                  +.
        cmp     #$03                            ; CDC1 C9 03                    ..
        rts                                     ; CDC3 60                       `

; ----------------------------------------------------------------------------
movebackcrouchedunder:
        lda     robincrouch                     ; CDC4 AD 15 03                 ...
        cmp     #$FC                            ; CDC7 C9 FC                    ..
        bcc     endcrouch                       ; CDC9 90 6B                    .k
        bit     oleftright                      ; CDCB 2C 0D 03                 ,..
        bmi     slidingneg                      ; CDCE 30 32                    02
        lda     #$06                            ; CDD0 A9 06                    ..
        jsr     findroofright                   ; CDD2 20 B1 CD                  ..
        beq     slidebackright                  ; CDD5 F0 19                    ..
        lda     #$FA                            ; CDD7 A9 FA                    ..
        jsr     findroofleft                    ; CDD9 20 9E CD                  ..
        bne     @n2                           ; CDDC D0 0B                    ..
        inc     robinxl                         ; CDDE EE 08 03                 ...
        bne     @n1                           ; CDE1 D0 03                    ..
        inc     robinxh                         ; CDE3 EE 09 03                 ...
@n1:  jmp     setcrouch                       ; CDE6 4C 31 CE                 L1.

; ----------------------------------------------------------------------------
@n2:  lda     #$06                            ; CDE9 A9 06                    ..
        jsr     findroofright                   ; CDEB 20 B1 CD                  ..
        bne     endcrouch                       ; CDEE D0 46                    .F
slidebackright:
        dec     robinxl                         ; CDF0 CE 08 03                 ...
        pha                                     ; CDF3 48                       H
        lda     #$FF                            ; CDF4 A9 FF                    ..
        cmp     robinxl                         ; CDF6 CD 08 03                 ...
        bne     @n3                           ; CDF9 D0 03                    ..
        dec     robinxh                         ; CDFB CE 09 03                 ...
@n3:  pla                                     ; CDFE 68                       h
        jmp     setcrouch                       ; CDFF 4C 31 CE                 L1.

; ----------------------------------------------------------------------------
slidingneg:
        lda     #$FA                            ; CE02 A9 FA                    ..
        jsr     findroofleft                    ; CE04 20 9E CD                  ..
        beq     slidebackleft                   ; CE07 F0 20                    . 
        lda     #$06                            ; CE09 A9 06                    ..
        jsr     findroofright                   ; CE0B 20 B1 CD                  ..
        bne     @n5                           ; CE0E D0 12                    ..
        dec     robinxl                         ; CE10 CE 08 03                 ...
        pha                                     ; CE13 48                       H
        lda     #$FF                            ; CE14 A9 FF                    ..
        cmp     robinxl                         ; CE16 CD 08 03                 ...
        bne     @n4                           ; CE19 D0 03                    ..
        dec     robinxh                         ; CE1B CE 09 03                 ...
@n4:  pla                                     ; CE1E 68                       h
        jmp     setcrouch                       ; CE1F 4C 31 CE                 L1.

; ----------------------------------------------------------------------------
@n5:  lda     #$FA                            ; CE22 A9 FA                    ..
        jsr     findroofleft                    ; CE24 20 9E CD                  ..
        bne     endcrouch                       ; CE27 D0 0D                    ..
slidebackleft:
        inc     robinxl                         ; CE29 EE 08 03                 ...
        bne     setcrouch                       ; CE2C D0 03                    ..
        inc     robinxh                         ; CE2E EE 09 03                 ...
setcrouch:
        lda     #$FC                            ; CE31 A9 FC                    ..
        sta     robincrouch                     ; CE33 8D 15 03                 ...
endcrouch:
        rts                                     ; CE36 60                       `

; ----------------------------------------------------------------------------
storeoutoldrobin:
        lda     robinladder                     ; CE37 AD 1A 03                 ...
        sta     oldladder                       ; CE3A 8D 22 03                 .".
        lda     robinxl                         ; CE3D AD 08 03                 ...
        sta     oldxl                           ; CE40 8D 1F 03                 ...
        lda     robinxh                         ; CE43 AD 09 03                 ...
        sta     oldxh                           ; CE46 8D 20 03                 . .
        lda     robiny                          ; CE49 AD 0A 03                 ...
        sta     oldy                            ; CE4C 8D 21 03                 .!.
dontstoreold:
        rts                                     ; CE4F 60                       `

; ----------------------------------------------------------------------------
restoreoldrobin:
        lda     oldladder                       ; CE50 AD 22 03                 .".
        sta     robinladder                     ; CE53 8D 1A 03                 ...
        lda     oldxl                           ; CE56 AD 1F 03                 ...
        sta     robinxl                         ; CE59 8D 08 03                 ...
        lda     oldxh                           ; CE5C AD 20 03                 . .
        sta     robinxh                         ; CE5F 8D 09 03                 ...
        lda     oldy                            ; CE62 AD 21 03                 .!.
        sta     robiny                          ; CE65 8D 0A 03                 ...
        lda     #$80                            ; CE68 A9 80                    ..
        sta     robingravity                    ; CE6A 8D 18 03                 ...
        rts                                     ; CE6D 60                       `

; ----------------------------------------------------------------------------
checkrobinbehind:
        ldx     #$00                            ; CE6E A2 00                    ..
        lda     robinbehind                     ; CE70 AD 1D 03                 ...
        cmp     #$F8                            ; CE73 C9 F8                    ..
        bcs     @n2                           ; CE75 B0 1F                    ..
        cmp     #$F4                            ; CE77 C9 F4                    ..
        bcc     @n2                           ; CE79 90 1B                    ..
        beq     @n1                           ; CE7B F0 0D                    ..
        lda     #$00                            ; CE7D A9 00                    ..
        sta     robininvinc                     ; CE7F 8D 1C 03                 ...
        sta     killed                          ; CE82 8D 23 03                 .#.
        lda     #$03                            ; CE85 A9 03                    ..
        ; stepped in lava
        jsr     subfromhearts1                  ; CE87 20 9D F5                  ..
@n1:  lda     runcount                        ; CE8A AD 11 03                 ...
        beq     @n4                           ; CE8D F0 05                    ..
        lda     #$01                            ; CE8F A9 01                    ..
        sta     runcount                        ; CE91 8D 11 03                 ...
@n4:  ldx     #$20                            ; CE94 A2 20                    . 
@n2:  stx     a:$66                           ; CE96 8E 66 00                 .f.
        rts                                     ; CE99 60                       `

; ----------------------------------------------------------------------------
; ==========================================================================
; XTRACONT.ROU
; ==========================================================================
putextrason:
        lda     #$00                            ; CE9A A9 00                    ..
        sta     extravarpointer                 ; CE9C 85 4C                    .L
        lda     mapno                           ; CE9E A5 42                    .B
        asl     a                               ; CEA0 0A                       .
        tax                                     ; CEA1 AA                       .
        lda     maprouspointer,x                ; CEA2 BD FA CE                 ...
        sta     address9                        ; CEA5 85 2D                    .-
        lda     maprouspointer_hi,x                         ; CEA7 BD FB CE                 ...
        sta     $2E                             ; CEAA 85 2E                    ..
anotherrou:
        ldy     #$00                            ; CEAC A0 00                    ..
        lda     (address9),y                    ; CEAE B1 2D                    .-
        asl     a                               ; CEB0 0A                       .
        tax                                     ; CEB1 AA                       .
        lda     routinepointers,x               ; CEB2 BD 14 CF                 ...
        sta     address8                        ; CEB5 85 2B                    .+
        lda     routinepointers_hi,x                         ; CEB7 BD 15 CF                 ...
        sta     $2C                             ; CEBA 85 2C                    .,
        iny                                     ; CEBC C8                       .
        lda     (address9),y                    ; CEBD B1 2D                    .-
        sta     noofparas                       ; CEBF 85 4B                    .K
        iny                                     ; CEC1 C8                       .
        ldx     extravarpointer                 ; CEC2 A6 4C                    .L
        jmp     (address8)                      ; CEC4 6C 2B 00                 l+.

; ----------------------------------------------------------------------------
backfromrou:
        clc                                     ; CEC7 18                       .
        adc     extravarpointer                 ; CEC8 65 4C                    eL
        sta     extravarpointer                 ; CECA 85 4C                    .L
backfromrounovars:
        lda     noofparas                       ; CECC A5 4B                    .K
        clc                                     ; CECE 18                       .
        adc     address9                        ; CECF 65 2D                    e-
        sta     address9                        ; CED1 85 2D                    .-
        bcc     @n1                           ; CED3 90 02                    ..
        inc     $2E                             ; CED5 E6 2E                    ..
@n1:  jmp     anotherrou                      ; CED7 4C AC CE                 L..

; ----------------------------------------------------------------------------
endofrous:
        cpx     #$80                            ; CEDA E0 80                    ..
        bcc     endofrous_n4                           ; CEDC 90 1B                    ..
        jsr     turninteron                     ; CEDE 20 77 F4                  w.
endofrous_n1:  php                                     ; CEE1 08                       .
        pha                                     ; CEE2 48                       H
        lda     control1                        ; CEE3 A5 02                    ..
        and     #$1E                            ; CEE5 29 1E                    ).
        clc                                     ; CEE7 18                       .
        adc     #$01                            ; CEE8 69 01                    i.
        sta     _control1                       ; CEEA 8D 01 20                 .. 
        pla                                     ; CEED 68                       h
        plp                                     ; CEEE 28                       (
        lda     control1                        ; CEEF A5 02                    ..
        and     #$1E                            ; CEF1 29 1E                    ).
        sta     _control1                       ; CEF3 8D 01 20                 .. 
        jmp     endofrous_n1                           ; CEF6 4C E1 CE                 L..

; ----------------------------------------------------------------------------
endofrous_n4:  rts                                     ; CEF9 60                       `

; ----------------------------------------------------------------------------
maprouspointer:
        .byte   $28                             ; CEFA 28                       (
maprouspointer_hi:  .byte   $CF,$89,$CF,$C2,$CF,$DA,$CF,$28 ; CEFB CF 89 CF C2 CF DA CF 28  .......(
        .byte   $D0,$F1,$D0,$98,$D1,$1D,$D2,$08 ; CF03 D0 F1 D0 98 D1 1D D2 08  ........
        .byte   $D3,$2F,$D3,$55,$D3,$70,$D3,$87 ; CF0B D3 2F D3 55 D3 70 D3 87  ./.U.p..
        .byte   $D3                             ; CF13 D3                       .
routinepointers:
        .byte   $DA                             ; CF14 DA                       .
routinepointers_hi:  .byte   $CE,$BC,$D7,$FC,$D7,$40,$D9,$50 ; CF15 CE BC D7 FC D7 40 D9 50  .....@.P
        .byte   $DA,$BF,$DA,$CC,$DB,$19,$DC,$B8 ; CF1D DA BF DA CC DB 19 DC B8  ........
        .byte   $DC,$06,$DE,$05,$06,$15,$25,$38 ; CF25 DC 06 DE 05 06 15 25 38  ......%8
        .byte   $F9,$06,$06,$04,$30,$03,$19,$03 ; CF2D F9 06 06 04 30 03 19 03  ....0...
        .byte   $08,$17,$CC,$02,$34,$03,$9F,$05 ; CF35 08 17 CC 02 34 03 9F 05  ....4...
        .byte   $06,$18,$37,$B8,$F8,$05,$06,$1F ; CF3D 06 18 37 B8 F8 05 06 1F  ..7.....
        .byte   $3E,$78,$20,$01,$07,$44,$88,$1B ; CF45 3E 78 20 01 07 44 88 1B  >x ..D..
        .byte   $0A,$0A,$01,$07,$43,$06,$1B,$0A ; CF4D 0A 0A 01 07 43 06 1B 0A  ....C...
        .byte   $0A,$01,$07,$3B,$88,$1B,$08,$08 ; CF55 0A 01 07 3B 88 1B 08 08  ...;....
        .byte   $02,$09,$88,$02,$A0,$03,$63,$05 ; CF5D 02 09 88 02 A0 03 63 05  ......c.
        .byte   $0A,$01,$07,$0B,$89,$1B,$0C,$06 ; CF65 0A 01 07 0B 89 1B 0C 06  ........
        .byte   $02,$0A,$89,$37,$A0,$FE,$84,$06 ; CF6D 02 0A 89 37 A0 FE 84 06  ...7....
        .byte   $06,$10,$02,$09,$8C,$46,$A0,$FE ; CF75 06 10 02 09 8C 46 A0 FE  .....F..
        .byte   $02,$08,$08,$07,$06,$43,$01,$88 ; CF7D 02 08 08 07 06 43 01 88  .....C..
        .byte   $0A,$09,$02,$00,$03,$08,$0C,$5C ; CF85 0A 09 02 00 03 08 0C 5C  .......\
        .byte   $00,$D4,$00,$9F,$01,$07,$08,$86 ; CF8D 00 D4 00 9F 01 07 08 86  ........
        .byte   $FC,$0A,$0A,$01,$07,$09,$86,$FD ; CF95 FC 0A 0A 01 07 09 86 FD  ........
        .byte   $0A,$0A,$02,$0B,$86,$0E,$40,$02 ; CF9D 0A 0A 02 0B 86 0E 40 02  ......@.
        .byte   $A3,$05,$05,$05,$0F,$02,$09,$87 ; CFA5 A3 05 05 05 0F 02 09 87  ........
        .byte   $1D,$A0,$FE,$63,$05,$0A,$05,$06 ; CFAD 1D A0 FE 63 05 0A 05 06  ...c....
        .byte   $0D,$0D,$18,$FB,$07,$06,$40,$1D ; CFB5 0D 0D 18 FB 07 06 40 1D  ......@.
        .byte   $68,$08,$09,$02,$00,$05,$06,$0F ; CFBD 68 08 09 02 00 05 06 0F  h.......
        .byte   $02,$A8,$10,$02,$09,$8A,$02,$90 ; CFC5 02 A8 10 02 09 8A 02 90  ........
        .byte   $02,$62,$03,$0A,$05,$06,$42,$0A ; CFCD 02 62 03 0A 05 06 42 0A  .b....B.
        .byte   $B8,$17,$09,$02,$00,$05,$06,$13 ; CFD5 B8 17 09 02 00 05 06 13  ........
        .byte   $03,$48,$14,$05,$06,$19,$03,$A8 ; CFDD 03 48 14 05 06 19 03 A8  .H......
        .byte   $F7,$05,$06,$1A,$17,$48,$F6,$05 ; CFE5 F7 05 06 1A 17 48 F6 05  .....H..
        .byte   $06,$1B,$31,$48,$1C,$03,$08,$1C ; CFED 06 1B 31 48 1C 03 08 1C  ..1H....
        .byte   $7C,$03,$C4,$03,$7F,$04,$08,$20 ; CFF5 7C 03 C4 03 7F 04 08 20  |...... 
        .byte   $34,$02,$00,$B8,$5F,$02,$09,$91 ; CFFD 34 02 00 B8 5F 02 09 91  4..._...
        .byte   $12,$C0,$02,$05,$03,$0A,$02,$09 ; D005 12 C0 02 05 03 0A 02 09  ........
        .byte   $92,$1B,$60,$FE,$03,$03,$11,$06 ; D00D 92 1B 60 FE 03 03 11 06  ..`.....
        .byte   $06,$1E,$40,$03,$0B,$02,$0B,$93 ; D015 06 1E 40 03 0B 02 0B 93  ..@.....
        .byte   $27,$C0,$FE,$04,$04,$04,$08,$0E ; D01D 27 C0 FE 04 04 04 08 0E  '.......
        .byte   $09,$02,$00,$05,$06,$07,$3D,$48 ; D025 09 02 00 05 06 07 3D 48  ......=H
        .byte   $FC,$07,$06,$08,$1F,$98,$00,$05 ; D02D FC 07 06 08 1F 98 00 05  ........
        .byte   $06,$09,$1F,$98,$00,$02,$08,$85 ; D035 06 09 1F 98 00 02 08 85  ........
        .byte   $04,$40,$02,$C5,$14,$07,$06,$0A ; D03D 04 40 02 C5 14 07 06 0A  .@......
        .byte   $02,$B8,$01,$05,$06,$0B,$02,$B8 ; D045 02 B8 01 05 06 0B 02 B8  ........
        .byte   $0C,$05,$06,$0E,$4D,$28,$FA,$04 ; D04D 0C 05 06 0E 4D 28 FA 04  ....M(..
        .byte   $08,$10,$2C,$05,$00,$84,$3F,$05 ; D055 08 10 2C 05 00 84 3F 05  ..,...?.
        .byte   $06,$11,$78,$68,$EF,$03,$08,$14 ; D05D 06 11 78 68 EF 03 08 14  ..xh....
        .byte   $2C,$06,$C4,$06,$AF,$05,$06,$1D ; D065 2C 06 C4 06 AF 05 06 1D  ,.......
        .byte   $BE,$78,$1E,$04,$08,$1E,$9C,$0C ; D06D BE 78 1E 04 08 1E 9C 0C  .x......
        .byte   $00,$C8,$3F,$05,$06,$21,$B0,$38 ; D075 00 C8 3F 05 06 21 B0 38  ..?..!.8
        .byte   $F5,$05,$06,$22,$9A,$70,$23,$03 ; D07D F5 05 06 22 9A 70 23 03  ...".p#.
        .byte   $08,$23,$FC,$08,$54,$09,$4F,$02 ; D085 08 23 FC 08 54 09 4F 02  .#..T.O.
        .byte   $08,$8B,$51,$40,$02,$43,$0D,$02 ; D08D 08 8B 51 40 02 43 0D 02  ..Q@.C..
        .byte   $09,$8D,$43,$70,$02,$43,$04,$0A ; D095 09 8D 43 70 02 43 04 0A  ..Cp.C..
        .byte   $02,$0A,$8E,$59,$D0,$02,$02,$04 ; D09D 02 0A 8E 59 D0 02 02 04  ...Y....
        .byte   $04,$0C,$06,$07,$84,$60,$FD,$07 ; D0A5 04 0C 06 07 84 60 FD 07  .....`..
        .byte   $0D,$02,$08,$8F,$8B,$90,$02,$03 ; D0AD 0D 02 08 8F 8B 90 02 03  ........
        .byte   $0A,$01,$07,$83,$8B,$CD,$08,$08 ; D0B5 0A 01 07 83 8B CD 08 08  ........
        .byte   $01,$07,$84,$8B,$CD,$08,$08,$07 ; D0BD 01 07 84 8B CD 08 08 07  ........
        .byte   $06,$90,$BD,$38,$07,$02,$09,$96 ; D0C5 06 90 BD 38 07 02 09 96  ...8....
        .byte   $C0,$90,$FE,$82,$05,$0C,$07,$06 ; D0CD C0 90 FE 82 05 0C 07 06  ........
        .byte   $4A,$2D,$A8,$0F,$07,$06,$4B,$0B ; D0D5 4A 2D A8 0F 07 06 4B 0B  J-....K.
        .byte   $B8,$10,$02,$09,$AC,$CA,$D0,$FE ; D0DD B8 10 02 09 AC CA D0 FE  ........
        .byte   $83,$04,$0C,$07,$06,$51,$04,$58 ; D0E5 83 04 0C 07 06 51 04 58  .....Q.X
        .byte   $16,$09,$02,$00,$05,$06,$00,$08 ; D0ED 16 09 02 00 05 06 00 08  ........
        .byte   $A8,$01,$03,$08,$01,$4C,$00,$A4 ; D0F5 A8 01 03 08 01 4C 00 A4  .....L..
        .byte   $00,$5F,$05,$06,$02,$03,$58,$FF ; D0FD 00 5F 05 06 02 03 58 FF  ._....X.
        .byte   $05,$06,$03,$26,$98,$04,$03,$08 ; D105 05 06 03 26 98 04 03 08  ...&....
        .byte   $04,$1C,$03,$92,$03,$6F,$02,$09 ; D10D 04 1C 03 92 03 6F 02 09  .....o..
        .byte   $80,$03,$A0,$02,$01,$0E,$05,$05 ; D115 80 03 A0 02 01 0E 05 05  ........
        .byte   $06,$05,$56,$28,$FE,$05,$06,$06 ; D11D 06 05 56 28 FE 05 06 06  ..V(....
        .byte   $4C,$78,$FD,$02,$08,$81,$21,$D0 ; D125 4C 78 FD 02 08 81 21 D0  Lx....!.
        .byte   $FE,$E2,$1E,$02,$08,$82,$44,$60 ; D12D FE E2 1E 02 08 82 44 60  ......D`
        .byte   $FE,$82,$0D,$02,$08,$83,$54,$60 ; D135 FE 82 0D 02 08 83 54 60  ......T`
        .byte   $FE,$02,$14,$02,$09,$84,$4E,$90 ; D13D FE 02 14 02 09 84 4E 90  ......N.
        .byte   $01,$43,$0F,$14,$02,$09,$12,$73 ; D145 01 43 0F 14 02 09 12 73  .C.....s
        .byte   $80,$FE,$41,$05,$14,$05,$06,$16 ; D14D 80 FE 41 05 14 05 06 16  ..A.....
        .byte   $63,$38,$00,$07,$06,$41,$63,$38 ; D155 63 38 00 07 06 41 63 38  c8...Ac8
        .byte   $09,$05,$06,$24,$A6,$58,$25,$04 ; D15D 09 05 06 24 A6 58 25 04  ...$.X%.
        .byte   $08,$25,$D0,$0A,$00,$A6,$4F,$06 ; D165 08 25 D0 0A 00 A6 4F 06  .%....O.
        .byte   $06,$A8,$40,$FC,$09,$02,$0A,$94 ; D16D 06 A8 40 FC 09 02 0A 94  ..@.....
        .byte   $8C,$90,$02,$83,$05,$05,$14,$02 ; D175 8C 90 02 83 05 05 14 02  ........
        .byte   $09,$9E,$5F,$A0,$02,$02,$05,$14 ; D17D 09 9E 5F A0 02 02 05 14  .._.....
        .byte   $07,$06,$44,$5D,$78,$0B,$07,$06 ; D185 07 06 44 5D 78 0B 07 06  ..D]x...
        .byte   $49,$17,$18,$0E,$07,$06,$52,$AD ; D18D 49 17 18 0E 07 06 52 AD  I.....R.
        .byte   $28,$17,$00,$05,$06,$26,$95,$C8 ; D195 28 17 00 05 06 26 95 C8  (....&..
        .byte   $27,$03,$08,$27,$4C,$09,$B4,$09 ; D19D 27 03 08 27 4C 09 B4 09  '..'L...
        .byte   $6F,$01,$07,$AB,$89,$F8,$14,$14 ; D1A5 6F 01 07 AB 89 F8 14 14  o.......
        .byte   $05,$06,$30,$6C,$C8,$31,$05,$06 ; D1AD 05 06 30 6C C8 31 05 06  ..0l.1..
        .byte   $34,$0A,$A8,$35,$03,$08,$35,$AC ; D1B5 34 0A A8 35 03 08 35 AC  4..5..5.
        .byte   $02,$44,$03,$3F,$05,$06,$36,$49 ; D1BD 02 44 03 3F 05 06 36 49  .D.?..6I
        .byte   $28,$F1,$06,$06,$71,$60,$03,$0A ; D1C5 28 F1 06 06 71 60 03 0A  (...q`..
        .byte   $02,$08,$95,$A6,$40,$FE,$82,$0D ; D1CD 02 08 95 A6 40 FE 82 0D  ....@...
        .byte   $06,$06,$47,$60,$03,$18,$02,$09 ; D1D5 06 06 47 60 03 18 02 09  ..G`....
        .byte   $98,$11,$A0,$02,$04,$0A,$04,$02 ; D1DD 98 11 A0 02 04 0A 04 02  ........
        .byte   $0A,$99,$21,$A0,$02,$02,$04,$04 ; D1E5 0A 99 21 A0 02 02 04 04  ..!.....
        .byte   $08,$02,$0B,$9A,$0E,$D0,$FE,$04 ; D1ED 08 02 0B 9A 0E D0 FE 04  ........
        .byte   $04,$04,$08,$08,$02,$08,$A6,$36 ; D1F5 04 04 08 08 02 08 A6 36  .......6
        .byte   $40,$FE,$82,$0C,$07,$06,$4C,$1D ; D1FD 40 FE 82 0C 07 06 4C 1D  @.....L.
        .byte   $A0,$11,$07,$06,$4D,$44,$40,$12 ; D205 A0 11 07 06 4D 44 40 12  ....MD@.
        .byte   $02,$09,$A7,$68,$D0,$FE,$01,$07 ; D20D 02 09 A7 68 D0 FE 01 07  ...h....
        .byte   $0E,$07,$06,$4E,$8C,$18,$13,$00 ; D215 0E 07 06 4E 8C 18 13 00  ...N....
        .byte   $07,$06,$28,$90,$D0,$02,$05,$06 ; D21D 07 06 28 90 D0 02 05 06  ..(.....
        .byte   $29,$93,$88,$00,$07,$06,$2B,$93 ; D225 29 93 88 00 07 06 2B 93  ).....+.
        .byte   $88,$03,$05,$06,$2A,$98,$48,$F4 ; D22D 88 03 05 06 2A 98 48 F4  ....*.H.
        .byte   $01,$07,$9C,$85,$FD,$0A,$23,$01 ; D235 01 07 9C 85 FD 0A 23 01  ......#.
        .byte   $07,$9E,$87,$FD,$0F,$1E,$01,$07 ; D23D 07 9E 87 FD 0F 1E 01 07  ........
        .byte   $9C,$89,$FD,$14,$19,$01,$07,$9E ; D245 9C 89 FD 14 19 01 07 9E  ........
        .byte   $8B,$FD,$19,$14,$05,$06,$2E,$68 ; D24D 8B FD 19 14 05 06 2E 68  .......h
        .byte   $B8,$00,$07,$06,$2F,$68,$B8,$05 ; D255 B8 00 07 06 2F 68 B8 05  ..../h..
        .byte   $03,$08,$31,$2C,$05,$74,$05,$7F ; D25D 03 08 31 2C 05 74 05 7F  ..1,.t..
        .byte   $01,$07,$55,$04,$1B,$0A,$0A,$01 ; D265 01 07 55 04 1B 0A 0A 01  ..U.....
        .byte   $07,$58,$04,$1B,$0A,$0A,$05,$06 ; D26D 07 58 04 1B 0A 0A 05 06  .X......
        .byte   $37,$30,$68,$38,$03,$08,$38,$FC ; D275 37 30 68 38 03 08 38 FC  70h8..8.
        .byte   $00,$54,$01,$3F,$03,$08,$3A,$7C ; D27D 00 54 01 3F 03 08 3A 7C  .T.?..:|
        .byte   $01,$C4,$01,$3F,$03,$08,$3C,$4C ; D285 01 C4 01 3F 03 08 3C 4C  ...?..<L
        .byte   $02,$C4,$02,$3F,$02,$09,$97,$96 ; D28D 02 C4 02 3F 02 09 97 96  ...?....
        .byte   $50,$02,$83,$14,$19,$06,$06,$89 ; D295 50 02 83 14 19 06 06 89  P.......
        .byte   $C0,$03,$12,$02,$0A,$9B,$7F,$D0 ; D29D C0 03 12 02 0A 9B 7F D0  ........
        .byte   $FE,$83,$03,$03,$0A,$06,$07,$76 ; D2A5 FE 83 03 03 0A 06 07 76  .......v
        .byte   $50,$03,$10,$16,$05,$06,$45,$78 ; D2AD 50 03 10 16 05 06 45 78  P.....Ex
        .byte   $88,$46,$03,$08,$46,$9C,$07,$34 ; D2B5 88 46 03 08 46 9C 07 34  .F..F..4
        .byte   $08,$5F,$02,$0A,$A2,$3C,$D0,$FE ; D2BD 08 5F 02 0A A2 3C D0 FE  ._...<..
        .byte   $05,$05,$05,$0A,$02,$0B,$A3,$44 ; D2C5 05 05 05 0A 02 0B A3 44  .......D
        .byte   $70,$FE,$83,$04,$04,$08,$08,$02 ; D2CD 70 FE 83 04 04 08 08 02  p.......
        .byte   $0A,$A4,$19,$D0,$02,$83,$05,$05 ; D2D5 0A A4 19 D0 02 83 05 05  ........
        .byte   $0A,$02,$09,$A5,$12,$D0,$02,$05 ; D2DD 0A 02 09 A5 12 D0 02 05  ........
        .byte   $0A,$0A,$07,$06,$48,$16,$58,$0D ; D2E5 0A 0A 07 06 48 16 58 0D  ....H.X.
        .byte   $02,$0A,$A9,$03,$70,$02,$05,$04 ; D2ED 02 0A A9 03 70 02 05 04  ....p...
        .byte   $03,$08,$02,$0A,$AD,$5B,$40,$02 ; D2F5 03 08 02 0A AD 5B 40 02  .....[@.
        .byte   $03,$04,$03,$08,$07,$06,$50,$95 ; D2FD 03 04 03 08 07 06 50 95  ......P.
        .byte   $18,$15,$00,$05,$06,$39,$1E,$B8 ; D305 18 15 00 05 06 39 1E B8  .....9..
        .byte   $3A,$05,$06,$3F,$04,$38,$F0,$02 ; D30D 3A 05 06 3F 04 38 F0 02  :..?.8..
        .byte   $08,$A1,$1A,$60,$FE,$04,$0C,$07 ; D315 08 A1 1A 60 FE 04 0C 07  ...`....
        .byte   $06,$47,$18,$88,$0C,$02,$0C,$AA ; D31D 06 47 18 88 0C 02 0C AA  .G......
        .byte   $0A,$D0,$FE,$82,$03,$03,$03,$03 ; D325 0A D0 FE 82 03 03 03 03  ........
        .byte   $09,$00,$05,$06,$2C,$04,$28,$00 ; D32D 09 00 05 06 2C 04 28 00  ....,.(.
        .byte   $07,$06,$2D,$04,$28,$04,$02,$0B ; D335 07 06 2D 04 28 04 02 0B  ..-.(...
        .byte   $9F,$1D,$D0,$FE,$84,$03,$03,$07 ; D33D 9F 1D D0 FE 84 03 03 07  ........
        .byte   $07,$02,$08,$A0,$0C,$90,$02,$02 ; D345 07 02 08 A0 0C 90 02 02  ........
        .byte   $07,$07,$06,$4F,$1C,$20,$14,$00 ; D34D 07 07 06 4F 1C 20 14 00  ...O. ..
        .byte   $05,$06,$3B,$01,$88,$3C,$05,$06 ; D355 05 06 3B 01 88 3C 05 06  ..;..<..
        .byte   $3D,$13,$18,$00,$07,$06,$3E,$13 ; D35D 3D 13 18 00 07 06 3E 13  =.....>.
        .byte   $18,$06,$02,$08,$AB,$0A,$D0,$FE ; D365 18 06 02 08 AB 0A D0 FE  ........
        .byte   $04,$05,$00,$05,$06,$32,$1D,$58 ; D36D 04 05 00 05 06 32 1D 58  .....2.X
        .byte   $F3,$05,$06,$33,$03,$68,$F2,$02 ; D375 F3 05 06 33 03 68 F2 02  ...3.h..
        .byte   $0A,$9C,$15,$D0,$FE,$04,$04,$04 ; D37D 0A 9C 15 D0 FE 04 04 04  ........
        .byte   $0C,$00,$08,$05,$00,$0E,$30,$02 ; D385 0C 00 08 05 00 0E 30 02  ......0.
        .byte   $08,$9D,$02,$D0,$02,$05,$09,$00 ; D38D 08 9D 02 D0 02 05 09 00  ........
doordata:
        .byte   $05                             ; D395 05                       .
LD396:  .byte   $0E                             ; D396 0E                       .
LD397:  .byte   $45,$05,$4F,$2C,$05,$37,$2C,$04 ; D397 45 05 4F 2C 05 37 2C 04  E.O,.7,.
        .byte   $1D,$25,$04,$4A,$23,$04,$4C,$2B ; D39F 1D 25 04 4A 23 04 4C 2B  .%.J#.L+
        .byte   $00,$1F,$2B,$00,$31,$24,$03,$0F ; D3A7 00 1F 2B 00 31 24 03 0F  ..+.1$..
        .byte   $35,$03,$2F,$3B,$04,$92,$2C,$07 ; D3AF 35 03 2F 3B 04 92 2C 07  5./;..,.
        .byte   $92,$28,$07,$4A,$3C,$0B,$11,$4C ; D3B7 92 28 07 4A 3C 0B 11 4C  .(.J<..L
        .byte   $06,$61,$4C,$0B,$17,$23,$05,$80 ; D3BF 06 61 4C 0B 17 23 05 80  .aL..#..
        .byte   $1C                             ; D3C7 1C                       .
; ----------------------------------------------------------------------------
resetextravars:
        lda     #$03                            ; D3C8 A9 03                    ..
        sta     $1C                             ; D3CA 85 1C                    ..
        lda     #$00                            ; D3CC A9 00                    ..
        sta     address                         ; D3CE 85 1B                    ..
        ldy     #$35                            ; D3D0 A0 35                    .5
@n1:  sta     (address),y                     ; D3D2 91 1B                    ..
        iny                                     ; D3D4 C8                       .
        bne     @n2                           ; D3D5 D0 02                    ..
        inc     $1C                             ; D3D7 E6 1C                    ..
@n2:  cpy     #$13                            ; D3D9 C0 13                    ..
        bne     @n1                           ; D3DB D0 F5                    ..
        ldx     #$05                            ; D3DD A2 05                    ..
        cpx     $1C                             ; D3DF E4 1C                    ..
        bne     @n1                           ; D3E1 D0 EF                    ..
        rts                                     ; D3E3 60                       `

; ----------------------------------------------------------------------------
resetextras:
        lda     #$FF                            ; D3E4 A9 FF                    ..
        ldx     #$20                            ; D3E6 A2 20                    . 
@n1:  sta     $0640,x                         ; D3E8 9D 40 06                 .@.
        dex                                     ; D3EB CA                       .
        bpl     @n1                           ; D3EC 10 FA                    ..
        lda     #$00                            ; D3EE A9 00                    ..
        ldx     #$0E                            ; D3F0 A2 0E                    ..
@n2:  sta     $0660,x                         ; D3F2 9D 60 06                 .`.
        dex                                     ; D3F5 CA                       .
        bpl     @n2                           ; D3F6 10 FA                    ..
        rts                                     ; D3F8 60                       `

; ----------------------------------------------------------------------------
pickupcollision1:
        ldy     #$04                            ; D3F9 A0 04                    ..
        lda     (address9),y                    ; D3FB B1 2D                    .-
        tay                                     ; D3FD A8                       .
; collision between robin and fruit using address8
pickupcollision:
        bit     robincrouch                     ; D3FE 2C 15 03                 ,..
        bmi     crouchcollide                   ; D401 30 0D                    0.
        sec                                     ; D403 38                       8
        sbc     robiny                          ; D404 ED 0A 03                 ...
        clc                                     ; D407 18                       .
        adc     #$22                            ; D408 69 22                    i"
        cmp     #$2A                            ; D40A C9 2A                    .*
        bcs     nopickcoll                      ; D40C B0 18                    ..
        bcc     nowthex                         ; D40E 90 0B                    ..
crouchcollide:
        sec                                     ; D410 38                       8
        sbc     robiny                          ; D411 ED 0A 03                 ...
        clc                                     ; D414 18                       .
        adc     #$18                            ; D415 69 18                    i.
        cmp     #$20                            ; D417 C9 20                    . 
        bcs     nopickcoll                      ; D419 B0 0B                    ..
nowthex:lda     address8                        ; D41B A5 2B                    .+
        sec                                     ; D41D 38                       8
        sbc     robinonscrx                     ; D41E ED 0B 03                 ...
        clc                                     ; D421 18                       .
        adc     #$0C                            ; D422 69 0C                    i.
        cmp     #$18                            ; D424 C9 18                    ..
nopickcoll:
        rts                                     ; D426 60                       `

; ----------------------------------------------------------------------------
bitpattern:
        .byte   $80                             ; D427 80                       .
        rti                                     ; D428 40                       @

; ----------------------------------------------------------------------------
        jsr     L0810                           ; D429 20 10 08                  ..
        .byte   $04                             ; D42C 04                       .
        .byte   $02                             ; D42D 02                       .
checkifextraon  := * + 1
        ora     ($B1,x)                         ; D42E 01 B1                    ..
checkifdooron   := * + 1
        and     $29A8                           ; D430 2D A8 29                 -.)
        .byte   $07                             ; D433 07                       .
        tax                                     ; D434 AA                       .
        tya                                     ; D435 98                       .
        lsr     a                               ; D436 4A                       J
        lsr     a                               ; D437 4A                       J
        lsr     a                               ; D438 4A                       J
        tay                                     ; D439 A8                       .
        lda     $0640,y                         ; D43A B9 40 06                 .@.
        and     bitpattern,x                    ; D43D 3D 27 D4                 ='.
        rts                                     ; D440 60                       `

; ----------------------------------------------------------------------------
turnoffextra:
        ldy     #$02                            ; D441 A0 02                    ..
        lda     (address9),y                    ; D443 B1 2D                    .-
turnoffdoor:
        tay                                     ; D445 A8                       .
        and     #$07                            ; D446 29 07                    ).
        tax                                     ; D448 AA                       .
        tya                                     ; D449 98                       .
        lsr     a                               ; D44A 4A                       J
        lsr     a                               ; D44B 4A                       J
        lsr     a                               ; D44C 4A                       J
        tay                                     ; D44D A8                       .
        lda     $0640,y                         ; D44E B9 40 06                 .@.
        eor     bitpattern,x                    ; D451 5D 27 D4                 ]'.
        sta     $0640,y                         ; D454 99 40 06                 .@.
        rts                                     ; D457 60                       `

; bcs not on main screen or on either side screens
; ----------------------------------------------------------------------------
checkonscreensides:
        ldy     #$03                            ; D458 A0 03                    ..
checkonscreensides1:
        lda     (address9),y                    ; D45A B1 2D                    .-
        sec                                     ; D45C 38                       8
        sbc     scrxl                           ; D45D E5 3B                    .;
        sta     address7                        ; D45F 85 29                    .)
        iny                                     ; D461 C8                       .
        lda     (address9),y                    ; D462 B1 2D                    .-
        sbc     scrxh                           ; D464 E5 3C                    .<
        sta     a:temp7                         ; D466 8D 38 00                 .8.
        clc                                     ; D469 18                       .
        adc     #$01                            ; D46A 69 01                    i.
        cmp     #$03                            ; D46C C9 03                    ..
        rts                                     ; D46E 60                       `

; new format xl,xh,y,chr,col*16+numofpars,flags+rou,0,0,0,0,0,0,0,0,0,0 ;16 in all
; flags 128=keep coord on robin
; 64 =add gravity
; ----------------------------------------------------------------------------
startstarstable:
        .byte   $01,$00,$00,$8C,$33,$80,$04,$00 ; D46F 01 00 00 8C 33 80 04 00  ....3...
        .byte   $10,$10,$04,$00,$00,$00,$00,$00 ; D477 10 10 04 00 00 00 00 00  ........
        .byte   $01,$00,$00,$8C,$35,$81,$00,$00 ; D47F 01 00 00 8C 35 81 00 00  ....5...
        .byte   $04,$1A,$08,$0D,$04,$13,$00,$06 ; D487 04 1A 08 0D 04 13 00 06  ........
        .byte   $01,$00,$00,$8C,$32,$83,$FC,$00 ; D48F 01 00 00 8C 32 83 FC 00  ....2...
        .byte   $FC,$10,$00,$00,$00,$00,$00,$00 ; D497 FC 10 00 00 00 00 00 00  ........
        .byte   $01,$00,$00,$9A,$11,$04,$04,$10 ; D49F 01 00 00 9A 11 04 04 10  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; D4A7 00 00 00 00 00 00 00 00  ........
        .byte   $01,$00,$00,$97,$23,$05,$04,$00 ; D4AF 01 00 00 97 23 05 04 00  ....#...
        .byte   $04,$10,$04,$00,$00,$00,$00,$00 ; D4B7 04 10 04 00 00 00 00 00  ........
        .byte   $01,$00,$00,$97,$25,$06,$04,$00 ; D4BF 01 00 00 97 25 06 04 00  ....%...
        .byte   $04,$1A,$04,$0D,$04,$13,$04,$06 ; D4C7 04 1A 04 0D 04 13 04 06  ........
        .byte   $01,$00,$00,$96,$11,$04,$04,$10 ; D4CF 01 00 00 96 11 04 04 10  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; D4D7 00 00 00 00 00 00 00 00  ........
        .byte   $01,$00,$00,$8C,$31,$04,$04,$10 ; D4DF 01 00 00 8C 31 04 04 10  ....1...
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; D4E7 00 00 00 00 00 00 00 00  ........
; ----------------------------------------------------------------------------
startstars:
        sta     temp2                           ; D4EF 85 33                    .3
        ldx     #$00                            ; D4F1 A2 00                    ..
        lda     heartstable,x                   ; D4F3 BD E1 04                 ...
        beq     gotstarsx                       ; D4F6 F0 10                    ..
        ldx     #$10                            ; D4F8 A2 10                    ..
        lda     heartstable,x                   ; D4FA BD E1 04                 ...
        beq     gotstarsx                       ; D4FD F0 09                    ..
smiley: ldx     #$20                            ; D4FF A2 20                    . 
        lda     heartstable,x                   ; D501 BD E1 04                 ...
        beq     gotstarsx                       ; D504 F0 02                    ..
        ldx     #$00                            ; D506 A2 00                    ..
gotstarsx:
        stx     temp1                           ; D508 86 32                    .2
        lda     temp2                           ; D50A A5 33                    .3
        asl     a                               ; D50C 0A                       .
        asl     a                               ; D50D 0A                       .
        asl     a                               ; D50E 0A                       .
        asl     a                               ; D50F 0A                       .
        tay                                     ; D510 A8                       .
        lda     #$10                            ; D511 A9 10                    ..
        sta     temp2                           ; D513 85 33                    .3
@n1:  lda     startstarstable,y               ; D515 B9 6F D4                 .o.
        sta     heartstable,x                   ; D518 9D E1 04                 ...
        iny                                     ; D51B C8                       .
        inx                                     ; D51C E8                       .
        dec     temp2                           ; D51D C6 33                    .3
        bne     @n1                           ; D51F D0 F4                    ..
        ldx     temp1                           ; D521 A6 32                    .2
        lda     $2C                             ; D523 A5 2C                    .,
        sta     $04E3,x                         ; D525 9D E3 04                 ...
        lda     address7                        ; D528 A5 29                    .)
        sta     heartstable,x                   ; D52A 9D E1 04                 ...
        lda     $2A                             ; D52D A5 2A                    .*
        sta     $04E2,x                         ; D52F 9D E2 04                 ...
        rts                                     ; D532 60                       `

; ----------------------------------------------------------------------------
doorrou:lda     animatedoor                     ; D533 AD 28 03                 .(.
        beq     enddoor                         ; D536 F0 3D                    .=
        and     #$07                            ; D538 29 07                    ).
        bne     donedoor                        ; D53A D0 36                    .6
        lda     #$04                            ; D53C A9 04                    ..
        jsr     soundfx                         ; D53E 20 28 F4                  (.
        lda     animatedoor                     ; D541 AD 28 03                 .(.
        cmp     #$08                            ; D544 C9 08                    ..
        beq     finishdoor                      ; D546 F0 1E                    ..
        and     #$0F                            ; D548 29 0F                    ).
        beq     overboundry                     ; D54A F0 0E                    ..
        ldx     doorx                           ; D54C AE 29 03                 .).
        ldy     doory                           ; D54F AC 2A 03                 .*.
        lda     #$01                            ; D552 A9 01                    ..
        jsr     addachangedblock                ; D554 20 58 FA                  X.
        jmp     donedoor                        ; D557 4C 72 D5                 Lr.

; ----------------------------------------------------------------------------
overboundry:
        ldx     doorx                           ; D55A AE 29 03                 .).
        ldy     doory                           ; D55D AC 2A 03                 .*.
        dey                                     ; D560 88                       .
        lda     #$02                            ; D561 A9 02                    ..
        jsr     addachangedblock                ; D563 20 58 FA                  X.
finishdoor:
        ldx     doorx                           ; D566 AE 29 03                 .).
        ldy     doory                           ; D569 AC 2A 03                 .*.
        jsr     deleteachangedblock             ; D56C 20 C0 FA                  ..
        dec     doory                           ; D56F CE 2A 03                 .*.
donedoor:
        dec     animatedoor                     ; D572 CE 28 03                 .(.
enddoor:rts                                     ; D575 60                       `

; ----------------------------------------------------------------------------
closedoor:
        ldx     doorx                           ; D576 AE 29 03                 .).
        ldy     doory                           ; D579 AC 2A 03                 .*.
        lda     #$02                            ; D57C A9 02                    ..
        jsr     addachangedblock                ; D57E 20 58 FA                  X.
        dec     doory                           ; D581 CE 2A 03                 .*.
@n2:  ldx     doorx                           ; D584 AE 29 03                 .).
        ldy     doory                           ; D587 AC 2A 03                 .*.
        lda     #$03                            ; D58A A9 03                    ..
        jsr     addachangedblock                ; D58C 20 58 FA                  X.
        dec     doory                           ; D58F CE 2A 03                 .*.
        lda     animatedoor                     ; D592 AD 28 03                 .(.
        clc                                     ; D595 18                       .
        adc     #$F0                            ; D596 69 F0                    i.
        sta     animatedoor                     ; D598 8D 28 03                 .(.
        cmp     #$08                            ; D59B C9 08                    ..
        bne     @n2                           ; D59D D0 E5                    ..
        rts                                     ; D59F 60                       `

; a=number of door to open
; ----------------------------------------------------------------------------
openadoor:
        sta     temp                            ; D5A0 85 31                    .1
        jsr     turnoffdoor                     ; D5A2 20 45 D4                  E.
openadoor1:
        lda     #$FF                            ; D5A5 A9 FF                    ..
        sec                                     ; D5A7 38                       8
        sbc     temp                            ; D5A8 E5 31                    .1
        sta     temp1                           ; D5AA 85 32                    .2
        asl     a                               ; D5AC 0A                       .
        clc                                     ; D5AD 18                       .
        adc     temp1                           ; D5AE 65 32                    e2
        tax                                     ; D5B0 AA                       .
        lda     doordata,x                      ; D5B1 BD 95 D3                 ...
        cmp     mapno                           ; D5B4 C5 42                    .B
        bne     @n1                           ; D5B6 D0 1B                    ..
        lda     LD397,x                         ; D5B8 BD 97 D3                 ...
        and     #$0F                            ; D5BB 29 0F                    ).
        sta     doory                           ; D5BD 8D 2A 03                 .*.
        lda     LD397,x                         ; D5C0 BD 97 D3                 ...
        and     #$F0                            ; D5C3 29 F0                    ).
        clc                                     ; D5C5 18                       .
        adc     #$08                            ; D5C6 69 08                    i.
        sta     animatedoor                     ; D5C8 8D 28 03                 .(.
        lda     LD396,x                         ; D5CB BD 96 D3                 ...
        sta     doorx                           ; D5CE 8D 29 03                 .).
        lda     #$00                            ; D5D1 A9 00                    ..
@n1:  rts                                     ; D5D3 60                       `

; ----------------------------------------------------------------------------
resetdoorsintomap:
        lda     #$FF                            ; D5D4 A9 FF                    ..
@n2:  sta     temp                            ; D5D6 85 31                    .1
        jsr     checkifdooron                   ; D5D8 20 31 D4                  1.
        beq     @n3                           ; D5DB F0 0E                    ..
        jsr     openadoor1                      ; D5DD 20 A5 D5                  ..
        bne     @n3                           ; D5E0 D0 09                    ..
        lda     temp                            ; D5E2 A5 31                    .1
        pha                                     ; D5E4 48                       H
        jsr     closedoor                       ; D5E5 20 76 D5                  v.
        pla                                     ; D5E8 68                       h
        sta     temp                            ; D5E9 85 31                    .1
@n3:  dec     temp                            ; D5EB C6 31                    .1
        lda     temp                            ; D5ED A5 31                    .1
        cmp     #$ED                            ; D5EF C9 ED                    ..
        bne     @n2                           ; D5F1 D0 E3                    ..
        rts                                     ; D5F3 60                       `

; 1st is always robins arrow, the rest are enemies
; ----------------------------------------------------------------------------
robinshootarrow:
        lda     robinxl                         ; D5F4 AD 08 03                 ...
        sta     arrowxl                         ; D5F7 8D 29 04                 .).
        lda     robinxh                         ; D5FA AD 09 03                 ...
        sta     arrowxh                         ; D5FD 8D 31 04                 .1.
        lda     robiny                          ; D600 AD 0A 03                 ...
        clc                                     ; D603 18                       .
        adc     #$E8                            ; D604 69 E8                    i.
        sta     arrowy                          ; D606 8D 39 04                 .9.
        ldx     #$04                            ; D609 A2 04                    ..
        lda     oleftright                      ; D60B AD 0D 03                 ...
        bpl     @n1                           ; D60E 10 10                    ..
        ldx     #$FC                            ; D610 A2 FC                    ..
        lda     arrowxl                         ; D612 AD 29 04                 .).
        sec                                     ; D615 38                       8
        sbc     #$08                            ; D616 E9 08                    ..
        sta     arrowxl                         ; D618 8D 29 04                 .).
        bcs     @n1                           ; D61B B0 03                    ..
        dec     arrowxh                         ; D61D CE 31 04                 .1.
@n1:  stx     arrowdir                        ; D620 8E 41 04                 .A.
        lda     #$28                            ; D623 A9 28                    .(
        sta     arrowcounter                    ; D625 8D 51 04                 .Q.
        rts                                     ; D628 60                       `

; (address9),y points at >x,<x,y,dir
; ----------------------------------------------------------------------------
shootarrow:
        sta     temp                            ; D629 85 31                    .1
        ldx     #$01                            ; D62B A2 01                    ..
@n2:  lda     arrowcounter,x                  ; D62D BD 51 04                 .Q.
        beq     gotarrowpos                     ; D630 F0 06                    ..
        inx                                     ; D632 E8                       .
        cpx     #$08                            ; D633 E0 08                    ..
        bne     @n2                           ; D635 D0 F6                    ..
        rts                                     ; D637 60                       `

; ----------------------------------------------------------------------------
gotarrowpos:
        lda     (address9),y                    ; D638 B1 2D                    .-
        ldy     #$00                            ; D63A A0 00                    ..
        sta     arrowdir,x                      ; D63C 9D 41 04                 .A.
        cmp     #$00                            ; D63F C9 00                    ..
        bpl     @n3                           ; D641 10 02                    ..
        ldy     #$FF                            ; D643 A0 FF                    ..
@n3:  lda     #$64                            ; D645 A9 64                    .d
        sta     arrowcounter,x                  ; D647 9D 51 04                 .Q.
        lda     #$00                            ; D64A A9 00                    ..
        sta     arrowcanon,x                    ; D64C 9D 49 04                 .I.
        lda     arrowdir,x                      ; D64F BD 41 04                 .A.
        asl     a                               ; D652 0A                       .
        asl     a                               ; D653 0A                       .
        clc                                     ; D654 18                       .
        adc     address7                        ; D655 65 29                    e)
        sta     arrowxl,x                       ; D657 9D 29 04                 .).
        tya                                     ; D65A 98                       .
        adc     $2A                             ; D65B 65 2A                    e*
        sta     arrowxh,x                       ; D65D 9D 31 04                 .1.
        lda     temp                            ; D660 A5 31                    .1
        sta     arrowy,x                        ; D662 9D 39 04                 .9.
        rts                                     ; D665 60                       `

; ----------------------------------------------------------------------------
addarrowdir:
        lda     arrowdir,x                      ; D666 BD 41 04                 .A.
        bpl     @n2                           ; D669 10 12                    ..
        lda     arrowxl,x                       ; D66B BD 29 04                 .).
        clc                                     ; D66E 18                       .
        adc     arrowdir,x                      ; D66F 7D 41 04                 }A.
        sta     arrowxl,x                       ; D672 9D 29 04                 .).
        bcs     @n1                           ; D675 B0 03                    ..
        dec     arrowxh,x                       ; D677 DE 31 04                 .1.
@n1:  jmp     @n3                           ; D67A 4C 8C D6                 L..

; ----------------------------------------------------------------------------
@n2:  lda     arrowxl,x                       ; D67D BD 29 04                 .).
        clc                                     ; D680 18                       .
        adc     arrowdir,x                      ; D681 7D 41 04                 }A.
        sta     arrowxl,x                       ; D684 9D 29 04                 .).
        bcc     @n3                           ; D687 90 03                    ..
        inc     arrowxh,x                       ; D689 FE 31 04                 .1.
@n3:  rts                                     ; D68C 60                       `

; ----------------------------------------------------------------------------
updatearrows:
        ldx     #$00                            ; D68D A2 00                    ..
doeacharrow:
        lda     arrowcounter,x                  ; D68F BD 51 04                 .Q.
        beq     @n4                           ; D692 F0 02                    ..
        bpl     @n5                           ; D694 10 03                    ..
@n4:  jmp     nextarrow                       ; D696 4C 36 D7                 L6.

; ----------------------------------------------------------------------------
@n5:  dec     arrowcounter,x                  ; D699 DE 51 04                 .Q.
contarrow:
        jsr     addarrowdir                     ; D69C 20 66 D6                  f.
printarrow:
        stx     tempx                           ; D69F 86 2F                    ./
        lda     arrowxh,x                       ; D6A1 BD 31 04                 .1.
        sta     temp                            ; D6A4 85 31                    .1
        lda     arrowxl,x                       ; D6A6 BD 29 04                 .).
        clc                                     ; D6A9 18                       .
        adc     #$04                            ; D6AA 69 04                    i.
        bcc     @n1                           ; D6AC 90 02                    ..
        inc     temp                            ; D6AE E6 31                    .1
@n1:  ldy     arrowy,x                        ; D6B0 BC 39 04                 .9.
        iny                                     ; D6B3 C8                       .
        iny                                     ; D6B4 C8                       .
        iny                                     ; D6B5 C8                       .
        iny                                     ; D6B6 C8                       .
        iny                                     ; D6B7 C8                       .
        iny                                     ; D6B8 C8                       .
        ldx     temp                            ; D6B9 A6 31                    .1
        jsr     findsolid                       ; D6BB 20 2B F9                  +.
        cmp     #$03                            ; D6BE C9 03                    ..
        bne     arrownothitwall                 ; D6C0 D0 0D                    ..
; arrow hit wall
takearrowoff:
        lda     #$20                            ; D6C2 A9 20                    . 
        jsr     soundfx                         ; D6C4 20 28 F4                  (.
takearrowoff1:
        ldx     tempx                           ; D6C7 A6 2F                    ./
        jsr     takearrowoffrou                 ; D6C9 20 63 D7                  c.
        jmp     nextarrow                       ; D6CC 4C 36 D7                 L6.

; ----------------------------------------------------------------------------
arrownothitwall:
        ldx     tempx                           ; D6CF A6 2F                    ./
        lda     arrowxl,x                       ; D6D1 BD 29 04                 .).
        sec                                     ; D6D4 38                       8
        sbc     scrxl                           ; D6D5 E5 3B                    .;
        sta     tempy                           ; D6D7 85 30                    .0
        lda     arrowxh,x                       ; D6D9 BD 31 04                 .1.
        sbc     scrxh                           ; D6DC E5 3C                    .<
        bne     nextarrow                       ; D6DE D0 56                    .V
        lda     arrowdir,x                      ; D6E0 BD 41 04                 .A.
        and     #$40                            ; D6E3 29 40                    )@
        eor     arrowcanon,x                    ; D6E5 5D 49 04                 ]I.
        sta     temp                            ; D6E8 85 31                    .1
        lda     arrowy,x                        ; D6EA BD 39 04                 .9.
        clc                                     ; D6ED 18                       .
        adc     #$0C                            ; D6EE 69 0C                    i.
        tay                                     ; D6F0 A8                       .
        lda     arrowcanon,x                    ; D6F1 BD 49 04                 .I.
        beq     isanarrow                       ; D6F4 F0 02                    ..
        lda     #$1D                            ; D6F6 A9 1D                    ..
isanarrow:
        clc                                     ; D6F8 18                       .
        adc     #$79                            ; D6F9 69 79                    iy
        ldx     tempy                           ; D6FB A6 30                    .0
        jsr     pokesprite                      ; D6FD 20 CD EF                  ..
        ldx     tempx                           ; D700 A6 2F                    ./
        ; now check collision with robin
        beq     nextarrow                       ; D702 F0 32                    .2
        lda     arrowy,x                        ; D704 BD 39 04                 .9.
        clc                                     ; D707 18                       .
        ; slight bodge to make them easiler to jump over
        adc     #$06                            ; D708 69 06                    i.
        sec                                     ; D70A 38                       8
        sbc     robiny                          ; D70B ED 0A 03                 ...
        bcs     nextarrow                       ; D70E B0 26                    .&
        lda     arrowy,x                        ; D710 BD 39 04                 .9.
        clc                                     ; D713 18                       .
        adc     #$02                            ; D714 69 02                    i.
        sec                                     ; D716 38                       8
        sbc     robinheight                     ; D717 ED 16 03                 ...
        bcc     nextarrow                       ; D71A 90 1A                    ..
        lda     tempy                           ; D71C A5 30                    .0
        sec                                     ; D71E 38                       8
        sbc     robinonscrx                     ; D71F ED 0B 03                 ...
        clc                                     ; D722 18                       .
        adc     #$0C                            ; D723 69 0C                    i.
        cmp     #$18                            ; D725 C9 18                    ..
        bcs     nextarrow                       ; D727 B0 0D                    ..
        lda     robininvinc                     ; D729 AD 1C 03                 ...
        bne     nextarrow                       ; D72C D0 08                    ..
        lda     #$01                            ; D72E A9 01                    ..
        ; arrow has hit robin
        jsr     subfromhearts                   ; D730 20 97 F5                  ..
        jmp     takearrowoff1                   ; D733 4C C7 D6                 L..

; ----------------------------------------------------------------------------
nextarrow:
        inx                                     ; D736 E8                       .
        cpx     #$08                            ; D737 E0 08                    ..
        beq     @n1                           ; D739 F0 03                    ..
        jmp     doeacharrow                     ; D73B 4C 8F D6                 L..

; ----------------------------------------------------------------------------
@n1:  lda     deadarrowcount                  ; D73E AD 27 03                 .'.
        beq     @n2                           ; D741 F0 1F                    ..
        dec     deadarrowcount                  ; D743 CE 27 03                 .'.
        lda     deadarrowx                      ; D746 AD 24 03                 .$.
        sec                                     ; D749 38                       8
        sbc     scrxl                           ; D74A E5 3B                    .;
        tax                                     ; D74C AA                       .
        lda     $0325                           ; D74D AD 25 03                 .%.
        sbc     scrxh                           ; D750 E5 3C                    .<
        sta     a:temp7                         ; D752 8D 38 00                 .8.
        ldy     deadarrowy                      ; D755 AC 26 03                 .&.
        lda     deadarrowcount                  ; D758 AD 27 03                 .'.
        lsr     a                               ; D75B 4A                       J
        clc                                     ; D75C 18                       .
        adc     #$29                            ; D75D 69 29                    i)
        jsr     winprintsprite                  ; D75F 20 3A EE                  :.
@n2:  rts                                     ; D762 60                       `

; ----------------------------------------------------------------------------
takearrowoffrou:
        lda     arrowxl,x                       ; D763 BD 29 04                 .).
        sta     deadarrowx                      ; D766 8D 24 03                 .$.
        lda     arrowxh,x                       ; D769 BD 31 04                 .1.
        sta     $0325                           ; D76C 8D 25 03                 .%.
        lda     arrowy,x                        ; D76F BD 39 04                 .9.
        sta     deadarrowy                      ; D772 8D 26 03                 .&.
        lda     #$08                            ; D775 A9 08                    ..
        sta     deadarrowcount                  ; D777 8D 27 03                 .'.
        lda     #$00                            ; D77A A9 00                    ..
        sta     arrowy,x                        ; D77C 9D 39 04                 .9.
        sta     arrowcounter,x                  ; D77F 9D 51 04                 .Q.
        rts                                     ; D782 60                       `

; ----------------------------------------------------------------------------
dectiming:
        ldx     extravarpointer                 ; D783 A6 4C                    .L
        lda     extravars,x                     ; D785 BD A9 03                 ...
        beq     dotimingproblem                 ; D788 F0 0A                    ..
        lda     counter                         ; D78A A5 10                    ..
        and     #$07                            ; D78C 29 07                    ).
        bne     @n3                           ; D78E D0 03                    ..
        dec     extravars,x                     ; D790 DE A9 03                 ...
@n3:  rts                                     ; D793 60                       `

; enter with a=number of paras through data,start of times
; ----------------------------------------------------------------------------
dotimingproblem:
        tya                                     ; D794 98                       .
        eor     #$FF                            ; D795 49 FF                    I.
        clc                                     ; D797 18                       .
        adc     noofparas                       ; D798 65 4B                    eK
        sta     temp                            ; D79A 85 31                    .1
        ldx     extravarpointer                 ; D79C A6 4C                    .L
        inc     $03AA,x                         ; D79E FE AA 03                 ...
        lda     $03AA,x                         ; D7A1 BD AA 03                 ...
        cmp     temp                            ; D7A4 C5 31                    .1
        bne     @n4                           ; D7A6 D0 05                    ..
        lda     #$00                            ; D7A8 A9 00                    ..
        sta     $03AA,x                         ; D7AA 9D AA 03                 ...
@n4:  sta     temp                            ; D7AD 85 31                    .1
        inc     temp                            ; D7AF E6 31                    .1
@n5:  iny                                     ; D7B1 C8                       .
        dec     temp                            ; D7B2 C6 31                    .1
        bne     @n5                           ; D7B4 D0 FB                    ..
        lda     (address9),y                    ; D7B6 B1 2D                    .-
        sta     extravars,x                     ; D7B8 9D A9 03                 ...
        rts                                     ; D7BB 60                       `

; format x,y+128*start on,block,on,off,(on,off etc) ;128=start off
; ----------------------------------------------------------------------------
; ==========================================================================
; XTRAROUS.ROU
; ==========================================================================
flashblock:
        lda     extravars,x                     ; D7BC BD A9 03                 ...
        bne     endflashblock                   ; D7BF D0 31                    .1
        lda     (address9),y                    ; D7C1 B1 2D                    .-
        sta     toplevvar1                      ; D7C3 85 11                    ..
        sec                                     ; D7C5 38                       8
        sbc     mapstrip                        ; D7C6 E5 3D                    .=
        clc                                     ; D7C8 18                       .
        adc     #$10                            ; D7C9 69 10                    i.
        cmp     #$30                            ; D7CB C9 30                    .0
        bcs     endflashblock                   ; D7CD B0 23                    .#
        iny                                     ; D7CF C8                       .
        lda     (address9),y                    ; D7D0 B1 2D                    .-
        and     #$1F                            ; D7D2 29 1F                    ).
        sta     toplevvar2                      ; D7D4 85 12                    ..
        lda     (address9),y                    ; D7D6 B1 2D                    .-
        rol     a                               ; D7D8 2A                       *
        iny                                     ; D7D9 C8                       .
        lda     (address9),y                    ; D7DA B1 2D                    .-
        sta     toplevvar3                      ; D7DC 85 13                    ..
        sty     tempy                           ; D7DE 84 30                    .0
        lda     $03AA,x                         ; D7E0 BD AA 03                 ...
        adc     #$00                            ; D7E3 69 00                    i.
        and     #$01                            ; D7E5 29 01                    ).
        bne     turnblockoff                    ; D7E7 D0 06                    ..
        jsr     addachangedblock1               ; D7E9 20 5E FA                  ^.
        jmp     endflashblock                   ; D7EC 4C F2 D7                 L..

; ----------------------------------------------------------------------------
turnblockoff:
        jsr     deleteachangedblock1            ; D7EF 20 C4 FA                  ..
endflashblock:
        ldy     #$04                            ; D7F2 A0 04                    ..
        jsr     dectiming                       ; D7F4 20 83 D7                  ..
        lda     #$02                            ; D7F7 A9 02                    ..
        jmp     backfromrou                     ; D7F9 4C C7 CE                 L..

; format X,X,extrano,xstrip,y,speed of arrow,128*height+col*32+num to kill,count,(count,count etc)
; ----------------------------------------------------------------------------
standguard:
        jsr     checkifextraon                  ; D7FC 20 2F D4                  /.
        bne     @n2                           ; D7FF D0 03                    ..
        jmp     guardturnedoff                  ; D801 4C 09 D9                 L..

; ----------------------------------------------------------------------------
@n2:  ldy     #$03                            ; D804 A0 03                    ..
        lda     (address9),y                    ; D806 B1 2D                    .-
        sec                                     ; D808 38                       8
        sbc     mapstrip                        ; D809 E5 3D                    .=
        clc                                     ; D80B 18                       .
        adc     #$08                            ; D80C 69 08                    i.
        cmp     #$22                            ; D80E C9 22                    ."
        bcc     @n3                           ; D810 90 03                    ..
        jmp     veryendstandguard               ; D812 4C 04 D9                 L..

; ----------------------------------------------------------------------------
@n3:  lda     (address9),y                    ; D815 B1 2D                    .-
        jsr     multstripby16                   ; D817 20 F6 C1                  ..
        sta     address7                        ; D81A 85 29                    .)
        ldx     extravarpointer                 ; D81C A6 4C                    .L
        lda     extravars,x                     ; D81E BD A9 03                 ...
        bne     printtheguard                   ; D821 D0 28                    .(
        ldy     #$06                            ; D823 A0 06                    ..
        lda     (address9),y                    ; D825 B1 2D                    .-
        sta     temp                            ; D827 85 31                    .1
        ldy     #$04                            ; D829 A0 04                    ..
        lda     (address9),y                    ; D82B B1 2D                    .-
        clc                                     ; D82D 18                       .
        adc     #$EA                            ; D82E 69 EA                    i.
        bit     temp                            ; D830 24 31                    $1
        bpl     @n4                           ; D832 10 03                    ..
        clc                                     ; D834 18                       .
        adc     #$F9                            ; D835 69 F9                    i.
@n4:  iny                                     ; D837 C8                       .
        jsr     shootarrow                      ; D838 20 29 D6                  ).
        lda     #$0B                            ; D83B A9 0B                    ..
        jsr     soundfx                         ; D83D 20 28 F4                  (.
        ldx     extravarpointer                 ; D840 A6 4C                    .L
        lda     $03AB,x                         ; D842 BD AB 03                 ...
        clc                                     ; D845 18                       .
        adc     #$40                            ; D846 69 40                    i@
        sta     $03AB,x                         ; D848 9D AB 03                 ...
printtheguard:
        lda     address7                        ; D84B A5 29                    .)
        sec                                     ; D84D 38                       8
        sbc     scrxl                           ; D84E E5 3B                    .;
        sta     address8                        ; D850 85 2B                    .+
        lda     $2A                             ; D852 A5 2A                    .*
        sbc     scrxh                           ; D854 E5 3C                    .<
        sta     a:temp7                         ; D856 8D 38 00                 .8.
        bne     @n5                           ; D859 D0 17                    ..
        ; col guard with robin
        jsr     pickupcollision1                ; D85B 20 F9 D3                  ..
        bcs     @n5                           ; D85E B0 12                    ..
        lda     robininvinc                     ; D860 AD 1C 03                 ...
        bne     @n5                           ; D863 D0 0D                    ..
        lda     #$01                            ; D865 A9 01                    ..
        sta     $03AB,x                         ; D867 9D AB 03                 ...
        lda     #$03                            ; D86A A9 03                    ..
        jsr     subfromhearts                   ; D86C 20 97 F5                  ..
        jmp     @n7                           ; D86F 4C 9A D8                 L..

; ----------------------------------------------------------------------------
@n5:  lda     $03AB,x                         ; D872 BD AB 03                 ...
        and     #$0F                            ; D875 29 0F                    ).
        tay                                     ; D877 A8                       .
        bne     @n6                           ; D878 D0 0B                    ..
        ldy     #$06                            ; D87A A0 06                    ..
        lda     (address9),y                    ; D87C B1 2D                    .-
        and     #$0F                            ; D87E 29 0F                    ).
        sta     $03AB,x                         ; D880 9D AB 03                 ...
        bne     @n5                           ; D883 D0 ED                    ..
@n6:  lda     guardcolours,y                  ; D885 B9 0E D9                 ...
        sta     a:$67                           ; D888 8D 67 00                 .g.
        lda     arrowcounter                    ; D88B AD 51 04                 .Q.
        beq     @n2                           ; D88E F0 40                    .@
        jsr     collidewitharrow                ; D890 20 17 D9                  ..
        bcs     @n2                           ; D893 B0 3B                    .;
        ldx     #$00                            ; D895 A2 00                    ..
        jsr     takearrowoffrou                 ; D897 20 63 D7                  c.
; decing number of times guard hit
@n7:  ldx     extravarpointer                 ; D89A A6 4C                    .L
        dec     $03AB,x                         ; D89C DE AB 03                 ...
        ldy     #$04                            ; D89F A0 04                    ..
        lda     (address9),y                    ; D8A1 B1 2D                    .-
        sta     $2C                             ; D8A3 85 2C                    .,
        lda     $03AB,x                         ; D8A5 BD AB 03                 ...
        and     #$0F                            ; D8A8 29 0F                    ).
        bne     @n1                           ; D8AA D0 15                    ..
        jsr     turnoffextra                    ; D8AC 20 41 D4                  A.
        lda     #$05                            ; D8AF A9 05                    ..
        ; large explosion for guard
        jsr     startstars                      ; D8B1 20 EF D4                  ..
        lda     #$1D                            ; D8B4 A9 1D                    ..
        jsr     soundfx                         ; D8B6 20 28 F4                  (.
        lda     #$45                            ; D8B9 A9 45                    .E
        jsr     addtoscore                      ; D8BB 20 4B F5                  K.
        jmp     @n2                           ; D8BE 4C D0 D8                 L..

; small explosion for guard
; ----------------------------------------------------------------------------
@n1:  lda     #$04                            ; D8C1 A9 04                    ..
        jsr     startstars                      ; D8C3 20 EF D4                  ..
        lda     #$42                            ; D8C6 A9 42                    .B
        jsr     addtoscore                      ; D8C8 20 4B F5                  K.
        lda     #$1B                            ; D8CB A9 1B                    ..
        jsr     soundfx                         ; D8CD 20 28 F4                  (.
@n2:  ldx     extravarpointer                 ; D8D0 A6 4C                    .L
        lda     $03AB,x                         ; D8D2 BD AB 03                 ...
        and     #$F0                            ; D8D5 29 F0                    ).
        beq     @n3                           ; D8D7 F0 0B                    ..
        lda     $03AB,x                         ; D8D9 BD AB 03                 ...
        clc                                     ; D8DC 18                       .
        adc     #$F0                            ; D8DD 69 F0                    i.
        sta     $03AB,x                         ; D8DF 9D AB 03                 ...
        lda     #$02                            ; D8E2 A9 02                    ..
@n3:  sta     temp2                           ; D8E4 85 33                    .3
        ldy     #$04                            ; D8E6 A0 04                    ..
        lda     (address9),y                    ; D8E8 B1 2D                    .-
        sta     temp                            ; D8EA 85 31                    .1
        iny                                     ; D8EC C8                       .
        lda     (address9),y                    ; D8ED B1 2D                    .-
        asl     a                               ; D8EF 0A                       .
        php                                     ; D8F0 08                       .
        iny                                     ; D8F1 C8                       .
        lda     (address9),y                    ; D8F2 B1 2D                    .-
        asl     a                               ; D8F4 0A                       .
        lda     #$37                            ; D8F5 A9 37                    .7
        adc     #$00                            ; D8F7 69 00                    i.
        clc                                     ; D8F9 18                       .
        adc     temp2                           ; D8FA 65 33                    e3
        plp                                     ; D8FC 28                       (
        ldx     address8                        ; D8FD A6 2B                    .+
        ldy     temp                            ; D8FF A4 31                    .1
        jsr     winprintspriteposrev            ; D901 20 3B EE                  ;.
veryendstandguard:
        ldy     #$06                            ; D904 A0 06                    ..
        jsr     dectiming                       ; D906 20 83 D7                  ..
guardturnedoff:
        lda     #$03                            ; D909 A9 03                    ..
        jmp     backfromrou                     ; D90B 4C C7 CE                 L..

; ----------------------------------------------------------------------------
guardcolours:
        .byte   $FF,$03,$01,$00,$02,$02,$02,$02 ; D90E FF 03 01 00 02 02 02 02  ........
        .byte   $02                             ; D916 02                       .
; ----------------------------------------------------------------------------
collidewitharrow:
        ldy     #$04                            ; D917 A0 04                    ..
        lda     (address9),y                    ; D919 B1 2D                    .-
        sec                                     ; D91B 38                       8
        sbc     arrowy                          ; D91C ED 39 04                 .9.
        cmp     #$20                            ; D91F C9 20                    . 
        bcs     notcollidewitharrow             ; D921 B0 1C                    ..
; lda (address9),y
collidebatwitharrow:
        lda     address7                        ; D923 A5 29                    .)
        sec                                     ; D925 38                       8
        sbc     arrowxl                         ; D926 ED 29 04                 .).
        sta     temp                            ; D929 85 31                    .1
        ; lda (address9),y
        lda     $2A                             ; D92B A5 2A                    .*
        sbc     arrowxh                         ; D92D ED 31 04                 .1.
        tax                                     ; D930 AA                       .
        lda     temp                            ; D931 A5 31                    .1
        clc                                     ; D933 18                       .
        adc     #$0C                            ; D934 69 0C                    i.
        bcc     @n1                           ; D936 90 01                    ..
        inx                                     ; D938 E8                       .
@n1:  cpx     #$00                            ; D939 E0 00                    ..
        bne     notcollidewitharrow             ; D93B D0 02                    ..
        cmp     #$18                            ; D93D C9 18                    ..
notcollidewitharrow:
        rts                                     ; D93F 60                       `

; format X,X,num,>minx,<minx,>maxx,<manx,y
; always starts off and min coord
; ----------------------------------------------------------------------------
platformh:
        iny                                     ; D940 C8                       .
        lda     (address9),y                    ; D941 B1 2D                    .-
        sec                                     ; D943 38                       8
        sbc     scrxl                           ; D944 E5 3B                    .;
        iny                                     ; D946 C8                       .
        lda     (address9),y                    ; D947 B1 2D                    .-
        sbc     scrxh                           ; D949 E5 3C                    .<
        clc                                     ; D94B 18                       .
        adc     #$01                            ; D94C 69 01                    i.
        bmi     endplatformh                    ; D94E 30 5E                    0^
        iny                                     ; D950 C8                       .
        lda     (address9),y                    ; D951 B1 2D                    .-
        sec                                     ; D953 38                       8
        sbc     scrxl                           ; D954 E5 3B                    .;
        iny                                     ; D956 C8                       .
        lda     (address9),y                    ; D957 B1 2D                    .-
        sbc     scrxh                           ; D959 E5 3C                    .<
        cmp     #$03                            ; D95B C9 03                    ..
        bcs     endplatformh                    ; D95D B0 4F                    .O
        jsr     moveplatformh                   ; D95F 20 FA D9                  ..
        ldx     extravarpointer                 ; D962 A6 4C                    .L
        lda     a:temp7                         ; D964 AD 38 00                 .8.
        bne     endplatformh                    ; D967 D0 45                    .E
        jsr     collplatwithrob                 ; D969 20 B3 D9                  ..
        bcs     endplatformh                    ; D96C B0 40                    .@
        lda     $03AC,x                         ; D96E BD AC 03                 ...
        beq     @n5                           ; D971 F0 1C                    ..
        bmi     @n3                           ; D973 30 0B                    0.
        inc     robinxl                         ; D975 EE 08 03                 ...
        bne     @n2                           ; D978 D0 03                    ..
        inc     robinxh                         ; D97A EE 09 03                 ...
@n2:  jmp     @n5                           ; D97D 4C 8F D9                 L..

; ----------------------------------------------------------------------------
@n3:  dec     robinxl                         ; D980 CE 08 03                 ...
        pha                                     ; D983 48                       H
        lda     #$FF                            ; D984 A9 FF                    ..
        cmp     robinxl                         ; D986 CD 08 03                 ...
        bne     @n4                           ; D989 D0 03                    ..
        dec     robinxh                         ; D98B CE 09 03                 ...
@n4:  pla                                     ; D98E 68                       h
@n5:  lda     orobinxl                        ; D98F AD 0E 03                 ...
        cmp     robinxl                         ; D992 CD 08 03                 ...
        beq     platnotmoving                   ; D995 F0 14                    ..
        bcc     platmovingright                 ; D997 90 0A                    ..
        jsr     findwallleft                    ; D999 20 F9 CC                  ..
        beq     platnotmoving                   ; D99C F0 0D                    ..
        jsr     restorex                        ; D99E 20 DD CA                  ..
        beq     platnotmoving                   ; D9A1 F0 08                    ..
platmovingright:
        jsr     findwallright                   ; D9A3 20 3A CD                  :.
        beq     platnotmoving                   ; D9A6 F0 03                    ..
        jsr     restorex                        ; D9A8 20 DD CA                  ..
platnotmoving:
        jsr     robinjumpoffplatform            ; D9AB 20 9B DA                  ..
endplatformh:
        lda     #$04                            ; D9AE A9 04                    ..
        jmp     backfromrou                     ; D9B0 4C C7 CE                 L..

; ----------------------------------------------------------------------------
collplatwithrob:
        lda     $03AB,x                         ; D9B3 BD AB 03                 ...
        sec                                     ; D9B6 38                       8
        sbc     robiny                          ; D9B7 ED 0A 03                 ...
        clc                                     ; D9BA 18                       .
        adc     #$04                            ; D9BB 69 04                    i.
        cmp     #$06                            ; D9BD C9 06                    ..
        bcs     @n1                           ; D9BF B0 0B                    ..
        lda     address7                        ; D9C1 A5 29                    .)
        sec                                     ; D9C3 38                       8
        sbc     robinonscrx                     ; D9C4 ED 0B 03                 ...
        clc                                     ; D9C7 18                       .
        adc     #$0E                            ; D9C8 69 0E                    i.
        cmp     #$1C                            ; D9CA C9 1C                    ..
@n1:  rts                                     ; D9CC 60                       `

; ----------------------------------------------------------------------------
checkifplaton:
        lda     $03AC,x                         ; D9CD BD AC 03                 ...
        bne     @n2                           ; D9D0 D0 24                    .$
        ldy     #$03                            ; D9D2 A0 03                    ..
        lda     (address9),y                    ; D9D4 B1 2D                    .-
        sta     extravars,x                     ; D9D6 9D A9 03                 ...
        iny                                     ; D9D9 C8                       .
        lda     (address9),y                    ; D9DA B1 2D                    .-
        sta     $03AA,x                         ; D9DC 9D AA 03                 ...
        ldy     #$07                            ; D9DF A0 07                    ..
        lda     (address9),y                    ; D9E1 B1 2D                    .-
        sta     $03AB,x                         ; D9E3 9D AB 03                 ...
        ldy     #$02                            ; D9E6 A0 02                    ..
        jsr     checkifextraon                  ; D9E8 20 2F D4                  /.
        ldx     extravarpointer                 ; D9EB A6 4C                    .L
        cmp     #$00                            ; D9ED C9 00                    ..
        bne     @n3                           ; D9EF D0 06                    ..
        lda     #$01                            ; D9F1 A9 01                    ..
        sta     $03AC,x                         ; D9F3 9D AC 03                 ...
@n2:  rts                                     ; D9F6 60                       `

; ----------------------------------------------------------------------------
@n3:  lda     #$00                            ; D9F7 A9 00                    ..
        rts                                     ; D9F9 60                       `

; ----------------------------------------------------------------------------
moveplatformh:
        jsr     checkifplaton                   ; D9FA 20 CD D9                  ..
        beq     printplatform                   ; D9FD F0 35                    .5
        bmi     plathminus                      ; D9FF 30 0D                    0.
        ldy     #$05                            ; DA01 A0 05                    ..
        inc     extravars,x                     ; DA03 FE A9 03                 ...
        bne     @n4                           ; DA06 D0 03                    ..
        inc     $03AA,x                         ; DA08 FE AA 03                 ...
@n4:  jmp     movedplath                      ; DA0B 4C 1D DA                 L..

; ----------------------------------------------------------------------------
plathminus:
        ldy     #$03                            ; DA0E A0 03                    ..
        dec     extravars,x                     ; DA10 DE A9 03                 ...
        lda     extravars,x                     ; DA13 BD A9 03                 ...
        cmp     #$FF                            ; DA16 C9 FF                    ..
        bne     movedplath                      ; DA18 D0 03                    ..
        dec     $03AA,x                         ; DA1A DE AA 03                 ...
movedplath:
        lda     extravars,x                     ; DA1D BD A9 03                 ...
        cmp     (address9),y                    ; DA20 D1 2D                    .-
        bne     printplatform                   ; DA22 D0 10                    ..
        iny                                     ; DA24 C8                       .
        lda     $03AA,x                         ; DA25 BD AA 03                 ...
        cmp     (address9),y                    ; DA28 D1 2D                    .-
        bne     printplatform                   ; DA2A D0 08                    ..
reverseplatdir:
        lda     $03AC,x                         ; DA2C BD AC 03                 ...
        eor     #$FF                            ; DA2F 49 FF                    I.
        sta     $03AC,x                         ; DA31 9D AC 03                 ...
printplatform:
        lda     extravars,x                     ; DA34 BD A9 03                 ...
        sec                                     ; DA37 38                       8
        sbc     scrxl                           ; DA38 E5 3B                    .;
        sta     address7                        ; DA3A 85 29                    .)
        lda     $03AA,x                         ; DA3C BD AA 03                 ...
        sbc     scrxh                           ; DA3F E5 3C                    .<
        sta     a:temp7                         ; DA41 8D 38 00                 .8.
        ldy     $03AB,x                         ; DA44 BC AB 03                 ...
        sty     $2A                             ; DA47 84 2A                    .*
        ldx     address7                        ; DA49 A6 29                    .)
        lda     #$25                            ; DA4B A9 25                    .%
        jmp     winprintsprite                  ; DA4D 4C 3A EE                 L:.

; format X,X,num,>x,<x,X,maxy,miny
; always starts off and min coord
; ----------------------------------------------------------------------------
platformv:
        iny                                     ; DA50 C8                       .
        lda     (address9),y                    ; DA51 B1 2D                    .-
        sec                                     ; DA53 38                       8
        sbc     scrxl                           ; DA54 E5 3B                    .;
        iny                                     ; DA56 C8                       .
        lda     (address9),y                    ; DA57 B1 2D                    .-
        sbc     scrxh                           ; DA59 E5 3C                    .<
        clc                                     ; DA5B 18                       .
        adc     #$01                            ; DA5C 69 01                    i.
        cmp     #$03                            ; DA5E C9 03                    ..
        bcs     endplatformv                    ; DA60 B0 12                    ..
        jsr     moveplatformv                   ; DA62 20 79 DA                  y.
        ldx     extravarpointer                 ; DA65 A6 4C                    .L
        lda     a:temp7                         ; DA67 AD 38 00                 .8.
        bne     endplatformv                    ; DA6A D0 08                    ..
        jsr     collplatwithrob                 ; DA6C 20 B3 D9                  ..
        bcs     endplatformv                    ; DA6F B0 03                    ..
        jsr     robinjumpoffplatform            ; DA71 20 9B DA                  ..
endplatformv:
        lda     #$04                            ; DA74 A9 04                    ..
        jmp     backfromrou                     ; DA76 4C C7 CE                 L..

; ----------------------------------------------------------------------------
moveplatformv:
        lda     counter                         ; DA79 A5 10                    ..
        and     #$01                            ; DA7B 29 01                    ).
        bne     printplatform                   ; DA7D D0 B5                    ..
        jsr     checkifplaton                   ; DA7F 20 CD D9                  ..
        beq     printplatform                   ; DA82 F0 B0                    ..
        bmi     plathminusv                     ; DA84 30 07                    0.
        ldy     #$06                            ; DA86 A0 06                    ..
        inc     $03AB,x                         ; DA88 FE AB 03                 ...
        bne     movedplathv                     ; DA8B D0 05                    ..
plathminusv:
        ldy     #$07                            ; DA8D A0 07                    ..
        dec     $03AB,x                         ; DA8F DE AB 03                 ...
movedplathv:
        lda     $03AB,x                         ; DA92 BD AB 03                 ...
        cmp     (address9),y                    ; DA95 D1 2D                    .-
        beq     reverseplatdir                  ; DA97 F0 93                    ..
        bne     printplatform                   ; DA99 D0 99                    ..
robinjumpoffplatform:
        lda     robingravity                    ; DA9B AD 18 03                 ...
        cmp     #$80                            ; DA9E C9 80                    ..
        beq     @n1                           ; DAA0 F0 04                    ..
        cmp     #$00                            ; DAA2 C9 00                    ..
        bmi     endjumpoffplatform              ; DAA4 30 18                    0.
@n1:  lda     #$00                            ; DAA6 A9 00                    ..
        sta     robinjumping                    ; DAA8 8D 17 03                 ...
        lda     $2A                             ; DAAB A5 2A                    .*
        sta     robiny                          ; DAAD 8D 0A 03                 ...
        lda     #$80                            ; DAB0 A9 80                    ..
        sta     robingravity                    ; DAB2 8D 18 03                 ...
        lda     pad                             ; DAB5 A5 07                    ..
        and     #$80                            ; DAB7 29 80                    ).
        beq     endjumpoffplatform              ; DAB9 F0 03                    ..
        jmp     jumpingok                       ; DABB 4C 48 C7                 LH.

; ----------------------------------------------------------------------------
endjumpoffplatform:
        rts                                     ; DABE 60                       `

; format X,X,num,xstrip,y
; ----------------------------------------------------------------------------
keyrou: jsr     checkifextraon                  ; DABF 20 2F D4                  /.
        beq     @n4                           ; DAC2 F0 6B                    .k
        ldy     #$03                            ; DAC4 A0 03                    ..
        lda     (address9),y                    ; DAC6 B1 2D                    .-
        sec                                     ; DAC8 38                       8
        sbc     mapstrip                        ; DAC9 E5 3D                    .=
        cmp     #$12                            ; DACB C9 12                    ..
        bcs     @n4                           ; DACD B0 60                    .`
        lda     (address9),y                    ; DACF B1 2D                    .-
        jsr     multstripby16sub                ; DAD1 20 00 C2                  ..
        jsr     pickupcollision1                ; DAD4 20 F9 D3                  ..
        bcs     @n3                           ; DAD7 B0 3E                    .>
        sty     $2C                             ; DAD9 84 2C                    .,
        ldy     #$03                            ; DADB A0 03                    ..
        lda     (address9),y                    ; DADD B1 2D                    .-
        tay                                     ; DADF A8                       .
        lda     times16lo,y                     ; DAE0 B9 1A C0                 ...
        sta     address7                        ; DAE3 85 29                    .)
        lda     times16hi,y                     ; DAE5 B9 1E C1                 ...
        sta     $2A                             ; DAE8 85 2A                    .*
        lda     #$03                            ; DAEA A9 03                    ..
        ; start key explosion keys
        jsr     startstars                      ; DAEC 20 EF D4                  ..
        lda     #$31                            ; DAEF A9 31                    .1
        jsr     addtoscore                      ; DAF1 20 4B F5                  K.
        lda     #$45                            ; DAF4 A9 45                    .E
        jsr     addtoscore                      ; DAF6 20 4B F5                  K.
        jsr     turnoffextra                    ; DAF9 20 41 D4                  A.
        lda     #$11                            ; DAFC A9 11                    ..
        jsr     soundfx                         ; DAFE 20 28 F4                  (.
        ldy     #$05                            ; DB01 A0 05                    ..
        lda     (address9),y                    ; DB03 B1 2D                    .-
        beq     @n4                           ; DB05 F0 28                    .(
        cmp     #$ED                            ; DB07 C9 ED                    ..
        bcs     @n2                           ; DB09 B0 06                    ..
        ; this turns on lifts
        jsr     turnoffdoor                     ; DB0B 20 45 D4                  E.
        jmp     @n4                           ; DB0E 4C 2F DB                 L/.

; ----------------------------------------------------------------------------
@n2:  jsr     openadoor                       ; DB11 20 A0 D5                  ..
        jmp     @n4                           ; DB14 4C 2F DB                 L/.

; ----------------------------------------------------------------------------
@n3:  lda     a:temp7                         ; DB17 AD 38 00                 .8.
        bne     @n4                           ; DB1A D0 13                    ..
        lda     #$01                            ; DB1C A9 01                    ..
        sta     temp                            ; DB1E 85 31                    .1
        ; make keys pulse
        lda     counter                         ; DB20 A5 10                    ..
        lsr     a                               ; DB22 4A                       J
        lsr     a                               ; DB23 4A                       J
        and     #$03                            ; DB24 29 03                    ).
        sta     temp                            ; DB26 85 31                    .1
        ldx     address8                        ; DB28 A6 2B                    .+
        lda     #$9B                            ; DB2A A9 9B                    ..
        jsr     pokesprite2by2                  ; DB2C 20 EB EF                  ..
@n4:  jmp     backfromrounovars               ; DB2F 4C CC CE                 L..

; ----------------------------------------------------------------------------
updatespitters:
        lda     counter                         ; DB32 A5 10                    ..
        asl     a                               ; DB34 0A                       .
        asl     a                               ; DB35 0A                       .
        asl     a                               ; DB36 0A                       .
        asl     a                               ; DB37 0A                       .
        and     #$C0                            ; DB38 29 C0                    ).
        clc                                     ; DB3A 18                       .
        adc     #$03                            ; DB3B 69 03                    i.
        sta     temp                            ; DB3D 85 31                    .1
        ldx     #$03                            ; DB3F A2 03                    ..
loopspit:
        stx     temp8                           ; DB41 86 39                    .9
        lda     spittery,x                      ; DB43 BD 61 04                 .a.
        beq     endloopspit                     ; DB46 F0 56                    .V
        inc     spittery,x                      ; DB48 FE 61 04                 .a.
        inc     spittery,x                      ; DB4B FE 61 04                 .a.
        lda     spittery,x                      ; DB4E BD 61 04                 .a.
        cmp     #$DC                            ; DB51 C9 DC                    ..
        bcs     takespitoff1                    ; DB53 B0 44                    .D
        ldy     #$02                            ; DB55 A0 02                    ..
        lda     spitterdir,x                    ; DB57 BD 65 04                 .e.
        bpl     @n5                           ; DB5A 10 02                    ..
        ldy     #$FE                            ; DB5C A0 FE                    ..
@n5:  tya                                     ; DB5E 98                       .
        clc                                     ; DB5F 18                       .
        adc     spitterxl,x                     ; DB60 7D 59 04                 }Y.
        sta     spitterxl,x                     ; DB63 9D 59 04                 .Y.
        lda     spitterxh,x                     ; DB66 BD 5D 04                 .].
        adc     spitterdir,x                    ; DB69 7D 65 04                 }e.
        sta     spitterxh,x                     ; DB6C 9D 5D 04                 .].
        lda     spitterxl,x                     ; DB6F BD 59 04                 .Y.
        sec                                     ; DB72 38                       8
        sbc     scrxl                           ; DB73 E5 3B                    .;
        sta     temp9                           ; DB75 85 3A                    .:
        lda     spitterxh,x                     ; DB77 BD 5D 04                 .].
        sbc     scrxh                           ; DB7A E5 3C                    .<
        bne     endloopspit                     ; DB7C D0 20                    . 
        lda     spittery,x                      ; DB7E BD 61 04                 .a.
        sta     address7                        ; DB81 85 29                    .)
        clc                                     ; DB83 18                       .
        adc     #$0C                            ; DB84 69 0C                    i.
        tay                                     ; DB86 A8                       .
        ldx     temp9                           ; DB87 A6 3A                    .:
        lda     #$99                            ; DB89 A9 99                    ..
        jsr     pokesprite                      ; DB8B 20 CD EF                  ..
        ldy     address7                        ; DB8E A4 29                    .)
        ldx     temp9                           ; DB90 A6 3A                    .:
        jsr     checkchrcollision               ; DB92 20 A4 DB                  ..
        bcc     endloopspit                     ; DB95 90 07                    ..
        ldx     temp8                           ; DB97 A6 39                    .9
takespitoff1:
        lda     #$00                            ; DB99 A9 00                    ..
        sta     spittery,x                      ; DB9B 9D 61 04                 .a.
endloopspit:
        ldx     temp8                           ; DB9E A6 39                    .9
        dex                                     ; DBA0 CA                       .
        bpl     loopspit                        ; DBA1 10 9E                    ..
        rts                                     ; DBA3 60                       `

; for spitter
; enter x,y
; ----------------------------------------------------------------------------
checkchrcollision:
        txa                                     ; DBA4 8A                       .
        sec                                     ; DBA5 38                       8
        sbc     robinonscrx                     ; DBA6 ED 0B 03                 ...
        clc                                     ; DBA9 18                       .
        adc     #$0A                            ; DBAA 69 0A                    i.
        cmp     #$14                            ; DBAC C9 14                    ..
        bcs     spitnocollision                 ; DBAE B0 1A                    ..
        tya                                     ; DBB0 98                       .
        sec                                     ; DBB1 38                       8
        sbc     robiny                          ; DBB2 ED 0A 03                 ...
        bcs     spitnocollision                 ; DBB5 B0 13                    ..
        tya                                     ; DBB7 98                       .
        sec                                     ; DBB8 38                       8
        sbc     robinheight                     ; DBB9 ED 16 03                 ...
        bcc     spitnocollision                 ; DBBC 90 0C                    ..
        lda     robininvinc                     ; DBBE AD 1C 03                 ...
        bne     spitnocollision                 ; DBC1 D0 07                    ..
        lda     #$01                            ; DBC3 A9 01                    ..
        ; spit has hit robin
        jsr     subfromhearts                   ; DBC5 20 97 F5                  ..
        sec                                     ; DBC8 38                       8
        rts                                     ; DBC9 60                       `

; ----------------------------------------------------------------------------
spitnocollision:
        clc                                     ; DBCA 18                       .
        rts                                     ; DBCB 60                       `

; format X,X,xstrip,y,speed of arrow,count,(count,count etc)
; ----------------------------------------------------------------------------
canonrou:
        lda     (address9),y                    ; DBCC B1 2D                    .-
        sec                                     ; DBCE 38                       8
        sbc     mapstrip                        ; DBCF E5 3D                    .=
        clc                                     ; DBD1 18                       .
        adc     #$08                            ; DBD2 69 08                    i.
        cmp     #$22                            ; DBD4 C9 22                    ."
        bcs     veryendcanon                    ; DBD6 B0 37                    .7
        lda     (address9),y                    ; DBD8 B1 2D                    .-
        jsr     multstripby16                   ; DBDA 20 F6 C1                  ..
        sta     address7                        ; DBDD 85 29                    .)
        lda     extravars,x                     ; DBDF BD A9 03                 ...
        bne     endcanon                        ; DBE2 D0 0D                    ..
        ldy     #$03                            ; DBE4 A0 03                    ..
        lda     (address9),y                    ; DBE6 B1 2D                    .-
        iny                                     ; DBE8 C8                       .
        jsr     shootarrow                      ; DBE9 20 29 D6                  ).
        lda     #$02                            ; DBEC A9 02                    ..
        sta     arrowcanon,x                    ; DBEE 9D 49 04                 .I.
endcanon:
        lda     address7                        ; DBF1 A5 29                    .)
        sec                                     ; DBF3 38                       8
        sbc     scrxl                           ; DBF4 E5 3B                    .;
        tax                                     ; DBF6 AA                       .
        lda     $2A                             ; DBF7 A5 2A                    .*
        sbc     scrxh                           ; DBF9 E5 3C                    .<
        sta     a:temp7                         ; DBFB 8D 38 00                 .8.
        ldy     #$03                            ; DBFE A0 03                    ..
        lda     (address9),y                    ; DC00 B1 2D                    .-
        sta     temp                            ; DC02 85 31                    .1
        iny                                     ; DC04 C8                       .
        lda     (address9),y                    ; DC05 B1 2D                    .-
        asl     a                               ; DC07 0A                       .
        lda     #$24                            ; DC08 A9 24                    .$
        ldy     temp                            ; DC0A A4 31                    .1
        jsr     winprintspriteposrev            ; DC0C 20 3B EE                  ;.
veryendcanon:
        ldy     #$04                            ; DC0F A0 04                    ..
        jsr     dectiming                       ; DC11 20 83 D7                  ..
        lda     #$02                            ; DC14 A9 02                    ..
        jmp     backfromrou                     ; DC16 4C C7 CE                 L..

; format X,X,num,xstrip,y,secret num
; ----------------------------------------------------------------------------
secretrou:
        jsr     checkifextraon                  ; DC19 20 2F D4                  /.
        beq     @n1                           ; DC1C F0 38                    .8
        ldy     #$03                            ; DC1E A0 03                    ..
        lda     (address9),y                    ; DC20 B1 2D                    .-
        sec                                     ; DC22 38                       8
        sbc     mapstrip                        ; DC23 E5 3D                    .=
        cmp     #$12                            ; DC25 C9 12                    ..
        bcs     @n1                           ; DC27 B0 2D                    .-
        lda     (address9),y                    ; DC29 B1 2D                    .-
        jsr     multstripby16sub                ; DC2B 20 00 C2                  ..
        jsr     pickupcollision1                ; DC2E 20 F9 D3                  ..
        bcs     @n1                           ; DC31 B0 23                    .#
        jsr     turnoffextra                    ; DC33 20 41 D4                  A.
        ldy     #$05                            ; DC36 A0 05                    ..
        lda     (address9),y                    ; DC38 B1 2D                    .-
        tay                                     ; DC3A A8                       .
        and     #$07                            ; DC3B 29 07                    ).
        tax                                     ; DC3D AA                       .
        tya                                     ; DC3E 98                       .
        lsr     a                               ; DC3F 4A                       J
        lsr     a                               ; DC40 4A                       J
        lsr     a                               ; DC41 4A                       J
        tay                                     ; DC42 A8                       .
        lda     $0660,y                         ; DC43 B9 60 06                 .`.
        eor     bitpattern,x                    ; DC46 5D 27 D4                 ]'.
        sta     $0660,y                         ; DC49 99 60 06                 .`.
        ldy     #$05                            ; DC4C A0 05                    ..
        lda     (address9),y                    ; DC4E B1 2D                    .-
        jsr     turnonsecret                    ; DC50 20 79 DC                  y.
        jmp     @n1                           ; DC53 4C 56 DC                 LV.

; ----------------------------------------------------------------------------
@n1:  jmp     backfromrounovars               ; DC56 4C CC CE                 L..

; ----------------------------------------------------------------------------
doallsecrets:
        lda     #$17                            ; DC59 A9 17                    ..
secretloop:
        pha                                     ; DC5B 48                       H
        tay                                     ; DC5C A8                       .
        and     #$07                            ; DC5D 29 07                    ).
        tax                                     ; DC5F AA                       .
        tya                                     ; DC60 98                       .
        lsr     a                               ; DC61 4A                       J
        lsr     a                               ; DC62 4A                       J
        lsr     a                               ; DC63 4A                       J
        tay                                     ; DC64 A8                       .
        lda     $0660,y                         ; DC65 B9 60 06                 .`.
        and     bitpattern,x                    ; DC68 3D 27 D4                 ='.
        beq     @n2                           ; DC6B F0 05                    ..
        pla                                     ; DC6D 68                       h
        pha                                     ; DC6E 48                       H
        jsr     turnonsecret                    ; DC6F 20 79 DC                  y.
@n2:  pla                                     ; DC72 68                       h
        sec                                     ; DC73 38                       8
        sbc     #$01                            ; DC74 E9 01                    ..
        bpl     secretloop                      ; DC76 10 E3                    ..
        rts                                     ; DC78 60                       `

; a=num to turn on
; ----------------------------------------------------------------------------
turnonsecret:
        asl     a                               ; DC79 0A                       .
        tax                                     ; DC7A AA                       .
        jsr     changebank13rou                 ; DC7B 20 7C C2                  |.
        lda     $ABD9,x                         ; DC7E BD D9 AB                 ...
        sta     address                         ; DC81 85 1B                    ..
        lda     $ABDA,x                         ; DC83 BD DA AB                 ...
        sta     $1C                             ; DC86 85 1C                    ..
        lda     #$00                            ; DC88 A9 00                    ..
dosecret:
        pha                                     ; DC8A 48                       H
        tay                                     ; DC8B A8                       .
        jsr     changebank13rou                 ; DC8C 20 7C C2                  |.
        lda     (address),y                     ; DC8F B1 1B                    ..
        bpl     @n3                           ; DC91 10 05                    ..
        pla                                     ; DC93 68                       h
        jsr     changebank12rou                 ; DC94 20 74 C2                  t.
        rts                                     ; DC97 60                       `

; ----------------------------------------------------------------------------
@n3:  cmp     mapno                           ; DC98 C5 42                    .B
        bne     @n4                           ; DC9A D0 15                    ..
        iny                                     ; DC9C C8                       .
        lda     (address),y                     ; DC9D B1 1B                    ..
        sta     toplevvar1                      ; DC9F 85 11                    ..
        iny                                     ; DCA1 C8                       .
        lda     (address),y                     ; DCA2 B1 1B                    ..
        sta     toplevvar2                      ; DCA4 85 12                    ..
        iny                                     ; DCA6 C8                       .
        lda     (address),y                     ; DCA7 B1 1B                    ..
        sta     toplevvar3                      ; DCA9 85 13                    ..
        jsr     changebank12rou                 ; DCAB 20 74 C2                  t.
        jsr     addachangedblock1               ; DCAE 20 5E FA                  ^.
@n4:  pla                                     ; DCB1 68                       h
        clc                                     ; DCB2 18                       .
        adc     #$04                            ; DCB3 69 04                    i.
        jmp     dosecret                        ; DCB5 4C 8A DC                 L..

; ----------------------------------------------------------------------------
marionrou:
        ldy     #$03                            ; DCB8 A0 03                    ..
        lda     (address9),y                    ; DCBA B1 2D                    .-
        jsr     multstripby16sub                ; DCBC 20 00 C2                  ..
        lda     extravars,x                     ; DCBF BD A9 03                 ...
        cmp     #$C1                            ; DCC2 C9 C1                    ..
        beq     checkrobinanim                  ; DCC4 F0 32                    .2
        inc     extravars,x                     ; DCC6 FE A9 03                 ...
        and     #$1F                            ; DCC9 29 1F                    ).
        bne     checkrobinanim                  ; DCCB D0 2B                    .+
        lda     extravars,x                     ; DCCD BD A9 03                 ...
        lsr     a                               ; DCD0 4A                       J
        lsr     a                               ; DCD1 4A                       J
        lsr     a                               ; DCD2 4A                       J
        lsr     a                               ; DCD3 4A                       J
        lsr     a                               ; DCD4 4A                       J
        cmp     #$06                            ; DCD5 C9 06                    ..
        bne     @n5                           ; DCD7 D0 0A                    ..
        lda     changedblockspointer            ; DCD9 A5 52                    .R
        cmp     #$12                            ; DCDB C9 12                    ..
        bne     checkrobinanim                  ; DCDD D0 19                    ..
        ldy     #$06                            ; DCDF A0 06                    ..
        bne     @n6                           ; DCE1 D0 06                    ..
@n5:  tay                                     ; DCE3 A8                       .
        lda     treasures,y                     ; DCE4 B9 2E 03                 ...
        bne     checkrobinanim                  ; DCE7 D0 0F                    ..
@n6:  sty     temp                            ; DCE9 84 31                    .1
        lda     #$0C                            ; DCEB A9 0C                    ..
        sec                                     ; DCED 38                       8
        sbc     temp                            ; DCEE E5 31                    .1
        tay                                     ; DCF0 A8                       .
        ldx     #$0D                            ; DCF1 A2 0D                    ..
        lda     #$20                            ; DCF3 A9 20                    . 
        jsr     addachangedblock                ; DCF5 20 58 FA                  X.
checkrobinanim:
        ldx     extravarpointer                 ; DCF8 A6 4C                    .L
        lda     $03AA,x                         ; DCFA BD AA 03                 ...
        bne     alreadyanim                     ; DCFD D0 21                    .!
        lda     robiny                          ; DCFF AD 0A 03                 ...
        cmp     #$5F                            ; DD02 C9 5F                    ._
        bne     @n2                           ; DD04 D0 17                    ..
        lda     #$02                            ; DD06 A9 02                    ..
        jsr     starttune                       ; DD08 20 14 F4                  ..
        ldx     extravarpointer                 ; DD0B A6 4C                    .L
        ldy     #$0F                            ; DD0D A0 0F                    ..
        lda     #$00                            ; DD0F A9 00                    ..
        sta     $0653                           ; DD11 8D 53 06                 .S.
@n1:  sta     onscreenrou,y                   ; DD14 99 81 04                 ...
        dey                                     ; DD17 88                       .
        bpl     @n1                           ; DD18 10 FA                    ..
        inc     $03AA,x                         ; DD1A FE AA 03                 ...
@n2:  jmp     printmarion                     ; DD1D 4C 9D DD                 L..

; ----------------------------------------------------------------------------
alreadyanim:
        lda     $03AA,x                         ; DD20 BD AA 03                 ...
        cmp     #$96                            ; DD23 C9 96                    ..
        bne     @n3                           ; DD25 D0 03                    ..
        jmp     fireworkdisplay                 ; DD27 4C AB DD                 L..

; ----------------------------------------------------------------------------
@n3:  inc     $03AA,x                         ; DD2A FE AA 03                 ...
printrobinend:
        lda     minmap                          ; DD2D AD 05 03                 ...
        cmp     #$FF                            ; DD30 C9 FF                    ..
        beq     @n4                           ; DD32 F0 0A                    ..
        lda     #$42                            ; DD34 A9 42                    .B
        jsr     addtoscore                      ; DD36 20 4B F5                  K.
        lda     #$55                            ; DD39 A9 55                    .U
        jsr     addtoscore                      ; DD3B 20 4B F5                  K.
@n4:  lda     #$C8                            ; DD3E A9 C8                    ..
        sta     robininvinc                     ; DD40 8D 1C 03                 ...
        lda     #$00                            ; DD43 A9 00                    ..
        sta     robinjumping                    ; DD45 8D 17 03                 ...
        sta     robinladder                     ; DD48 8D 1A 03                 ...
        lda     $03AA,x                         ; DD4B BD AA 03                 ...
        bmi     @n5                           ; DD4E 30 08                    0.
        lda     #$C8                            ; DD50 A9 C8                    ..
        sec                                     ; DD52 38                       8
        sbc     $03AA,x                         ; DD53 FD AA 03                 ...
        bmi     @n6                           ; DD56 30 02                    0.
@n5:  lda     #$80                            ; DD58 A9 80                    ..
@n6:  sta     robinxl                         ; DD5A 8D 08 03                 ...
        lda     #$FF                            ; DD5D A9 FF                    ..
        sta     oleftright                      ; DD5F 8D 0D 03                 ...
        lda     #$00                            ; DD62 A9 00                    ..
        sta     robinfiring                     ; DD64 8D 14 03                 ...
        sta     robincrouch                     ; DD67 8D 15 03                 ...
        lda     $03AA,x                         ; DD6A BD AA 03                 ...
        bmi     @n8                           ; DD6D 30 1A                    0.
        cmp     #$37                            ; DD6F C9 37                    .7
        bcs     @n7                           ; DD71 B0 0E                    ..
        lda     $03AA,x                         ; DD73 BD AA 03                 ...
        lsr     a                               ; DD76 4A                       J
        lsr     a                               ; DD77 4A                       J
        lsr     a                               ; DD78 4A                       J
        and     #$07                            ; DD79 29 07                    ).
        sta     robinanim                       ; DD7B 8D 13 03                 ...
        jmp     @n9                           ; DD7E 4C 8E DD                 L..

; ----------------------------------------------------------------------------
@n7:  jsr     doheart                         ; DD81 20 F1 DD                  ..
        lda     #$FE                            ; DD84 A9 FE                    ..
        sta     robincrouch                     ; DD86 8D 15 03                 ...
@n8:  lda     #$FF                            ; DD89 A9 FF                    ..
        sta     robinanim                       ; DD8B 8D 13 03                 ...
@n9:  jsr     changebank13rou                 ; DD8E 20 7C C2                  |.
        jsr     b1_printrobin1                  ; DD91 20 C5 AF                  ..
        jsr     changebank12rou                 ; DD94 20 74 C2                  t.
        lda     robinxl                         ; DD97 AD 08 03                 ...
        sta     orobinxl                        ; DD9A 8D 0E 03                 ...
printmarion:
        ldx     #$6A                            ; DD9D A2 6A                    .j
        ldy     #$38                            ; DD9F A0 38                    .8
        lda     #$40                            ; DDA1 A9 40                    .@
        jsr     printsprite                           ; DDA3 20 F4 EC                  ..
        lda     #$03                            ; DDA6 A9 03                    ..
        jmp     backfromrou                     ; DDA8 4C C7 CE                 L..

; ----------------------------------------------------------------------------
fireworkdisplay:
        inc     $03AB,x                         ; DDAB FE AB 03                 ...
        lda     $03AB,x                         ; DDAE BD AB 03                 ...
        cmp     #$F9                            ; DDB1 C9 F9                    ..
        bne     @n10                           ; DDB3 D0 07                    ..
        lda     #$FD                            ; DDB5 A9 FD                    ..
        sta     fadecounter                     ; DDB7 85 4D                    .M
        sta     completedgame                   ; DDB9 8D A8 03                 ...
@n10:  lda     counter                         ; DDBC A5 10                    ..
        and     #$FE                            ; DDBE 29 FE                    ).
        clc                                     ; DDC0 18                       .
        adc     #$01                            ; DDC1 69 01                    i.
        sta     counter                         ; DDC3 85 10                    ..
        ldy     #$04                            ; DDC5 A0 04                    ..
        lda     heartstable                     ; DDC7 AD E1 04                 ...
        beq     @n11                           ; DDCA F0 06                    ..
        iny                                     ; DDCC C8                       .
        lda     $04F1                           ; DDCD AD F1 04                 ...
        bne     @n12                           ; DDD0 D0 1C                    ..
@n11:  lda     $05                             ; DDD2 A5 05                    ..
        and     #$7F                            ; DDD4 29 7F                    ).
        clc                                     ; DDD6 18                       .
        adc     #$40                            ; DDD7 69 40                    i@
        sta     $2C                             ; DDD9 85 2C                    .,
        lda     #$00                            ; DDDB A9 00                    ..
        sta     $2A                             ; DDDD 85 2A                    .*
        lda     $06                             ; DDDF A5 06                    ..
        and     #$7F                            ; DDE1 29 7F                    ).
        clc                                     ; DDE3 18                       .
        adc     #$40                            ; DDE4 69 40                    i@
        sta     address7                        ; DDE6 85 29                    .)
        tya                                     ; DDE8 98                       .
        jsr     startstars                      ; DDE9 20 EF D4                  ..
        ldx     extravarpointer                 ; DDEC A6 4C                    .L
@n12:  jmp     printrobinend                   ; DDEE 4C 2D DD                 L-.

; ----------------------------------------------------------------------------
doheart:lda     #$0C                            ; DDF1 A9 0C                    ..
        sta     coinnum                         ; DDF3 8D 34 03                 .4.
        lda     #$08                            ; DDF6 A9 08                    ..
        sta     coinnumx                        ; DDF8 8D 35 03                 .5.
        lda     #$41                            ; DDFB A9 41                    .A
        sta     coinnumy                        ; DDFD 8D 36 03                 .6.
        lda     #$40                            ; DE00 A9 40                    .@
        sta     coinnumcount                    ; DE02 8D 37 03                 .7.
        rts                                     ; DE05 60                       `

; ----------------------------------------------------------------------------
        jsr     changebank13rou                 ; DE06 20 7C C2                  |.
        jsr     b1_redefinewater                ; DE09 20 6C AB                  l.
        jsr     changebank12rou                 ; DE0C 20 74 C2                  t.
        jmp     backfromrounovars               ; DE0F 4C CC CE                 L..

; ----------------------------------------------------------------------------
; ==========================================================================
; ONSCREEN.ROU
; ==========================================================================
checkaddflamesetc:
        ldy     address9                        ; DE12 A4 2D                    .-
        lda     blockrous,y                     ; DE14 B9 70 DE                 .p.
        beq     putinnowt                       ; DE17 F0 1B                    ..
        sta     temp1                           ; DE19 85 32                    .2
        and     #$3F                            ; DE1B 29 3F                    )?
        sta     temp                            ; DE1D 85 31                    .1
        tax                                     ; DE1F AA                       .
        lda     ablockrous,x                    ; DE20 BD 52 DE                 .R.
        sta     address                         ; DE23 85 1B                    ..
        lda     ablockrous+1,x                  ; DE25 BD 53 DE                 .S.
        sta     $1C                             ; DE28 85 1C                    ..
        ldx     #$0F                            ; DE2A A2 0F                    ..
findaspace:
        lda     onscreenrou,x                   ; DE2C BD 81 04                 ...
        beq     gotspaceonscreen                ; DE2F F0 04                    ..
findaspace1:
        dex                                     ; DE31 CA                       .
        bpl     findaspace                      ; DE32 10 F8                    ..
putinnowt:
        rts                                     ; DE34 60                       `

; ----------------------------------------------------------------------------
gotspaceonscreen:
        bit     temp1                           ; DE35 24 32                    $2
        bvc     @n1                           ; DE37 50 09                    P.
        cpx     #$0F                            ; DE39 E0 0F                    ..
        beq     findaspace1                     ; DE3B F0 F4                    ..
        lda     $0482,x                         ; DE3D BD 82 04                 ...
        bne     findaspace1                     ; DE40 D0 EF                    ..
@n1:  lda     temp                            ; DE42 A5 31                    .1
        sta     onscreenrou,x                   ; DE44 9D 81 04                 ...
        lda     #$00                            ; DE47 A9 00                    ..
        sta     onscreencount1,x                ; DE49 9D C1 04                 ...
        sta     onscreencount2,x                ; DE4C 9D D1 04                 ...
        jmp     (address)                       ; DE4F 6C 1B 00                 l..

; ----------------------------------------------------------------------------
ablockrous:
        .word   $DE34,$DFFD,$E01D,$E035         ; DE52 34 DE FD DF 1D E0 35 E0  4.....5.
        .word   $E050,$E06F,$E091,$E074         ; DE5A 50 E0 6F E0 91 E0 74 E0  P.o...t.
        .word   $E09F,$E0F1,$E109,$E143         ; DE62 9F E0 F1 E0 09 E1 43 E1  ......C.
        .word   $E116,$E140,$E14A               ; DE6A 16 E1 40 E1 4A E1        ..@.J.
; ----------------------------------------------------------------------------
blockrous:
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DE70 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$02,$00,$00,$00,$00,$00 ; DE78 00 00 02 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DE80 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DE88 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DE90 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DE98 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$04,$04,$00,$00 ; DEA0 00 00 00 00 04 04 00 00  ........
        .byte   $00,$00,$00,$00,$02,$00,$00,$00 ; DEA8 00 00 00 00 02 00 00 00  ........
        .byte   $00,$00,$00,$00,$02,$00,$00,$00 ; DEB0 00 00 00 00 02 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DEB8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$06,$00,$00 ; DEC0 00 00 00 00 00 06 00 00  ........
        .byte   $00,$00,$00,$94,$96,$58,$00,$00 ; DEC8 00 00 00 94 96 58 00 00  .....X..
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DED0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DED8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DEE0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DEE8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DEF0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DEF8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF00 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF08 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF10 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$8C,$8E ; DF18 00 00 00 00 00 00 8C 8E  ........
        .byte   $0A,$00,$D0,$92,$00,$00,$00,$00 ; DF20 0A 00 D0 92 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF28 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF30 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF38 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF40 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF48 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF50 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; DF58 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$08,$9C,$00,$00,$00,$00 ; DF60 00 00 08 9C 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$02,$00 ; DF68 00 00 00 00 00 00 02 00  ........
; ----------------------------------------------------------------------------
updateonscreens:
        ldy     #$0F                            ; DF70 A0 0F                    ..
doupdates:
        ldx     onscreenrou,y                   ; DF72 BE 81 04                 ...
        beq     backfromscreenrou1              ; DF75 F0 15                    ..
        cpx     #$FF                            ; DF77 E0 FF                    ..
        beq     backfromscreenrou1              ; DF79 F0 11                    ..
        sty     address9                        ; DF7B 84 2D                    .-
        lda     updatescrrous,x                 ; DF7D BD 8E DF                 ...
        sta     address                         ; DF80 85 1B                    ..
        lda     updatescrrous+1,x               ; DF82 BD 8F DF                 ...
        sta     $1C                             ; DF85 85 1C                    ..
        jmp     (address)                       ; DF87 6C 1B 00                 l..

; ----------------------------------------------------------------------------
backfromscreenrou:
        ldy     address9                        ; DF8A A4 2D                    .-
backfromscreenrou1:
        dey                                     ; DF8C 88                       .
updatescrrous   := * + 1
        bpl     doupdates                       ; DF8D 10 E3                    ..
        .word   $7F60,$A7E1,$EBE1,$25E1         ; DF8F 60 7F E1 A7 E1 EB E1 25  `......%
        .word   $7FE2,$EBE2,$13E2,$03E3         ; DF97 E2 7F E2 EB E2 13 E3 03  ........
        .word   $2BE4,$1BE5,$CCE6,$09E8         ; DF9F E4 2B E5 1B E6 CC E8 09  .+......
        .word   $C6E7                           ; DFA7 E7 C6                    ..
        .byte   $E8                             ; DFA9 E8                       .
onscrxandy0     := * + 2
        cpy     $A9E8                           ; DFAA CC E8 A9                 ...
        brk                                     ; DFAD 00                       .
onscrxandy:
        ldy     blockx                          ; DFAE AC 03 03                 ...
        clc                                     ; DFB1 18                       .
        adc     banksel15,y                         ; DFB2 79 19 C0                 y..
        sta     onscreenxl,x                    ; DFB5 9D 91 04                 ...
        lda     times16hi_m1,y                         ; DFB8 B9 1D C1                 ...
        adc     #$00                            ; DFBB 69 00                    i.
        sta     onscreenxh,x                    ; DFBD 9D A1 04                 ...
        ldy     blocky                          ; DFC0 AC 04 03                 ...
        lda     times16lo,y                     ; DFC3 B9 1A C0                 ...
        sta     onscreeny,x                     ; DFC6 9D B1 04                 ...
        ldy     #$0F                            ; DFC9 A0 0F                    ..
@n1:  sty     temp                            ; DFCB 84 31                    .1
        cpx     temp                            ; DFCD E4 31                    .1
        beq     @n2                           ; DFCF F0 28                    .(
        lda     onscreenrou,y                   ; DFD1 B9 81 04                 ...
        beq     @n2                           ; DFD4 F0 23                    .#
        cmp     onscreenrou,x                   ; DFD6 DD 81 04                 ...
        bne     @n2                           ; DFD9 D0 1E                    ..
        lda     onscreenxl,x                    ; DFDB BD 91 04                 ...
        cmp     onscreenxl,y                    ; DFDE D9 91 04                 ...
        bne     @n2                           ; DFE1 D0 16                    ..
        lda     onscreenxh,x                    ; DFE3 BD A1 04                 ...
        cmp     onscreenxh,y                    ; DFE6 D9 A1 04                 ...
        bne     @n2                           ; DFE9 D0 0E                    ..
        lda     onscreeny,x                     ; DFEB BD B1 04                 ...
        cmp     onscreeny,y                     ; DFEE D9 B1 04                 ...
        bne     @n2                           ; DFF1 D0 06                    ..
        lda     #$00                            ; DFF3 A9 00                    ..
        sta     onscreenrou,x                   ; DFF5 9D 81 04                 ...
        rts                                     ; DFF8 60                       `

; ----------------------------------------------------------------------------
@n2:  dey                                     ; DFF9 88                       .
        bpl     @n1                           ; DFFA 10 CF                    ..
        rts                                     ; DFFC 60                       `

; ----------------------------------------------------------------------------
putinflames:
        lda     #$04                            ; DFFD A9 04                    ..
        cpy     #$0A                            ; DFFF C0 0A                    ..
        beq     addflame                        ; E001 F0 17                    ..
        cpy     #$FE                            ; E003 C0 FE                    ..
        beq     addflame                        ; E005 F0 13                    ..
        lda     #$0C                            ; E007 A9 0C                    ..
        cpy     #$44                            ; E009 C0 44                    .D
        bne     addflame                        ; E00B D0 0D                    ..
        jsr     onscrxandy                      ; E00D 20 AE DF                  ..
        lda     onscreeny,x                     ; E010 BD B1 04                 ...
        clc                                     ; E013 18                       .
        adc     #$F8                            ; E014 69 F8                    i.
        sta     onscreeny,x                     ; E016 9D B1 04                 ...
        rts                                     ; E019 60                       `

; ----------------------------------------------------------------------------
addflame:
        jmp     onscrxandy                      ; E01A 4C AE DF                 L..

; ----------------------------------------------------------------------------
putinspit:
        lda     #$00                            ; E01D A9 00                    ..
        cpy     #$34                            ; E01F C0 34                    .4
        beq     @n1                           ; E021 F0 02                    ..
        lda     #$FF                            ; E023 A9 FF                    ..
@n1:  sta     onscreencount1,x                ; E025 9D C1 04                 ...
        lda     blockx                          ; E028 AD 03 03                 ...
        and     #$07                            ; E02B 29 07                    ).
        sta     onscreencount2,x                ; E02D 9D D1 04                 ...
        lda     #$04                            ; E030 A9 04                    ..
        jmp     onscrxandy                      ; E032 4C AE DF                 L..

; ----------------------------------------------------------------------------
putineyes:
        lda     $06                             ; E035 A5 06                    ..
        cmp     #$1E                            ; E037 C9 1E                    ..
        bcs     dontputinonscreen               ; E039 B0 0D                    ..
        and     #$03                            ; E03B 29 03                    ).
        sta     onscreencount2,x                ; E03D 9D D1 04                 ...
        lda     $05                             ; E040 A5 05                    ..
        sta     onscreencount1,x                ; E042 9D C1 04                 ...
        jmp     onscrxandy0                     ; E045 4C AC DF                 L..

; ----------------------------------------------------------------------------
dontputinonscreen:
        lda     #$00                            ; E048 A9 00                    ..
        sta     onscreenrou,x                   ; E04A 9D 81 04                 ...
        jmp     random                          ; E04D 4C AC F3                 L..

; ----------------------------------------------------------------------------
putindrip:
        lda     blockx                          ; E050 AD 03 03                 ...
        and     #$03                            ; E053 29 03                    ).
        tay                                     ; E055 A8                       .
        lda     firestable,y                    ; E056 B9 6B E0                 .k.
        sta     onscreencount2,x                ; E059 9D D1 04                 ...
        lda     #$08                            ; E05C A9 08                    ..
        jsr     onscrxandy                      ; E05E 20 AE DF                  ..
        lda     onscreeny,x                     ; E061 BD B1 04                 ...
        clc                                     ; E064 18                       .
        adc     #$14                            ; E065 69 14                    i.
        sta     onscreeny,x                     ; E067 9D B1 04                 ...
        rts                                     ; E06A 60                       `

; ----------------------------------------------------------------------------
firestable:
        .byte   $FF,$7F,$3F,$7F                 ; E06B FF 7F 3F 7F              ..?.
; ----------------------------------------------------------------------------
putintramp:
        lda     #$08                            ; E06F A9 08                    ..
        jmp     onscrxandy                      ; E071 4C AE DF                 L..

; ----------------------------------------------------------------------------
putindrillup:
        lda     #$04                            ; E074 A9 04                    ..
        jsr     onscrxandy                      ; E076 20 AE DF                  ..
        lda     onscreeny,x                     ; E079 BD B1 04                 ...
        clc                                     ; E07C 18                       .
        adc     #$10                            ; E07D 69 10                    i.
putindriller:
        sta     onscreeny,x                     ; E07F 9D B1 04                 ...
        sta     onscreencount1,x                ; E082 9D C1 04                 ...
        lda     blockx                          ; E085 AD 03 03                 ...
        and     #$07                            ; E088 29 07                    ).
        clc                                     ; E08A 18                       .
        adc     #$C0                            ; E08B 69 C0                    i.
        sta     onscreencount2,x                ; E08D 9D D1 04                 ...
        rts                                     ; E090 60                       `

; ----------------------------------------------------------------------------
putindrilldown:
        lda     #$04                            ; E091 A9 04                    ..
        jsr     onscrxandy                      ; E093 20 AE DF                  ..
        lda     onscreeny,x                     ; E096 BD B1 04                 ...
        clc                                     ; E099 18                       .
        adc     #$F6                            ; E09A 69 F6                    i.
        jmp     putindriller                    ; E09C 4C 7F E0                 L..

; ----------------------------------------------------------------------------
putinbat:
        ldy     #$0F                            ; E09F A0 0F                    ..
morebats:
        lda     onscreenrou,y                   ; E0A1 B9 81 04                 ...
        cmp     #$10                            ; E0A4 C9 10                    ..
        bne     batok                           ; E0A6 D0 19                    ..
        lda     $0492,y                         ; E0A8 B9 92 04                 ...
        cmp     blockx                          ; E0AB CD 03 03                 ...
        bne     batok                           ; E0AE D0 11                    ..
        lda     $04B2,y                         ; E0B0 B9 B2 04                 ...
        cmp     blocky                          ; E0B3 CD 04 03                 ...
        bne     batok                           ; E0B6 D0 09                    ..
putincanceldouble:
        lda     #$00                            ; E0B8 A9 00                    ..
        sta     onscreenrou,x                   ; E0BA 9D 81 04                 ...
        sta     $0482,x                         ; E0BD 9D 82 04                 ...
        rts                                     ; E0C0 60                       `

; ----------------------------------------------------------------------------
batok:  dey                                     ; E0C1 88                       .
        bpl     morebats                        ; E0C2 10 DD                    ..
        lda     #$FF                            ; E0C4 A9 FF                    ..
        sta     $0482,x                         ; E0C6 9D 82 04                 ...
        lda     blockx                          ; E0C9 AD 03 03                 ...
        and     #$01                            ; E0CC 29 01                    ).
        bne     @n3                           ; E0CE D0 02                    ..
        lda     #$FF                            ; E0D0 A9 FF                    ..
@n3:  sta     onscreencount1,x                ; E0D2 9D C1 04                 ...
        lda     #$01                            ; E0D5 A9 01                    ..
        sta     onscreencount2,x                ; E0D7 9D D1 04                 ...
        sta     $04D2,x                         ; E0DA 9D D2 04                 ...
        lda     #$0A                            ; E0DD A9 0A                    ..
        sta     $04C2,x                         ; E0DF 9D C2 04                 ...
        lda     blockx                          ; E0E2 AD 03 03                 ...
        sta     $0492,x                         ; E0E5 9D 92 04                 ...
        lda     blocky                          ; E0E8 AD 04 03                 ...
        sta     $04B2,x                         ; E0EB 9D B2 04                 ...
        jmp     onscrxandy0                     ; E0EE 4C AC DF                 L..

; ----------------------------------------------------------------------------
putinrat:
        lda     #$80                            ; E0F1 A9 80                    ..
        sta     onscreencount1,x                ; E0F3 9D C1 04                 ...
        lda     blockx                          ; E0F6 AD 03 03                 ...
        and     #$03                            ; E0F9 29 03                    ).
        tay                                     ; E0FB A8                       .
        lda     rattable,y                      ; E0FC B9 05 E1                 ...
        sta     onscreencount2,x                ; E0FF 9D D1 04                 ...
        jmp     onscrxandy0                     ; E102 4C AC DF                 L..

; ----------------------------------------------------------------------------
rattable:
        .byte   $03,$83,$01,$81                 ; E105 03 83 01 81              ....
; ----------------------------------------------------------------------------
putinspider:
        lda     blockx                          ; E109 AD 03 03                 ...
        and     #$01                            ; E10C 29 01                    ).
        sta     onscreencount2,x                ; E10E 9D D1 04                 ...
        lda     #$09                            ; E111 A9 09                    ..
        jmp     onscrxandy                      ; E113 4C AE DF                 L..

; ----------------------------------------------------------------------------
putinbarrel:
        lda     #$FF                            ; E116 A9 FF                    ..
        sta     $0482,x                         ; E118 9D 82 04                 ...
        lda     #$00                            ; E11B A9 00                    ..
        sta     $04B2,x                         ; E11D 9D B2 04                 ...
        lda     blockx                          ; E120 AD 03 03                 ...
        and     #$01                            ; E123 29 01                    ).
        bne     @n1                           ; E125 D0 02                    ..
        lda     #$FF                            ; E127 A9 FF                    ..
@n1:  sta     $04D2,x                         ; E129 9D D2 04                 ...
        lda     blockx                          ; E12C AD 03 03                 ...
        lsr     a                               ; E12F 4A                       J
        and     #$01                            ; E130 29 01                    ).
        sta     onscreencount2,x                ; E132 9D D1 04                 ...
        lda     #$08                            ; E135 A9 08                    ..
        jsr     onscrxandy                      ; E137 20 AE DF                  ..
        bne     @n2                           ; E13A D0 03                    ..
        jmp     putincanceldouble               ; E13C 4C B8 E0                 L..

; ----------------------------------------------------------------------------
@n2:  rts                                     ; E13F 60                       `

; ----------------------------------------------------------------------------
putinblock:
        jmp     onscrxandy0                     ; E140 4C AC DF                 L..

; ----------------------------------------------------------------------------
putinheart:
        jsr     changebank13rou                 ; E143 20 7C C2                  |.
        ldy     #$60                            ; E146 A0 60                    .`
        bne     putinheartbit                   ; E148 D0 05                    ..
putincoin:
        jsr     changebank13rou                 ; E14A 20 7C C2                  |.
        ldy     #$00                            ; E14D A0 00                    ..
putinheartbit:
        jsr     b1_putinheartbank               ; E14F 20 E8 A7                  ..
        jsr     changebank12rou                 ; E152 20 74 C2                  t.
        rts                                     ; E155 60                       `

; ----------------------------------------------------------------------------
calconscreenx:
        lda     onscreenxl,y                    ; E156 B9 91 04                 ...
        sec                                     ; E159 38                       8
        sbc     scrxl                           ; E15A E5 3B                    .;
        tax                                     ; E15C AA                       .
        lda     onscreenxh,y                    ; E15D B9 A1 04                 ...
        sbc     scrxh                           ; E160 E5 3C                    .<
        sta     a:temp7                         ; E162 8D 38 00                 .8.
        bne     outofscreen                     ; E165 D0 01                    ..
        rts                                     ; E167 60                       `

; ----------------------------------------------------------------------------
outofscreen:
        bpl     @n5                           ; E168 10 06                    ..
        cpx     #$E0                            ; E16A E0 E0                    ..
        bcs     @n1                           ; E16C B0 10                    ..
        bcc     @n6                           ; E16E 90 04                    ..
@n5:  cpx     #$20                            ; E170 E0 20                    . 
        bcc     @n1                           ; E172 90 0A                    ..
@n6:  lda     #$00                            ; E174 A9 00                    ..
        sta     onscreenrou,y                   ; E176 99 81 04                 ...
        pla                                     ; E179 68                       h
        pla                                     ; E17A 68                       h
        jmp     backfromscreenrou               ; E17B 4C 8A DF                 L..

; ----------------------------------------------------------------------------
@n1:  rts                                     ; E17E 60                       `

; ----------------------------------------------------------------------------
updateflames:
        jsr     calconscreenx                   ; E17F 20 56 E1                  V.
        lda     a:temp7                         ; E182 AD 38 00                 .8.
        bne     @n1                           ; E185 D0 1D                    ..
        sty     temp1                           ; E187 84 32                    .2
        ldy     #$03                            ; E189 A0 03                    ..
        lda     counter                         ; E18B A5 10                    ..
        and     #$04                            ; E18D 29 04                    ).
        bne     @n3                           ; E18F D0 03                    ..
        dex                                     ; E191 CA                       .
        ldy     #$43                            ; E192 A0 43                    .C
@n3:  sty     temp                            ; E194 84 31                    .1
        ldy     temp1                           ; E196 A4 32                    .2
        lda     onscreeny,y                     ; E198 B9 B1 04                 ...
        clc                                     ; E19B 18                       .
        adc     #$0C                            ; E19C 69 0C                    i.
        tay                                     ; E19E A8                       .
        lda     #$95                            ; E19F A9 95                    ..
        jsr     pokesprite                      ; E1A1 20 CD EF                  ..
@n1:  jmp     backfromscreenrou               ; E1A4 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatespit:
        ldx     onscreencount2,y                ; E1A7 BE D1 04                 ...
        lda     spitdelay,x                     ; E1AA BD E3 E1                 ...
        and     counter                         ; E1AD 25 10                    %.
        bne     endspitter                      ; E1AF D0 2F                    ./
        jsr     calconscreenx                   ; E1B1 20 56 E1                  V.
        ldx     #$03                            ; E1B4 A2 03                    ..
findspitterslot:
        lda     spittery,x                      ; E1B6 BD 61 04                 .a.
        beq     gotspitter                      ; E1B9 F0 05                    ..
        dex                                     ; E1BB CA                       .
        bpl     findspitterslot                 ; E1BC 10 F8                    ..
        beq     endspitter                      ; E1BE F0 20                    . 
gotspitter:
        lda     onscreenxl,y                    ; E1C0 B9 91 04                 ...
        sta     spitterxl,x                     ; E1C3 9D 59 04                 .Y.
        lda     onscreenxh,y                    ; E1C6 B9 A1 04                 ...
        sta     spitterxh,x                     ; E1C9 9D 5D 04                 .].
        lda     onscreeny,y                     ; E1CC B9 B1 04                 ...
        clc                                     ; E1CF 18                       .
        adc     #$08                            ; E1D0 69 08                    i.
        sta     spittery,x                      ; E1D2 9D 61 04                 .a.
        lda     onscreencount1,y                ; E1D5 B9 C1 04                 ...
        sta     spitterdir,x                    ; E1D8 9D 65 04                 .e.
        lda     #$21                            ; E1DB A9 21                    .!
        jsr     soundfx                         ; E1DD 20 28 F4                  (.
endspitter:
        jmp     backfromscreenrou               ; E1E0 4C 8A DF                 L..

; ----------------------------------------------------------------------------
spitdelay:
        .byte   $FF,$7F,$FF,$FF,$7F,$FF,$FF,$7F ; E1E3 FF 7F FF FF 7F FF FF 7F  ........
; ----------------------------------------------------------------------------
updateeyes:
        lda     counter                         ; E1EB A5 10                    ..
        and     #$03                            ; E1ED 29 03                    ).
        bne     @n2                           ; E1EF D0 18                    ..
        lda     onscreencount1,y                ; E1F1 B9 C1 04                 ...
        sec                                     ; E1F4 38                       8
        sbc     #$01                            ; E1F5 E9 01                    ..
        sta     onscreencount1,y                ; E1F7 99 C1 04                 ...
        bne     @n2                           ; E1FA D0 0D                    ..
        lda     seed                            ; E1FC A5 04                    ..
        sta     onscreencount1,y                ; E1FE 99 C1 04                 ...
        lda     onscreencount2,y                ; E201 B9 D1 04                 ...
        eor     #$FF                            ; E204 49 FF                    I.
        sta     onscreencount2,y                ; E206 99 D1 04                 ...
@n2:  lda     onscreencount2,y                ; E209 B9 D1 04                 ...
        bmi     @n1                           ; E20C 30 14                    0.
        jsr     calconscreenx                   ; E20E 20 56 E1                  V.
        lda     onscreencount2,y                ; E211 B9 D1 04                 ...
        sta     temp                            ; E214 85 31                    .1
        lda     onscreeny,y                     ; E216 B9 B1 04                 ...
        tay                                     ; E219 A8                       .
        lda     temp                            ; E21A A5 31                    .1
        clc                                     ; E21C 18                       .
        adc     #$33                            ; E21D 69 33                    i3
        jsr     winprintsprite                  ; E21F 20 3A EE                  :.
@n1:  jmp     backfromscreenrou               ; E222 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatedrips:
        lda     onscreencount1,y                ; E225 B9 C1 04                 ...
        bne     firehappening                   ; E228 D0 14                    ..
        lda     counter                         ; E22A A5 10                    ..
        clc                                     ; E22C 18                       .
        adc     onscreenxl,y                    ; E22D 79 91 04                 y..
        and     onscreencount2,y                ; E230 39 D1 04                 9..
        bne     enddrips                        ; E233 D0 3F                    .?
        lda     #$08                            ; E235 A9 08                    ..
        jsr     soundfx                         ; E237 20 28 F4                  (.
        ldy     address9                        ; E23A A4 2D                    .-
        lda     #$40                            ; E23C A9 40                    .@
firehappening:
        sec                                     ; E23E 38                       8
        sbc     #$01                            ; E23F E9 01                    ..
        sta     onscreencount1,y                ; E241 99 C1 04                 ...
        jsr     calconscreenx                   ; E244 20 56 E1                  V.
        stx     address8                        ; E247 86 2B                    .+
        lda     onscreeny,y                     ; E249 B9 B1 04                 ...
        jsr     pickupcollision                 ; E24C 20 FE D3                  ..
        bcs     @n1                           ; E24F B0 09                    ..
        tya                                     ; E251 98                       .
        pha                                     ; E252 48                       H
        lda     #$01                            ; E253 A9 01                    ..
        jsr     subfromhearts                   ; E255 20 97 F5                  ..
        pla                                     ; E258 68                       h
        tay                                     ; E259 A8                       .
@n1:  lda     onscreeny,y                     ; E25A B9 B1 04                 ...
        sta     temp                            ; E25D 85 31                    .1
        lda     onscreencount1,y                ; E25F B9 C1 04                 ...
        lsr     a                               ; E262 4A                       J
        lsr     a                               ; E263 4A                       J
        sta     temp1                           ; E264 85 32                    .2
        lsr     a                               ; E266 4A                       J
        and     #$07                            ; E267 29 07                    ).
        tay                                     ; E269 A8                       .
        lda     firetable,y                     ; E26A B9 77 E2                 .w.
        ldy     temp                            ; E26D A4 31                    .1
        lsr     temp1                           ; E26F 46 32                    F2
        jsr     winprintspriteposrev            ; E271 20 3B EE                  ;.
enddrips:
        jmp     backfromscreenrou               ; E274 4C 8A DF                 L..

; ----------------------------------------------------------------------------
firetable:
        .byte   $3B,$3C,$3D,$3E,$3F,$3E,$3D,$3C ; E277 3B 3C 3D 3E 3F 3E 3D 3C  ;<=>?>=<
; ----------------------------------------------------------------------------
updatetramp:
        jsr     calconscreenx                   ; E27F 20 56 E1                  V.
        stx     address8                        ; E282 86 2B                    .+
        lda     a:temp7                         ; E284 AD 38 00                 .8.
        bne     endtramp                        ; E287 D0 43                    .C
        lda     robingravity                    ; E289 AD 18 03                 ...
        clc                                     ; E28C 18                       .
        adc     #$02                            ; E28D 69 02                    i.
        bmi     endtramp                        ; E28F 30 3B                    0;
        lda     onscreeny,y                     ; E291 B9 B1 04                 ...
        clc                                     ; E294 18                       .
        adc     #$10                            ; E295 69 10                    i.
        jsr     pickupcollision                 ; E297 20 FE D3                  ..
        bcs     endtramp                        ; E29A B0 30                    .0
        lda     #$00                            ; E29C A9 00                    ..
        sec                                     ; E29E 38                       8
        sbc     robingravity                    ; E29F ED 18 03                 ...
        cmp     #$E8                            ; E2A2 C9 E8                    ..
        bcc     @n1                           ; E2A4 90 03                    ..
        sta     robingravity                    ; E2A6 8D 18 03                 ...
@n1:  jsr     checkleftrightkeys              ; E2A9 20 1B C8                  ..
        jsr     addleftright1                   ; E2AC 20 12 CC                  ..
        lda     orobinxl                        ; E2AF AD 0E 03                 ...
        sta     robinxl                         ; E2B2 8D 08 03                 ...
        lda     orobinxh                        ; E2B5 AD 0F 03                 ...
        sta     robinxh                         ; E2B8 8D 09 03                 ...
        lda     #$15                            ; E2BB A9 15                    ..
        jsr     soundfx                         ; E2BD 20 28 F4                  (.
        ldy     address9                        ; E2C0 A4 2D                    .-
        lda     #$01                            ; E2C2 A9 01                    ..
        sta     robinjumping                    ; E2C4 8D 17 03                 ...
        lda     #$FA                            ; E2C7 A9 FA                    ..
        sta     onscreencount1,y                ; E2C9 99 C1 04                 ...
endtramp:
        lda     onscreeny,y                     ; E2CC B9 B1 04                 ...
        sta     $2C                             ; E2CF 85 2C                    .,
        lda     onscreencount1,y                ; E2D1 B9 C1 04                 ...
        bpl     @n1b                           ; E2D4 10 09                    ..
        ldx     address9                        ; E2D6 A6 2D                    .-
        inc     onscreencount1,x                ; E2D8 FE C1 04                 ...
        lda     #$2E                            ; E2DB A9 2E                    ..
        bne     @n2                           ; E2DD D0 02                    ..
@n1b:  lda     #$2D                            ; E2DF A9 2D                    .-
@n2:  ldx     address8                        ; E2E1 A6 2B                    .+
        ldy     $2C                             ; E2E3 A4 2C                    .,
        jsr     winprintsprite                  ; E2E5 20 3A EE                  :.
        jmp     backfromscreenrou               ; E2E8 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatedrilldown:
        jsr     calconscreenx                   ; E2EB 20 56 E1                  V.
        lda     #$80                            ; E2EE A9 80                    ..
        sta     $2A                             ; E2F0 85 2A                    .*
        lda     #$FF                            ; E2F2 A9 FF                    ..
        jsr     standarddrill                   ; E2F4 20 37 E3                  7.
        ldx     a:temp7                         ; E2F7 AE 38 00                 .8.
        bne     enddrilldown                    ; E2FA D0 14                    ..
        cpy     $2C                             ; E2FC C4 2C                    .,
        bcc     enddrilldown                    ; E2FE 90 10                    ..
@n1:  ldx     address8                        ; E300 A6 2B                    .+
        jsr     pokesprite                      ; E302 20 CD EF                  ..
        tya                                     ; E305 98                       .
        clc                                     ; E306 18                       .
        adc     #$F8                            ; E307 69 F8                    i.
        tay                                     ; E309 A8                       .
        lda     #$BE                            ; E30A A9 BE                    ..
        cpy     $2C                             ; E30C C4 2C                    .,
        bcs     @n1                           ; E30E B0 F0                    ..
enddrilldown:
        jmp     backfromscreenrou               ; E310 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatedrillup:
        jsr     calconscreenx                   ; E313 20 56 E1                  V.
        lda     #$00                            ; E316 A9 00                    ..
        sta     $2A                             ; E318 85 2A                    .*
        lda     #$01                            ; E31A A9 01                    ..
        jsr     standarddrill                   ; E31C 20 37 E3                  7.
        ldx     a:temp7                         ; E31F AE 38 00                 .8.
        bne     enddrillup                      ; E322 D0 10                    ..
@n1:  ldx     address8                        ; E324 A6 2B                    .+
        jsr     pokesprite                      ; E326 20 CD EF                  ..
        tya                                     ; E329 98                       .
        clc                                     ; E32A 18                       .
        adc     #$08                            ; E32B 69 08                    i.
        tay                                     ; E32D A8                       .
        lda     #$BE                            ; E32E A9 BE                    ..
        cpy     $2C                             ; E330 C4 2C                    .,
        bcc     @n1                           ; E332 90 F0                    ..
enddrillup:
        jmp     backfromscreenrou               ; E334 4C 8A DF                 L..

; ----------------------------------------------------------------------------
standarddrill:
        sta     address7                        ; E337 85 29                    .)
        stx     address8                        ; E339 86 2B                    .+
        lda     onscreencount2,y                ; E33B B9 D1 04                 ...
        and     #$40                            ; E33E 29 40                    )@
        beq     @n1                           ; E340 F0 0C                    ..
        lda     counter                         ; E342 A5 10                    ..
        ; beq !2
        bne     printdrillup                    ; E344 D0 6D                    .m
        ; rts
        lda     onscreencount2,y                ; E346 B9 D1 04                 ...
        and     #$BF                            ; E349 29 BF                    ).
        sta     onscreencount2,y                ; E34B 99 D1 04                 ...
@n1:  lda     onscreencount2,y                ; E34E B9 D1 04                 ...
        and     #$07                            ; E351 29 07                    ).
        sta     temp                            ; E353 85 31                    .1
        asl     a                               ; E355 0A                       .
        clc                                     ; E356 18                       .
        adc     temp                            ; E357 65 31                    e1
        tax                                     ; E359 AA                       .
        lda     drillerpatterns_1,x                         ; E35A BD EC E3                 ...
        sta     $28                             ; E35D 85 28                    .(
        lda     drillerpatterns_2,x                         ; E35F BD ED E3                 ...
        eor     counter                         ; E362 45 10                    E.
        sta     address6                        ; E364 85 27                    .'
        lda     onscreencount2,y                ; E366 B9 D1 04                 ...
        bpl     movingdrill                     ; E369 10 0F                    ..
        lda     address6                        ; E36B A5 27                    .'
        cmp     drillerpatterns,x               ; E36D DD EB E3                 ...
        bne     contdrill                       ; E370 D0 36                    .6
        lda     onscreencount2,y                ; E372 B9 D1 04                 ...
        eor     #$80                            ; E375 49 80                    I.
        sta     onscreencount2,y                ; E377 99 D1 04                 ...
movingdrill:
        lda     address6                        ; E37A A5 27                    .'
        bmi     drillcomingdown                 ; E37C 30 10                    0.
        and     $28                             ; E37E 25 28                    %(
        bne     contdrill                       ; E380 D0 26                    .&
        lda     onscreencount1,y                ; E382 B9 C1 04                 ...
        sec                                     ; E385 38                       8
        sbc     address7                        ; E386 E5 29                    .)
        sta     onscreencount1,y                ; E388 99 C1 04                 ...
        jmp     contdrill                       ; E38B 4C A8 E3                 L..

; ----------------------------------------------------------------------------
drillcomingdown:
        and     $28                             ; E38E 25 28                    %(
        bne     contdrill                       ; E390 D0 16                    ..
        lda     onscreencount1,y                ; E392 B9 C1 04                 ...
        clc                                     ; E395 18                       .
        adc     address7                        ; E396 65 29                    e)
        sta     onscreencount1,y                ; E398 99 C1 04                 ...
        cmp     onscreeny,y                     ; E39B D9 B1 04                 ...
        bne     contdrill                       ; E39E D0 08                    ..
        lda     onscreencount2,y                ; E3A0 B9 D1 04                 ...
        eor     #$80                            ; E3A3 49 80                    I.
        sta     onscreencount2,y                ; E3A5 99 D1 04                 ...
contdrill:
        ldx     address8                        ; E3A8 A6 2B                    .+
        lda     onscreencount1,y                ; E3AA B9 C1 04                 ...
        tay                                     ; E3AD A8                       .
        jsr     checkchrcollision               ; E3AE 20 A4 DB                  ..
        ldy     address9                        ; E3B1 A4 2D                    .-
printdrillup:
        lda     a:temp7                         ; E3B3 AD 38 00                 .8.
        bne     @n1                           ; E3B6 D0 17                    ..
        lda     #$21                            ; E3B8 A9 21                    .!
        clc                                     ; E3BA 18                       .
        adc     $2A                             ; E3BB 65 2A                    e*
        sta     temp                            ; E3BD 85 31                    .1
        lda     onscreeny,y                     ; E3BF B9 B1 04                 ...
        clc                                     ; E3C2 18                       .
        adc     #$0C                            ; E3C3 69 0C                    i.
        sta     $2C                             ; E3C5 85 2C                    .,
        tay                                     ; E3C7 A8                       .
        ldx     address8                        ; E3C8 A6 2B                    .+
        lda     #$7F                            ; E3CA A9 7F                    ..
        jsr     pokesprite                      ; E3CC 20 CD EF                  ..
@n1:  ldy     address9                        ; E3CF A4 2D                    .-
        lda     address6                        ; E3D1 A5 27                    .'
        asl     a                               ; E3D3 0A                       .
        asl     a                               ; E3D4 0A                       .
        asl     a                               ; E3D5 0A                       .
        asl     a                               ; E3D6 0A                       .
        and     #$40                            ; E3D7 29 40                    )@
        clc                                     ; E3D9 18                       .
        adc     #$02                            ; E3DA 69 02                    i.
        clc                                     ; E3DC 18                       .
        adc     $2A                             ; E3DD 65 2A                    e*
        sta     temp                            ; E3DF 85 31                    .1
        lda     onscreencount1,y                ; E3E1 B9 C1 04                 ...
        clc                                     ; E3E4 18                       .
        adc     #$0C                            ; E3E5 69 0C                    i.
        tay                                     ; E3E7 A8                       .
        lda     #$BD                            ; E3E8 A9 BD                    ..
        rts                                     ; E3EA 60                       `

; defb waitcount,speed,start in/out
; ----------------------------------------------------------------------------
drillerpatterns:
        .byte   $40                             ; E3EB 40                       @
drillerpatterns_1:  .byte   $01                             ; E3EC 01                       .
drillerpatterns_2:  .byte   $00,$20,$01,$FF,$40,$03,$00,$28 ; E3ED 00 20 01 FF 40 03 00 28  . ..@..(
        .byte   $03,$FF,$28,$01,$00,$40,$01,$FF ; E3F5 03 FF 28 01 00 40 01 FF  ..(..@..
        .byte   $20,$03,$00,$40,$03,$FF         ; E3FD 20 03 00 40 03 FF         ..@..
; ----------------------------------------------------------------------------
updatebat:
        lda     counter                         ; E403 A5 10                    ..
        and     #$01                            ; E405 29 01                    ).
        bne     batnotmoving                    ; E407 D0 03                    ..
        jsr     movebat                         ; E409 20 80 E4                  ..
batnotmoving:
        lda     onscreeny,y                     ; E40C B9 B1 04                 ...
        sta     $2C                             ; E40F 85 2C                    .,
        lda     onscreenxl,y                    ; E411 B9 91 04                 ...
        sta     address7                        ; E414 85 29                    .)
        sec                                     ; E416 38                       8
        sbc     scrxl                           ; E417 E5 3B                    .;
        sta     address8                        ; E419 85 2B                    .+
        lda     onscreenxh,y                    ; E41B B9 A1 04                 ...
        sta     $2A                             ; E41E 85 2A                    .*
        sbc     scrxh                           ; E420 E5 3C                    .<
        sta     a:temp7                         ; E422 8D 38 00                 .8.
        lda     onscreeny,y                     ; E425 B9 B1 04                 ...
        sec                                     ; E428 38                       8
        sbc     arrowy                          ; E429 ED 39 04                 .9.
        clc                                     ; E42C 18                       .
        adc     #$04                            ; E42D 69 04                    i.
        ; purposly big collison,was too difficult
        cmp     #$10                            ; E42F C9 10                    ..
        bcs     missedbat                       ; E431 B0 20                    . 
        jsr     collidebatwitharrow             ; E433 20 23 D9                  #.
        bcs     missedbat                       ; E436 B0 1B                    ..
        ldx     #$00                            ; E438 A2 00                    ..
        jsr     takearrowoffrou                 ; E43A 20 63 D7                  c.
        lda     #$1A                            ; E43D A9 1A                    ..
        jsr     soundfx                         ; E43F 20 28 F4                  (.
turnoffbat:
        ldy     address9                        ; E442 A4 2D                    .-
        lda     #$04                            ; E444 A9 04                    ..
        jsr     startstars                      ; E446 20 EF D4                  ..
        lda     #$41                            ; E449 A9 41                    .A
        jsr     addtoscore                      ; E44B 20 4B F5                  K.
        ldy     address9                        ; E44E A4 2D                    .-
        jmp     turnoffdouble                   ; E450 4C 20 E7                 L .

; ----------------------------------------------------------------------------
missedbat:
        ldx     address8                        ; E453 A6 2B                    .+
        lda     a:temp7                         ; E455 AD 38 00                 .8.
        bne     @n2                           ; E458 D0 09                    ..
        ldy     $2C                             ; E45A A4 2C                    .,
        jsr     checkchrcollision               ; E45C 20 A4 DB                  ..
        bcs     turnoffbat                      ; E45F B0 E1                    ..
        bcc     @n1                           ; E461 90 0A                    ..
@n2:  clc                                     ; E463 18                       .
        adc     #$01                            ; E464 69 01                    i.
        cmp     #$03                            ; E466 C9 03                    ..
        bcc     @n1                           ; E468 90 03                    ..
        jmp     turnoffdouble                   ; E46A 4C 20 E7                 L .

; ----------------------------------------------------------------------------
@n1:  ldy     $2C                             ; E46D A4 2C                    .,
        ldx     address8                        ; E46F A6 2B                    .+
        lda     counter                         ; E471 A5 10                    ..
        lsr     a                               ; E473 4A                       J
        lsr     a                               ; E474 4A                       J
        and     #$01                            ; E475 29 01                    ).
        clc                                     ; E477 18                       .
        adc     #$31                            ; E478 69 31                    i1
        jsr     winprintsprite                  ; E47A 20 3A EE                  :.
        jmp     backfromscreenrou               ; E47D 4C 8A DF                 L..

; ----------------------------------------------------------------------------
movebat:lda     onscreenxl,y                    ; E480 B9 91 04                 ...
        and     #$07                            ; E483 29 07                    ).
        bne     batxok                          ; E485 D0 39                    .9
        lda     onscreeny,y                     ; E487 B9 B1 04                 ...
        sta     address7                        ; E48A 85 29                    .)
        lda     onscreenxh,y                    ; E48C B9 A1 04                 ...
        tax                                     ; E48F AA                       .
        lda     onscreencount1,y                ; E490 B9 C1 04                 ...
        beq     nowbaty                         ; E493 F0 42                    .B
        bmi     batnegx                         ; E495 30 0C                    0.
        lda     onscreenxl,y                    ; E497 B9 91 04                 ...
        clc                                     ; E49A 18                       .
        adc     #$08                            ; E49B 69 08                    i.
        bcc     doxbatchr                       ; E49D 90 0D                    ..
        inx                                     ; E49F E8                       .
        jmp     doxbatchr                       ; E4A0 4C AC E4                 L..

; ----------------------------------------------------------------------------
batnegx:lda     onscreenxl,y                    ; E4A3 B9 91 04                 ...
        sec                                     ; E4A6 38                       8
        sbc     #$08                            ; E4A7 E9 08                    ..
        bcs     doxbatchr                       ; E4A9 B0 01                    ..
        dex                                     ; E4AB CA                       .
doxbatchr:
        ldy     address7                        ; E4AC A4 29                    .)
        jsr     findsolid                       ; E4AE 20 2B F9                  +.
        ldy     address9                        ; E4B1 A4 2D                    .-
        cmp     #$03                            ; E4B3 C9 03                    ..
        bne     batxok                          ; E4B5 D0 09                    ..
        lda     #$00                            ; E4B7 A9 00                    ..
        sec                                     ; E4B9 38                       8
        sbc     onscreencount1,y                ; E4BA F9 C1 04                 ...
        sta     onscreencount1,y                ; E4BD 99 C1 04                 ...
batxok: ldx     #$00                            ; E4C0 A2 00                    ..
        lda     onscreencount1,y                ; E4C2 B9 C1 04                 ...
        bpl     @n1                           ; E4C5 10 02                    ..
        ldx     #$FF                            ; E4C7 A2 FF                    ..
@n1:  clc                                     ; E4C9 18                       .
        adc     onscreenxl,y                    ; E4CA 79 91 04                 y..
        sta     onscreenxl,y                    ; E4CD 99 91 04                 ...
        txa                                     ; E4D0 8A                       .
        adc     onscreenxh,y                    ; E4D1 79 A1 04                 y..
        sta     onscreenxh,y                    ; E4D4 99 A1 04                 ...
nowbaty:lda     onscreeny,y                     ; E4D7 B9 B1 04                 ...
        clc                                     ; E4DA 18                       .
        adc     #$F8                            ; E4DB 69 F8                    i.
        ldx     onscreencount2,y                ; E4DD BE D1 04                 ...
        cpx     #$00                            ; E4E0 E0 00                    ..
        beq     batyok                          ; E4E2 F0 21                    .!
        bmi     batnegy                         ; E4E4 30 03                    0.
        clc                                     ; E4E6 18                       .
        adc     #$10                            ; E4E7 69 10                    i.
batnegy:sta     address7                        ; E4E9 85 29                    .)
        lda     onscreenxl,y                    ; E4EB B9 91 04                 ...
        ldx     onscreenxh,y                    ; E4EE BE A1 04                 ...
        ldy     address7                        ; E4F1 A4 29                    .)
        jsr     findsolid                       ; E4F3 20 2B F9                  +.
        ldy     address9                        ; E4F6 A4 2D                    .-
        cmp     #$03                            ; E4F8 C9 03                    ..
        bne     batyok                          ; E4FA D0 09                    ..
        lda     #$00                            ; E4FC A9 00                    ..
        sec                                     ; E4FE 38                       8
        sbc     onscreencount2,y                ; E4FF F9 D1 04                 ...
        sta     onscreencount2,y                ; E502 99 D1 04                 ...
batyok: lda     $04D2,y                         ; E505 B9 D2 04                 ...
        clc                                     ; E508 18                       .
        adc     #$01                            ; E509 69 01                    i.
        sta     $04D2,y                         ; E50B 99 D2 04                 ...
        lsr     a                               ; E50E 4A                       J
        lsr     a                               ; E50F 4A                       J
        lsr     a                               ; E510 4A                       J
        and     #$07                            ; E511 29 07                    ).
        tax                                     ; E513 AA                       .
        lda     batwobble,x                     ; E514 BD 23 E5                 .#.
        clc                                     ; E517 18                       .
        adc     onscreencount2,y                ; E518 79 D1 04                 y..
        clc                                     ; E51B 18                       .
        adc     onscreeny,y                     ; E51C 79 B1 04                 y..
        sta     onscreeny,y                     ; E51F 99 B1 04                 ...
        rts                                     ; E522 60                       `

; ----------------------------------------------------------------------------
batwobble:
        .byte   $00,$01,$01,$00,$00,$FF,$FF,$00 ; E523 00 01 01 00 00 FF FF 00  ........
; ----------------------------------------------------------------------------
updaterat:
        lda     onscreenxh,y                    ; E52B B9 A1 04                 ...
        sec                                     ; E52E 38                       8
        sbc     scrxh                           ; E52F E5 3C                    .<
        clc                                     ; E531 18                       .
        adc     #$02                            ; E532 69 02                    i.
        cmp     #$05                            ; E534 C9 05                    ..
        bcc     @n1                           ; E536 90 08                    ..
        lda     #$00                            ; E538 A9 00                    ..
        sta     onscreenrou,y                   ; E53A 99 81 04                 ...
        jmp     backfromscreenrou               ; E53D 4C 8A DF                 L..

; ----------------------------------------------------------------------------
@n1:  lda     onscreencount2,y                ; E540 B9 D1 04                 ...
        and     #$07                            ; E543 29 07                    ).
        and     counter                         ; E545 25 10                    %.
        bne     movedrat                        ; E547 D0 23                    .#
        lda     onscreencount2,y                ; E549 B9 D1 04                 ...
        bmi     @n2                           ; E54C 30 13                    0.
        lda     onscreencount1,y                ; E54E B9 C1 04                 ...
        clc                                     ; E551 18                       .
        adc     #$01                            ; E552 69 01                    i.
        bne     @n3                           ; E554 D0 13                    ..
@n4:  lda     onscreencount2,y                ; E556 B9 D1 04                 ...
        eor     #$80                            ; E559 49 80                    I.
        sta     onscreencount2,y                ; E55B 99 D1 04                 ...
        jmp     movedrat                        ; E55E 4C 6C E5                 Ll.

; ----------------------------------------------------------------------------
@n2:  lda     onscreencount1,y                ; E561 B9 C1 04                 ...
        clc                                     ; E564 18                       .
        adc     #$FF                            ; E565 69 FF                    i.
        beq     @n4                           ; E567 F0 ED                    ..
@n3:  sta     onscreencount1,y                ; E569 99 C1 04                 ...
movedrat:
        lda     onscreencount1,y                ; E56C B9 C1 04                 ...
        sta     temp9                           ; E56F 85 3A                    .:
        sec                                     ; E571 38                       8
        sbc     #$80                            ; E572 E9 80                    ..
        php                                     ; E574 08                       .
        clc                                     ; E575 18                       .
        adc     onscreenxl,y                    ; E576 79 91 04                 y..
        sta     address8                        ; E579 85 2B                    .+
        lda     onscreenxh,y                    ; E57B B9 A1 04                 ...
        adc     #$00                            ; E57E 69 00                    i.
        plp                                     ; E580 28                       (
        sbc     #$00                            ; E581 E9 00                    ..
        sta     $2C                             ; E583 85 2C                    .,
        tax                                     ; E585 AA                       .
        lda     onscreeny,y                     ; E586 B9 B1 04                 ...
        sta     temp8                           ; E589 85 39                    .9
        lda     address8                        ; E58B A5 2B                    .+
        and     #$07                            ; E58D 29 07                    ).
        bne     ratnothitwall                   ; E58F D0 41                    .A
        lda     onscreencount2,y                ; E591 B9 D1 04                 ...
        and     #$80                            ; E594 29 80                    ).
        eor     #$80                            ; E596 49 80                    I.
        bpl     @n1                           ; E598 10 02                    ..
        lda     #$18                            ; E59A A9 18                    ..
@n1:  clc                                     ; E59C 18                       .
        adc     address8                        ; E59D 65 2B                    e+
        bcc     @n2                           ; E59F 90 01                    ..
        inx                                     ; E5A1 E8                       .
@n2:  sec                                     ; E5A2 38                       8
        sbc     #$10                            ; E5A3 E9 10                    ..
        bcs     @n3                           ; E5A5 B0 01                    ..
        dex                                     ; E5A7 CA                       .
@n3:  stx     $2A                             ; E5A8 86 2A                    .*
        sta     address7                        ; E5AA 85 29                    .)
        ldy     temp8                           ; E5AC A4 39                    .9
        jsr     findsolid                       ; E5AE 20 2B F9                  +.
        ldy     address9                        ; E5B1 A4 2D                    .-
        cmp     #$03                            ; E5B3 C9 03                    ..
        beq     rathitwall                      ; E5B5 F0 13                    ..
        ldx     $2A                             ; E5B7 A6 2A                    .*
        lda     temp8                           ; E5B9 A5 39                    .9
        clc                                     ; E5BB 18                       .
        adc     #$10                            ; E5BC 69 10                    i.
        tay                                     ; E5BE A8                       .
        lda     address7                        ; E5BF A5 29                    .)
        jsr     findsolid                       ; E5C1 20 2B F9                  +.
        ldy     address9                        ; E5C4 A4 2D                    .-
        cmp     #$00                            ; E5C6 C9 00                    ..
        bne     ratnothitwall                   ; E5C8 D0 08                    ..
rathitwall:
        lda     onscreencount2,y                ; E5CA B9 D1 04                 ...
        eor     #$80                            ; E5CD 49 80                    I.
        sta     onscreencount2,y                ; E5CF 99 D1 04                 ...
ratnothitwall:
        lda     onscreencount2,y                ; E5D2 B9 D1 04                 ...
        lsr     a                               ; E5D5 4A                       J
        and     #$40                            ; E5D6 29 40                    )@
        clc                                     ; E5D8 18                       .
        adc     #$01                            ; E5D9 69 01                    i.
        sta     temp                            ; E5DB 85 31                    .1
        lda     address8                        ; E5DD A5 2B                    .+
        sec                                     ; E5DF 38                       8
        sbc     scrxl                           ; E5E0 E5 3B                    .;
        sta     address7                        ; E5E2 85 29                    .)
        tax                                     ; E5E4 AA                       .
        lda     $2C                             ; E5E5 A5 2C                    .,
        sbc     scrxh                           ; E5E7 E5 3C                    .<
        sta     a:temp7                         ; E5E9 8D 38 00                 .8.
        lda     onscreeny,y                     ; E5EC B9 B1 04                 ...
        sta     $2A                             ; E5EF 85 2A                    .*
        clc                                     ; E5F1 18                       .
        ; changing y of collison on rat
        adc     #$04                            ; E5F2 69 04                    i.
        tay                                     ; E5F4 A8                       .
        ldx     address7                        ; E5F5 A6 29                    .)
        lda     a:temp7                         ; E5F7 AD 38 00                 .8.
        bne     @n1                           ; E5FA D0 1C                    ..
        jsr     checkchrcollision               ; E5FC 20 A4 DB                  ..
        ldx     address7                        ; E5FF A6 29                    .)
        lda     $2A                             ; E601 A5 2A                    .*
        clc                                     ; E603 18                       .
        adc     #$08                            ; E604 69 08                    i.
        tay                                     ; E606 A8                       .
        lda     temp9                           ; E607 A5 3A                    .:
        asl     a                               ; E609 0A                       .
        and     #$04                            ; E60A 29 04                    ).
        clc                                     ; E60C 18                       .
        adc     #$90                            ; E60D 69 90                    i.
        cmp     #$90                            ; E60F C9 90                    ..
        beq     @n2                           ; E611 F0 02                    ..
        lda     #$C8                            ; E613 A9 C8                    ..
@n2:  jsr     pokesprite2by2                  ; E615 20 EB EF                  ..
@n1:  jmp     backfromscreenrou               ; E618 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatespider:
        jsr     calconscreenx                   ; E61B 20 56 E1                  V.
        stx     address8                        ; E61E 86 2B                    .+
        lda     onscreencount1,y                ; E620 B9 C1 04                 ...
        sta     temp1                           ; E623 85 32                    .2
        clc                                     ; E625 18                       .
        adc     onscreeny,y                     ; E626 79 B1 04                 y..
        clc                                     ; E629 18                       .
        adc     #$08                            ; E62A 69 08                    i.
        sta     temp9                           ; E62C 85 3A                    .:
        lda     onscreeny,y                     ; E62E B9 B1 04                 ...
        clc                                     ; E631 18                       .
        adc     #$0C                            ; E632 69 0C                    i.
        sta     $2C                             ; E634 85 2C                    .,
        lda     onscreencount2,y                ; E636 B9 D1 04                 ...
        bpl     spidergoingdown                 ; E639 10 1E                    ..
        lda     counter                         ; E63B A5 10                    ..
        and     #$03                            ; E63D 29 03                    ).
        bne     movedspider                     ; E63F D0 45                    .E
        lda     onscreencount1,y                ; E641 B9 C1 04                 ...
        clc                                     ; E644 18                       .
        adc     #$FF                            ; E645 69 FF                    i.
        sta     onscreencount1,y                ; E647 99 C1 04                 ...
        beq     spiderchange                    ; E64A F0 32                    .2
        lda     onscreencount2,y                ; E64C B9 D1 04                 ...
        and     #$01                            ; E64F 29 01                    ).
        beq     movedspider                     ; E651 F0 33                    .3
        lda     counter                         ; E653 A5 10                    ..
        beq     spiderchange                    ; E655 F0 27                    .'
        bne     movedspider                     ; E657 D0 2D                    .-
spidergoingdown:
        lda     onscreencount1,y                ; E659 B9 C1 04                 ...
        clc                                     ; E65C 18                       .
        adc     #$01                            ; E65D 69 01                    i.
        sta     onscreencount1,y                ; E65F 99 C1 04                 ...
        and     #$07                            ; E662 29 07                    ).
        bne     movedspider                     ; E664 D0 20                    . 
        lda     temp9                           ; E666 A5 3A                    .:
        clc                                     ; E668 18                       .
        adc     #$10                            ; E669 69 10                    i.
        sta     temp                            ; E66B 85 31                    .1
        ldx     onscreenxh,y                    ; E66D BE A1 04                 ...
        lda     onscreenxl,y                    ; E670 B9 91 04                 ...
        ldy     temp                            ; E673 A4 31                    .1
        jsr     findsolid                       ; E675 20 2B F9                  +.
        ldy     address9                        ; E678 A4 2D                    .-
        cmp     #$00                            ; E67A C9 00                    ..
        beq     movedspider                     ; E67C F0 08                    ..
spiderchange:
        lda     onscreencount2,y                ; E67E B9 D1 04                 ...
        eor     #$80                            ; E681 49 80                    I.
        sta     onscreencount2,y                ; E683 99 D1 04                 ...
movedspider:
        lda     temp9                           ; E686 A5 3A                    .:
        jsr     pickupcollision                 ; E688 20 FE D3                  ..
        bcs     printspider                     ; E68B B0 07                    ..
        lda     #$01                            ; E68D A9 01                    ..
        jsr     subfromhearts                   ; E68F 20 97 F5                  ..
        ldy     address9                        ; E692 A4 2D                    .-
printspider:
        lda     onscreencount2,y                ; E694 B9 D1 04                 ...
        and     #$01                            ; E697 29 01                    ).
        bne     @n2                           ; E699 D0 0A                    ..
        ; chain
        lda     #$98                            ; E69B A9 98                    ..
        ; balls+1
        sta     address7                        ; E69D 85 29                    .)
        ldx     #$02                            ; E69F A2 02                    ..
        lda     #$B3                            ; E6A1 A9 B3                    ..
        bne     @n3                           ; E6A3 D0 14                    ..
; spiders web
@n2:  lda     #$94                            ; E6A5 A9 94                    ..
        sta     address7                        ; E6A7 85 29                    .)
        ldx     #$01                            ; E6A9 A2 01                    ..
        lda     onscreencount1,y                ; E6AB B9 C1 04                 ...
        and     #$02                            ; E6AE 29 02                    ).
        clc                                     ; E6B0 18                       .
        adc     #$A4                            ; E6B1 69 A4                    i.
        cmp     #$A4                            ; E6B3 C9 A4                    ..
        beq     @n3                           ; E6B5 F0 02                    ..
        lda     #$F2                            ; E6B7 A9 F2                    ..
@n3:  stx     $2A                             ; E6B9 86 2A                    .*
        stx     temp                            ; E6BB 86 31                    .1
        ldy     temp9                           ; E6BD A4 3A                    .:
        ldx     a:temp7                         ; E6BF AE 38 00                 .8.
        bne     @n4                           ; E6C2 D0 05                    ..
        ldx     address8                        ; E6C4 A6 2B                    .+
        ; winprintsprite
        jsr     pokesprite2by2                  ; E6C6 20 EB EF                  ..
@n4:  lda     address8                        ; E6C9 A5 2B                    .+
        clc                                     ; E6CB 18                       .
        adc     #$FC                            ; E6CC 69 FC                    i.
        sta     address8                        ; E6CE 85 2B                    .+
        bcs     @n1                           ; E6D0 B0 03                    ..
        dec     a:temp7                         ; E6D2 CE 38 00                 .8.
@n1:  lda     a:temp7                         ; E6D5 AD 38 00                 .8.
        bne     endspider                       ; E6D8 D0 2C                    .,
        lda     $2A                             ; E6DA A5 2A                    .*
        sta     temp                            ; E6DC 85 31                    .1
        lda     temp9                           ; E6DE A5 3A                    .:
        clc                                     ; E6E0 18                       .
        adc     #$FC                            ; E6E1 69 FC                    i.
        tay                                     ; E6E3 A8                       .
        cmp     #$08                            ; E6E4 C9 08                    ..
        bcc     endspider                       ; E6E6 90 1E                    ..
drawchain:
        ldx     address8                        ; E6E8 A6 2B                    .+
        lda     address7                        ; E6EA A5 29                    .)
        jsr     pokesprite                      ; E6EC 20 CD EF                  ..
        tya                                     ; E6EF 98                       .
        sec                                     ; E6F0 38                       8
        sbc     #$08                            ; E6F1 E9 08                    ..
        tay                                     ; E6F3 A8                       .
        cmp     $2C                             ; E6F4 C5 2C                    .,
        bcs     drawchain                       ; E6F6 B0 F0                    ..
        lda     $2A                             ; E6F8 A5 2A                    .*
        clc                                     ; E6FA 18                       .
        adc     #$20                            ; E6FB 69 20                    i 
        sta     temp                            ; E6FD 85 31                    .1
        ldx     address8                        ; E6FF A6 2B                    .+
        lda     address7                        ; E701 A5 29                    .)
        jsr     pokesprite                      ; E703 20 CD EF                  ..
endspider:
        jmp     backfromscreenrou               ; E706 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updatebarrel:
        lda     $04B2,y                         ; E709 B9 B2 04                 ...
        bne     barrelmoving                    ; E70C D0 3D                    .=
        lda     onscreenxl,y                    ; E70E B9 91 04                 ...
        sec                                     ; E711 38                       8
        sbc     scrxl                           ; E712 E5 3B                    .;
        lda     onscreenxh,y                    ; E714 B9 A1 04                 ...
        sbc     scrxh                           ; E717 E5 3C                    .<
        clc                                     ; E719 18                       .
        adc     #$01                            ; E71A 69 01                    i.
        cmp     #$03                            ; E71C C9 03                    ..
        bcc     dontturnoffbarrel               ; E71E 90 0B                    ..
turnoffdouble:
        lda     #$00                            ; E720 A9 00                    ..
        sta     onscreenrou,y                   ; E722 99 81 04                 ...
        sta     $0482,y                         ; E725 99 82 04                 ...
        jmp     backfromscreenrou               ; E728 4C 8A DF                 L..

; ----------------------------------------------------------------------------
dontturnoffbarrel:
        lda     onscreeny,y                     ; E72B B9 B1 04                 ...
        clc                                     ; E72E 18                       .
        adc     #$01                            ; E72F 69 01                    i.
        sta     $04B2,y                         ; E731 99 B2 04                 ...
        lda     onscreenxl,y                    ; E734 B9 91 04                 ...
        sta     $0492,y                         ; E737 99 92 04                 ...
        lda     onscreenxh,y                    ; E73A B9 A1 04                 ...
        sta     $04A2,y                         ; E73D 99 A2 04                 ...
        lda     $04D2,y                         ; E740 B9 D2 04                 ...
        sta     onscreencount1,y                ; E743 99 C1 04                 ...
        lda     #$00                            ; E746 A9 00                    ..
        sta     $04C2,y                         ; E748 99 C2 04                 ...
barrelmoving:
        lda     $0492,y                         ; E74B B9 92 04                 ...
        sec                                     ; E74E 38                       8
        sbc     scrxl                           ; E74F E5 3B                    .;
        sta     address7                        ; E751 85 29                    .)
        lda     $04A2,y                         ; E753 B9 A2 04                 ...
        sbc     scrxh                           ; E756 E5 3C                    .<
        sta     a:temp7                         ; E758 8D 38 00                 .8.
        jsr     movebarrel                      ; E75B 20 92 E7                  ..
        lda     $04B2,y                         ; E75E B9 B2 04                 ...
        sta     $2A                             ; E761 85 2A                    .*
        ldx     address7                        ; E763 A6 29                    .)
        lda     onscreencount2,y                ; E765 B9 D1 04                 ...
        bne     @n1                           ; E768 D0 15                    ..
        lda     a:temp7                         ; E76A AD 38 00                 .8.
        bne     endbarrel                       ; E76D D0 20                    . 
        lda     #$02                            ; E76F A9 02                    ..
        sta     temp                            ; E771 85 31                    .1
        ; balls
        lda     #$AF                            ; E773 A9 AF                    ..
        ldy     $2A                             ; E775 A4 2A                    .*
        beq     endbarrel                       ; E777 F0 16                    ..
        jsr     pokesprite2by2                  ; E779 20 EB EF                  ..
        jmp     backfromscreenrou               ; E77C 4C 8A DF                 L..

; ----------------------------------------------------------------------------
@n1:  lda     address7                        ; E77F A5 29                    .)
        lsr     a                               ; E781 4A                       J
        lsr     a                               ; E782 4A                       J
        and     #$03                            ; E783 29 03                    ).
        clc                                     ; E785 18                       .
        adc     #$20                            ; E786 69 20                    i 
        ldy     $2A                             ; E788 A4 2A                    .*
        beq     endbarrel                       ; E78A F0 03                    ..
        jsr     winprintsprite                  ; E78C 20 3A EE                  :.
endbarrel:
        jmp     backfromscreenrou               ; E78F 4C 8A DF                 L..

; ----------------------------------------------------------------------------
movebarrel:
        ldx     onscreencount1,y                ; E792 BE C1 04                 ...
        stx     temp9                           ; E795 86 3A                    .:
        inx                                     ; E797 E8                       .
        lda     $0492,y                         ; E798 B9 92 04                 ...
        clc                                     ; E79B 18                       .
        adc     onscreencount1,y                ; E79C 79 C1 04                 y..
        sta     $0492,y                         ; E79F 99 92 04                 ...
        lda     $04A2,y                         ; E7A2 B9 A2 04                 ...
        adc     highbitadd,x                    ; E7A5 7D DB F4                 }..
        sta     $04A2,y                         ; E7A8 99 A2 04                 ...
        lda     $04C2,y                         ; E7AB B9 C2 04                 ...
        beq     @n3                           ; E7AE F0 32                    .2
        bmi     @n1                           ; E7B0 30 05                    0.
        lsr     a                               ; E7B2 4A                       J
        lsr     a                               ; E7B3 4A                       J
        jmp     @n2                           ; E7B4 4C C3 E7                 L..

; ----------------------------------------------------------------------------
@n1:  eor     #$FF                            ; E7B7 49 FF                    I.
        clc                                     ; E7B9 18                       .
        adc     #$01                            ; E7BA 69 01                    i.
        lsr     a                               ; E7BC 4A                       J
        lsr     a                               ; E7BD 4A                       J
        eor     #$FF                            ; E7BE 49 FF                    I.
        clc                                     ; E7C0 18                       .
        adc     #$01                            ; E7C1 69 01                    i.
@n2:  clc                                     ; E7C3 18                       .
        adc     $04B2,y                         ; E7C4 79 B2 04                 y..
        sta     $04B2,y                         ; E7C7 99 B2 04                 ...
        tax                                     ; E7CA AA                       .
        cpx     #$C0                            ; E7CB E0 C0                    ..
        bcc     @n3                           ; E7CD 90 13                    ..
        lda     $04C2,y                         ; E7CF B9 C2 04                 ...
        clc                                     ; E7D2 18                       .
        adc     #$01                            ; E7D3 69 01                    i.
        sta     $04C2,y                         ; E7D5 99 C2 04                 ...
        cpx     #$E8                            ; E7D8 E0 E8                    ..
        bcc     @n4                           ; E7DA 90 05                    ..
        lda     #$00                            ; E7DC A9 00                    ..
        sta     $04B2,y                         ; E7DE 99 B2 04                 ...
@n4:  rts                                     ; E7E1 60                       `

; ----------------------------------------------------------------------------
@n3:  ldx     $04A2,y                         ; E7E2 BE A2 04                 ...
        lda     onscreencount1,y                ; E7E5 B9 C1 04                 ...
        bne     @n5                           ; E7E8 D0 07                    ..
        lda     $0492,y                         ; E7EA B9 92 04                 ...
        and     #$07                            ; E7ED 29 07                    ).
        bne     barrelonfloor                   ; E7EF D0 2A                    .*
@n5:  lda     $04B2,y                         ; E7F1 B9 B2 04                 ...
        clc                                     ; E7F4 18                       .
        adc     #$09                            ; E7F5 69 09                    i.
        sta     temp                            ; E7F7 85 31                    .1
        lda     $0492,y                         ; E7F9 B9 92 04                 ...
        ldy     temp                            ; E7FC A4 31                    .1
        jsr     findsolid                       ; E7FE 20 2B F9                  +.
        ldy     address9                        ; E801 A4 2D                    .-
        cmp     #$03                            ; E803 C9 03                    ..
        beq     barrelonfloor                   ; E805 F0 14                    ..
        lda     counter                         ; E807 A5 10                    ..
        and     #$01                            ; E809 29 01                    ).
        bne     donegrav                        ; E80B D0 2F                    ./
        lda     $04C2,y                         ; E80D B9 C2 04                 ...
        clc                                     ; E810 18                       .
        adc     #$01                            ; E811 69 01                    i.
        cmp     #$11                            ; E813 C9 11                    ..
        bne     storegrav                       ; E815 D0 22                    ."
        lda     #$10                            ; E817 A9 10                    ..
        bne     storegrav                       ; E819 D0 1E                    ..
barrelonfloor:
        lda     $04C2,y                         ; E81B B9 C2 04                 ...
        bmi     donegrav                        ; E81E 30 1C                    0.
        cmp     #$04                            ; E820 C9 04                    ..
        bcc     @n1                           ; E822 90 0A                    ..
        lda     a:temp7                         ; E824 AD 38 00                 .8.
        bne     @n1                           ; E827 D0 05                    ..
        lda     #$10                            ; E829 A9 10                    ..
        jsr     soundfx                         ; E82B 20 28 F4                  (.
@n1:  lda     $04C2,y                         ; E82E B9 C2 04                 ...
        bmi     donegrav                        ; E831 30 09                    0.
        lsr     a                               ; E833 4A                       J
        eor     #$FF                            ; E834 49 FF                    I.
        clc                                     ; E836 18                       .
        adc     #$01                            ; E837 69 01                    i.
storegrav:
        sta     $04C2,y                         ; E839 99 C2 04                 ...
donegrav:
        lda     $0492,y                         ; E83C B9 92 04                 ...
        asl     temp9                           ; E83F 06 3A                    .:
        adc     #$00                            ; E841 69 00                    i.
        and     #$03                            ; E843 29 03                    ).
        bne     barrelnothitwall                ; E845 D0 3B                    .;
        lda     $0492,y                         ; E847 B9 92 04                 ...
        ldx     onscreencount1,y                ; E84A BE C1 04                 ...
        bmi     @n1                           ; E84D 30 06                    0.
        clc                                     ; E84F 18                       .
        adc     #$08                            ; E850 69 08                    i.
        jmp     @n2                           ; E852 4C 58 E8                 LX.

; ----------------------------------------------------------------------------
@n1:  clc                                     ; E855 18                       .
        adc     #$F8                            ; E856 69 F8                    i.
@n2:  sta     temp                            ; E858 85 31                    .1
        inx                                     ; E85A E8                       .
        lda     $04A2,y                         ; E85B B9 A2 04                 ...
        adc     highbitadd,x                    ; E85E 7D DB F4                 }..
        tax                                     ; E861 AA                       .
        lda     $04B2,y                         ; E862 B9 B2 04                 ...
        clc                                     ; E865 18                       .
        adc     #$06                            ; E866 69 06                    i.
        tay                                     ; E868 A8                       .
        lda     temp                            ; E869 A5 31                    .1
        jsr     findsolid                       ; E86B 20 2B F9                  +.
        ldy     address9                        ; E86E A4 2D                    .-
        lda     solidfound                      ; E870 A5 43                    .C
        cmp     #$03                            ; E872 C9 03                    ..
        bne     barrelnothitwall                ; E874 D0 0C                    ..
        lda     #$00                            ; E876 A9 00                    ..
        sec                                     ; E878 38                       8
        sbc     onscreencount1,y                ; E879 F9 C1 04                 ...
        sta     onscreencount1,y                ; E87C 99 C1 04                 ...
        jmp     barrelnothitwall                ; E87F 4C 82 E8                 L..

; ----------------------------------------------------------------------------
barrelnothitwall:
        lda     a:temp7                         ; E882 AD 38 00                 .8.
        bne     endbarrelmove                   ; E885 D0 3E                    .>
        lda     address7                        ; E887 A5 29                    .)
        sec                                     ; E889 38                       8
        sbc     robinonscrx                     ; E88A ED 0B 03                 ...
        clc                                     ; E88D 18                       .
        adc     #$0C                            ; E88E 69 0C                    i.
        cmp     #$18                            ; E890 C9 18                    ..
        bcs     endbarrelmove                   ; E892 B0 31                    .1
        lda     $04B2,y                         ; E894 B9 B2 04                 ...
        sec                                     ; E897 38                       8
        sbc     robiny                          ; E898 ED 0A 03                 ...
        clc                                     ; E89B 18                       .
        adc     #$20                            ; E89C 69 20                    i 
        cmp     #$1E                            ; E89E C9 1E                    ..
        bcc     barrelhitrobin                  ; E8A0 90 17                    ..
        ldx     robinladder                     ; E8A2 AE 1A 03                 ...
        bne     endbarrelmove                   ; E8A5 D0 1E                    ..
        cmp     #$2C                            ; E8A7 C9 2C                    .,
        bcs     endbarrelmove                   ; E8A9 B0 1A                    ..
        lda     $04B2,y                         ; E8AB B9 B2 04                 ...
        clc                                     ; E8AE 18                       .
        adc     #$F7                            ; E8AF 69 F7                    i.
        sta     $2A                             ; E8B1 85 2A                    .*
        jsr     robinjumpoffplatform            ; E8B3 20 9B DA                  ..
        ldy     address9                        ; E8B6 A4 2D                    .-
        rts                                     ; E8B8 60                       `

; ----------------------------------------------------------------------------
barrelhitrobin:
        lda     robininvinc                     ; E8B9 AD 1C 03                 ...
        bne     endbarrelmove                   ; E8BC D0 07                    ..
        lda     #$01                            ; E8BE A9 01                    ..
        jsr     subfromhearts                   ; E8C0 20 97 F5                  ..
        ldy     address9                        ; E8C3 A4 2D                    .-
endbarrelmove:
        rts                                     ; E8C5 60                       `

; ----------------------------------------------------------------------------
updateblock:
        jsr     calconscreenx                   ; E8C6 20 56 E1                  V.
        jmp     backfromscreenrou               ; E8C9 4C 8A DF                 L..

; ----------------------------------------------------------------------------
updateheart:
        jsr     calconscreenx                   ; E8CC 20 56 E1                  V.
        jsr     changebank13rou                 ; E8CF 20 7C C2                  |.
        jsr     b1_restupdatecoin               ; E8D2 20 DA A6                  ..
        jsr     changebank12rou                 ; E8D5 20 74 C2                  t.
        jmp     backfromscreenrou               ; E8D8 4C 8A DF                 L..

; spritetable: 66 word pointers to sprite definitions
; ----------------------------------------------------------------------------
; ==========================================================================
; SPRITESD.DAT
; ==========================================================================
spritetable:
        .word   $E9D9,$E9DE,$E9E3,$E9E8         ; E8DB D9 E9 DE E9 E3 E9 E8 E9  ........
        .word   $E9ED,$E9F3,$E9F9,$E9FF         ; E8E3 ED E9 F3 E9 F9 E9 FF E9  ........
        .word   $EA04,$EA09,$EA0F,$E9FF         ; E8EB 04 EA 09 EA 0F EA FF E9  ........
        .word   $EA30,$EA3D,$EA57,$EA68         ; E8F3 30 EA 3D EA 57 EA 68 EA  0.=.W.h.
        .word   $EA79,$EA8A,$EA9B,$EAA9         ; E8FB 79 EA 8A EA 9B EA A9 EA  y.......
        .word   $EAAE,$EABB,$EACC,$EADA         ; E903 AE EA BB EA CC EA DA EA  ........
        .word   $EAAE,$EAE5,$EAEA,$EAFB         ; E90B AE EA E5 EA EA EA FB EA  ........
        .word   $EB04,$EB0E,$EB1F,$EB24         ; E913 04 EB 0E EB 1F EB 24 EB  ......$.
        .word   $EB31,$EB42,$EB53,$EB42         ; E91B 31 EB 42 EB 53 EB 42 EB  1.B.S.B.
        .word   $EB64,$EB6A,$E95F,$E9A3         ; E923 64 EB 6A EB 5F E9 A3 E9  d.j._...
        .word   $E9C4,$EBC6,$EBD7,$EBE8         ; E92B C4 E9 C6 EB D7 EB E8 EB  ........
        .word   $EBF9,$EB70,$EB81,$EB8A         ; E933 F9 EB 70 EB 81 EB 8A EB  ..p.....
        .word   $EB95,$EBA6,$EBAF,$EC0A         ; E93B 95 EB A6 EB AF EB 0A EC  ........
        .word   $EC13,$EC1C,$EC25,$EC2E         ; E943 13 EC 1C EC 25 EC 2E EC  ....%...
        .word   $EC41,$EC54,$EC61,$EC7A         ; E94B 41 EC 54 EC 61 EC 7A EC  A.T.a.z.
        .word   $EC7F,$EC90,$ECA1,$ECAE         ; E953 7F EC 90 EC A1 EC AE EC  ........
        .word   $ECBB,$ECD8                     ; E95B BB EC D8 EC              ....
; --- titlelogos group ---
; ----------------------------------------------------------------------------
spr_codemasterlogo:
        .byte   $07,$00,$80,$E9,$20,$FD,$08,$85 ; E95F 07 00 80 E9 20 FD 08 85  .... ...
        .byte   $E9,$20,$F8,$10,$8B,$E9,$20,$F8 ; E967 E9 20 F8 10 8B E9 20 F8  . .... .
        .byte   $18,$92,$E9,$20,$FB,$20,$99,$E9 ; E96F 18 92 E9 20 FB 20 99 E9  ... . ..
        .byte   $20,$05,$28,$9F,$E9             ; E977 20 05 28 9F E9            .(..
spr_cm_chrdata0:
        .byte   $30,$F8,$24,$F2,$41             ; E97C 30 F8 24 F2 41           0.$.A
spr_cm_chrdata1:
        .byte   $D5,$D6,$D7,$D8,$51,$D9         ; E981 D5 D6 D7 D8 51 D9        ....Q.
spr_cm_chrdata2:
        .byte   $DA,$DB,$DC,$DD,$61,$DE,$DF     ; E987 DA DB DC DD 61 DE DF     ....a..
spr_cm_chrdata3:
        .byte   $E0,$E1,$E2,$E3,$61,$E4,$E5     ; E98E E0 E1 E2 E3 61 E4 E5     ....a..
spr_cm_chrdata4:
        .byte   $E6,$E7,$E8,$E9,$51,$EA         ; E995 E6 E7 E8 E9 51 EA        ....Q.
spr_cm_chrdata5:
        .byte   $EB,$EC,$ED,$EE,$31,$EF,$F0,$F1 ; E99B EB EC ED EE 31 EF F0 F1  ....1...
spr_camericalogo:
        .byte   $02,$01,$AC,$E9,$21,$06,$10,$BD ; E9A3 02 01 AC E9 21 06 10 BD  ....!...
        .byte   $E9,$82                         ; E9AB E9 82                    ..
spr_cam_chrdata0:
        .byte   $DC,$DD,$DE,$DF,$E0,$E1,$E2,$E3 ; E9AD DC DD DE DF E0 E1 E2 E3  ........
        .byte   $E4,$E5,$E6                     ; E9B5 E4 E5 E6                 ...
spr_cam_chrdata1:
        .byte   $E7,$E8,$E9,$EA,$EB,$61,$EC,$ED ; E9B8 E7 E8 E9 EA EB 61 EC ED  .....a..
        .byte   $ED,$ED,$ED,$EE                 ; E9C0 ED ED ED EE              ....
spr_pressstart:
        .byte   $02,$02,$CD,$E9,$22,$00,$0A,$D3 ; E9C4 02 02 CD E9 22 00 0A D3  ...."...
spr_ps_chrdata0:
        .byte   $E9,$51,$EF,$F0,$F1,$F2         ; E9CC E9 51 EF F0 F1 F2        .Q....
spr_ps_chrdata1:
        .byte   $F2,$51,$F2,$F3,$F4,$F0,$F3     ; E9D2 F2 51 F2 F3 F4 F0 F3     .Q.....
; --- robinheads group (4 frames) ---
spr_head0:
        .byte   $01,$3C                         ; E9D9 01 3C                    .<
spritetable_100:  .byte   $FB                             ; E9DB FB                       .
spritetable_101:  .byte   $F1,$01                         ; E9DC F1 01                    ..
spr_head1:
        .byte   $01,$3C,$FB,$F1,$05             ; E9DE 01 3C FB F1 05           .<...
spr_head2:
        .byte   $01,$3C,$FB,$F1,$09             ; E9E3 01 3C FB F1 09           .<...
spr_head3:
        .byte   $01,$7C,$F8,$F1,$0D             ; E9E8 01 7C F8 F1 0D           .|...
; --- robinbodies group (7 frames) ---
spr_robinbody0:
        .byte   $01,$24,$F9,$F2,$14,$EA         ; E9ED 01 24 F9 F2 14 EA        .$....
spr_robinbody1:
        .byte   $01,$24,$F7,$F1,$1B,$EA         ; E9F3 01 24 F7 F1 1B EA        .$....
spr_robinbody2:
        .byte   $01,$24,$F8,$F3,$22,$EA         ; E9F9 01 24 F8 F3 22 EA        .$..".
spr_robinbody3:
        .byte   $01,$3C,$FA,$F4,$23             ; E9FF 01 3C FA F4 23           .<..#
spr_robinbody4:
        .byte   $01,$3C,$FA,$F5,$27             ; EA04 01 3C FA F5 27           .<..'
spr_robinbody5:
        .byte   $01,$24,$F8,$F3,$29,$EA         ; EA09 01 24 F8 F3 29 EA        .$..).
spr_robinbody6:
        .byte   $01,$3C,$F9,$F3,$31,$32,$11,$12 ; EA0F 01 3C F9 F3 31 32 11 12  .<..12..
        .byte   $13,$14,$15,$16,$32,$17,$18,$19 ; EA17 13 14 15 16 32 17 18 19  ....2...
        .byte   $1A,$1B,$1C,$32,$1D,$1E,$1F,$20 ; EA1F 1A 1B 1C 32 1D 1E 1F 20  ...2... 
        .byte   $21,$22,$32,$2B,$2C,$2D,$2E,$2F ; EA27 21 22 32 2B 2C 2D 2E 2F  !"2+,-./
        .byte   $30                             ; EA2F 30                       0
; --- bodyfiring group (standing + 4 fire frames) ---
spr_robinstanding:
        .byte   $01,$24,$F8,$F1,$36,$EA,$23,$35 ; EA30 01 24 F8 F1 36 EA 23 35  .$..6.#5
        .byte   $36,$37,$38,$39,$3A             ; EA38 36 37 38 39 3A           6789:
spr_bodyfire0:
        .byte   $03,$24,$F8,$F1,$4D,$EA,$24,$00 ; EA3D 03 24 F8 F1 4D EA 24 00  .$..M.$.
        .byte   $F1,$50,$EA,$24,$08,$F5,$54,$EA ; EA45 F1 50 EA 24 08 F5 54 EA  .P.$..T.
        .byte   $12,$35,$3B,$13,$36,$3C,$3D,$12 ; EA4D 12 35 3B 13 36 3C 3D 12  .5;.6<=.
        .byte   $3E,$3F                         ; EA55 3E 3F                    >?
spr_bodyfire1:
        .byte   $02,$24,$F8,$F1,$61,$EA,$34,$08 ; EA57 02 24 F8 F1 61 EA 34 08  .$..a.4.
        .byte   $01,$44,$32,$35,$36,$40,$41,$42 ; EA5F 01 44 32 35 36 40 41 42  .D256@AB
        .byte   $43                             ; EA67 43                       C
spr_bodyfire2:
        .byte   $02,$24,$F8,$F1,$72,$EA,$34,$08 ; EA68 02 24 F8 F1 72 EA 34 08  .$..r.4.
        .byte   $01,$49,$32,$35,$45,$46,$41,$47 ; EA70 01 49 32 35 45 46 41 47  .I25EFAG
        .byte   $48                             ; EA78 48                       H
spr_bodyfire3:
        .byte   $02,$24,$F8,$F1,$83,$EA,$34,$08 ; EA79 02 24 F8 F1 83 EA 34 08  .$....4.
        .byte   $01,$4E,$32,$35,$4A,$4B,$41,$4C ; EA81 01 4E 32 35 4A 4B 41 4C  .N25JKAL
        .byte   $4D                             ; EA89 4D                       M
; --- legsrunning group (7 frames) ---
spr_legsrun0:
        .byte   $02,$24,$FA,$F2,$95,$EA,$24,$F8 ; EA8A 02 24 FA F2 95 EA 24 F8  .$....$.
        .byte   $FA,$98,$EA,$21,$4F,$50,$21,$51 ; EA92 FA 98 EA 21 4F 50 21 51  ...!OP!Q
        .byte   $52                             ; EA9A 52                       R
spr_legsrun1:
        .byte   $02,$24,$F3,$F3,$A5,$EA,$34,$03 ; EA9B 02 24 F3 F3 A5 EA 34 03  .$....4.
        .byte   $FB,$56,$31,$53,$54,$55         ; EAA3 FB 56 31 53 54 55        .V1STU
spr_legsrun2:
        .byte   $01,$3C,$F6,$F2,$57             ; EAA9 01 3C F6 F2 57           .<..W
spr_legsrun3:
        .byte   $02,$24,$FA,$F2,$B8,$EA,$34,$FA ; EAAE 02 24 FA F2 B8 EA 34 FA  .$....4.
        .byte   $FA,$5D,$21,$5B,$5C             ; EAB6 FA 5D 21 5B 5C           .]![\
spr_legsrun4:
        .byte   $02,$24,$F9,$F2,$C6,$EA,$24,$F8 ; EABB 02 24 F9 F2 C6 EA 24 F8  .$....$.
        .byte   $FA,$C9,$EA,$21,$5E,$5F,$21,$51 ; EAC3 FA C9 EA 21 5E 5F 21 51  ...!^_!Q
        .byte   $52                             ; EACB 52                       R
spr_legsrun5:
        .byte   $02,$24,$F4,$F3,$D6,$EA,$34,$04 ; EACC 02 24 F4 F3 D6 EA 34 04  .$....4.
        .byte   $FB,$56,$31,$53,$60,$55         ; EAD4 FB 56 31 53 60 55        .V1S`U
spr_legsrun6:
        .byte   $01,$24,$F7,$F2,$E0,$EA,$22,$57 ; EADA 01 24 F7 F2 E0 EA 22 57  .$...."W
        .byte   $61,$59,$5A                     ; EAE2 61 59 5A                 aYZ
; --- morelegs group (standing, jumping, crouch, ladder) ---
spr_legsstanding:
        .byte   $01,$3C,$FC,$F2,$62             ; EAE5 01 3C FC F2 62           .<..b
spr_legsjumping:
        .byte   $02,$24,$F9,$F3,$F5,$EA,$24,$F8 ; EAEA 02 24 F9 F3 F5 EA 24 F8  .$....$.
        .byte   $FB,$F8,$EA,$21,$66,$67,$21,$68 ; EAF2 FB F8 EA 21 66 67 21 68  ...!fg!h
        .byte   $69                             ; EAFA 69                       i
spr_bodyonladder:
        .byte   $01,$24,$FB,$F9,$01,$EB,$21,$6A ; EAFB 01 24 FB F9 01 EB 21 6A  .$....!j
        .byte   $6B                             ; EB03 6B                       k
spr_legsonladder:
        .byte   $01,$24,$F7,$F9,$0A,$EB,$31,$6C ; EB04 01 24 F7 F9 0A EB 31 6C  .$....1l
        .byte   $6D,$6E                         ; EB0C 6D 6E                    mn
spr_bodyfullcrouch:
        .byte   $03,$24,$F3,$F6,$1C,$EB,$34,$03 ; EB0E 03 24 F3 F6 1C EB 34 03  .$....4.
        .byte   $F5,$71,$34,$05,$FB,$56,$21,$6F ; EB16 F5 71 34 05 FB 56 21 6F  .q4..V!o
        .byte   $70                             ; EB1E 70                       p
spr_legsfullcrouch:
        .byte   $01,$3C,$F7,$F1,$72             ; EB1F 01 3C F7 F1 72           .<..r
spr_legshalfcrouch:
        .byte   $02,$24,$FB,$F4,$2E,$EB,$34,$FB ; EB24 02 24 FB F4 2E EB 34 FB  .$....4.
        .byte   $FC,$78,$21,$76,$77             ; EB2C FC 78 21 76 77           .x!vw
; --- barrels group (3 rotation frames) ---
spr_barrel0:
        .byte   $04,$31,$F8,$F8,$A8,$71,$00,$F8 ; EB31 04 31 F8 F8 A8 71 00 F8  .1...q..
        .byte   $A8,$B1,$F8,$F8,$A8,$F1,$00,$F8 ; EB39 A8 B1 F8 F8 A8 F1 00 F8  ........
        .byte   $A8                             ; EB41 A8                       .
spr_barrel1:
        .byte   $04,$31,$F8,$F8,$AA,$31,$00,$F8 ; EB42 04 31 F8 F8 AA 31 00 F8  .1...1..
        .byte   $AB,$F1,$F8,$F8,$AB,$F1,$00,$F8 ; EB4A AB F1 F8 F8 AB F1 00 F8  ........
        .byte   $AA                             ; EB52 AA                       .
spr_barrel2:
        .byte   $04,$31,$F8,$F8,$A9,$71,$00,$F8 ; EB53 04 31 F8 F8 A9 71 00 F8  .1...q..
        .byte   $A9,$B1,$F8,$F8,$A9,$F1,$00,$F8 ; EB5B A9 B1 F8 F8 A9 F1 00 F8  ........
        .byte   $A9                             ; EB63 A9                       .
; --- canon + platform ---
spr_canon:
        .byte   $01,$22,$F4,$00,$BB,$EB         ; EB64 01 22 F4 00 BB EB        ."....
spr_platform:
        .byte   $01,$21,$F4,$01,$C2,$EB         ; EB6A 01 21 F4 01 C2 EB        .!....
; --- trampoline group (2 frames) ---
spr_trampet0:
        .byte   $04,$32,$F8,$00,$A2,$72,$00,$00 ; EB70 04 32 F8 00 A2 72 00 00  .2...r..
        .byte   $A2,$32,$F8,$08,$A3,$72,$00,$08 ; EB78 A2 32 F8 08 A3 72 00 08  .2...r..
        .byte   $A3                             ; EB80 A3                       .
spr_trampet1:
        .byte   $02,$32,$F8,$08,$A1,$72,$00,$08 ; EB81 02 32 F8 08 A1 72 00 08  .2...r..
        .byte   $A1                             ; EB89 A1                       .
; --- spider group (2 frames) ---
spr_spider0:
        .byte   $02,$21,$F8,$F8,$A0,$EB,$61,$00 ; EB8A 02 21 F8 F8 A0 EB 61 00  .!....a.
        .byte   $F8,$A0,$EB                     ; EB92 F8 A0 EB                 ...
spr_spider1:
        .byte   $02,$21,$F8,$F8,$A3,$EB,$61,$00 ; EB95 02 21 F8 F8 A3 EB 61 00  .!....a.
        .byte   $F8,$A3,$EB,$12,$A4,$A5,$12,$A6 ; EB9D F8 A3 EB 12 A4 A5 12 A6  ........
        .byte   $A7                             ; EBA5 A7                       .
; --- bat group (2 frames) ---
spr_bat0:
        .byte   $02,$31,$F8,$FC,$9F,$71,$00,$FC ; EBA6 02 31 F8 FC 9F 71 00 FC  .1...q..
        .byte   $9F                             ; EBAE 9F                       .
spr_bat1:
        .byte   $02,$31,$F8,$FB,$A0,$71,$00,$FB ; EBAF 02 31 F8 FB A0 71 00 FB  .1...q..
        .byte   $A0,$12,$B3,$B4,$32             ; EBB7 A0 12 B3 B4 32           ....2
; --- shared chr blocks (coin, canon, platform) ---
spr_coindata:
        .byte   $B7,$B8,$B9                     ; EBBC B7 B8 B9                 ...
spr_canondata:
        .byte   $BA,$BB,$BC,$31                 ; EBBF BA BB BC 31              ...1
spr_platdata:
        .byte   $AC,$AD,$AE                     ; EBC3 AC AD AE                 ...
; --- deadarrow group (4 distance frames) ---
spr_deadarrow0:
        .byte   $04,$31,$F0,$10,$C7,$71,$10,$10 ; EBC6 04 31 F0 10 C7 71 10 10  .1...q..
        .byte   $C7,$F1,$10,$F0,$C7,$B1,$F0,$F0 ; EBCE C7 F1 10 F0 C7 B1 F0 F0  ........
        .byte   $C7                             ; EBD6 C7                       .
spr_deadarrow1:
        .byte   $04,$31,$F4,$0C,$C7,$71,$0C,$0C ; EBD7 04 31 F4 0C C7 71 0C 0C  .1...q..
        .byte   $C7,$F1,$0C,$F4,$C7,$B1,$F4,$F4 ; EBDF C7 F1 0C F4 C7 B1 F4 F4  ........
        .byte   $C7                             ; EBE7 C7                       .
spr_deadarrow2:
        .byte   $04,$31,$F8,$08,$C7,$71,$08,$08 ; EBE8 04 31 F8 08 C7 71 08 08  .1...q..
        .byte   $C7,$F1,$08,$F8,$C7,$B1,$F8,$F8 ; EBF0 C7 F1 08 F8 C7 B1 F8 F8  ........
        .byte   $C7                             ; EBF8 C7                       .
spr_deadarrow3:
        .byte   $04,$31,$FC,$04,$C7,$71,$04,$04 ; EBF9 04 31 FC 04 C7 71 04 04  .1...q..
        .byte   $C7,$F1,$04,$FC,$C7,$B1,$FC,$FC ; EC01 C7 F1 04 FC C7 B1 FC FC  ........
        .byte   $C7                             ; EC09 C7                       .
; --- eyes group (4 frames) ---
spr_eye0:
        .byte   $02,$31,$FC,$00,$C5,$71,$04,$00 ; EC0A 02 31 FC 00 C5 71 04 00  .1...q..
        .byte   $C5                             ; EC12 C5                       .
spr_eye1:
        .byte   $02,$31,$FD,$00,$C6,$31,$02,$00 ; EC13 02 31 FD 00 C6 31 02 00  .1...1..
        .byte   $C6                             ; EC1B C6                       .
spr_eye2:
        .byte   $02,$F1,$FD,$F8,$C6,$F1,$03,$F8 ; EC1C 02 F1 FD F8 C6 F1 03 F8  ........
        .byte   $C6                             ; EC24 C6                       .
spr_eye3:
        .byte   $02,$F1,$FE,$F8,$C6,$F1,$04,$F8 ; EC25 02 F1 FE F8 C6 F1 04 F8  ........
        .byte   $C6                             ; EC2D C6                       .
; --- guard group (low/high fire + recoil) ---
spr_guardlow:
        .byte   $02,$34,$08,$EE,$EC,$24,$F8,$E0 ; EC2E 02 34 08 EE EC 24 F8 E0  .4...$..
        .byte   $38,$EC,$24                     ; EC36 38 EC 24                 8.$
spr_guardbody:
        .byte   $E4,$E5,$E6,$E7,$E8,$E9,$EA,$EB ; EC39 E4 E5 E6 E7 E8 E9 EA EB  ........
spr_guardhigh:
        .byte   $02,$34,$08,$E8,$F1,$24,$F8,$E0 ; EC41 02 34 08 E8 F1 24 F8 E0  .4...$..
        .byte   $4B,$EC,$24                     ; EC49 4B EC 24                 K.$
spr_guardbody1:
        .byte   $E4,$E5,$ED,$EE,$EF,$F0,$EA,$EB ; EC4C E4 E5 ED EE EF F0 EA EB  ........
spr_guardlow1:
        .byte   $03,$34,$06,$EE,$EC,$3C,$F7,$E0 ; EC54 03 34 06 EE EC 3C F7 E0  .4...<..
        .byte   $E4,$3C,$F8,$F0,$E8             ; EC5C E4 3C F8 F0 E8           .<...
spr_guardhigh1:
        .byte   $03,$34,$06,$E8,$F1,$24,$F7,$E0 ; EC61 03 34 06 E8 F1 24 F7 E0  .4...$..
        .byte   $70,$EC,$24,$F8,$F0,$75,$EC,$22 ; EC69 70 EC 24 F8 F0 75 EC 22  p.$..u."
spr_guardbody2:
        .byte   $E4,$E5,$ED,$EE,$22             ; EC71 E4 E5 ED EE 22           ...."
spr_guardbody3:
        .byte   $EF,$F0,$EA,$EB                 ; EC76 EF F0 EA EB              ....
; --- fire group (5 frames) ---
spr_fire0:
        .byte   $01,$B3,$FC,$08,$95             ; EC7A 01 B3 FC 08 95           .....
spr_fire1:
        .byte   $04,$33,$FB,$F0,$BF,$33,$FE,$F0 ; EC7F 04 33 FB F0 BF 33 FE F0  .3...3..
        .byte   $C0,$33,$FB,$F4,$C1,$33,$FE,$F4 ; EC87 C0 33 FB F4 C1 33 FE F4  .3...3..
        .byte   $C2                             ; EC8F C2                       .
spr_fire2:
        .byte   $04,$33,$F9,$F0,$BF,$33,$FF,$F0 ; EC90 04 33 F9 F0 BF 33 FF F0  .3...3..
        .byte   $C0,$33,$F9,$F6,$C1,$33,$FF,$F6 ; EC98 C0 33 F9 F6 C1 33 FF F6  .3...3..
        .byte   $C2                             ; ECA0 C2                       .
spr_fire3:
        .byte   $03,$3B,$F8,$F0,$BF,$33,$F8,$FC ; ECA1 03 3B F8 F0 BF 33 F8 FC  .;...3..
        .byte   $C3,$33,$00,$FC,$C4             ; ECA9 C3 33 00 FC C4           .3...
spr_fire4:
        .byte   $03,$3B,$F8,$F0,$BF,$33,$F8,$00 ; ECAE 03 3B F8 F0 BF 33 F8 00  .;...3..
        .byte   $C3,$33,$00,$00,$C4             ; ECB6 C3 33 00 00 C4           .3...
; --- marion ---
spr_marion:
        .byte   $04,$23,$00,$00,$CF,$EC,$23,$02 ; ECBB 04 23 00 00 CF EC 23 02  .#....#.
        .byte   $08,$D2,$EC,$3B,$03,$10         ; ECC3 08 D2 EC 3B 03 10        ...;..
spr_marion_chr1:
        .byte   $FA,$23,$02,$20                 ; ECC9 FA 23 02 20              .#. 
spr_marion_chr2:
        .byte   $D5,$EC,$21,$F6                 ; ECCD D5 EC 21 F6              ..!.
spr_marion_chr3:
        .byte   $F7,$21,$F8,$F9,$21,$FE,$FF     ; ECD1 F7 21 F8 F9 21 FE FF     .!..!..
; --- pause sprite ---
spr_pausespr:
        .byte   $05,$32,$00,$00,$7A,$32,$0A,$00 ; ECD8 05 32 00 00 7A 32 0A 00  .2..z2..
        .byte   $7B,$32,$14,$00,$7C,$32,$1E,$00 ; ECE0 7B 32 14 00 7C 32 1E 00  {2..|2..
        .byte   $7D,$32,$28,$00,$7E,$32,$32,$00 ; ECE8 7D 32 28 00 7E 32 32 00  }2(.~22.
        .byte   $7F                             ; ECF0 7F                       .
; ----------------------------------------------------------------------------
; ==========================================================================
; SPRITESR.ROU
; ==========================================================================
printspriterev:
        sec                                     ; ECF1 38                       8
        bcs     printspriteposrev               ; ECF2 B0 01                    ..
printsprite:  clc                                     ; ECF4 18                       .
printspriteposrev:
        stx     temp2                           ; ECF5 86 33                    .3
        ldx     #$00                            ; ECF7 A2 00                    ..
        stx     temp1                           ; ECF9 86 32                    .2
        ror     temp1                           ; ECFB 66 32                    f2
        sty     temp3                           ; ECFD 84 34                    .4
        asl     a                               ; ECFF 0A                       .
        tay                                     ; ED00 A8                       .
        bcs     @n2                           ; ED01 B0 0D                    ..
        lda     spritetable,y                   ; ED03 B9 DB E8                 ...
        sta     address2                        ; ED06 85 1F                    ..
        lda     spritetable+1,y                 ; ED08 B9 DC E8                 ...
        sta     $20                             ; ED0B 85 20                    . 
        jmp     @n3                           ; ED0D 4C 1A ED                 L..

; ----------------------------------------------------------------------------
@n2:  lda     spritetable_100,y                         ; ED10 B9 DB E9                 ...
        sta     address2                        ; ED13 85 1F                    ..
        lda     spritetable_101,y                         ; ED15 B9 DC E9                 ...
        sta     $20                             ; ED18 85 20                    . 
@n3:  ldy     #$00                            ; ED1A A0 00                    ..
        lda     (address2),y                    ; ED1C B1 1F                    ..
        sta     temp5                           ; ED1E 85 36                    .6
        lda     temp3                           ; ED20 A5 34                    .4
        clc                                     ; ED22 18                       .
        adc     #$0C                            ; ED23 69 0C                    i.
        sta     temp3                           ; ED25 85 34                    .4
        iny                                     ; ED27 C8                       .
eachfrminspritelp:
        lda     (address2),y                    ; ED28 B1 1F                    ..
        ldx     temp1                           ; ED2A A6 32                    .2
        bpl     @n4                           ; ED2C 10 02                    ..
        eor     #$40                            ; ED2E 49 40                    I@
@n4:  sta     temp                            ; ED30 85 31                    .1
        bit     playermask                      ; ED32 2C 36 EE                 ,6.
        beq     @n5                           ; ED35 F0 03                    ..
        clc                                     ; ED37 18                       .
        adc     $67                             ; ED38 65 67                    eg
@n5:  and     #$C3                            ; ED3A 29 C3                    ).
        sta     toplevvar9                      ; ED3C 85 19                    ..
        lda     #$08                            ; ED3E A9 08                    ..
        asl     temp                            ; ED40 06 31                    .1
        bcc     notvert                         ; ED42 90 02                    ..
        lda     #$F8                            ; ED44 A9 F8                    ..
notvert:sta     toplevvar8                      ; ED46 85 18                    ..
        lda     #$08                            ; ED48 A9 08                    ..
        asl     temp                            ; ED4A 06 31                    .1
        bcc     nothor                          ; ED4C 90 02                    ..
        lda     #$F8                            ; ED4E A9 F8                    ..
nothor: sta     toplevvar7                      ; ED50 85 17                    ..
        iny                                     ; ED52 C8                       .
        lda     #$00                            ; ED53 A9 00                    ..
        tax                                     ; ED55 AA                       .
        asl     temp                            ; ED56 06 31                    .1
        bcc     nodisplacements                 ; ED58 90 07                    ..
        lda     (address2),y                    ; ED5A B1 1F                    ..
        tax                                     ; ED5C AA                       .
        iny                                     ; ED5D C8                       .
        lda     (address2),y                    ; ED5E B1 1F                    ..
        iny                                     ; ED60 C8                       .
nodisplacements:
        stx     toplevvar5                      ; ED61 86 15                    ..
        sta     toplevvar6                      ; ED63 85 16                    ..
        lda     (address2),y                    ; ED65 B1 1F                    ..
        asl     temp                            ; ED67 06 31                    .1
        bcc     mustbespr                       ; ED69 90 26                    .&
        tax                                     ; ED6B AA                       .
        sta     address3                        ; ED6C 85 21                    .!
        lda     #$01                            ; ED6E A9 01                    ..
        asl     temp                            ; ED70 06 31                    .1
        bcc     nottwobytwo                     ; ED72 90 0A                    ..
        asl     a                               ; ED74 0A                       .
        inx                                     ; ED75 E8                       .
        stx     $22                             ; ED76 86 22                    ."
        inx                                     ; ED78 E8                       .
        stx     address4                        ; ED79 86 23                    .#
        inx                                     ; ED7B E8                       .
        stx     $24                             ; ED7C 86 24                    .$
nottwobytwo:
        sta     toplevvar1                      ; ED7E 85 11                    ..
        sta     toplevvar2                      ; ED80 85 12                    ..
        sty     temp4                           ; ED82 84 35                    .5
        lda     #$21                            ; ED84 A9 21                    .!
        sta     address1                        ; ED86 85 1D                    ..
        lda     #$00                            ; ED88 A9 00                    ..
        sta     $1E                             ; ED8A 85 1E                    ..
        ldy     #$00                            ; ED8C A0 00                    ..
        jmp     mustbejustchr                   ; ED8E 4C AB ED                 L..

; ----------------------------------------------------------------------------
mustbespr:
        sta     address1                        ; ED91 85 1D                    ..
        iny                                     ; ED93 C8                       .
        sty     temp4                           ; ED94 84 35                    .5
        lda     (address2),y                    ; ED96 B1 1F                    ..
        sta     $1E                             ; ED98 85 1E                    ..
PP1_UNPACK:
        ldy     #$00                            ; ED9A A0 00                    ..
        lda     (address1),y                    ; ED9C B1 1D                    ..
        lsr     a                               ; ED9E 4A                       J
        lsr     a                               ; ED9F 4A                       J
        lsr     a                               ; EDA0 4A                       J
        lsr     a                               ; EDA1 4A                       J
        sta     toplevvar1                      ; EDA2 85 11                    ..
        lda     (address1),y                    ; EDA4 B1 1D                    ..
        and     #$0F                            ; EDA6 29 0F                    ).
        sta     toplevvar2                      ; EDA8 85 12                    ..
        iny                                     ; EDAA C8                       .
mustbejustchr:
        lda     toplevvar5                      ; EDAB A5 15                    ..
        bit     temp1                           ; EDAD 24 32                    $2
        bmi     @n6                           ; EDAF 30 0D                    0.
        bit     toplevvar7                      ; EDB1 24 17                    $.
        bpl     @n8                           ; EDB3 10 18                    ..
        ldx     toplevvar1                      ; EDB5 A6 11                    ..
        clc                                     ; EDB7 18                       .
        adc     frmtimes8,x                     ; EDB8 7D 2C EE                 },.
        jmp     @n8                           ; EDBB 4C CD ED                 L..

; ----------------------------------------------------------------------------
@n6:  bit     toplevvar7                      ; EDBE 24 17                    $.
        bmi     @n7                           ; EDC0 30 06                    0.
        ldx     toplevvar1                      ; EDC2 A6 11                    ..
        clc                                     ; EDC4 18                       .
        adc     frmtimes8,x                     ; EDC5 7D 2C EE                 },.
@n7:  eor     #$FF                            ; EDC8 49 FF                    I.
        clc                                     ; EDCA 18                       .
        adc     #$F9                            ; EDCB 69 F9                    i.
@n8:  clc                                     ; EDCD 18                       .
        adc     temp2                           ; EDCE 65 33                    e3
        sta     toplevvar5                      ; EDD0 85 15                    ..
        lda     toplevvar8                      ; EDD2 A5 18                    ..
        bpl     notflippedover                  ; EDD4 10 05                    ..
        sec                                     ; EDD6 38                       8
        sbc     toplevvar6                      ; EDD7 E5 16                    ..
        sta     toplevvar6                      ; EDD9 85 16                    ..
notflippedover:
        lda     temp3                           ; EDDB A5 34                    .4
        clc                                     ; EDDD 18                       .
        adc     toplevvar6                      ; EDDE 65 16                    e.
        sta     toplevvar6                      ; EDE0 85 16                    ..
        ldx     spriteblockpointer              ; EDE2 A6 0E                    ..
        beq     nomorespritechrsleft            ; EDE4 F0 39                    .9
yspritelp:
        lda     toplevvar1                      ; EDE6 A5 11                    ..
        sta     toplevvar3                      ; EDE8 85 13                    ..
        lda     toplevvar5                      ; EDEA A5 15                    ..
        sta     $68                             ; EDEC 85 68                    .h
xspritelp:
        lda     toplevvar6                      ; EDEE A5 16                    ..
        sta     spriteblock,x                   ; EDF0 9D 00 02                 ...
        lda     (address1),y                    ; EDF3 B1 1D                    ..
        iny                                     ; EDF5 C8                       .
        inx                                     ; EDF6 E8                       .
        sta     spriteblock,x                   ; EDF7 9D 00 02                 ...
        lda     toplevvar9                      ; EDFA A5 19                    ..
        ora     $66                             ; EDFC 05 66                    .f
        inx                                     ; EDFE E8                       .
        sta     spriteblock,x                   ; EDFF 9D 00 02                 ...
        inx                                     ; EE02 E8                       .
        lda     $68                             ; EE03 A5 68                    .h
        sta     spriteblock,x                   ; EE05 9D 00 02                 ...
        inx                                     ; EE08 E8                       .
        beq     nomorespritechrsleft            ; EE09 F0 14                    ..
        clc                                     ; EE0B 18                       .
        adc     toplevvar7                      ; EE0C 65 17                    e.
        sta     $68                             ; EE0E 85 68                    .h
        dec     toplevvar3                      ; EE10 C6 13                    ..
        bne     xspritelp                       ; EE12 D0 DA                    ..
        lda     toplevvar6                      ; EE14 A5 16                    ..
        clc                                     ; EE16 18                       .
        adc     toplevvar8                      ; EE17 65 18                    e.
        sta     toplevvar6                      ; EE19 85 16                    ..
        dec     toplevvar2                      ; EE1B C6 12                    ..
        bne     yspritelp                       ; EE1D D0 C7                    ..
nomorespritechrsleft:
        stx     spriteblockpointer              ; EE1F 86 0E                    ..
        dec     temp5                           ; EE21 C6 36                    .6
        beq     @n1                           ; EE23 F0 06                    ..
        ldy     temp4                           ; EE25 A4 35                    .5
        iny                                     ; EE27 C8                       .
        jmp     eachfrminspritelp               ; EE28 4C 28 ED                 L(.

; ----------------------------------------------------------------------------
@n1:  rts                                     ; EE2B 60                       `

; ----------------------------------------------------------------------------
frmtimes8:
        .byte   $00,$00,$08,$10,$18,$20,$28,$30 ; EE2C 00 00 08 10 18 20 28 30  ..... (0
        .byte   $38,$40                         ; EE34 38 40                    8@
; ----------------------------------------------------------------------------
playermask:
        .byte   $04                             ; EE36 04                       .
        sec                                     ; EE37 38                       8
        bcs     winprintspriteposrev            ; EE38 B0 01                    ..
winprintsprite:
        clc                                     ; EE3A 18                       .
winprintspriteposrev:
        stx     temp2                           ; EE3B 86 33                    .3
        ldx     #$00                            ; EE3D A2 00                    ..
        sta     temp1                           ; EE3F 85 32                    .2
        ror     temp1                           ; EE41 66 32                    f2
        ldx     temp7                           ; EE43 A6 38                    .8
        inx                                     ; EE45 E8                       .
        cpx     #$03                            ; EE46 E0 03                    ..
        bcc     @n3                           ; EE48 90 01                    ..
@n2:  rts                                     ; EE4A 60                       `

; ----------------------------------------------------------------------------
@n3:  cpx     #$01                            ; EE4B E0 01                    ..
        beq     @n5                           ; EE4D F0 0F                    ..
        bcc     @n4                           ; EE4F 90 07                    ..
        ldx     temp2                           ; EE51 A6 33                    .3
        cpx     #$E8                            ; EE53 E0 E8                    ..
        bcc     @n5                           ; EE55 90 07                    ..
        rts                                     ; EE57 60                       `

; ----------------------------------------------------------------------------
@n4:  ldx     temp2                           ; EE58 A6 33                    .3
        cpx     #$18                            ; EE5A E0 18                    ..
        bcs     @n2                           ; EE5C B0 EC                    ..
@n5:  sty     temp3                           ; EE5E 84 34                    .4
        asl     a                               ; EE60 0A                       .
        tay                                     ; EE61 A8                       .
        bcs     @n6                           ; EE62 B0 0D                    ..
        lda     spritetable,y                   ; EE64 B9 DB E8                 ...
        sta     address2                        ; EE67 85 1F                    ..
        lda     spritetable+1,y                 ; EE69 B9 DC E8                 ...
        sta     $20                             ; EE6C 85 20                    . 
        jmp     @n7                           ; EE6E 4C 7B EE                 L{.

; ----------------------------------------------------------------------------
@n6:  lda     spritetable_100,y                         ; EE71 B9 DB E9                 ...
        sta     address2                        ; EE74 85 1F                    ..
        lda     spritetable_101,y                         ; EE76 B9 DC E9                 ...
        sta     $20                             ; EE79 85 20                    . 
@n7:  ldy     #$00                            ; EE7B A0 00                    ..
        lda     (address2),y                    ; EE7D B1 1F                    ..
        sta     temp5                           ; EE7F 85 36                    .6
        lda     temp3                           ; EE81 A5 34                    .4
        clc                                     ; EE83 18                       .
        adc     #$0C                            ; EE84 69 0C                    i.
        sta     temp3                           ; EE86 85 34                    .4
        iny                                     ; EE88 C8                       .
wineachfrminspritelp:
        lda     temp7                           ; EE89 A5 38                    .8
        sta     temp6                           ; EE8B 85 37                    .7
        lda     (address2),y                    ; EE8D B1 1F                    ..
        bit     temp1                           ; EE8F 24 32                    $2
        bpl     @n8                           ; EE91 10 02                    ..
        eor     #$40                            ; EE93 49 40                    I@
@n8:  sta     temp                            ; EE95 85 31                    .1
        bit     playermask                      ; EE97 2C 36 EE                 ,6.
        beq     @n9                           ; EE9A F0 03                    ..
        clc                                     ; EE9C 18                       .
        adc     $67                             ; EE9D 65 67                    eg
@n9:  and     #$C3                            ; EE9F 29 C3                    ).
        sta     toplevvar9                      ; EEA1 85 19                    ..
        lda     #$08                            ; EEA3 A9 08                    ..
        asl     temp                            ; EEA5 06 31                    .1
        bcc     winnotvert                      ; EEA7 90 02                    ..
        lda     #$F8                            ; EEA9 A9 F8                    ..
winnotvert:
        sta     toplevvar8                      ; EEAB 85 18                    ..
        lda     #$08                            ; EEAD A9 08                    ..
        asl     temp                            ; EEAF 06 31                    .1
        bcc     winnothor                       ; EEB1 90 02                    ..
        lda     #$F8                            ; EEB3 A9 F8                    ..
winnothor:
        sta     toplevvar7                      ; EEB5 85 17                    ..
        iny                                     ; EEB7 C8                       .
        lda     #$00                            ; EEB8 A9 00                    ..
        tax                                     ; EEBA AA                       .
        asl     temp                            ; EEBB 06 31                    .1
        bcc     winnodisplacements              ; EEBD 90 07                    ..
        lda     (address2),y                    ; EEBF B1 1F                    ..
        tax                                     ; EEC1 AA                       .
        iny                                     ; EEC2 C8                       .
        lda     (address2),y                    ; EEC3 B1 1F                    ..
        iny                                     ; EEC5 C8                       .
winnodisplacements:
        stx     toplevvar5                      ; EEC6 86 15                    ..
        sta     toplevvar6                      ; EEC8 85 16                    ..
        lda     (address2),y                    ; EECA B1 1F                    ..
        asl     temp                            ; EECC 06 31                    .1
        bcc     winmustbespr                    ; EECE 90 26                    .&
        tax                                     ; EED0 AA                       .
        sta     address3                        ; EED1 85 21                    .!
        lda     #$01                            ; EED3 A9 01                    ..
        asl     temp                            ; EED5 06 31                    .1
        bcc     winnottwobytwo                  ; EED7 90 0A                    ..
        asl     a                               ; EED9 0A                       .
        inx                                     ; EEDA E8                       .
        stx     $22                             ; EEDB 86 22                    ."
        inx                                     ; EEDD E8                       .
        stx     address4                        ; EEDE 86 23                    .#
        inx                                     ; EEE0 E8                       .
        stx     $24                             ; EEE1 86 24                    .$
winnottwobytwo:
        sta     toplevvar1                      ; EEE3 85 11                    ..
        sta     toplevvar2                      ; EEE5 85 12                    ..
        sty     temp4                           ; EEE7 84 35                    .5
        lda     #$21                            ; EEE9 A9 21                    .!
        sta     address1                        ; EEEB 85 1D                    ..
        lda     #$00                            ; EEED A9 00                    ..
        sta     $1E                             ; EEEF 85 1E                    ..
        ldy     #$00                            ; EEF1 A0 00                    ..
        jmp     winmustbejustchr                ; EEF3 4C 10 EF                 L..

; ----------------------------------------------------------------------------
winmustbespr:
        sta     address1                        ; EEF6 85 1D                    ..
        iny                                     ; EEF8 C8                       .
        sty     temp4                           ; EEF9 84 35                    .5
        lda     (address2),y                    ; EEFB B1 1F                    ..
        sta     $1E                             ; EEFD 85 1E                    ..
        ldy     #$00                            ; EEFF A0 00                    ..
        lda     (address1),y                    ; EF01 B1 1D                    ..
        lsr     a                               ; EF03 4A                       J
        lsr     a                               ; EF04 4A                       J
        lsr     a                               ; EF05 4A                       J
        lsr     a                               ; EF06 4A                       J
        sta     toplevvar1                      ; EF07 85 11                    ..
        lda     (address1),y                    ; EF09 B1 1D                    ..
        and     #$0F                            ; EF0B 29 0F                    ).
        sta     toplevvar2                      ; EF0D 85 12                    ..
        iny                                     ; EF0F C8                       .
winmustbejustchr:
        bit     temp1                           ; EF10 24 32                    $2
        bmi     @n3                           ; EF12 30 17                    0.
        lda     toplevvar5                      ; EF14 A5 15                    ..
        bmi     @n1                           ; EF16 30 02                    0.
        inc     temp6                           ; EF18 E6 37                    .7
@n1:  bit     toplevvar7                      ; EF1A 24 17                    $.
        bpl     @n2                           ; EF1C 10 08                    ..
        ldx     toplevvar1                      ; EF1E A6 11                    ..
        clc                                     ; EF20 18                       .
        adc     frmtimes8,x                     ; EF21 7D 2C EE                 },.
        bcs     @n6                           ; EF24 B0 22                    ."
@n2:  dec     temp6                           ; EF26 C6 37                    .7
        jmp     @n6                           ; EF28 4C 48 EF                 LH.

; ----------------------------------------------------------------------------
@n3:  lda     toplevvar5                      ; EF2B A5 15                    ..
        bmi     @n4                           ; EF2D 30 02                    0.
        dec     temp6                           ; EF2F C6 37                    .7
@n4:  bit     toplevvar7                      ; EF31 24 17                    $.
        bmi     @n5                           ; EF33 30 0A                    0.
        ldx     toplevvar1                      ; EF35 A6 11                    ..
        clc                                     ; EF37 18                       .
        adc     frmtimes8,x                     ; EF38 7D 2C EE                 },.
        bcc     @n5                           ; EF3B 90 02                    ..
        dec     temp6                           ; EF3D C6 37                    .7
@n5:  eor     #$FF                            ; EF3F 49 FF                    I.
        clc                                     ; EF41 18                       .
        adc     #$F9                            ; EF42 69 F9                    i.
        bcs     @n6                           ; EF44 B0 02                    ..
        dec     temp6                           ; EF46 C6 37                    .7
@n6:  clc                                     ; EF48 18                       .
        adc     temp2                           ; EF49 65 33                    e3
        sta     toplevvar5                      ; EF4B 85 15                    ..
        bcc     aroundaddx                      ; EF4D 90 02                    ..
        inc     temp6                           ; EF4F E6 37                    .7
aroundaddx:
        lda     toplevvar8                      ; EF51 A5 18                    ..
        bpl     winnotflippedover               ; EF53 10 05                    ..
        sec                                     ; EF55 38                       8
        sbc     toplevvar6                      ; EF56 E5 16                    ..
        sta     toplevvar6                      ; EF58 85 16                    ..
winnotflippedover:
        lda     temp3                           ; EF5A A5 34                    .4
        clc                                     ; EF5C 18                       .
        adc     toplevvar6                      ; EF5D 65 16                    e.
        sta     toplevvar6                      ; EF5F 85 16                    ..
        ldx     spriteblockpointer              ; EF61 A6 0E                    ..
        beq     winnomorespritechrsleft         ; EF63 F0 5B                    .[
winyspritelp:
        lda     toplevvar1                      ; EF65 A5 11                    ..
        sta     toplevvar3                      ; EF67 85 13                    ..
        lda     toplevvar5                      ; EF69 A5 15                    ..
        sta     $68                             ; EF6B 85 68                    .h
        lda     temp6                           ; EF6D A5 37                    .7
        sta     temp8                           ; EF6F 85 39                    .9
winxspritelp:
        lda     temp8                           ; EF71 A5 39                    .9
        bne     winthischrnotonscreen           ; EF73 D0 20                    . 
        lda     toplevvar6                      ; EF75 A5 16                    ..
        cmp     #$F0                            ; EF77 C9 F0                    ..
        bcs     winthischrnotonscreen           ; EF79 B0 1A                    ..
        sta     spriteblock,x                   ; EF7B 9D 00 02                 ...
        lda     (address1),y                    ; EF7E B1 1D                    ..
        inx                                     ; EF80 E8                       .
        sta     spriteblock,x                   ; EF81 9D 00 02                 ...
        lda     toplevvar9                      ; EF84 A5 19                    ..
        ora     $66                             ; EF86 05 66                    .f
        inx                                     ; EF88 E8                       .
        sta     spriteblock,x                   ; EF89 9D 00 02                 ...
        inx                                     ; EF8C E8                       .
        lda     $68                             ; EF8D A5 68                    .h
        sta     spriteblock,x                   ; EF8F 9D 00 02                 ...
        inx                                     ; EF92 E8                       .
        beq     winnomorespritechrsleft         ; EF93 F0 2B                    .+
winthischrnotonscreen:
        iny                                     ; EF95 C8                       .
        lda     toplevvar7                      ; EF96 A5 17                    ..
        bmi     @n7                           ; EF98 30 0E                    0.
        lda     $68                             ; EF9A A5 68                    .h
        clc                                     ; EF9C 18                       .
        adc     toplevvar7                      ; EF9D 65 17                    e.
        sta     $68                             ; EF9F 85 68                    .h
        bcc     @n8                           ; EFA1 90 0E                    ..
        inc     temp8                           ; EFA3 E6 39                    .9
        jmp     @n8                           ; EFA5 4C B1 EF                 L..

; ----------------------------------------------------------------------------
@n7:  clc                                     ; EFA8 18                       .
        adc     $68                             ; EFA9 65 68                    eh
        sta     $68                             ; EFAB 85 68                    .h
        bcs     @n8                           ; EFAD B0 02                    ..
        dec     temp8                           ; EFAF C6 39                    .9
@n8:  dec     toplevvar3                      ; EFB1 C6 13                    ..
        bne     winxspritelp                    ; EFB3 D0 BC                    ..
        lda     toplevvar6                      ; EFB5 A5 16                    ..
        clc                                     ; EFB7 18                       .
        adc     toplevvar8                      ; EFB8 65 18                    e.
        sta     toplevvar6                      ; EFBA 85 16                    ..
        dec     toplevvar2                      ; EFBC C6 12                    ..
        bne     winyspritelp                    ; EFBE D0 A5                    ..
winnomorespritechrsleft:
        stx     spriteblockpointer              ; EFC0 86 0E                    ..
        dec     temp5                           ; EFC2 C6 36                    .6
        beq     @n9                           ; EFC4 F0 06                    ..
        ldy     temp4                           ; EFC6 A4 35                    .5
        iny                                     ; EFC8 C8                       .
        jmp     wineachfrminspritelp            ; EFC9 4C 89 EE                 L..

; ----------------------------------------------------------------------------
@n9:  rts                                     ; EFCC 60                       `

; x=x y=y A=chr temp=attribute
; ----------------------------------------------------------------------------
pokesprite:
        stx     toplevvar1                      ; EFCD 86 11                    ..
        ldx     spriteblockpointer              ; EFCF A6 0E                    ..
        beq     nomorespriteplaces              ; EFD1 F0 17                    ..
        sta     $0201,x                         ; EFD3 9D 01 02                 ...
        lda     toplevvar1                      ; EFD6 A5 11                    ..
        sta     $0203,x                         ; EFD8 9D 03 02                 ...
        tya                                     ; EFDB 98                       .
        sta     spriteblock,x                   ; EFDC 9D 00 02                 ...
        lda     temp                            ; EFDF A5 31                    .1
        sta     $0202,x                         ; EFE1 9D 02 02                 ...
        txa                                     ; EFE4 8A                       .
        clc                                     ; EFE5 18                       .
        adc     #$04                            ; EFE6 69 04                    i.
        sta     spriteblockpointer              ; EFE8 85 0E                    ..
nomorespriteplaces:
        rts                                     ; EFEA 60                       `

; x=x y=y A=chr to start at temp=attribute, this indicates flips
; 128=vert 64=hor
; ----------------------------------------------------------------------------
pokesprite2by2:
        stx     toplevvar1                      ; EFEB 86 11                    ..
        ldx     spriteblockpointer              ; EFED A6 0E                    ..
        bne     @n11                           ; EFEF D0 01                    ..
@n10:  rts                                     ; EFF1 60                       `

; ----------------------------------------------------------------------------
@n11:  cpx     #$F0                            ; EFF2 E0 F0                    ..
        bcs     @n10                           ; EFF4 B0 FB                    ..
        sta     $0201,x                         ; EFF6 9D 01 02                 ...
        adc     #$01                            ; EFF9 69 01                    i.
        sta     $0205,x                         ; EFFB 9D 05 02                 ...
        adc     #$01                            ; EFFE 69 01                    i.
        sta     $0209,x                         ; F000 9D 09 02                 ...
        adc     #$01                            ; F003 69 01                    i.
        sta     $020D,x                         ; F005 9D 0D 02                 ...
        lda     temp                            ; F008 A5 31                    .1
        sta     $0202,x                         ; F00A 9D 02 02                 ...
        sta     $0206,x                         ; F00D 9D 06 02                 ...
        sta     $020A,x                         ; F010 9D 0A 02                 ...
        sta     $020E,x                         ; F013 9D 0E 02                 ...
        and     #$80                            ; F016 29 80                    ).
        bne     flippedvert                     ; F018 D0 16                    ..
        tya                                     ; F01A 98                       .
        clc                                     ; F01B 18                       .
        adc     #$0C                            ; F01C 69 0C                    i.
        sta     $0208,x                         ; F01E 9D 08 02                 ...
        sta     $020C,x                         ; F021 9D 0C 02                 ...
        clc                                     ; F024 18                       .
        adc     #$F8                            ; F025 69 F8                    i.
        sta     spriteblock,x                   ; F027 9D 00 02                 ...
        sta     $0204,x                         ; F02A 9D 04 02                 ...
        jmp     nowhor                          ; F02D 4C 43 F0                 LC.

; ----------------------------------------------------------------------------
flippedvert:
        tya                                     ; F030 98                       .
        clc                                     ; F031 18                       .
        adc     #$0C                            ; F032 69 0C                    i.
        sta     spriteblock,x                   ; F034 9D 00 02                 ...
        sta     $0204,x                         ; F037 9D 04 02                 ...
        clc                                     ; F03A 18                       .
        adc     #$F8                            ; F03B 69 F8                    i.
        sta     $0208,x                         ; F03D 9D 08 02                 ...
        sta     $020C,x                         ; F040 9D 0C 02                 ...
nowhor: lda     toplevvar1                      ; F043 A5 11                    ..
        bit     temp                            ; F045 24 31                    $1
        bvs     flippedhor                      ; F047 70 1C                    p.
        sta     $0207,x                         ; F049 9D 07 02                 ...
        sta     $020F,x                         ; F04C 9D 0F 02                 ...
        clc                                     ; F04F 18                       .
        adc     #$F8                            ; F050 69 F8                    i.
        bcs     @n1                           ; F052 B0 08                    ..
        lda     #$F5                            ; F054 A9 F5                    ..
        sta     spriteblock,x                   ; F056 9D 00 02                 ...
        sta     $0208,x                         ; F059 9D 08 02                 ...
@n1:  sta     $0203,x                         ; F05C 9D 03 02                 ...
        sta     $020B,x                         ; F05F 9D 0B 02                 ...
        jmp     done2by2                        ; F062 4C 7E F0                 L~.

; ----------------------------------------------------------------------------
flippedhor:
        sta     $0203,x                         ; F065 9D 03 02                 ...
        sta     $020B,x                         ; F068 9D 0B 02                 ...
        clc                                     ; F06B 18                       .
        adc     #$F8                            ; F06C 69 F8                    i.
        bcs     @n2                           ; F06E B0 08                    ..
        lda     #$F5                            ; F070 A9 F5                    ..
        sta     $0204,x                         ; F072 9D 04 02                 ...
        sta     $020C,x                         ; F075 9D 0C 02                 ...
@n2:  sta     $0207,x                         ; F078 9D 07 02                 ...
        sta     $020F,x                         ; F07B 9D 0F 02                 ...
done2by2:
        txa                                     ; F07E 8A                       .
        clc                                     ; F07F 18                       .
        adc     #$10                            ; F080 69 10                    i.
        sta     spriteblockpointer              ; F082 85 0E                    ..
        rts                                     ; F084 60                       `

; ----------------------------------------------------------------------------
; ==========================================================================
; PRTMESS.ROU
; ==========================================================================
prtmessagefly:
        asl     flyflag                         ; F085 06 0B                    ..
@fly:  bit     flyflag                         ; F087 24 0B                    $.
        bpl     @fly                           ; F089 10 FC                    ..
prtmessage:
        stx     toplevvar1                      ; F08B 86 11                    ..
        sty     toplevvar2                      ; F08D 84 12                    ..
printwhatataddress:
        ldy     #$00                            ; F08F A0 00                    ..
printwhatataddress1:
        lda     (toplevvar1),y                  ; F091 B1 11                    ..
        iny                                     ; F093 C8                       .
        cmp     #$80                            ; F094 C9 80                    ..
        bcs     notchr                          ; F096 B0 05                    ..
        sta     _vramdata                       ; F098 8D 07 20                 .. 
        bcc     printwhatataddress1             ; F09B 90 F4                    ..
notchr: cmp     #$F0                            ; F09D C9 F0                    ..
        bcc     mustbeaddress                   ; F09F 90 23                    .#
        cmp     #$FF                            ; F0A1 C9 FF                    ..
        bne     @n3                           ; F0A3 D0 01                    ..
        rts                                     ; F0A5 60                       `

; ----------------------------------------------------------------------------
@n3:  cmp     #$FC                            ; F0A6 C9 FC                    ..
        beq     setstringlen                    ; F0A8 F0 2B                    .+
        cmp     #$FE                            ; F0AA C9 FE                    ..
        beq     gosub                           ; F0AC F0 4E                    .N
        cmp     #$FB                            ; F0AE C9 FB                    ..
        beq     startloop                       ; F0B0 F0 32                    .2
        cmp     #$FA                            ; F0B2 C9 FA                    ..
        beq     endloop                         ; F0B4 F0 37                    .7
        cmp     #$F9                            ; F0B6 C9 F9                    ..
        beq     downlinerou                     ; F0B8 F0 63                    .c
        cmp     #$F7                            ; F0BA C9 F7                    ..
        beq     attrdownrou                     ; F0BC F0 76                    .v
        jmp     jumpnewmessagejump              ; F0BE 4C 38 F1                 L8.

; ----------------------------------------------------------------------------
printwhatataddress2:
        iny                                     ; F0C1 C8                       .
        ; this will always jump
        bne     printwhatataddress1             ; F0C2 D0 CD                    ..
mustbeaddress:
        and     #$7F                            ; F0C4 29 7F                    ).
        sta     toplevvar4                      ; F0C6 85 14                    ..
        sta     _vramaddr                       ; F0C8 8D 06 20                 .. 
        lda     (toplevvar1),y                  ; F0CB B1 11                    ..
        sta     toplevvar3                      ; F0CD 85 13                    ..
        sta     _vramaddr                       ; F0CF 8D 06 20                 .. 
        jmp     printwhatataddress2             ; F0D2 4C C1 F0                 L..

; ----------------------------------------------------------------------------
setstringlen:
        lda     (toplevvar1),y                  ; F0D5 B1 11                    ..
        iny                                     ; F0D7 C8                       .
        tax                                     ; F0D8 AA                       .
stringlen1:
        lda     (toplevvar1),y                  ; F0D9 B1 11                    ..
        iny                                     ; F0DB C8                       .
        sta     _vramdata                       ; F0DC 8D 07 20                 .. 
        dex                                     ; F0DF CA                       .
        bne     stringlen1                      ; F0E0 D0 F7                    ..
        ; must always jmp
        beq     printwhatataddress1             ; F0E2 F0 AD                    ..
startloop:
        lda     (toplevvar1),y                  ; F0E4 B1 11                    ..
        iny                                     ; F0E6 C8                       .
repeatingloop:
        pha                                     ; F0E7 48                       H
        tya                                     ; F0E8 98                       .
        pha                                     ; F0E9 48                       H
        jmp     printwhatataddress1             ; F0EA 4C 91 F0                 L..

; ----------------------------------------------------------------------------
endloop:sty     toplevvar5                      ; F0ED 84 15                    ..
        pla                                     ; F0EF 68                       h
        tay                                     ; F0F0 A8                       .
        pla                                     ; F0F1 68                       h
        sec                                     ; F0F2 38                       8
        sbc     #$01                            ; F0F3 E9 01                    ..
        bne     repeatingloop                   ; F0F5 D0 F0                    ..
        ldy     toplevvar5                      ; F0F7 A4 15                    ..
        jmp     printwhatataddress1             ; F0F9 4C 91 F0                 L..

; ----------------------------------------------------------------------------
gosub:  lda     toplevvar1                      ; F0FC A5 11                    ..
        pha                                     ; F0FE 48                       H
        lda     toplevvar2                      ; F0FF A5 12                    ..
        pha                                     ; F101 48                       H
        lda     (toplevvar1),y                  ; F102 B1 11                    ..
        tax                                     ; F104 AA                       .
        iny                                     ; F105 C8                       .
        lda     (toplevvar1),y                  ; F106 B1 11                    ..
        iny                                     ; F108 C8                       .
        sta     toplevvar2                      ; F109 85 12                    ..
        stx     toplevvar1                      ; F10B 86 11                    ..
        tya                                     ; F10D 98                       .
        pha                                     ; F10E 48                       H
        jsr     printwhatataddress              ; F10F 20 8F F0                  ..
        pla                                     ; F112 68                       h
        tay                                     ; F113 A8                       .
        pla                                     ; F114 68                       h
        sta     toplevvar2                      ; F115 85 12                    ..
        pla                                     ; F117 68                       h
        sta     toplevvar1                      ; F118 85 11                    ..
        jmp     printwhatataddress1             ; F11A 4C 91 F0                 L..

; ----------------------------------------------------------------------------
downlinerou:
        lda     #$20                            ; F11D A9 20                    . 
joindownline:
        clc                                     ; F11F 18                       .
        adc     toplevvar3                      ; F120 65 13                    e.
        sta     toplevvar3                      ; F122 85 13                    ..
        tax                                     ; F124 AA                       .
        bcc     @n1                           ; F125 90 02                    ..
        inc     toplevvar4                      ; F127 E6 14                    ..
@n1:  lda     toplevvar4                      ; F129 A5 14                    ..
        sta     _vramaddr                       ; F12B 8D 06 20                 .. 
        stx     _vramaddr                       ; F12E 8E 06 20                 .. 
        jmp     printwhatataddress1             ; F131 4C 91 F0                 L..

; ----------------------------------------------------------------------------
attrdownrou:
        lda     #$08                            ; F134 A9 08                    ..
        bne     joindownline                    ; F136 D0 E7                    ..
jumpnewmessagejump:
        lda     (toplevvar1),y                  ; F138 B1 11                    ..
        tax                                     ; F13A AA                       .
        iny                                     ; F13B C8                       .
        lda     (toplevvar1),y                  ; F13C B1 11                    ..
        sta     toplevvar2                      ; F13E 85 12                    ..
        stx     toplevvar1                      ; F140 86 11                    ..
        jmp     printwhatataddress              ; F142 4C 8F F0                 L..

; format addr,addr,len,string
; ----------------------------------------------------------------------------
addtoprintbuffer:
        stx     toplevvar1                      ; F145 86 11                    ..
        sty     toplevvar2                      ; F147 84 12                    ..
        ldy     #$00                            ; F149 A0 00                    ..
        ldx     vrampointer                     ; F14B A6 0C                    ..
        lda     (toplevvar1),y                  ; F14D B1 11                    ..
        sta     vrambuffer,x                    ; F14F 9D 00 01                 ...
        iny                                     ; F152 C8                       .
        inx                                     ; F153 E8                       .
        lda     (toplevvar1),y                  ; F154 B1 11                    ..
        sta     vrambuffer,x                    ; F156 9D 00 01                 ...
        iny                                     ; F159 C8                       .
        inx                                     ; F15A E8                       .
        lda     (toplevvar1),y                  ; F15B B1 11                    ..
        sta     vrambuffer,x                    ; F15D 9D 00 01                 ...
        inx                                     ; F160 E8                       .
        sta     toplevvar5                      ; F161 85 15                    ..
        iny                                     ; F163 C8                       .
addtoprintbufferlp:
        lda     (toplevvar1),y                  ; F164 B1 11                    ..
        sta     vrambuffer,x                    ; F166 9D 00 01                 ...
        iny                                     ; F169 C8                       .
        inx                                     ; F16A E8                       .
        dec     toplevvar5                      ; F16B C6 15                    ..
        bne     addtoprintbufferlp              ; F16D D0 F5                    ..
        stx     vrampointer                     ; F16F 86 0C                    ..
        rts                                     ; F171 60                       `

; ----------------------------------------------------------------------------
        jsr     addtoprintbuffer                ; F172 20 45 F1                  E.
        asl     flyflag                         ; F175 06 0B                    ..
@fly:  bit     flyflag                         ; F177 24 0B                    $.
        bpl     @fly                           ; F179 10 FC                    ..
; emptys print buffer that was filled by addtoprintbuffer
; this should be automatically called on the interupt
; however it can just be called if the screen is off
emptyprintbuffer:
        lda     vrampointer                     ; F17B A5 0C                    ..
        beq     retmessage                      ; F17D F0 28                    .(
        ldy     #$00                            ; F17F A0 00                    ..
veryfastprintout:
        lda     vrambuffer,y                    ; F181 B9 00 01                 ...
        and     #$7F                            ; F184 29 7F                    ).
        sta     _vramaddr                       ; F186 8D 06 20                 .. 
        iny                                     ; F189 C8                       .
        lda     vrambuffer,y                    ; F18A B9 00 01                 ...
        sta     _vramaddr                       ; F18D 8D 06 20                 .. 
        iny                                     ; F190 C8                       .
        ldx     vrambuffer,y                    ; F191 BE 00 01                 ...
        iny                                     ; F194 C8                       .
stringlen:
        lda     vrambuffer,y                    ; F195 B9 00 01                 ...
        sta     _vramdata                       ; F198 8D 07 20                 .. 
        iny                                     ; F19B C8                       .
        dex                                     ; F19C CA                       .
        bne     stringlen                       ; F19D D0 F6                    ..
        cpy     vrampointer                     ; F19F C4 0C                    ..
        bne     veryfastprintout                ; F1A1 D0 DE                    ..
        lda     #$00                            ; F1A3 A9 00                    ..
        sta     vrampointer                     ; F1A5 85 0C                    ..
retmessage:
        rts                                     ; F1A7 60                       `

; >chrdata,<chrdata,start,len,bank+128 if char
; ----------------------------------------------------------------------------
; ==========================================================================
; UNPACK.ROU
; ==========================================================================
compactedchrstable:
        .byte   $2C                             ; F1A8 2C                       ,
LF1A9:  .byte   $84                             ; F1A9 84                       .
LF1AA:  .byte   $00                             ; F1AA 00                       .
LF1AB:  .byte   $0E,$E9,$90,$00,$8E,$7A,$99,$00 ; F1AB 0E E9 90 00 8E 7A 99 00  .....z..
        .byte   $0E,$6F,$8B,$00,$8E,$6F,$8B,$00 ; F1B3 0E 6F 8B 00 8E 6F 8B 00  .o...o..
        .byte   $0E,$50,$AC,$00,$8E,$52,$B1,$9D ; F1BB 0E 50 AC 00 8E 52 B1 9D  .P...R..
        .byte   $8E,$27,$B2,$F7,$8E,$55,$B2,$9D ; F1C3 8E 27 B2 F7 8E 55 B2 9D  .'...U..
        .byte   $8E,$EE,$B5,$9D,$8E,$68,$BA,$B4 ; F1CB 8E EE B5 9D 8E 68 BA B4  .....h..
        .byte   $8E,$8D,$BC,$B4,$8E,$13,$A2,$00 ; F1D3 8E 8D BC B4 8E 13 A2 00  ........
        .byte   $0E,$C7,$BE,$00,$0E             ; F1DB 0E C7 BE 00 0E           .....
; ----------------------------------------------------------------------------
copyblockofcompactedchrs:
        asl     a                               ; F1E0 0A                       .
        asl     a                               ; F1E1 0A                       .
        tay                                     ; F1E2 A8                       .
        lda     bankno                          ; F1E3 A5 0D                    ..
        pha                                     ; F1E5 48                       H
        lda     LF1AB,y                         ; F1E6 B9 AB F1                 ...
        and     #$0F                            ; F1E9 29 0F                    ).
        jsr     changebankrou                   ; F1EB 20 42 F4                  B.
        lda     LF1AA,y                         ; F1EE B9 AA F1                 ...
        sta     temp                            ; F1F1 85 31                    .1
        lda     LF1AB,y                         ; F1F3 B9 AB F1                 ...
        asl     a                               ; F1F6 0A                       .
        lda     #$00                            ; F1F7 A9 00                    ..
        adc     #$00                            ; F1F9 69 00                    i.
        asl     temp                            ; F1FB 06 31                    .1
        rol     a                               ; F1FD 2A                       *
        asl     temp                            ; F1FE 06 31                    .1
        rol     a                               ; F200 2A                       *
        asl     temp                            ; F201 06 31                    .1
        rol     a                               ; F203 2A                       *
        asl     temp                            ; F204 06 31                    .1
        rol     a                               ; F206 2A                       *
        sta     _vramaddr                       ; F207 8D 06 20                 .. 
        lda     temp                            ; F20A A5 31                    .1
        sta     _vramaddr                       ; F20C 8D 06 20                 .. 
        lda     compactedchrstable,y            ; F20F B9 A8 F1                 ...
        sta     a:address1                      ; F212 8D 1D 00                 ...
        lda     LF1A9,y                         ; F215 B9 A9 F1                 ...
        sta     a:$1E                           ; F218 8D 1E 00                 ...
        jsr     pp1_unpack                      ; F21B 20 3B F2                  ;.
        pla                                     ; F21E 68                       h
        jmp     changebankrou                   ; F21F 4C 42 F4                 LB.

; ----------------------------------------------------------------------------
pp1_download3:
        stx     address1                        ; F222 86 1D                    ..
        sty     $1E                             ; F224 84 1E                    ..
        txa                                     ; F226 8A                       .
        lda     bankno                          ; F227 A5 0D                    ..
        pha                                     ; F229 48                       H
        txa                                     ; F22A 8A                       .
        jsr     changebankrou                   ; F22B 20 42 F4                  B.
        jsr     pp1_unpack                      ; F22E 20 3B F2                  ;.
        pla                                     ; F231 68                       h
        jmp     changebankrou                   ; F232 4C 42 F4                 LB.

; ----------------------------------------------------------------------------
pp1_download2:
        stx     address1                        ; F235 86 1D                    ..
        sty     $1E                             ; F237 84 1E                    ..
pp1_download:
        ldx     #$0D                            ; F239 A2 0D                    ..
pp1_unpack:
        ldy     #$00                            ; F23B A0 00                    ..
        lda     (address1),y                    ; F23D B1 1D                    ..
        sta     temp1                           ; F23F 85 32                    .2
        sta     temp8                           ; F241 85 39                    .9
        iny                                     ; F243 C8                       .
        lda     #$80                            ; F244 A9 80                    ..
        sta     temp2                           ; F246 85 33                    .3
pp1_chrloop:
        jsr     pp1_getc                        ; F248 20 05 F3                  ..
        bcs     pp1_gotheader                   ; F24B B0 2F                    ./
        ldx     #$03                            ; F24D A2 03                    ..
LF24F:  jsr     pp1_get2                        ; F24F 20 15 F3                  ..
        sta     address2,x                      ; F252 95 1F                    ..
        beq     LF279                           ; F254 F0 23                    .#
        lsr     a                               ; F256 4A                       J
        beq     LF274                           ; F257 F0 1B                    ..
        bcc     LF263                           ; F259 90 08                    ..
        jsr     pp1_t3                          ; F25B 20 50 F3                  P.
        sta     address8,x                      ; F25E 95 2B                    .+
        jmp     LF279                           ; F260 4C 79 F2                 Ly.

; ----------------------------------------------------------------------------
LF263:  jsr     pp1_t3                          ; F263 20 50 F3                  P.
        sta     temp3                           ; F266 85 34                    .4
        jsr     pp1_getc                        ; F268 20 05 F3                  ..
        bcc     LF279                           ; F26B 90 0C                    ..
        lda     temp3                           ; F26D A5 34                    .4
        sta     address6,x                      ; F26F 95 27                    .'
        jmp     LF279                           ; F271 4C 79 F2                 Ly.

; ----------------------------------------------------------------------------
LF274:  jsr     pp1_t1                          ; F274 20 3A F3                  :.
        sta     address4,x                      ; F277 95 23                    .#
LF279:  dex                                     ; F279 CA                       .
        bpl     LF24F                           ; F27A 10 D3                    ..
pp1_gotheader:
        ldx     #$07                            ; F27C A2 07                    ..
pp1_getline:
        stx     temp3                           ; F27E 86 34                    .4
        asl     temp2                           ; F280 06 33                    .3
        bcc     LF28B                           ; F282 90 07                    ..
        bne     pp1_gotline                     ; F284 D0 5F                    ._
        jsr     pp1_getq                        ; F286 20 0A F3                  ..
        bcs     pp1_gotline                     ; F289 B0 5A                    .Z
LF28B:  jsr     pp1_get2                        ; F28B 20 15 F3                  ..
        tax                                     ; F28E AA                       .
        sta     temp4                           ; F28F 85 35                    .5
        lsr     a                               ; F291 4A                       J
        ora     #$02                            ; F292 09 02                    ..
        sta     temp5                           ; F294 85 36                    .6
LF296:  lda     address2,x                      ; F296 B5 1F                    ..
        beq     LF2DC                           ; F298 F0 42                    .B
        asl     temp2                           ; F29A 06 33                    .3
        bcc     LF2A5                           ; F29C 90 07                    ..
        bne     LF2DC                           ; F29E D0 3C                    .<
        jsr     pp1_getq                        ; F2A0 20 0A F3                  ..
        bcs     LF2DC                           ; F2A3 B0 37                    .7
LF2A5:  lda     address2,x                      ; F2A5 B5 1F                    ..
        lsr     a                               ; F2A7 4A                       J
        beq     LF2D9                           ; F2A8 F0 2F                    ./
        bcc     LF2C8                           ; F2AA 90 1C                    ..
        asl     temp2                           ; F2AC 06 33                    .3
        bcc     LF2B7                           ; F2AE 90 07                    ..
        bne     LF2D9                           ; F2B0 D0 27                    .'
        jsr     pp1_getq                        ; F2B2 20 0A F3                  ..
        bcs     LF2D9                           ; F2B5 B0 22                    ."
LF2B7:  asl     temp2                           ; F2B7 06 33                    .3
        bcc     LF2D3                           ; F2B9 90 18                    ..
        bne     LF2C2                           ; F2BB D0 05                    ..
        jsr     pp1_getq                        ; F2BD 20 0A F3                  ..
        bcc     LF2D3                           ; F2C0 90 11                    ..
LF2C2:  lda     address8,x                      ; F2C2 B5 2B                    .+
        tax                                     ; F2C4 AA                       .
        jmp     LF2DD                           ; F2C5 4C DD F2                 L..

; ----------------------------------------------------------------------------
LF2C8:  asl     temp2                           ; F2C8 06 33                    .3
        bcc     LF2D9                           ; F2CA 90 0D                    ..
        bne     LF2D3                           ; F2CC D0 05                    ..
        jsr     pp1_getq                        ; F2CE 20 0A F3                  ..
        bcc     LF2D9                           ; F2D1 90 06                    ..
LF2D3:  lda     address6,x                      ; F2D3 B5 27                    .'
        tax                                     ; F2D5 AA                       .
        jmp     LF2DD                           ; F2D6 4C DD F2                 L..

; ----------------------------------------------------------------------------
LF2D9:  lda     address4,x                      ; F2D9 B5 23                    .#
        tax                                     ; F2DB AA                       .
LF2DC:  txa                                     ; F2DC 8A                       .
LF2DD:  lsr     a                               ; F2DD 4A                       J
        rol     temp4                           ; F2DE 26 35                    &5
        lsr     a                               ; F2E0 4A                       J
        rol     temp5                           ; F2E1 26 36                    &6
        bcc     LF296                           ; F2E3 90 B1                    ..
pp1_gotline:
        lda     temp4                           ; F2E5 A5 35                    .5
        sta     _vramdata                       ; F2E7 8D 07 20                 .. 
        ldx     temp3                           ; F2EA A6 34                    .4
        lda     temp5                           ; F2EC A5 36                    .6
        sta     toplevvar1,x                    ; F2EE 95 11                    ..
        dex                                     ; F2F0 CA                       .
        bpl     pp1_getline                     ; F2F1 10 8B                    ..
        ldx     #$07                            ; F2F3 A2 07                    ..
LF2F5:  lda     toplevvar1,x                    ; F2F5 B5 11                    ..
        sta     _vramdata                       ; F2F7 8D 07 20                 .. 
        dex                                     ; F2FA CA                       .
        bpl     LF2F5                           ; F2FB 10 F8                    ..
        dec     temp1                           ; F2FD C6 32                    .2
        beq     LF304                           ; F2FF F0 03                    ..
        jmp     pp1_chrloop                     ; F301 4C 48 F2                 LH.

; ----------------------------------------------------------------------------
LF304:  rts                                     ; F304 60                       `

; ----------------------------------------------------------------------------
pp1_getc:
        asl     temp2                           ; F305 06 33                    .3
        beq     pp1_getq                        ; F307 F0 01                    ..
        rts                                     ; F309 60                       `

; ----------------------------------------------------------------------------
pp1_getq:
        lda     (address1),y                    ; F30A B1 1D                    ..
        iny                                     ; F30C C8                       .
        bne     LF311                           ; F30D D0 02                    ..
        inc     $1E                             ; F30F E6 1E                    ..
LF311:  rol     a                               ; F311 2A                       *
        sta     temp2                           ; F312 85 33                    .3
        rts                                     ; F314 60                       `

; ----------------------------------------------------------------------------
pp1_get2:
        asl     temp2                           ; F315 06 33                    .3
        bne     LF323                           ; F317 D0 0A                    ..
        lda     (address1),y                    ; F319 B1 1D                    ..
        iny                                     ; F31B C8                       .
        bne     LF320                           ; F31C D0 02                    ..
        inc     $1E                             ; F31E E6 1E                    ..
LF320:  rol     a                               ; F320 2A                       *
        sta     temp2                           ; F321 85 33                    .3
LF323:  rol     a                               ; F323 2A                       *
        and     #$01                            ; F324 29 01                    ).
        asl     temp2                           ; F326 06 33                    .3
        beq     LF32C                           ; F328 F0 02                    ..
        rol     a                               ; F32A 2A                       *
        rts                                     ; F32B 60                       `

; ----------------------------------------------------------------------------
LF32C:  pha                                     ; F32C 48                       H
        lda     (address1),y                    ; F32D B1 1D                    ..
        iny                                     ; F32F C8                       .
        bne     LF334                           ; F330 D0 02                    ..
        inc     $1E                             ; F332 E6 1E                    ..
LF334:  rol     a                               ; F334 2A                       *
        sta     temp2                           ; F335 85 33                    .3
        pla                                     ; F337 68                       h
        rol     a                               ; F338 2A                       *
        rts                                     ; F339 60                       `

; ----------------------------------------------------------------------------
pp1_t1: jsr     pp1_getc                        ; F33A 20 05 F3                  ..
        bcc     LF343                           ; F33D 90 04                    ..
        lda     PP1_FC1,x                       ; F33F BD 87 F3                 ...
        rts                                     ; F342 60                       `

; ----------------------------------------------------------------------------
LF343:  jsr     pp1_getc                        ; F343 20 05 F3                  ..
        bcs     LF34C                           ; F346 B0 04                    ..
        lda     PP1_FC2,x                       ; F348 BD 84 F3                 ...
        rts                                     ; F34B 60                       `

; ----------------------------------------------------------------------------
LF34C:  lda     PP1_FC3,x                       ; F34C BD 81 F3                 ...
        rts                                     ; F34F 60                       `

; ----------------------------------------------------------------------------
pp1_t3: jsr     pp1_t1                          ; F350 20 3A F3                  :.
        sta     address4,x                      ; F353 95 23                    .#
        beq     LF378                           ; F355 F0 21                    .!
        cmp     #$02                            ; F357 C9 02                    ..
        bcc     LF36F                           ; F359 90 14                    ..
        beq     LF366                           ; F35B F0 09                    ..
        lda     PP1_FC1,x                       ; F35D BD 87 F3                 ...
        sta     address6,x                      ; F360 95 27                    .'
        lda     PP1_FC2,x                       ; F362 BD 84 F3                 ...
        rts                                     ; F365 60                       `

; ----------------------------------------------------------------------------
LF366:  lda     PP1_FC1,x                       ; F366 BD 87 F3                 ...
        sta     address6,x                      ; F369 95 27                    .'
        lda     pp1_f2h,x                       ; F36B BD 8F F3                 ...
        rts                                     ; F36E 60                       `

; ----------------------------------------------------------------------------
LF36F:  lda     pp1_f1l,x                       ; F36F BD 8B F3                 ...
        sta     address6,x                      ; F372 95 27                    .'
        lda     PP1_FC3,x                       ; F374 BD 81 F3                 ...
        rts                                     ; F377 60                       `

; ----------------------------------------------------------------------------
LF378:  lda     PP1_FC2,x                       ; F378 BD 84 F3                 ...
        sta     address6,x                      ; F37B 95 27                    .'
        lda     PP1_FC3,x                       ; F37D BD 81 F3                 ...
        rts                                     ; F380 60                       `

; ----------------------------------------------------------------------------
PP1_FC3:.byte   $03,$03,$03                     ; F381 03 03 03                 ...
PP1_FC2:.byte   $02,$02,$01                     ; F384 02 02 01                 ...
PP1_FC1:.byte   $01,$00,$00,$00                 ; F387 01 00 00 00              ....
pp1_f1l:.byte   $02,$FF,$00,$00                 ; F38B 02 FF 00 00              ....
pp1_f2h:.byte   $03,$03,$FF,$01                 ; F38F 03 03 FF 01              ....
; ----------------------------------------------------------------------------
; ==========================================================================
; GENERAL.ROU
; ==========================================================================
readkeypads:
        ldx     #$01                            ; F393 A2 01                    ..
        stx     _kpreg1                         ; F395 8E 16 40                 ..@
        dex                                     ; F398 CA                       .
        stx     _kpreg1                         ; F399 8E 16 40                 ..@
        lda     pad                             ; F39C A5 07                    ..
        sta     debounce                        ; F39E 85 08                    ..
        ldy     #$08                            ; F3A0 A0 08                    ..
padloop2:
        lda     _kpreg1                         ; F3A2 AD 16 40                 ..@
        lsr     a                               ; F3A5 4A                       J
        rol     pad                             ; F3A6 26 07                    &.
        dey                                     ; F3A8 88                       .
        bne     padloop2                        ; F3A9 D0 F7                    ..
        rts                                     ; F3AB 60                       `

; ----------------------------------------------------------------------------
random: lda     counter                         ; F3AC A5 10                    ..
        ror     a                               ; F3AE 6A                       j
        eor     $05                             ; F3AF 45 05                    E.
        eor     seed                            ; F3B1 45 04                    E.
        rol     a                               ; F3B3 2A                       *
        ror     $06                             ; F3B4 66 06                    f.
        sta     $05                             ; F3B6 85 05                    ..
        eor     #$FF                            ; F3B8 49 FF                    I.
        rol     a                               ; F3BA 2A                       *
        eor     seed                            ; F3BB 45 04                    E.
        sta     seed                            ; F3BD 85 04                    ..
        rts                                     ; F3BF 60                       `

; ----------------------------------------------------------------------------
        lda     #$10                            ; F3C0 A9 10                    ..
        bne     generalkeytest                  ; F3C2 D0 06                    ..
        lda     #$20                            ; F3C4 A9 20                    . 
        bne     generalkeytest                  ; F3C6 D0 02                    ..
        lda     #$FF                            ; F3C8 A9 FF                    ..
generalkeytest:
        sta     temp                            ; F3CA 85 31                    .1
        lda     pad                             ; F3CC A5 07                    ..
        and     temp                            ; F3CE 25 31                    %1
        beq     @n1                           ; F3D0 F0 08                    ..
        lda     debounce                        ; F3D2 A5 08                    ..
        and     temp1                           ; F3D4 25 32                    %2
        beq     @n2                           ; F3D6 F0 03                    ..
        lda     #$00                            ; F3D8 A9 00                    ..
@n1:  rts                                     ; F3DA 60                       `

; ----------------------------------------------------------------------------
@n2:  lda     #$01                            ; F3DB A9 01                    ..
        rts                                     ; F3DD 60                       `

; ----------------------------------------------------------------------------
checkforpausekey:
        lda     dontpause                       ; F3DE A5 45                    .E
        bne     @n3                           ; F3E0 D0 0E                    ..
        lda     pad                             ; F3E2 A5 07                    ..
        and     #$10                            ; F3E4 29 10                    ).
        beq     @n5                           ; F3E6 F0 19                    ..
        lda     debounce                        ; F3E8 A5 08                    ..
        and     #$10                            ; F3EA 29 10                    ).
        bne     @n5                           ; F3EC D0 13                    ..
        lda     pause                           ; F3EE A5 44                    .D
@n3:  eor     #$01                            ; F3F0 49 01                    I.
        sta     pause                           ; F3F2 85 44                    .D
        beq     @n4                           ; F3F4 F0 06                    ..
        lda     #$00                            ; F3F6 A9 00                    ..
        sta     $4015                           ; F3F8 8D 15 40                 ..@
        rts                                     ; F3FB 60                       `

; ----------------------------------------------------------------------------
@n4:  lda     #$0F                            ; F3FC A9 0F                    ..
        sta     $4015                           ; F3FE 8D 15 40                 ..@
@n5:  rts                                     ; F401 60                       `

; ----------------------------------------------------------------------------
clearfullspriteblock:
        ldx     #$00                            ; F402 A2 00                    ..
        jsr     clearspriteblock1               ; F404 20 55 F4                  U.
sendspriteblock:
        lda     #$00                            ; F407 A9 00                    ..
        sta     _spriteaddr                     ; F409 8D 03 20                 .. 
        lda     #$02                            ; F40C A9 02                    ..
        sta     _dmafunc                        ; F40E 8D 14 40                 ..@
        rts                                     ; F411 60                       `

; ----------------------------------------------------------------------------
turnofftune:
        lda     #$00                            ; F412 A9 00                    ..
starttune:
        tay                                     ; F414 A8                       .
        lda     bankno                          ; F415 A5 0D                    ..
        pha                                     ; F417 48                       H
        jsr     changebank13rou                 ; F418 20 7C C2                  |.
        lda     #$00                            ; F41B A9 00                    ..
        sta     $4015                           ; F41D 8D 15 40                 ..@
        tya                                     ; F420 98                       .
        jsr     b1_START_MUSIC                  ; F421 20 07 80                  ..
        pla                                     ; F424 68                       h
        jmp     changebankrou                   ; F425 4C 42 F4                 LB.

; ----------------------------------------------------------------------------
soundfx:sta     $60                             ; F428 85 60                    .`
        txa                                     ; F42A 8A                       .
        pha                                     ; F42B 48                       H
        tya                                     ; F42C 98                       .
        pha                                     ; F42D 48                       H
        lda     bankno                          ; F42E A5 0D                    ..
        pha                                     ; F430 48                       H
        jsr     changebank13rou                 ; F431 20 7C C2                  |.
        lda     $60                             ; F434 A5 60                    .`
        jsr     b1_fx_setup                     ; F436 20 7E A4                  ~.
        pla                                     ; F439 68                       h
        jsr     changebankrou                   ; F43A 20 42 F4                  B.
        pla                                     ; F43D 68                       h
        tay                                     ; F43E A8                       .
        pla                                     ; F43F 68                       h
        tax                                     ; F440 AA                       .
        rts                                     ; F441 60                       `

; ----------------------------------------------------------------------------
changebankrou:
        sta     bankno                          ; F442 85 0D                    ..
changebankrou1:
        tax                                     ; F444 AA                       .
        sta     bank_table,x                    ; F445 9D 0A C0                 ...
        rts                                     ; F448 60                       `

; ----------------------------------------------------------------------------
clearscr:
        .byte   $A0,$00,$FB,$40,$FB,$20,$00,$FA ; F449 A0 00 FB 40 FB 20 00 FA  ...@. ..
        .byte   $FA,$FF                         ; F451 FA FF                    ..
; ----------------------------------------------------------------------------
clearspriteblock:
        ldx     #$04                            ; F453 A2 04                    ..
clearspriteblock1:
        stx     spriteblockpointer              ; F455 86 0E                    ..
@n1:  lda     #$FE                            ; F457 A9 FE                    ..
        sta     spriteblock,x                   ; F459 9D 00 02                 ...
        lda     #$00                            ; F45C A9 00                    ..
        sta     $0203,x                         ; F45E 9D 03 02                 ...
        sta     $0202,x                         ; F461 9D 02 02                 ...
        sta     $0201,x                         ; F464 9D 01 02                 ...
        inx                                     ; F467 E8                       .
        inx                                     ; F468 E8                       .
        inx                                     ; F469 E8                       .
        inx                                     ; F46A E8                       .
        bne     @n1                           ; F46B D0 EA                    ..
        rts                                     ; F46D 60                       `

; ----------------------------------------------------------------------------
        asl     flyflag                         ; F46E 06 0B                    ..
@fly:  bit     flyflag                         ; F470 24 0B                    $.
        bpl     @fly                           ; F472 10 FC                    ..
        jsr     sendspriteblock                 ; F474 20 07 F4                  ..
turninteron:
        lda     #$FF                            ; F477 A9 FF                    ..
        sta     debounce                        ; F479 85 08                    ..
        ldx     x_scroll                        ; F47B A6 0A                    ..
        ldy     y_scroll                        ; F47D A4 09                    ..
        stx     _scrollcon                      ; F47F 8E 05 20                 .. 
        sty     _scrollcon                      ; F482 8C 05 20                 .. 
        lda     control0                        ; F485 A5 01                    ..
        ldy     control1                        ; F487 A4 02                    ..
        ; start flyback interupt
        sta     _control0                       ; F489 8D 00 20                 .. 
        sty     _control1                       ; F48C 8C 01 20                 .. 
        lda     #$FF                            ; F48F A9 FF                    ..
        sta     interon                         ; F491 85 03                    ..
        rts                                     ; F493 60                       `

; ----------------------------------------------------------------------------
turninterofffade:
        lda     #$00                            ; F494 A9 00                    ..
        sta     finishedloop                    ; F496 8D 00 03                 ...
        lda     #$FC                            ; F499 A9 FC                    ..
        sta     fadecounter                     ; F49B 85 4D                    .M
fadeoffscreen:
        asl     flyflag                         ; F49D 06 0B                    ..
@fly:  bit     flyflag                         ; F49F 24 0B                    $.
        bpl     @fly                           ; F4A1 10 FC                    ..
        lda     fadecounter                     ; F4A3 A5 4D                    .M
        cmp     #$FF                            ; F4A5 C9 FF                    ..
        bne     fadeoffscreen                   ; F4A7 D0 F4                    ..
        jmp     turninteroff1                   ; F4A9 4C B2 F4                 L..

; ----------------------------------------------------------------------------
turninteroff:
        asl     flyflag                         ; F4AC 06 0B                    ..
@fly:  bit     flyflag                         ; F4AE 24 0B                    $.
        bpl     @fly                           ; F4B0 10 FC                    ..
turninteroff1:
        lda     #$00                            ; F4B2 A9 00                    ..
        sta     finishedloop                    ; F4B4 8D 00 03                 ...
        sta     interon                         ; F4B7 85 03                    ..
        sta     _control1                       ; F4B9 8D 01 20                 .. 
        sta     x_scroll                        ; F4BC 85 0A                    ..
        sta     y_scroll                        ; F4BE 85 09                    ..
        sta     _scrollcon                      ; F4C0 8D 05 20                 .. 
        sta     _scrollcon                      ; F4C3 8D 05 20                 .. 
        sta     vrampointer                     ; F4C6 85 0C                    ..
        sta     pause                           ; F4C8 85 44                    .D
        lda     #$1E                            ; F4CA A9 1E                    ..
        sta     control1                        ; F4CC 85 02                    ..
        lda     #$90                            ; F4CE A9 90                    ..
        sta     control0                        ; F4D0 85 01                    ..
        sta     _control0                       ; F4D2 8D 00 20                 .. 
        jmp     clearfullspriteblock            ; F4D5 4C 02 F4                 L..

; ----------------------------------------------------------------------------
        inc     lives                           ; F4D8 E6 48                    .H
        rts                                     ; F4DA 60                       `

; ----------------------------------------------------------------------------
highbitadd:
        .byte   $FF,$00,$00                     ; F4DB FF 00 00                 ...
; ----------------------------------------------------------------------------
printlives:
        lda     lives                           ; F4DE A5 48                    .H
        beq     @n3                           ; F4E0 F0 26                    .&
        bmi     @n3                           ; F4E2 30 24                    0$
        cmp     #$03                            ; F4E4 C9 03                    ..
        bcc     @n1                           ; F4E6 90 02                    ..
        lda     #$03                            ; F4E8 A9 03                    ..
@n1:  sta     temp9                           ; F4EA 85 3A                    .:
        lda     #$40                            ; F4EC A9 40                    .@
        sta     temp                            ; F4EE 85 31                    .1
        lda     #$14                            ; F4F0 A9 14                    ..
        sta     address5                        ; F4F2 85 25                    .%
@n2:  ldy     address5                        ; F4F4 A4 25                    .%
        ldx     #$F0                            ; F4F6 A2 F0                    ..
        lda     #$01                            ; F4F8 A9 01                    ..
        jsr     pokesprite2by2                  ; F4FA 20 EB EF                  ..
        lda     address5                        ; F4FD A5 25                    .%
        clc                                     ; F4FF 18                       .
        adc     #$18                            ; F500 69 18                    i.
        sta     address5                        ; F502 85 25                    .%
        dec     temp9                           ; F504 C6 3A                    .:
        bne     @n2                           ; F506 D0 EC                    ..
@n3:  rts                                     ; F508 60                       `

; ----------------------------------------------------------------------------
printscore:
        lda     #$5E                            ; F509 A9 5E                    .^
        ldy     #$00                            ; F50B A0 00                    ..
@n4:  ldx     score,y                         ; F50D BE 75 05                 .u.
        bne     @n5                           ; F510 D0 08                    ..
        clc                                     ; F512 18                       .
        adc     #$05                            ; F513 69 05                    i.
        iny                                     ; F515 C8                       .
        cpy     #$03                            ; F516 C0 03                    ..
        bne     @n4                           ; F518 D0 F3                    ..
@n5:  sta     temp                            ; F51A 85 31                    .1
@n6:  lda     score,y                         ; F51C B9 75 05                 .u.
        clc                                     ; F51F 18                       .
        adc     #$80                            ; F520 69 80                    i.
        ldx     spriteblockpointer              ; F522 A6 0E                    ..
        beq     @n1                           ; F524 F0 24                    .$
        sta     $0201,x                         ; F526 9D 01 02                 ...
        lda     temp1                           ; F529 A5 32                    .2
        lda     #$02                            ; F52B A9 02                    ..
        sta     $0202,x                         ; F52D 9D 02 02                 ...
        lda     temp                            ; F530 A5 31                    .1
        sta     $0203,x                         ; F532 9D 03 02                 ...
        clc                                     ; F535 18                       .
        adc     #$0A                            ; F536 69 0A                    i.
        sta     temp                            ; F538 85 31                    .1
        lda     #$10                            ; F53A A9 10                    ..
        sta     spriteblock,x                   ; F53C 9D 00 02                 ...
        txa                                     ; F53F 8A                       .
        clc                                     ; F540 18                       .
        adc     #$04                            ; F541 69 04                    i.
        sta     spriteblockpointer              ; F543 85 0E                    ..
        iny                                     ; F545 C8                       .
        cpy     #$06                            ; F546 C0 06                    ..
        bne     @n6                           ; F548 D0 D2                    ..
@n1:  rts                                     ; F54A 60                       `

; add low nibble of A to
; (hi nibble)th digit of score 0=100,000 5=1 unit
; ----------------------------------------------------------------------------
addtoscore:
        sty     tempy                           ; F54B 84 30                    .0
        pha                                     ; F54D 48                       H
        lsr     a                               ; F54E 4A                       J
        lsr     a                               ; F54F 4A                       J
        lsr     a                               ; F550 4A                       J
        lsr     a                               ; F551 4A                       J
        tay                                     ; F552 A8                       .
        pla                                     ; F553 68                       h
        and     #$0F                            ; F554 29 0F                    ).
addtolp:clc                                     ; F556 18                       .
        adc     score,y                         ; F557 79 75 05                 yu.
        sta     score,y                         ; F55A 99 75 05                 .u.
        cmp     #$0A                            ; F55D C9 0A                    ..
        bcc     endupdatescore                  ; F55F 90 0B                    ..
        sec                                     ; F561 38                       8
        sbc     #$0A                            ; F562 E9 0A                    ..
        sta     score,y                         ; F564 99 75 05                 .u.
        lda     #$01                            ; F567 A9 01                    ..
        dey                                     ; F569 88                       .
        bpl     addtolp                         ; F56A 10 EA                    ..
endupdatescore:
        ldy     tempy                           ; F56C A4 30                    .0
        rts                                     ; F56E 60                       `

; ----------------------------------------------------------------------------
resetscore:
        ldy     #$06                            ; F56F A0 06                    ..
@loop:  lda     #$00                            ; F571 A9 00                    ..
        sta     score,y                         ; F573 99 75 05                 .u.
        lda     #$08                            ; F576 A9 08                    ..
        sta     treasures,y                     ; F578 99 2E 03                 ...
        dey                                     ; F57B 88                       .
        bpl     @loop                           ; F57C 10 F3                    ..
        rts                                     ; F57E 60                       `

; ----------------------------------------------------------------------------
        lda     hearts                          ; F57F A5 49                    .I
        clc                                     ; F581 18                       .
        adc     #$01                            ; F582 69 01                    i.
        sta     hearts                          ; F584 85 49                    .I
        cmp     #$05                            ; F586 C9 05                    ..
        bcc     @n2                           ; F588 90 0C                    ..
        inc     lives                           ; F58A E6 48                    .H
        clc                                     ; F58C 18                       .
        adc     #$FD                            ; F58D 69 FD                    i.
        sta     hearts                          ; F58F 85 49                    .I
        lda     #$24                            ; F591 A9 24                    .$
        jsr     soundfx                         ; F593 20 28 F4                  (.
@n2:  rts                                     ; F596 60                       `

; a=number of hearts to sub
; ----------------------------------------------------------------------------
subfromhearts:
        ldy     robininvinc                     ; F597 AC 1C 03                 ...
        beq     subfromhearts1                  ; F59A F0 01                    ..
        rts                                     ; F59C 60                       `

; ----------------------------------------------------------------------------
subfromhearts1:
        eor     #$FF                            ; F59D 49 FF                    I.
        clc                                     ; F59F 18                       .
        adc     #$01                            ; F5A0 69 01                    i.
        clc                                     ; F5A2 18                       .
        adc     hearts                          ; F5A3 65 49                    eI
        sta     hearts                          ; F5A5 85 49                    .I
        ldy     #$96                            ; F5A7 A0 96                    ..
        sty     robininvinc                     ; F5A9 8C 1C 03                 ...
        cmp     #$00                            ; F5AC C9 00                    ..
        beq     killyou1                        ; F5AE F0 06                    ..
        bpl     littlekill                      ; F5B0 10 22                    ."
        lda     #$00                            ; F5B2 A9 00                    ..
        sta     hearts                          ; F5B4 85 49                    .I
killyou1:
        lda     #$64                            ; F5B6 A9 64                    .d
        sta     killed                          ; F5B8 8D 23 03                 .#.
        lda     #$01                            ; F5BB A9 01                    ..
        sta     temp2                           ; F5BD 85 33                    .3
        lda     #$00                            ; F5BF A9 00                    ..
        sta     heartstable                     ; F5C1 8D E1 04                 ...
        sta     $04F1                           ; F5C4 8D F1 04                 ...
        sta     $0501                           ; F5C7 8D 01 05                 ...
        ldx     #$20                            ; F5CA A2 20                    . 
        ; startstars ;large robin explosion
        jsr     gotstarsx                       ; F5CC 20 08 D5                  ..
        lda     #$1E                            ; F5CF A9 1E                    ..
        jmp     soundfx                         ; F5D1 4C 28 F4                 L(.

; ----------------------------------------------------------------------------
littlekill:
        lda     #$00                            ; F5D4 A9 00                    ..
        ; small robin explosion
        jsr     startstars                      ; F5D6 20 EF D4                  ..
        lda     #$1C                            ; F5D9 A9 1C                    ..
        jmp     soundfx                         ; F5DB 4C 28 F4                 L(.

; ----------------------------------------------------------------------------
printhearts:
        lda     #$18                            ; F5DE A9 18                    ..
        sta     temp                            ; F5E0 85 31                    .1
        ldy     hearts                          ; F5E2 A4 49                    .I
        bmi     @n1                           ; F5E4 30 45                    0E
        beq     @n1                           ; F5E6 F0 43                    .C
        lda     heartcounter                    ; F5E8 A5 4A                    .J
        bit     pause                           ; F5EA 24 44                    $D
        bne     @n3                           ; F5EC D0 06                    ..
        clc                                     ; F5EE 18                       .
        adc     LF62F,y                         ; F5EF 79 2F F6                 y/.
        sta     heartcounter                    ; F5F2 85 4A                    .J
@n3:  lda     heartcounter                    ; F5F4 A5 4A                    .J
        lsr     a                               ; F5F6 4A                       J
        lsr     a                               ; F5F7 4A                       J
        lsr     a                               ; F5F8 4A                       J
        lsr     a                               ; F5F9 4A                       J
        lsr     a                               ; F5FA 4A                       J
        lsr     a                               ; F5FB 4A                       J
        tax                                     ; F5FC AA                       .
        lda     heartsdefs,x                    ; F5FD BD 2C F6                 .,.
        sta     temp1                           ; F600 85 32                    .2
@n2:  ldx     spriteblockpointer              ; F602 A6 0E                    ..
        beq     @n1                           ; F604 F0 25                    .%
        lda     temp1                           ; F606 A5 32                    .2
        sta     $0201,x                         ; F608 9D 01 02                 ...
        lda     #$03                            ; F60B A9 03                    ..
        sta     $0202,x                         ; F60D 9D 02 02                 ...
        sta     $0206,x                         ; F610 9D 06 02                 ...
        lda     #$10                            ; F613 A9 10                    ..
        sta     $0203,x                         ; F615 9D 03 02                 ...
        lda     temp                            ; F618 A5 31                    .1
        sta     spriteblock,x                   ; F61A 9D 00 02                 ...
        clc                                     ; F61D 18                       .
        adc     #$18                            ; F61E 69 18                    i.
        sta     temp                            ; F620 85 31                    .1
        txa                                     ; F622 8A                       .
        clc                                     ; F623 18                       .
        adc     #$04                            ; F624 69 04                    i.
        sta     spriteblockpointer              ; F626 85 0E                    ..
        dey                                     ; F628 88                       .
        bne     @n2                           ; F629 D0 D7                    ..
@n1:  rts                                     ; F62B 60                       `

; ----------------------------------------------------------------------------
heartsdefs:
        .byte   $8A,$8B,$8C                     ; F62C 8A 8B 8C                 ...
LF62F:  .byte   $8B                             ; F62F 8B                       .
heartbeat:
        .byte   $12,$0E,$0A,$08,$06,$04,$02,$01 ; F630 12 0E 0A 08 06 04 02 01  ........
        .byte   $01,$02,$01,$01,$03             ; F638 01 02 01 01 03           .....
; equal=keep going round loop
; ----------------------------------------------------------------------------
waitforstartkey:
        lda     fadecounter                     ; F63D A5 4D                    .M
        cmp     #$FF                            ; F63F C9 FF                    ..
        beq     @n2                           ; F641 F0 1D                    ..
        cmp     #$00                            ; F643 C9 00                    ..
        bne     wfsk_n1                           ; F645 D0 1F                    ..
        lda     pad                             ; F647 A5 07                    ..
        and     #$10                            ; F649 29 10                    ).
        beq     wfsk_ret                           ; F64B F0 1B                    ..
        lda     debounce                        ; F64D A5 08                    ..
        and     #$10                            ; F64F 29 10                    ).
        bne     wfsk_n1                           ; F651 D0 13                    ..
        lda     solidfound                      ; F653 A5 43                    .C
        clc                                     ; F655 18                       .
        adc     #$80                            ; F656 69 80                    i.
        sta     solidfound                      ; F658 85 43                    .C
        lda     #$FB                            ; F65A A9 FB                    ..
        sta     fadecounter                     ; F65C 85 4D                    .M
        bne     wfsk_n1                           ; F65E D0 06                    ..
@n2:  jsr     turninteroff1                   ; F660 20 B2 F4                  ..
        lda     #$01                            ; F663 A9 01                    ..
        rts                                     ; F665 60                       `

; ----------------------------------------------------------------------------
wfsk_n1:  lda     #$00                            ; F666 A9 00                    ..
wfsk_ret:  rts                                     ; F668 60                       `

; ----------------------------------------------------------------------------
; ==========================================================================
; MAPSCROL.ROU
; ==========================================================================
attributemasks:
        .byte   $FC,$F3,$CF,$3F                 ; F669 FC F3 CF 3F              ...?
attributeands:
        .byte   $00,$00,$00,$00,$01,$04,$10,$40 ; F66D 00 00 00 00 01 04 10 40  .......@
        .byte   $02,$08,$20,$80,$03,$0C,$30,$C0 ; F675 02 08 20 80 03 0C 30 C0  .. ...0.
; ----------------------------------------------------------------------------
setxscroll:
        lda     scrxl                           ; F67D A5 3B                    .;
        sta     address2                        ; F67F 85 1F                    ..
        lda     scrxh                           ; F681 A5 3C                    .<
        sta     $20                             ; F683 85 20                    . 
        lda     robinxl                         ; F685 AD 08 03                 ...
        sec                                     ; F688 38                       8
        sbc     #$78                            ; F689 E9 78                    .x
        sta     address2                        ; F68B 85 1F                    ..
        lda     robinxh                         ; F68D AD 09 03                 ...
        sbc     #$00                            ; F690 E9 00                    ..
        cmp     #$FF                            ; F692 C9 FF                    ..
        bne     @n1                           ; F694 D0 04                    ..
        lda     #$00                            ; F696 A9 00                    ..
        sta     address2                        ; F698 85 1F                    ..
@n1:  sta     $20                             ; F69A 85 20                    . 
        lda     $20                             ; F69C A5 20                    . 
        sta     temp                            ; F69E 85 31                    .1
        lda     address2                        ; F6A0 A5 1F                    ..
        lsr     temp                            ; F6A2 46 31                    F1
        ror     a                               ; F6A4 6A                       j
        lsr     temp                            ; F6A5 46 31                    F1
        ror     a                               ; F6A7 6A                       j
        lsr     temp                            ; F6A8 46 31                    F1
        ror     a                               ; F6AA 6A                       j
        lsr     temp                            ; F6AB 46 31                    F1
        ror     a                               ; F6AD 6A                       j
        sta     mapstrip                        ; F6AE 85 3D                    .=
        cmp     #$00                            ; F6B0 C9 00                    ..
        bcc     mapnotmoved                     ; F6B2 90 66                    .f
        cmp     maxmap                          ; F6B4 CD 06 03                 ...
        bcc     printmapdownside                ; F6B7 90 17                    ..
        lda     maxmap                          ; F6B9 AD 06 03                 ...
        sta     mapstrip                        ; F6BC 85 3D                    .=
        ldx     #$00                            ; F6BE A2 00                    ..
        stx     $20                             ; F6C0 86 20                    . 
        asl     a                               ; F6C2 0A                       .
        rol     $20                             ; F6C3 26 20                    & 
        asl     a                               ; F6C5 0A                       .
        rol     $20                             ; F6C6 26 20                    & 
        asl     a                               ; F6C8 0A                       .
        rol     $20                             ; F6C9 26 20                    & 
        asl     a                               ; F6CB 0A                       .
        rol     $20                             ; F6CC 26 20                    & 
        sta     address2                        ; F6CE 85 1F                    ..
printmapdownside:
        lda     scrxh                           ; F6D0 A5 3C                    .<
        cmp     $20                             ; F6D2 C5 20                    . 
        bne     @n1                           ; F6D4 D0 04                    ..
        lda     scrxl                           ; F6D6 A5 3B                    .;
        cmp     address2                        ; F6D8 C5 1F                    ..
@n1:  beq     mapnotmoved                     ; F6DA F0 3E                    .>
        bcs     decmapset                       ; F6DC B0 0B                    ..
        ldx     #$FF                            ; F6DE A2 FF                    ..
        inc     scrxl                           ; F6E0 E6 3B                    .;
        bne     @n2                           ; F6E2 D0 02                    ..
        inc     scrxh                           ; F6E4 E6 3C                    .<
@n2:  jmp     setmapset                       ; F6E6 4C F7 F6                 L..

; ----------------------------------------------------------------------------
decmapset:
        dec     scrxl                           ; F6E9 C6 3B                    .;
        pha                                     ; F6EB 48                       H
        lda     #$FF                            ; F6EC A9 FF                    ..
        cmp     scrxl                           ; F6EE C5 3B                    .;
        bne     @n1                           ; F6F0 D0 02                    ..
        dec     scrxh                           ; F6F2 C6 3C                    .<
@n1:  pla                                     ; F6F4 68                       h
        ldx     #$00                            ; F6F5 A2 00                    ..
setmapset:
        stx     scrolldir                       ; F6F7 86 47                    .G
        lda     scrxh                           ; F6F9 A5 3C                    .<
        sta     temp                            ; F6FB 85 31                    .1
        lda     scrxl                           ; F6FD A5 3B                    .;
        lsr     temp                            ; F6FF 46 31                    F1
        ror     a                               ; F701 6A                       j
        lsr     temp                            ; F702 46 31                    F1
        ror     a                               ; F704 6A                       j
        lsr     temp                            ; F705 46 31                    F1
        ror     a                               ; F707 6A                       j
        lsr     temp                            ; F708 46 31                    F1
        ror     a                               ; F70A 6A                       j
        sta     mapstrip                        ; F70B 85 3D                    .=
        jsr     bringonmap                      ; F70D 20 D8 F9                  ..
        lda     interon                         ; F710 A5 03                    ..
        bne     printmapdownside                ; F712 D0 BC                    ..
        jsr     emptyblockbuffer                ; F714 20 12 C2                  ..
        jmp     printmapdownside                ; F717 4C D0 F6                 L..

; ----------------------------------------------------------------------------
mapnotmoved:
        lsr     control0                        ; F71A 46 01                    F.
        lda     scrxl                           ; F71C A5 3B                    .;
        clc                                     ; F71E 18                       .
        adc     #$10                            ; F71F 69 10                    i.
        sta     x_scroll                        ; F721 85 0A                    ..
        lda     scrxh                           ; F723 A5 3C                    .<
        adc     #$00                            ; F725 69 00                    i.
        lsr     a                               ; F727 4A                       J
        rol     control0                        ; F728 26 01                    &.
        rts                                     ; F72A 60                       `

; ----------------------------------------------------------------------------
times14tablelo:
; times14tablelo — lookup table: entry[i] = <(i * 14)
times14tablelo_1 := times14tablelo + 1
.repeat 256, i
    .byte <(i * 14)
.endrepeat
times14tablehi:
; times14tablehi — lookup table: entry[i] = >(i * 14)
times14tablehi_1 := times14tablehi + 1
.repeat 256, i
    .byte >(i * 14)
.endrepeat
; ----------------------------------------------------------------------------
findsolid:
        cpy     #$E0                            ; F92B C0 E0                    ..
        bcc     @n2                           ; F92D 90 18                    ..
        pha                                     ; F92F 48                       H
        lda     robiny                          ; F930 AD 0A 03                 ...
        bpl     @n3                           ; F933 10 09                    ..
        tya                                     ; F935 98                       .
        clc                                     ; F936 18                       .
        adc     #$F0                            ; F937 69 F0                    i.
        tay                                     ; F939 A8                       .
        pla                                     ; F93A 68                       h
        jmp     findsolid                       ; F93B 4C 2B F9                 L+.

; ----------------------------------------------------------------------------
@n3:  tya                                     ; F93E 98                       .
        clc                                     ; F93F 18                       .
        adc     #$10                            ; F940 69 10                    i.
        tay                                     ; F942 A8                       .
        pla                                     ; F943 68                       h
        jmp     findsolid                       ; F944 4C 2B F9                 L+.

; ----------------------------------------------------------------------------
@n2:  jsr     findblock                       ; F947 20 72 F9                  r.
        tax                                     ; F94A AA                       .
        lda     #$00                            ; F94B A9 00                    ..
        lsr     temp                            ; F94D 46 31                    F1
        rol     a                               ; F94F 2A                       *
        lsr     temp1                           ; F950 46 32                    F2
        rol     a                               ; F952 2A                       *
        tay                                     ; F953 A8                       .
        lda     $8500,x                         ; F954 BD 00 85                 ...
        and     solidchrmasks,y                 ; F957 39 6E F9                 9n.
        dey                                     ; F95A 88                       .
        beq     shifts4                         ; F95B F0 08                    ..
        dey                                     ; F95D 88                       .
        beq     shifts2                         ; F95E F0 07                    ..
        dey                                     ; F960 88                       .
        beq     shifts0                         ; F961 F0 06                    ..
        lsr     a                               ; F963 4A                       J
        lsr     a                               ; F964 4A                       J
shifts4:lsr     a                               ; F965 4A                       J
        lsr     a                               ; F966 4A                       J
shifts2:lsr     a                               ; F967 4A                       J
        lsr     a                               ; F968 4A                       J
shifts0:sta     solidfound                      ; F969 85 43                    .C
        cmp     #$00                            ; F96B C9 00                    ..
        rts                                     ; F96D 60                       `

; ----------------------------------------------------------------------------
solidchrmasks:
        .byte   $C0,$30,$0C,$03                 ; F96E C0 30 0C 03              .0..
; ----------------------------------------------------------------------------
findblock:
        stx     temp                            ; F972 86 31                    .1
        lsr     temp                            ; F974 46 31                    F1
        ror     a                               ; F976 6A                       j
        lsr     temp                            ; F977 46 31                    F1
        ror     a                               ; F979 6A                       j
        lsr     temp                            ; F97A 46 31                    F1
        ror     a                               ; F97C 6A                       j
        lsr     temp                            ; F97D 46 31                    F1
        ror     a                               ; F97F 6A                       j
        tax                                     ; F980 AA                       .
        rol     temp1                           ; F981 26 32                    &2
        lda     mappointer                      ; F983 A5 40                    .@
        clc                                     ; F985 18                       .
        adc     times14tablelo_1,x                         ; F986 7D 2C F7                 },.
        sta     address                         ; F989 85 1B                    ..
        lda     $41                             ; F98B A5 41                    .A
        adc     times14tablehi_1,x                         ; F98D 7D 2C F8                 },.
        sta     $1C                             ; F990 85 1C                    ..
        tya                                     ; F992 98                       .
        lsr     a                               ; F993 4A                       J
        lsr     a                               ; F994 4A                       J
        lsr     a                               ; F995 4A                       J
        lsr     a                               ; F996 4A                       J
        tay                                     ; F997 A8                       .
        rol     temp                            ; F998 26 31                    &1
        lda     (address),y                     ; F99A B1 1B                    ..
        sta     blockfound                      ; F99C 8D 02 03                 ...
        stx     blockx                          ; F99F 8E 03 03                 ...
        sty     blocky                          ; F9A2 8C 04 03                 ...
        jsr     checkchangedblock               ; F9A5 20 2A FA                  *.
        lda     blockfound                      ; F9A8 AD 02 03                 ...
        rts                                     ; F9AB 60                       `

; ----------------------------------------------------------------------------
        jsr     findblock                       ; F9AC 20 72 F9                  r.
        tay                                     ; F9AF A8                       .
        lsr     temp                            ; F9B0 46 31                    F1
        bcs     bottompart                      ; F9B2 B0 12                    ..
        lsr     temp1                           ; F9B4 46 32                    F2
        bcs     rightside                       ; F9B6 B0 07                    ..
        lda     b2_cm_logo,y                    ; F9B8 B9 00 80                 ...
        sta     chrfound                        ; F9BB 8D 01 03                 ...
        rts                                     ; F9BE 60                       `

; ----------------------------------------------------------------------------
rightside:
        lda     $8100,y                         ; F9BF B9 00 81                 ...
        sta     chrfound                        ; F9C2 8D 01 03                 ...
        rts                                     ; F9C5 60                       `

; ----------------------------------------------------------------------------
bottompart:
        lsr     temp1                           ; F9C6 46 32                    F2
        bcs     rightside1                      ; F9C8 B0 07                    ..
        lda     $8200,y                         ; F9CA B9 00 82                 ...
        sta     chrfound                        ; F9CD 8D 01 03                 ...
        rts                                     ; F9D0 60                       `

; ----------------------------------------------------------------------------
rightside1:
        lda     $8300,y                         ; F9D1 B9 00 83                 ...
        sta     chrfound                        ; F9D4 8D 01 03                 ...
noblocksneeded:
        rts                                     ; F9D7 60                       `

; ----------------------------------------------------------------------------
bringonmap:
        lda     scrxl                           ; F9D8 A5 3B                    .;
        and     #$0F                            ; F9DA 29 0F                    ).
        cmp     #$0E                            ; F9DC C9 0E                    ..
        bcs     noblocksneeded                  ; F9DE B0 F7                    ..
        tay                                     ; F9E0 A8                       .
        sta     blocky                          ; F9E1 8D 04 03                 ...
        ldx     mapstrip                        ; F9E4 A6 3D                    .=
        bit     scrolldir                       ; F9E6 24 47                    $G
        bpl     @n1                           ; F9E8 10 08                    ..
        txa                                     ; F9EA 8A                       .
        clc                                     ; F9EB 18                       .
        adc     #$12                            ; F9EC 69 12                    i.
        sta     blockx                          ; F9EE 8D 03 03                 ...
        tax                                     ; F9F1 AA                       .
@n1:  stx     blockx                          ; F9F2 8E 03 03                 ...
        jsr     getblockbit                     ; F9F5 20 15 FA                  ..
        sta     address9                        ; F9F8 85 2D                    .-
        tay                                     ; F9FA A8                       .
        lda     blockrous,y                     ; F9FB B9 70 DE                 .p.
        ldy     blocky                          ; F9FE AC 04 03                 ...
        cmp     #$00                            ; FA01 C9 00                    ..
        bpl     @n3                           ; FA03 10 04                    ..
        dex                                     ; FA05 CA                       .
        jsr     getblockbit                     ; FA06 20 15 FA                  ..
@n3:  jsr     checkchangedblock1              ; FA09 20 2D FA                  -.
        lda     blockfound                      ; FA0C AD 02 03                 ...
        jsr     printblocktoscreen              ; FA0F 20 1F FB                  ..
        jmp     checkaddflamesetc               ; FA12 4C 12 DE                 L..

; ----------------------------------------------------------------------------
getblockbit:
        lda     mappointer                      ; FA15 A5 40                    .@
        clc                                     ; FA17 18                       .
        adc     times14tablelo,x                ; FA18 7D 2B F7                 }+.
        sta     address                         ; FA1B 85 1B                    ..
        lda     $41                             ; FA1D A5 41                    .A
        adc     times14tablehi,x                ; FA1F 7D 2B F8                 }+.
        sta     $1C                             ; FA22 85 1C                    ..
        lda     (address),y                     ; FA24 B1 1B                    ..
        sta     blockfound                      ; FA26 8D 02 03                 ...
        rts                                     ; FA29 60                       `

; ----------------------------------------------------------------------------
checkchangedblock:
        inc     blockx                          ; FA2A EE 03 03                 ...
checkchangedblock1:
        ldx     changedblockspointer            ; FA2D A6 52                    .R
        beq     @n3                           ; FA2F F0 23                    .#
        ldx     #$00                            ; FA31 A2 00                    ..
@n1:  lda     blockx                          ; FA33 AD 03 03                 ...
        cmp     changedblocks,x                 ; FA36 DD 33 05                 .3.
        bne     @n2                           ; FA39 D0 12                    ..
        lda     $0534,x                         ; FA3B BD 34 05                 .4.
        cmp     blocky                          ; FA3E CD 04 03                 ...
        bne     @n2                           ; FA41 D0 0A                    ..
        lda     $0535,x                         ; FA43 BD 35 05                 .5.
        sta     blockfound                      ; FA46 8D 02 03                 ...
        ldx     blockx                          ; FA49 AE 03 03                 ...
        rts                                     ; FA4C 60                       `

; ----------------------------------------------------------------------------
@n2:  inx                                     ; FA4D E8                       .
        inx                                     ; FA4E E8                       .
        inx                                     ; FA4F E8                       .
        cpx     changedblockspointer            ; FA50 E4 52                    .R
        bne     @n1                           ; FA52 D0 DF                    ..
@n3:  ldx     blockx                          ; FA54 AE 03 03                 ...
        rts                                     ; FA57 60                       `

; ----------------------------------------------------------------------------
addachangedblock:
        stx     toplevvar1                      ; FA58 86 11                    ..
        sty     toplevvar2                      ; FA5A 84 12                    ..
        sta     toplevvar3                      ; FA5C 85 13                    ..
addachangedblock1:
        lda     #$03                            ; FA5E A9 03                    ..
        ldx     changedblockspointer            ; FA60 A6 52                    .R
        beq     @n1                           ; FA62 F0 1D                    ..
        ldx     #$00                            ; FA64 A2 00                    ..
@n2:  lda     changedblocks,x                 ; FA66 BD 33 05                 .3.
        cmp     toplevvar1                      ; FA69 C5 11                    ..
        bne     @n3                           ; FA6B D0 0B                    ..
        lda     $0534,x                         ; FA6D BD 34 05                 .4.
        cmp     toplevvar2                      ; FA70 C5 12                    ..
        bne     @n3                           ; FA72 D0 04                    ..
        lda     #$00                            ; FA74 A9 00                    ..
        beq     @n1                           ; FA76 F0 09                    ..
@n3:  inx                                     ; FA78 E8                       .
        inx                                     ; FA79 E8                       .
        inx                                     ; FA7A E8                       .
        cpx     changedblockspointer            ; FA7B E4 52                    .R
        bne     @n2                           ; FA7D D0 E7                    ..
        lda     #$03                            ; FA7F A9 03                    ..
@n1:  clc                                     ; FA81 18                       .
        adc     changedblockspointer            ; FA82 65 52                    eR
        sta     changedblockspointer            ; FA84 85 52                    .R
        cmp     #$42                            ; FA86 C9 42                    .B
        bne     @n8                           ; FA88 D0 1B                    ..
        jsr     turninteron                     ; FA8A 20 77 F4                  w.
@testcrash:  php                                     ; FA8D 08                       .
        pha                                     ; FA8E 48                       H
        lda     control1                        ; FA8F A5 02                    ..
        and     #$1E                            ; FA91 29 1E                    ).
        clc                                     ; FA93 18                       .
        adc     #$01                            ; FA94 69 01                    i.
        sta     _control1                       ; FA96 8D 01 20                 .. 
        pla                                     ; FA99 68                       h
        plp                                     ; FA9A 28                       (
        lda     control1                        ; FA9B A5 02                    ..
        and     #$1E                            ; FA9D 29 1E                    ).
        sta     _control1                       ; FA9F 8D 01 20                 .. 
        jmp     @testcrash                           ; FAA2 4C 8D FA                 L..

; ----------------------------------------------------------------------------
@n8:  lda     toplevvar2                      ; FAA5 A5 12                    ..
        sta     $0534,x                         ; FAA7 9D 34 05                 .4.
        lda     toplevvar1                      ; FAAA A5 11                    ..
        sta     changedblocks,x                 ; FAAC 9D 33 05                 .3.
        lda     toplevvar3                      ; FAAF A5 13                    ..
        sta     $0535,x                         ; FAB1 9D 35 05                 .5.
        ldx     toplevvar1                      ; FAB4 A6 11                    ..
        bit     interon                         ; FAB6 24 03                    $.
        bpl     @n4                           ; FAB8 10 05                    ..
        ldy     toplevvar2                      ; FABA A4 12                    ..
        jmp     printblocktoscreencheck         ; FABC 4C 0C FB                 L..

; ----------------------------------------------------------------------------
@n4:  rts                                     ; FABF 60                       `

; ----------------------------------------------------------------------------
deleteachangedblock:
        stx     toplevvar1                      ; FAC0 86 11                    ..
        sty     toplevvar2                      ; FAC2 84 12                    ..
deleteachangedblock1:
        lda     changedblockspointer            ; FAC4 A5 52                    .R
        beq     @n4                           ; FAC6 F0 42                    .B
        ldx     #$00                            ; FAC8 A2 00                    ..
@n1:  lda     changedblocks,x                 ; FACA BD 33 05                 .3.
        cmp     toplevvar1                      ; FACD C5 11                    ..
        bne     @n2                           ; FACF D0 30                    .0
        lda     $0534,x                         ; FAD1 BD 34 05                 .4.
        cmp     toplevvar2                      ; FAD4 C5 12                    ..
        bne     @n2                           ; FAD6 D0 29                    .)
@n3:  lda     $0536,x                         ; FAD8 BD 36 05                 .6.
        sta     changedblocks,x                 ; FADB 9D 33 05                 .3.
        inx                                     ; FADE E8                       .
        cpx     changedblockspointer            ; FADF E4 52                    .R
        bne     @n3                           ; FAE1 D0 F5                    ..
        txa                                     ; FAE3 8A                       .
        clc                                     ; FAE4 18                       .
        adc     #$FD                            ; FAE5 69 FD                    i.
        sta     changedblockspointer            ; FAE7 85 52                    .R
        ldx     toplevvar1                      ; FAE9 A6 11                    ..
        lda     mappointer                      ; FAEB A5 40                    .@
        clc                                     ; FAED 18                       .
        adc     times14tablelo,x                ; FAEE 7D 2B F7                 }+.
        sta     address                         ; FAF1 85 1B                    ..
        lda     $41                             ; FAF3 A5 41                    .A
        adc     times14tablehi,x                ; FAF5 7D 2B F8                 }+.
        sta     $1C                             ; FAF8 85 1C                    ..
        ldy     toplevvar2                      ; FAFA A4 12                    ..
        lda     (address),y                     ; FAFC B1 1B                    ..
        jmp     printblocktoscreencheck         ; FAFE 4C 0C FB                 L..

; ----------------------------------------------------------------------------
@n2:  inx                                     ; FB01 E8                       .
        inx                                     ; FB02 E8                       .
        inx                                     ; FB03 E8                       .
        cpx     changedblockspointer            ; FB04 E4 52                    .R
        bne     @n1                           ; FB06 D0 C2                    ..
        ldx     toplevvar1                      ; FB08 A6 11                    ..
@n4:  rts                                     ; FB0A 60                       `

; ----------------------------------------------------------------------------
blocknotonscreen:
        rts                                     ; FB0B 60                       `

; ----------------------------------------------------------------------------
printblocktoscreencheck:
        stx     blockx                          ; FB0C 8E 03 03                 ...
        sty     blocky                          ; FB0F 8C 04 03                 ...
        sta     blockfound                      ; FB12 8D 02 03                 ...
        txa                                     ; FB15 8A                       .
        sec                                     ; FB16 38                       8
        sbc     mapstrip                        ; FB17 E5 3D                    .=
        bmi     blocknotonscreen                ; FB19 30 F0                    0.
        cmp     #$13                            ; FB1B C9 13                    ..
        bcs     blocknotonscreen                ; FB1D B0 EC                    ..
printblocktoscreen:
        ldy     blocky                          ; FB1F AC 04 03                 ...
        lda     blockx                          ; FB22 AD 03 03                 ...
        lsr     a                               ; FB25 4A                       J
        and     #$0F                            ; FB26 29 0F                    ).
        cmp     #$08                            ; FB28 C9 08                    ..
        bcc     @n1                           ; FB2A 90 03                    ..
        clc                                     ; FB2C 18                       .
        adc     #$30                            ; FB2D 69 30                    i0
@n1:  clc                                     ; FB2F 18                       .
        adc     attrytable,y                    ; FB30 79 EB FB                 y..
        sta     attripointer                    ; FB33 85 3E                    .>
@n12:  ldx     blockpointer                    ; FB35 A6 0F                    ..
        cpx     #$6E                            ; FB37 E0 6E                    .n
        bne     @n11                           ; FB39 D0 13                    ..
        lda     #$00                            ; FB3B A9 00                    ..
        sta     filledblockbuffer               ; FB3D 8D 11 05                 ...
        asl     flyflag                         ; FB40 06 0B                    ..
@fly:  bit     flyflag                         ; FB42 24 0B                    $.
        bpl     @fly                           ; FB44 10 FC                    ..
        lda     #$01                            ; FB46 A9 01                    ..
        sta     filledblockbuffer               ; FB48 8D 11 05                 ...
        jmp     @n12                           ; FB4B 4C 35 FB                 L5.

; ----------------------------------------------------------------------------
@n11:
LFB50           := * + 2
        ldy     blockfound                      ; FB4E AC 02 03                 ...
        lda     b2_cm_logo,y                    ; FB51 B9 00 80                 ...
        sta     $0172,x                         ; FB54 9D 72 01                 .r.
        lda     $8100,y                         ; FB57 B9 00 81                 ...
        sta     $0173,x                         ; FB5A 9D 73 01                 .s.
        lda     $8200,y                         ; FB5D B9 00 82                 ...
        sta     $0176,x                         ; FB60 9D 76 01                 .v.
        lda     $8300,y                         ; FB63 B9 00 83                 ...
        sta     $0177,x                         ; FB66 9D 77 01                 .w.
        lda     $8400,y                         ; FB69 B9 00 84                 ...
        sta     blockattri                      ; FB6C 85 3F                    .?
        lda     blockx                          ; FB6E AD 03 03                 ...
        lsr     a                               ; FB71 4A                       J
        lda     blocky                          ; FB72 AD 04 03                 ...
        rol     a                               ; FB75 2A                       *
        and     #$03                            ; FB76 29 03                    ).
        tay                                     ; FB78 A8                       .
        clc                                     ; FB79 18                       .
        adc     blockattri                      ; FB7A 65 3F                    e?
        sta     blockattri                      ; FB7C 85 3F                    .?
        ldx     attripointer                    ; FB7E A6 3E                    .>
        lda     attributes,x                    ; FB80 BD 38 03                 .8.
        and     attributemasks,y                ; FB83 39 69 F6                 9i.
        ldy     blockattri                      ; FB86 A4 3F                    .?
        ora     attributeands,y                 ; FB88 19 6D F6                 .m.
        sta     attributes,x                    ; FB8B 9D 38 03                 .8.
        ldx     blockpointer                    ; FB8E A6 0F                    ..
        sta     $017A,x                         ; FB90 9D 7A 01                 .z.
        txa                                     ; FB93 8A                       .
        clc                                     ; FB94 18                       .
        adc     #$0B                            ; FB95 69 0B                    i.
        sta     blockpointer                    ; FB97 85 0F                    ..
        lda     blockx                          ; FB99 AD 03 03                 ...
        and     #$1F                            ; FB9C 29 1F                    ).
        asl     a                               ; FB9E 0A                       .
        sta     temp                            ; FB9F 85 31                    .1
        and     #$20                            ; FBA1 29 20                    ) 
        beq     @n3                           ; FBA3 F0 03                    ..
        clc                                     ; FBA5 18                       .
        adc     #$E4                            ; FBA6 69 E4                    i.
@n3:  sta     temp1                           ; FBA8 85 32                    .2
        ldy     blocky                          ; FBAA AC 04 03                 ...
        lda     temp                            ; FBAD A5 31                    .1
        and     #$1F                            ; FBAF 29 1F                    ).
        clc                                     ; FBB1 18                       .
        adc     times32tablelo,y                ; FBB2 79 F2 C0                 y..
        sta     $0171,x                         ; FBB5 9D 71 01                 .q.
        lda     temp1                           ; FBB8 A5 32                    .2
        adc     times32tablehi,y                ; FBBA 79 00 C1                 y..
        sta     blockbuffer,x                   ; FBBD 9D 70 01                 .p.
        lda     $0171,x                         ; FBC0 BD 71 01                 .q.
        clc                                     ; FBC3 18                       .
        adc     #$20                            ; FBC4 69 20                    i 
        sta     $0175,x                         ; FBC6 9D 75 01                 .u.
        lda     blockbuffer,x                   ; FBC9 BD 70 01                 .p.
        adc     #$00                            ; FBCC 69 00                    i.
        sta     $0174,x                         ; FBCE 9D 74 01                 .t.
        ldy     #$23                            ; FBD1 A0 23                    .#
        lda     attripointer                    ; FBD3 A5 3E                    .>
        cmp     #$38                            ; FBD5 C9 38                    .8
        bcc     @n1                           ; FBD7 90 07                    ..
        sec                                     ; FBD9 38                       8
        sbc     #$38                            ; FBDA E9 38                    .8
        iny                                     ; FBDC C8                       .
        iny                                     ; FBDD C8                       .
        iny                                     ; FBDE C8                       .
        iny                                     ; FBDF C8                       .
@n1:  clc                                     ; FBE0 18                       .
        adc     #$C0                            ; FBE1 69 C0                    i.
        sta     $0179,x                         ; FBE3 9D 79 01                 .y.
        tya                                     ; FBE6 98                       .
        sta     $0178,x                         ; FBE7 9D 78 01                 .x.
        rts                                     ; FBEA 60                       `

; ----------------------------------------------------------------------------
attrytable:
        .byte   $00,$00,$08,$08,$10,$10,$18,$18 ; FBEB 00 00 08 08 10 10 18 18  ........
        .byte   $20,$20,$28,$28,$30,$30,$38,$38 ; FBF3 20 20 28 28 30 30 38 38    ((0088
; ----------------------------------------------------------------------------
gointonewmap:
        lda     mapno                           ; FBFB A5 42                    .B
        asl     a                               ; FBFD 0A                       .
        asl     a                               ; FBFE 0A                       .
        clc                                     ; FBFF 18                       .
        adc     mapno                           ; FC00 65 42                    eB
        clc                                     ; FC02 18                       .
        adc     mapno                           ; FC03 65 42                    eB
        tax                                     ; FC05 AA                       .
        lda     mapinfo,x                       ; FC06 BD 95 FD                 ...
        sta     mappointer                      ; FC09 85 40                    .@
        lda     LFD96,x                         ; FC0B BD 96 FD                 ...
        sta     $41                             ; FC0E 85 41                    .A
        stx     temp1                           ; FC10 86 32                    .2
        lda     interon                         ; FC12 A5 03                    ..
        beq     internoton                      ; FC14 F0 03                    ..
        jsr     turninterofffade                ; FC16 20 94 F4                  ..
internoton:
        jsr     setfade                         ; FC19 20 11 C5                  ..
        ldx     temp1                           ; FC1C A6 32                    .2
        ldy     #$00                            ; FC1E A0 00                    ..
        lda     minmap                          ; FC20 AD 05 03                 ...
        cmp     LFD97,x                         ; FC23 DD 97 FD                 ...
        bcs     @n9                           ; FC26 B0 02                    ..
        ldy     #$FF                            ; FC28 A0 FF                    ..
@n9:  sec                                     ; FC2A 38                       8
        sbc     LFD97,x                         ; FC2B FD 97 FD                 ...
        sty     $1C                             ; FC2E 84 1C                    ..
        asl     a                               ; FC30 0A                       .
        rol     $1C                             ; FC31 26 1C                    &.
        asl     a                               ; FC33 0A                       .
        rol     $1C                             ; FC34 26 1C                    &.
        asl     a                               ; FC36 0A                       .
        rol     $1C                             ; FC37 26 1C                    &.
        asl     a                               ; FC39 0A                       .
        rol     $1C                             ; FC3A 26 1C                    &.
        clc                                     ; FC3C 18                       .
        adc     robinxl                         ; FC3D 6D 08 03                 m..
        sta     robinxl                         ; FC40 8D 08 03                 ...
        lda     $1C                             ; FC43 A5 1C                    ..
        adc     robinxh                         ; FC45 6D 09 03                 m..
        sta     robinxh                         ; FC48 8D 09 03                 ...
        lda     LFD97,x                         ; FC4B BD 97 FD                 ...
        sta     minmap                          ; FC4E 8D 05 03                 ...
        lda     LFD98,x                         ; FC51 BD 98 FD                 ...
        clc                                     ; FC54 18                       .
        adc     #$F0                            ; FC55 69 F0                    i.
        sta     maxmap                          ; FC57 8D 06 03                 ...
        lda     robinxl                         ; FC5A AD 08 03                 ...
        clc                                     ; FC5D 18                       .
        adc     #$20                            ; FC5E 69 20                    i 
        sta     scrxl                           ; FC60 85 3B                    .;
        lda     robinxh                         ; FC62 AD 09 03                 ...
        adc     #$01                            ; FC65 69 01                    i.
        sta     scrxh                           ; FC67 85 3C                    .<
        stx     temp                            ; FC69 86 31                    .1
        ldy     LFD99,x                         ; FC6B BC 99 FD                 ...
        ldx     #$00                            ; FC6E A2 00                    ..
@n2:  lda     $861E,y                         ; FC70 B9 1E 86                 ...
        sta     fadecolours,x                   ; FC73 9D 13 05                 ...
        lda     $8696,x                         ; FC76 BD 96 86                 ...
        sta     $0523,x                         ; FC79 9D 23 05                 .#.
        iny                                     ; FC7C C8                       .
        inx                                     ; FC7D E8                       .
        cpx     #$10                            ; FC7E E0 10                    ..
        bne     @n2                           ; FC80 D0 EE                    ..
        ldx     temp                            ; FC82 A6 31                    .1
        lda     LFD9A,x                         ; FC84 BD 9A FD                 ...
        tax                                     ; FC87 AA                       .
makeupchrset:
        stx     hipos                           ; FC88 8E 2C 03                 .,.
        lda     $860E,x                         ; FC8B BD 0E 86                 ...
        bmi     nomorechrsformap                ; FC8E 30 0A                    0.
        jsr     copyblockofcompactedchrs        ; FC90 20 E0 F1                  ..
        ldx     hipos                           ; FC93 AE 2C 03                 .,.
        inx                                     ; FC96 E8                       .
        jmp     makeupchrset                    ; FC97 4C 88 FC                 L..

; ----------------------------------------------------------------------------
nomorechrsformap:
        lda     #$00                            ; FC9A A9 00                    ..
        sta     counter                         ; FC9C 85 10                    ..
        sta     animatedoor                     ; FC9E 8D 28 03                 .(.
        sta     changedblockspointer            ; FCA1 85 52                    .R
        jsr     resetdoorsintomap               ; FCA3 20 D4 D5                  ..
        jsr     doallsecrets                    ; FCA6 20 59 DC                  Y.
        jsr     resetextravars                  ; FCA9 20 C8 D3                  ..
        jsr     storeoutoldrobin                ; FCAC 20 37 CE                  7.
        jsr     setxscroll                      ; FCAF 20 7D F6                  }.
        lda     robinxl                         ; FCB2 AD 08 03                 ...
        sec                                     ; FCB5 38                       8
        sbc     scrxl                           ; FCB6 E5 3B                    .;
        sta     robinonscrx                     ; FCB8 8D 0B 03                 ...
        ldx     mapno                           ; FCBB A6 42                    .B
        lda     tuneforstrip,x                  ; FCBD BD E3 FD                 ...
        cmp     $05F0                           ; FCC0 CD F0 05                 ...
        beq     playingsametune                 ; FCC3 F0 03                    ..
        jsr     starttune                       ; FCC5 20 14 F4                  ..
playingsametune:
        lda     #$E3                            ; FCC8 A9 E3                    ..
LFCCB           := * + 1
        sta     y_scroll                        ; FCCA 85 09                    ..
        jmp     turninteron                     ; FCCC 4C 77 F4                 Lw.

; ----------------------------------------------------------------------------
checkoffscreen:
        ldx     mapno                           ; FCCF A6 42                    .B
        lda     $8600,x                         ; FCD1 BD 00 86                 ...
        sta     temp                            ; FCD4 85 31                    .1
        lda     killed                          ; FCD6 AD 23 03                 .#.
        bne     @n1                           ; FCD9 D0 14                    ..
        lda     robiny                          ; FCDB AD 0A 03                 ...
        sta     temp8                           ; FCDE 85 39                    .9
        cmp     #$20                            ; FCE0 C9 20                    . 
        bcc     goingofftop                     ; FCE2 90 0C                    ..
        cmp     #$D8                            ; FCE4 C9 D8                    ..
        bcc     @n1                           ; FCE6 90 07                    ..
        cmp     #$F0                            ; FCE8 C9 F0                    ..
        bcs     goingoffbottom                  ; FCEA B0 11                    ..
        jsr     setonladdervars                 ; FCEC 20 1D CA                  ..
@n1:  rts                                     ; FCEF 60                       `

; ----------------------------------------------------------------------------
goingofftop:
        lda     robiny                          ; FCF0 AD 0A 03                 ...
        clc                                     ; FCF3 18                       .
        adc     #$D0                            ; FCF4 69 D0                    i.
        sta     robiny                          ; FCF6 8D 0A 03                 ...
        inc     temp                            ; FCF9 E6 31                    .1
        bne     changingscreen                  ; FCFB D0 0B                    ..
goingoffbottom:
        lda     robiny                          ; FCFD AD 0A 03                 ...
        sec                                     ; FD00 38                       8
        sbc     #$D0                            ; FD01 E9 D0                    ..
        sta     robiny                          ; FD03 8D 0A 03                 ...
        dec     temp                            ; FD06 C6 31                    .1
changingscreen:
        lda     mapno                           ; FD08 A5 42                    .B
        asl     a                               ; FD0A 0A                       .
        asl     a                               ; FD0B 0A                       .
        clc                                     ; FD0C 18                       .
        adc     mapno                           ; FD0D 65 42                    eB
        clc                                     ; FD0F 18                       .
        adc     mapno                           ; FD10 65 42                    eB
        tay                                     ; FD12 A8                       .
        ldx     LFD97,y                         ; FD13 BE 97 FD                 ...
        lda     robinxl                         ; FD16 AD 08 03                 ...
        clc                                     ; FD19 18                       .
        adc     times16lo,x                     ; FD1A 7D 1A C0                 }..
        sta     address                         ; FD1D 85 1B                    ..
        lda     robinxh                         ; FD1F AD 09 03                 ...
        adc     times16hi,x                     ; FD22 7D 1E C1                 }..
        sta     $1C                             ; FD25 85 1C                    ..
        ldx     #$0C                            ; FD27 A2 0C                    ..
        stx     temp9                           ; FD29 86 3A                    .:
doeachmap:
        lda     $8600,x                         ; FD2B BD 00 86                 ...
        cmp     temp                            ; FD2E C5 31                    .1
        beq     possiblemap                     ; FD30 F0 1A                    ..
trynextmap:
        dec     temp9                           ; FD32 C6 3A                    .:
        ldx     temp9                           ; FD34 A6 3A                    .:
        bpl     doeachmap                       ; FD36 10 F3                    ..
        lda     temp8                           ; FD38 A5 39                    .9
        cmp     #$08                            ; FD3A C9 08                    ..
        bcs     @n1                           ; FD3C B0 04                    ..
        lda     #$08                            ; FD3E A9 08                    ..
        bne     @n2                           ; FD40 D0 06                    ..
@n1:  cmp     #$F8                            ; FD42 C9 F8                    ..
        bcc     @n2                           ; FD44 90 02                    ..
        lda     $F7                             ; FD46 A5 F7                    ..
@n2:  sta     robiny                          ; FD48 8D 0A 03                 ...
        rts                                     ; FD4B 60                       `

; ----------------------------------------------------------------------------
possiblemap:
        txa                                     ; FD4C 8A                       .
        asl     a                               ; FD4D 0A                       .
        asl     a                               ; FD4E 0A                       .
        clc                                     ; FD4F 18                       .
        adc     temp9                           ; FD50 65 3A                    e:
        clc                                     ; FD52 18                       .
        adc     temp9                           ; FD53 65 3A                    e:
        tay                                     ; FD55 A8                       .
        ldx     LFD97,y                         ; FD56 BE 97 FD                 ...
        lda     times16hi,x                     ; FD59 BD 1E C1                 ...
        cmp     $1C                             ; FD5C C5 1C                    ..
        bne     @n1                           ; FD5E D0 05                    ..
        lda     times16lo,x                     ; FD60 BD 1A C0                 ...
        cmp     address                         ; FD63 C5 1B                    ..
@n1:  bcs     trynextmap                      ; FD65 B0 CB                    ..
        lda     LFD97,y                         ; FD67 B9 97 FD                 ...
        clc                                     ; FD6A 18                       .
        adc     LFD98,y                         ; FD6B 79 98 FD                 y..
        tax                                     ; FD6E AA                       .
        lda     times16hi,x                     ; FD6F BD 1E C1                 ...
        cmp     $1C                             ; FD72 C5 1C                    ..
        bne     @n2                           ; FD74 D0 05                    ..
        lda     times16lo,x                     ; FD76 BD 1A C0                 ...
        cmp     address                         ; FD79 C5 1B                    ..
@n2:  bcc     trynextmap                      ; FD7B 90 B5                    ..
        jsr     setonladdervars                 ; FD7D 20 1D CA                  ..
        lda     #$00                            ; FD80 A9 00                    ..
        sta     $057D                           ; FD82 8D 7D 05                 .}.
        sta     $057E                           ; FD85 8D 7E 05                 .~.
        sta     $057F                           ; FD88 8D 7F 05                 ...
        sta     $0580                           ; FD8B 8D 80 05                 ...
        lda     temp9                           ; FD8E A5 3A                    .:
        sta     mapno                           ; FD90 85 42                    .B
        jmp     gointonewmap                    ; FD92 4C FB FB                 L..

; mappointer ,offset,width,paletteused,chrsused
; ----------------------------------------------------------------------------
mapinfo:.byte   $98                             ; FD95 98                       .
LFD96:  .byte   $86                             ; FD96 86                       .
LFD97:  .byte   $58                             ; FD97 58                       X
LFD98:  .byte   $48                             ; FD98 48                       H
LFD99:  .byte   $20                             ; FD99 20                        
LFD9A:  .byte   $00,$88,$8A,$20,$20,$10,$00,$48 ; FD9A 00 88 8A 20 20 10 00 48  ...  ..H
        .byte   $8C,$50,$10,$10,$00,$28,$8D,$80 ; FDA2 8C 50 10 10 00 28 8D 80  .P...(..
        .byte   $40,$10,$00,$A8,$90,$00,$D0,$30 ; FDAA 40 10 00 A8 90 00 D0 30  @......0
        .byte   $00,$08,$9C,$00,$B0,$00,$03,$A8 ; FDB2 00 08 9C 00 B0 00 03 A8  ........
        .byte   $A5,$00,$B0,$40,$07,$48,$AF,$10 ; FDBA A5 00 B0 40 07 48 AF 10  ...@.H..
        .byte   $A0,$60,$0B,$08,$B8,$10,$28,$50 ; FDC2 A0 60 0B 08 B8 10 28 50  .`....(P
        .byte   $07,$38,$BA,$90,$20,$00,$0B,$00 ; FDCA 07 38 BA 90 20 00 0B 00  .8.. ...
        .byte   $BC,$18,$18,$00,$0B,$50,$BD,$58 ; FDD2 BC 18 18 00 0B 50 BD 58  .....P.X
        .byte   $20,$60,$07,$10,$BF,$6A,$10,$00 ; FDDA 20 60 07 10 BF 6A 10 00   `...j..
        .byte   $0B                             ; FDE2 0B                       .
tuneforstrip:
        .byte   $06,$08,$08,$08,$06,$07,$09,$09 ; FDE3 06 08 08 08 06 07 09 09  ........
        .byte   $07,$07,$08,$08,$08             ; FDEB 07 07 08 08 08           .....
; ----------------------------------------------------------------------------
        .byte   $02                             ; FDF0 02                       .
        ora     #$11                            ; FDF1 09 11                    ..
        .byte   $D3                             ; FDF3 D3                       .
        cmp     ($85,x)                         ; FDF4 C1 85                    ..
        .byte   $1C                             ; FDF6 1C                       .
        ldx     #$0C                            ; FDF7 A2 0C                    ..
        stx     temp9                           ; FDF9 86 3A                    .:
@n1:  lda     $8600,x                         ; FDFB BD 00 86                 ...
        cmp     temp                            ; FDFE C5 31                    .1
        beq     @n1c                           ; FE00 F0 1A                    ..
@n2:  dec     temp9                           ; FE02 C6 3A                    .:
        ldx     temp9                           ; FE04 A6 3A                    .:
        bpl     @n1                           ; FE06 10 F3                    ..
        lda     temp8                           ; FE08 A5 39                    .9
        cmp     #$08                            ; FE0A C9 08                    ..
        bcs     @n1b                           ; FE0C B0 04                    ..
        lda     #$08                            ; FE0E A9 08                    ..
        bne     @n2b                           ; FE10 D0 06                    ..
@n1b:  cmp     #$F8                            ; FE12 C9 F8                    ..
        bcc     @n2b                           ; FE14 90 02                    ..
        lda     $F7                             ; FE16 A5 F7                    ..
@n2b:  sta     robiny                          ; FE18 8D 0A 03                 ...
        rts                                     ; FE1B 60                       `

; ----------------------------------------------------------------------------
@n1c:  txa                                     ; FE1C 8A                       .
        asl     a                               ; FE1D 0A                       .
        asl     a                               ; FE1E 0A                       .
        clc                                     ; FE1F 18                       .
        adc     temp9                           ; FE20 65 3A                    e:
        clc                                     ; FE22 18                       .
        adc     temp9                           ; FE23 65 3A                    e:
        tay                                     ; FE25 A8                       .
        ldx     LFE67,y                         ; FE26 BE 67 FE                 .g.
        lda     times16hi,x                     ; FE29 BD 1E C1                 ...
        cmp     $1C                             ; FE2C C5 1C                    ..
        bne     @n2c                           ; FE2E D0 05                    ..
        lda     times16lo,x                     ; FE30 BD 1A C0                 ...
        cmp     address                         ; FE33 C5 1B                    ..
@n2c:  bcs     @n2                           ; FE35 B0 CB                    ..
        lda     LFE67,y                         ; FE37 B9 67 FE                 .g.
        clc                                     ; FE3A 18                       .
        adc     LFE68,y                         ; FE3B 79 68 FE                 yh.
        tax                                     ; FE3E AA                       .
        lda     times16hi,x                     ; FE3F BD 1E C1                 ...
        cmp     $1C                             ; FE42 C5 1C                    ..
        bne     @n2d                           ; FE44 D0 05                    ..
        lda     times16lo,x                     ; FE46 BD 1A C0                 ...
        cmp     address                         ; FE49 C5 1B                    ..
@n2d:  bcc     @n2                           ; FE4B 90 B5                    ..
        jsr     dofiring_n2                           ; FE4D 20 8B CA                  ..
        lda     #$00                            ; FE50 A9 00                    ..
        sta     $057D                           ; FE52 8D 7D 05                 .}.
        sta     $057E                           ; FE55 8D 7E 05                 .~.
        sta     $057F                           ; FE58 8D 7F 05                 ...
        sta     $0580                           ; FE5B 8D 80 05                 ...
        lda     temp9                           ; FE5E A5 3A                    .:
        sta     mapno                           ; FE60 85 42                    .B
        jmp     LFCCB                           ; FE62 4C CB FC                 L..

; ----------------------------------------------------------------------------
        .byte   $98,$86                         ; FE65 98 86                    ..
LFE67:  .byte   $58                             ; FE67 58                       X
LFE68:  .byte   $48,$20,$00,$88,$8A,$20,$20,$10 ; FE68 48 20 00 88 8A 20 20 10  H ...  .
        .byte   $00,$48,$8C,$50,$10,$10,$00,$28 ; FE70 00 48 8C 50 10 10 00 28  .H.P...(
        .byte   $8D,$80,$40,$10,$00,$A8,$90,$00 ; FE78 8D 80 40 10 00 A8 90 00  ..@.....
        .byte   $D0,$30,$00,$08,$9C,$00,$B0,$00 ; FE80 D0 30 00 08 9C 00 B0 00  .0......
        .byte   $03,$A8,$A5,$00,$B0,$40,$07,$48 ; FE88 03 A8 A5 00 B0 40 07 48  .....@.H
        .byte   $AF,$10,$A0,$60,$0B,$08,$B8,$10 ; FE90 AF 10 A0 60 0B 08 B8 10  ...`....
        .byte   $28,$50,$07,$38,$BA,$90,$20,$00 ; FE98 28 50 07 38 BA 90 20 00  (P.8.. .
        .byte   $0B,$00,$BC,$18,$18,$00,$0B,$50 ; FEA0 0B 00 BC 18 18 00 0B 50  .......P
        .byte   $BD,$58,$20,$60,$07,$10,$BF,$6A ; FEA8 BD 58 20 60 07 10 BF 6A  .X `...j
        .byte   $10,$00,$0B,$06,$08,$08,$08,$06 ; FEB0 10 00 0B 06 08 08 08 06  ........
        .byte   $07,$09,$09,$07,$07,$08,$08,$08 ; FEB8 07 09 09 07 07 08 08 08  ........
        .byte   $01,$39,$11,$03,$01,$35,$10,$FF ; FEC0 01 39 11 03 01 35 10 FF  .9...5..
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FEC8 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FED0 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FED8 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FEE0 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FEE8 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FEF0 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$FF,$FF,$FF,$FF,$FF,$FF,$7F ; FEF8 00 FF FF FF FF FF FF 7F  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF00 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF08 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF10 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF18 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF20 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF28 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF30 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF38 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF40 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF48 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF50 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF58 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF60 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF68 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF70 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF78 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF80 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF88 00 00 00 00 00 00 00 00  ........
        .byte   $01,$00,$00,$00,$00,$00,$00,$00 ; FF90 01 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FF98 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFA0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFA8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFB0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFB8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFC0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFC8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFD0 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00,$00,$00,$00,$00 ; FFD8 00 00 00 00 00 00 00 00  ........
        .byte   $00,$00,$00,$00                 ; FFE0 00 00 00 00              ....
; ----------------------------------------------------------------------------
        php                                     ; FFE4 08                       .
        sec                                     ; FFE5 38                       8
        bcs     changebank_n2                           ; FFE6 B0 07                    ..
        pla                                     ; FFE8 68                       h
        plp                                     ; FFE9 28                       (
        rts                                     ; FFEA 60                       `

; ----------------------------------------------------------------------------
        nop                                     ; FFEB EA                       .
        nop                                     ; FFEC EA                       .
; ==========================================================================
; ENDCODE.ROU
; ==========================================================================
changebank_n1:  php                                     ; FFED 08                       .
        clc                                     ; FFEE 18                       .
changebank_n2:
LFFF0           := * + 1
        dec     lock_b                           ; FFEF CE 03 C0                 ...
        lda     lock_a                           ; FFF2 AD 02 C0                 ...
        and     #$02                            ; FFF5 29 02                    ).
        beq     changebank_n1                           ; FFF7 F0 F4                    ..
cm_irq: rti                                     ; FFF9 40                       @

; ----------------------------------------------------------------------------
vec_nmi:.word   $C007                           ; FFFA 07 C0                    ..
vec_reset:
        .word   $C284                           ; FFFC 84 C2                    ..
vec_irq:.byte   $F9                             ; FFFE F9                       .
        .byte   $FF                             ; FFFF FF                       .

; End of "BANK_3" segment
; ----------------------------------------------------------------------------
.code

