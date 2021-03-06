;***********************************
;** OCCUPIED REGS.: NONE          **
;** (C) 1989 STalin OF F.F.       **
;***********************************

EXEC=0           ;-1 FOR EXECUTABLE

BWIDTH=36        ;640 PIXELS
BHEIGTH=12       ;192 PIXELS
L=(8*BWIDTH)*(16*BHEIGTH)    ;BYTE LENGTH OF ONE SCREEN
NOSPR=8          ;NR OF GUBBE ANIMATIONS
NOBALLS=6


 IFEQ EXEC,-1
SCR1=$70000
 ELSE
SCR1=$F0000
 ENDIF
SCR2=SCR1+$8000

 JMP START

BUFF:             ;SCROLL TEXT BUFFER
 DS.B 2500,0

VBL:
 MOVE.W #$000,$FF8240
 MOVE.B SCREENS+1,$FF8201
 MOVE.B SCREENS+2,$FF8203
 ADDQ.W #1,CLOCK
 ST SYNCF

 MOVEM.L D0-D7/A0-A1,-(SP)
   LEA PAL3(PC),A0
   LEA $FF8240,A1
   MOVEM.L (A0),D0-D7
   MOVEM.L D0-D7,(A1)

   JSR MUSIC+$8A
 MOVEM.L (SP)+,D0-D7/A0-A1

 CLR.B $FFFA1B
 MOVE.B #40,$FFFA21
 MOVE.B #8,$FFFA1B
 RTE
SYNCF: DC.B 0,0

VBL2:
 MOVE.B #2,$FF820A ;50 HZ
 MOVE.L #VBL,$70
 RTE


MAIN:
 TST.B SYNCF
 BEQ.S MAIN
 CLR.B SYNCF
; MOVE.W CLOCK,D0
;SYNC:
; CMP.W CLOCK,D0
; BEQ.S SYNC

 JSR COLORS(PC)
 JSR SCROLLUPDAT(PC)
   JSR SLACKBALLS(PC)  ;
   JSR BALLS(PC)       ;
 JSR GUBBE(PC)
 JSR FF(PC)
 JSR TEXTSCROLL(PC)
 JSR UPSCROLL(PC)
 JSR SMALLSCROLL(PC)
 JSR REFLEX(PC)
; JSR REFANIM(PC)
; JSR CLEARDOTS
; JSR CALCDOTS(PC)
; JSR DOTS(PC)
 JSR CONTROL(PC)

 MOVE.L SCREENS,D0
 MOVE.L SCREENS+4,D1
 EXG.L D0,D1
 MOVE.L D0,SCREENS
 MOVE.L D1,SCREENS+4

 IFEQ EXEC,0
   CMP.B #$66,$FFFC02
   BEQ EXIT
   MOVE.W #$777,$FF8240
 ENDIF
 BRA MAIN


;RASTER0:
; SUBQ.B #1,RCNT
; BEQ.S RASTER1
;RS0PEK:
; MOVE.W COLORS,$FF8240
; ADDQ.L #2,RS0PEK+2
; BCLR #0,$FFFA0F
; RTE
;RCNT:
; DC.B 10,0

RASTER1:
 MOVEM.L D0-D7/A0,-(SP)
   LEA PAL(PC),A0
   MOVEM.L (A0),D0-D7
   LEA $FF8240,A0
   MOVEM.L D0-D7,(A0)
 MOVEM.L (SP)+,D0-D7/A0

; MOVE.B #10,RCNT
; MOVE.L #COLORS,RS0PEK+2

 MOVE.L #RASTER2,$120
 CLR.B $FFFA1B
 MOVE.B #118,$FFFA21
 MOVE.B #8,$FFFA1B
 BCLR #0,$FFFA0F
 RTE


RASTER2:
 MOVEM.L D0-D7/A0,-(SP)
   LEA PAL2(PC),A0
   MOVEM.L (A0),D0-D7
   LEA $FF8240,A0
   MOVEM.L D0-D7,(A0)
 MOVEM.L (SP)+,D0-D7/A0
 MOVE.L #RASTER1,$120
 BCLR #0,$FFFA0F
 RTE


COLORS:
 SUBQ.B #1,CCNT
 BNE.S COL1
 MOVE.B #3,CCNT
CPEK1:
 MOVE.W CTAB,D0
 BNE.S COL2
   MOVE.L #CTAB,CPEK1+2
   MOVE.W CTAB(PC),D0
COL2:
 ADDQ.L #2,CPEK1+2
 MOVE.W D0,PAL3+16
COL1:
 RTS
CCNT:
 DC.B 3,0
CTAB:
 DC.W $444,$555,$666,$777,$777,$777,$777,$666,$555,$444
 DC.W $444,$555,$666,$777,$777,$777,$777,$666,$555,$444
 DC.W $440,$550,$660,$770,$770,$770,$770,$660,$550,$440
 DC.W $440,$550,$660,$770,$770,$770,$770,$660,$550,$440
 DC.W 0

FF:
 MOVE.L SCREENS(PC),A3
 ADD.W #160*44+24,A3

 MOVE.L A3,A1
FFPEK1:
 MOVE.W FFY,D0
 BNE.S FF1
   MOVE.L #FFY,FFPEK1+2
   MOVE.W FFY(PC),D0
FF1:
 ADDQ.L #2,FFPEK1+2
 ADD.W D0,A1

 MOVEQ #0,D0
FFPEK3:
 MOVE.B FFX,D0
 BNE.S FF3
   MOVE.L #FFX,FFPEK3+2
   MOVE.B FFX(PC),D0
FF3:
 ADDQ.L #1,FFPEK3+2
 JSR ONEF(PC)


 MOVE.L A3,A1
FFPEK2:
 MOVE.W FFY+20,D0
 BNE.S FF2
   MOVE.L #FFY,FFPEK2+2
   MOVE.W FFY(PC),D0
FF2:
 ADDQ.L #2,FFPEK2+2
 ADD.W D0,A1

 MOVEQ #0,D0
FFPEK4:
 MOVE.B FFX+10,D0
 BNE.S FF4
   MOVE.L #FFX,FFPEK4+2
   MOVE.B FFX(PC),D0
FF4:
 ADDQ.L #1,FFPEK4+2
 JSR ONEF(PC)

 RTS

FADD:
 DC.W 0,1152,1152*2,1152*3,1152*4,1152*5,1152*6,1152*7,1152*8
 DC.W 1152*9,1152*10,1152*11,1152*12,1152*13,1152*14,1152*15
ONEF:
 LEA FFGRAF,A0
 MOVE.W D0,D1
 AND.B #%11110000,D0
 LSR.W #1,D0
 ADD.W D0,A1
 AND.W #15,D1
 LSL.W #1,D1         ;*2
 ADDA.W FADD(PC,D1.W),A0
 LEA 768(A0),A2

L@=0
N@=0
 REPEAT
   MOVEM.L L@(A1),D0-D5
   AND.L (A2),D0
   OR.L (A0)+,D0
   AND.L (A2)+,D1
   OR.L (A0)+,D1

   AND.L (A2),D2
   OR.L (A0)+,D2
   AND.L (A2)+,D3
   OR.L (A0)+,D3

   AND.L (A2),D4
   OR.L (A0)+,D4
   AND.L (A2)+,D5
   OR.L (A0)+,D5
   MOVEM.L D0-D5,L@(A1)
N@=N@+1
L@=L@+160
 UNTILEQ N@,32
 RTS



REFLEX:
 LEA REFGRAF,A5
 MOVE.L SCREENS(PC),A1
RPEK1:   ;PEK!
 LEA REFSIN,A4

N@=0
L@=6
 REPEAT
   LEA N@*40(A5),A0
   ADD.W (A4)+,A0
   MOVEM.W (A0)+,D0-D7/A2-A3
   MOVE.W D0,L@(A1)
   MOVE.W D1,L@+8(A1)
   MOVE.W D2,L@+16(A1)
   MOVE.W D3,L@+24(A1)
   MOVE.W D4,L@+32(A1)
   MOVE.W D5,L@+40(A1)
   MOVE.W D6,L@+48(A1)
   MOVE.W D7,L@+56(A1)
   MOVE.W A2,L@+64(A1)
   MOVE.W A3,L@+72(A1)

   MOVEM.W (A0),D0-D7/A2-A3
   MOVE.W D0,L@+80(A1)
   MOVE.W D1,L@+88(A1)
   MOVE.W D2,L@+96(A1)
   MOVE.W D3,L@+104(A1)
   MOVE.W D4,L@+112(A1)
   MOVE.W D5,L@+120(A1)
   MOVE.W D6,L@+128(A1)
   MOVE.W D7,L@+136(A1)
   MOVE.W A2,L@+144(A1)
   MOVE.W A3,L@+152(A1)
L@=L@+160
N@=N@+1
 UNTILEQ N@,40
 CMP.W #-1,(A4)
 BNE.S REF1
   MOVE.L #REFSIN,RPEK1+2
REF1:
 ADDQ.L #2,RPEK1+2
 RTS



;REFANIM:
; LEA $FC0000,A0
; MOVE.L SCREENS(PC),A1
;N@=0
;L@=0
; REPEAT
;   MOVEM.L (A0)+,D0-D3
;   MOVEM.L D0-D3,L@(A1)
;   MOVEM.L D0-D3,L@+144(A1)
;L@=L@+160
;N@=N@+1
; UNTILEQ N@,32
; RTS

;CLEARDOTS:
; MOVE.L SCREENS+4(PC),A0
; BTST #1,CLOCK+1
; BNE.S CDT1
;   ADD.W #160,A0
;CDT1:
; MOVEQ #0,D0
;L@=0
;N@=0
; REPEAT
;   MOVE.W D0,L@(A0)
;   MOVE.W D0,L@+8(A0)
;   MOVE.W D0,L@+144(A0)
;   MOVE.W D0,L@+152(A0)
;L@=L@+320
;N@=N@+1
; UNTILEQ N@,15
; RTS



;CALCDOTS:  ;PEK!!    MOVE DOTS TO NEW POSITION
; LEA BOFFTAB,A0      ;SOURCE
; LEA DOTTAB(PC),A1  ;DESTINY
;
; MOVEQ #0,D5
; MOVEQ #49,D2
;CB5:
; MOVE.W (A1),D1
; CMP.W (A0)+,D1
; BLO.S CB4
; BEQ.S CB7
; SUBQ.W #1,D1
;CB3:
; MOVE.W D1,(A1)+
;
; MOVE.W (A1),D1
; CMP.W (A0)+,D1
; BLO.S CB2
; BEQ.S CB6
; SUB.W #160,D1
;CB1:
; MOVE.W D1,(A1)+
;
; DBRA D2,CB5
; CMP.B #100,D5
; BEQ.S CB8        ;FIX NEW BOFFTAB
; RTS
;CB2:
; ADD.W #160,D1
; BRA.S CB1
;CB4:
; ADDQ.W #1,D1
; BRA.S CB3
;CB6:
; ADDQ.B #1,D5
; BRA.S CB1
;CB7:
; ADDQ.B #1,D5
; BRA.S CB3
;CB8:         ;PEK!!!
; MOVE.L BOFFSCRIPT,D0
; BNE.S CB9
;   MOVE.L #BOFFSCRIPT,CB8+2
;   MOVE.L BOFFSCRIPT,D0
;CB9:
; ADDQ.L #4,CB8+2
; MOVE.L D0,CALCDOTS+2
; RTS
;BOFFSCRIPT:
; DC.L BOFFTAB,BOFFTAB2,BOFFTAB3
; DC.L 0
;
;BOFFTAB:
;N@=0
; REPEAT
;   DC.W N@,N@*160
;   DC.W 29-N@,N@*160
;N@=N@+1
; UNTILEQ N@,25
;
;BOFFTAB2:
; DS.L 50,$00100000
;
;BOFFTAB3:
;N@=30
; REPEAT
;   DC.W N@,N@*160
;   DC.W 30-N@,N@*160-160
;N@=N@-1
; UNTILEQ N@,0
;
;DOTS:
; LEA DOTTAB(PC),A0
; MOVE.L SCREENS(PC),A1
; LEA 144(A1),A2
; MOVE.W #32768,D3
; MOVE.B #$F0,D6
; MOVE.B #$0F,D7
;
; MOVEQ #49,D5
;DOT1:
;   MOVE.L (A0)+,D0
;   MOVE.W D0,D2
;   SWAP D0
;   MOVE.W D0,D1
;   AND.B D6,D0
;   LSR.W #1,D0
;   ADD.W D0,D2
;   AND.B D7,D1
;   MOVE.W D3,D4
;   LSR.W D1,D4
;   OR.W D4,(A1,D2.W)
;   OR.W D4,(A2,D2.W)
; DBRA D5,DOT1
; RTS
;DOTTAB:
; DS.L 50,0


SS1: DC.B 1,0
SSNEW:
 MOVE.B #8,SS1
 MOVEQ #0,D0
SS3:
 MOVE.B SASCII,D0
 BNE.S SS4
   MOVE.L #SASCII,SS3+2
   MOVE.B SASCII(PC),D0
SS4:
 ADDQ.L #1,SS3+2
 SUB.B #32,D0
 LSL.W #5,D0
 LEA SMALLFONT(PC),A2
 ADD.W D0,A2
 MOVE.L A2,SS2+2
 CMP.L #BUFF+1536+220,A0
 BLO.S SS2
   LEA BUFF+1536(PC),A0
 BRA.S SS2
SMALLSCROLL:    ;PEK!
 LEA BUFF+1536,A0
   SUBQ.B #1,SS1
   BEQ.S SSNEW
SS2:     ;PEK!
 LEA SMALLFONT,A2
 MOVE.L (A2),(A0)+
 MOVE.L (A2)+,220(A0)
 MOVE.L A2,SS2+2
 MOVE.L A0,SMALLSCROLL+2

 MOVE.L SCREENS(PC),A1
L@=46*160+16+2
N@=0
 REPEAT
   MOVE.W (A0),L@(A1)
   MOVE.W (A0)+,L@+120(A1)
L@=L@+160
N@=N@+1
 UNTILEQ N@,110
 RTS


USC2: DC.B 1,0
USC3:
   MOVE.B #8,USC2
   MOVEQ #0,D0
USC5:      ;PEK!
   MOVE.B DUMSTRING,D0
   BNE.S USC6
USC8:
     TST.B HEREWEARE+1
     BNE.S USC9
       MOVE.L #DUMSTRING,USC5+2
       MOVE.B #' ',D0
       BRA.S USC6
USC9:     ;PEK!
     LEA DUMSTRING,A2
     MOVE.L A2,USC5+2
     MOVE.B (A2),D0
USC6:
   SUB.B #64,D0
   BPL.S USC7
     MOVEQ #0,D0    ;SPACE CARACTER
USC7:
   LSL.W #8,D0
   LEA UPFONT(PC),A2
   ADD.W D0,A2
   MOVE.L A2,USC1+2
   ADDQ.L #1,USC5+2

   CMP.L #BUFF+768,A0
   BLO.S USC1
     LEA BUFF,A0
     MOVE.L A0,UPSCROLL+2
   BRA.S USC1
UPSCROLL:
 LEA BUFF,A0
     SUBQ.B #1,USC2
     BEQ.S USC3
USC1:          ;PEK!
   LEA UPFONT+256,A2
   MOVEM.L (A2)+,D0-D7
   MOVE.L A2,USC1+2
     MOVEM.L D0-D7,(A0)
     MOVEM.L D0-D7,768(A0)
   ADD.W #32,A0
   MOVE.L A0,UPSCROLL+2
 MOVE.L SCREENS(PC),A1

L@=52*160
N@=0
 REPEAT
   MOVEM.L (A0)+,D0-D7/A2-A5
   MOVE.L D0,L@(A1)
   MOVE.L D0,L@+144(A1)
   MOVE.L D1,L@+8(A1)
   MOVE.L D1,L@+152(A1)

   MOVE.L D2,160+L@(A1)
   MOVE.L D2,160+L@+144(A1)
   MOVE.L D3,160+L@+8(A1)
   MOVE.L D3,160+L@+152(A1)

   MOVE.L D4,320+L@(A1)
   MOVE.L D4,320+L@+144(A1)
   MOVE.L D5,320+L@+8(A1)
   MOVE.L D5,320+L@+152(A1)

   MOVE.L D6,480+L@(A1)
   MOVE.L D6,480+L@+144(A1)
   MOVE.L D7,480+L@+8(A1)
   MOVE.L D7,480+L@+152(A1)

   MOVE.L A2,640+L@(A1)
   MOVE.L A2,640+L@+144(A1)
   MOVE.L A3,640+L@+8(A1)
   MOVE.L A3,640+L@+152(A1)

   MOVE.L A4,800+L@(A1)
   MOVE.L A4,800+L@+144(A1)
   MOVE.L A5,800+L@+8(A1)
   MOVE.L A5,800+L@+152(A1)

L@=L@+960
N@=N@+1
 UNTILEQ N@,16

 RTS


SLACKBALLS:
 MOVEQ #0,D0
 MOVEQ #0,D1
 MOVEQ #0,D2
 MOVEQ #0,D3

 LEA BLACKTAB1(PC),A1
 BTST #0,CLOCK+1
 BNE.S SL2
   ADD.W #24,A1
SL2:
 MOVE.L A1,A4
 MOVEQ #NOBALLS-1,D4
SL1:
 MOVE.L (A1)+,A0
N@=0
L@=0
 REPEAT
   MOVEM.L D0-D3,L@(A0)
   MOVEM.L D0-D3,L@-160*160(A0)
;   MOVE.L D0,L@(A0)
;   MOVE.W D0,L@+4(A0)
;   MOVE.L D0,L@+8(A0)
;   MOVE.W D0,L@+12(A0)
L@=L@+160
N@=N@+1
 UNTILEQ N@,9
 DBRA D4,SL1
 RTS


BLACKTAB1:
 DS.L NOBALLS,SCR1
BLACKTAB2:
 DS.L NOBALLS,SCR1
BTAB:
 DC.L BADD2,BALLX,BALLY
 DC.L BADD2+16,BALLX+8,BALLY+4
 DC.L BADD2+32,BALLX+16,BALLY+8
 DC.L BADD2+48,BALLX+24,BALLY+12
 DC.L BADD2+64,BALLX+32,BALLY+16
 DC.L BADD2+80,BALLX+40,BALLY+20
 DC.L BADD2+96,BALLX+48,BALLY+24
BADD2:
 DC.L BALLGRAF,BALLGRAF
 DC.L BALLGRAF,BALLGRAF
 DC.L BALLGRAF+2304,BALLGRAF+2304
 DC.L BALLGRAF+2304,BALLGRAF+2304
 DC.L BALLGRAF+4608,BALLGRAF+4608
 DC.L BALLGRAF+4608,BALLGRAF+4608
 DC.L BALLGRAF+6912,BALLGRAF+6912
 DC.L BALLGRAF+6912,BALLGRAF+6912
 DC.L BALLGRAF+9216,BALLGRAF+9216
 DC.L BALLGRAF+9216,BALLGRAF+9216
 DC.L BALLGRAF+6912,BALLGRAF+6912
 DC.L BALLGRAF+6912,BALLGRAF+6912
 DC.L BALLGRAF+4608,BALLGRAF+4608
 DC.L BALLGRAF+4608,BALLGRAF+4608
 DC.L BALLGRAF+2304,BALLGRAF+2304
 DC.L BALLGRAF+2304,BALLGRAF+2304
 DC.L 0
BALLS:
; LEA BLACKTAB1,A4 ;A4 ALREADY ASSIGNED IN SLACK
BPEK1:
 MOVE.W BALLX2,D6      ;EXTRA X SINUS
 BNE.S B6
   MOVE.L #BALLX2,BPEK1+2
   MOVE.W BALLX2(PC),D6
B6:
 ADDQ.L #2,BPEK1+2
 MOVE.W D6,BPEK2+2
 LEA BTAB(PC),A2
 MOVEQ #NOBALLS-1,D7
B1:
 SWAP D7
   MOVE.L (A2),A3      ;TWINKLE
   MOVE.L (A3)+,A0
   CMP.L #0,A0
   BNE.S B4
     LEA BADD2,A3
     MOVE.L (A3)+,A0
B4:
   MOVE.L A3,(A2)+
 MOVE.L SCREENS(PC),A1
   MOVE.L (A2),A3
   MOVE.W (A3)+,D0     ;X COORD
   BNE.S B3
      LEA BALLX(PC),A3
      MOVE.W (A3)+,D0
B3:
   MOVE.L A3,(A2)+
BPEK2:
   ADD.W #0,D0         ;ADD EXTRA X
   MOVE.W D0,D1
   AND.B #%11110000,D0
   LSR.W #1,D0
   ADD.W D0,A1
   AND.W #15,D1
   LSL.W #1,D1         ;*2
   ADDA.W BADD(PC,D1.W),A0
   MOVE.L (A2),A3
   MOVE.W (A3)+,D0     ;Y COORD
   BNE.S B5
      LEA BALLY(PC),A3
      MOVE.W (A3)+,D0
      BRA.S B5
BADD:
 DC.W 0,144,288,432,576,720,864,1008,1152,1296,1440,1584,1728,1872,2016,2160
B5:
   MOVE.L A3,(A2)+
   ADD.W D0,A1
   MOVE.L A1,(A4)+     ;SAVE ADDRESS FOR SLACKNING
N@=0
L@=0
 REPEAT
   MOVEM.W L@(A1),D0-D6
   MOVE.W (A0)+,D7
   AND.W D7,D0
   OR.W (A0)+,D0
   AND.W D7,D1
   OR.W (A0)+,D1
   AND.W D7,D2
   OR.W (A0)+,D2
   MOVE.W (A0)+,D7
   AND.W D7,D4
   OR.W (A0)+,D4
   AND.W D7,D5
   OR.W (A0)+,D5
   AND.W D7,D6
   OR.W (A0)+,D6
   MOVEM.W D0-D6,L@(A1)
   MOVEM.W D0-D6,L@-160*160(A1)
L@=L@+160
N@=N@+1
 UNTILEQ N@,9
 SWAP D7
 DBRA D7,B1

 RTS
BALLX:
 IBYTES BALLX.SIN
 DC.W 0
BALLX2:
 IBYTES BALLX2.SIN
 DC.W 0
BALLY:
 IBYTES BALLY.SIN
 DC.W 0


BUFWIDTH=2*40
NEWLETTER:
 MOVE.B #10,TCOUNT
   MOVEQ #0,D0
TP3:                ;PEK!!!
   MOVE.B ASCII,D0
   BNE.S TS4
   MOVE.B ASCII,D0
   MOVE.L #ASCII,TP3+2
TS4:
   ADDQ.L #1,TP3+2
     CMP.B #' ',D0
     BNE.S TS5
       MOVEQ #64,D0
TS5:
   SUB.B #64,D0
   MULU #320,D0
   LEA FONT,A0
   ADD.W D0,A0
   MOVE.L A0,TP1+2
 CMP.L #BUFF1+(BUFWIDTH/2),TP2+2
 BNE.S TP2
   MOVE.L #BUFF1,TP2+2
 BRA.S TP2
TCOUNT: DC.B 1,0
TEXTSCROLL:
   SUBQ.B #1,TCOUNT
   BEQ.S NEWLETTER
TP2:                ;WRITE A PIECE OF A LETTER.    PEK!!!
 LEA BUFF1,A1
TP1:         ;PEK!!!
 LEA FONT,A0
 BTST #0,TCOUNT
 BNE.S TS2
   ADDQ.L #2,TP2+2
   ADDQ.L #2,TP1+2
   ADD.L #10000,A0
   ADD.L #BUFWIDTH*32,A1
TS2:

N@=0
L@=0
X@=0
 REPEAT
   MOVE.W L@(A0),X@(A1)
   MOVE.W L@(A0),BUFWIDTH/2+X@(A1)
L@=L@+10
X@=X@+BUFWIDTH
N@=N@+1
 UNTILEQ N@,32

    MOVE.L SCREENS,A2
    ADD.L #168*160+6,A2

    ADDQ.L #2,A1
    MOVE.W #160,D1
    MOVE.W #BUFWIDTH,D2
    ADD.W D2,A1
    MOVEQ #29,D0        ;DUMP BUFFER TO SCREEN
TS1:
    MOVE.L A1,A0
L@=0
 REPEAT
    MOVE.W (A0)+,L@(A2)
L@=L@+8
 UNTILEQ L@,160
    ADD.W D1,A2
    ADD.W D2,A1
    DBRA D0,TS1
 RTS


CONTROL:   ;PEK!!!
 JSR READCTRL
 JSR CHOOSESCROLL       ;SHOW CORRECT SCROLLER DEPENDING ON GUBBES POSITION
 RTS


CHOOSESCROLL:
 BSR CSURR
 MOVE.B D1,D0
 OR.B D2,D0
 BTST #5,D0
 BEQ.S CHS2
  CMP.B HEREWEARE+1(PC),D0     ;SCROLLER ALREADY RUNNING?
  BEQ.S CHS1
   MOVE.B D0,HEREWEARE+1
   SUB.B #32,D0
   EXT.W D0
    LSL.W #2,D0
   MOVE.L CHOOSETAB(PC,D0.W),D0
   MOVE.L D0,USC5+2
   MOVE.L D0,USC9+2
CHS1:
 RTS
CHS2:
 CLR.B HEREWEARE+1
 RTS
CHOOSETAB:
 DC.L ASCIIS1,ASCIIS2,ASCIIS3,ASCIIS4
HEREWEARE: DC.B 0,0


READCTRL:
 MOVE.B $FFFC02,D0
 CMP.B #$48,D0
 BEQ UJUMP
 CMP.B #$52,D0
 BEQ LJUMP
 CMP.B #$47,D0
 BEQ RJUMP
 CMP.B #$4B,D0
 BEQ SCLEFT
 CMP.B #$4D,D0
 BEQ SCRIGHT
 CMP.B #$39,D0
 BEQ FIRE

 MOVE.B JOYREAD,D0
 BTST #0,D0
 BNE.S JUMP
 BTST #2,D0
 BNE SCLEFT
 BTST #3,D0
 BNE SCRIGHT
 BTST #7,D0
 BNE FIRE

 BSR TESTFALL
 RTS


FIRE:
 BSR CSURR
 BTST #5,D1
 BNE.S DEMOSELECT
 RTS
DEMOSELECT:
 MOVEQ #0,D0
 MOVE.B D1,D0
 SUB.B #32,D0
 MOVE.W D0,EXITCODE
 BRA EXIT


JUMP:
 BTST #2,D0
 BNE.S LJUMP
 BTST #3,D0
 BNE.S RJUMP
UJUMP:
 MOVE.B #9,JCOUNT
 MOVE.L #JUMPER,CONTROL+2
 RTS
JCOUNT: DC.W 0
LJUMP:
 MOVE.B #16,JCOUNT
 MOVE.L #LJUMPER,CONTROL+2
 RTS
RJUMP:
 MOVE.B #16,JCOUNT
 MOVE.L #RJUMPER,CONTROL+2
 RTS

JEND:
 MOVE.L #FALL,CONTROL+2
 RTS
LJUMPER:
 SUBQ.B #1,JCOUNT
 BEQ.S JEND
   BSR SCLEFT
   MOVE.L #LJUMPER,CONTROL+2
   CMP.B #8,JCOUNT
   BGE.S JU1
   BRA FALL
 RTS
RJUMPER:
 SUBQ.B #1,JCOUNT
 BEQ.S JEND
   BSR SCRIGHT
   MOVE.L #RJUMPER,CONTROL+2
   CMP.B #8,JCOUNT
   BGE.S JU1
   BRA FALL
 RTS
JUMPER:
 SUBQ.B #1,JCOUNT
 BEQ.S JEND
JU1:
 MOVE.W SCROLLY(PC),D0
 MOVE.W GUBBY(PC),D1
 MOVE.W D1,D2
 SUB.W D0,D2
 CMP.W #3*4,D2
 BGT.S SCU1

 TST.W SCROLLY
 BEQ SCU1
 SUBQ.W #1,SCROLLY
SCU1:
   CMP.W #4,GUBBY
   BEQ CBACK
   SUBQ.W #1,GUBBY
 RTS


FALL:
 MOVE.W GUBBY(PC),D0
 AND.W #3,D0
 BNE.S SCD2
   BSR CSURR
   TST.B D4
   BNE FALLEND
     MOVE.W GUBBX(PC),D0
     AND.W #3,D0
     BEQ.S SCD2
     TST.B D5
     BNE FALLEND
SCD2:
 MOVE.W SCROLLY(PC),D0
 MOVE.W GUBBY(PC),D1
 MOVE.W D1,D2
 SUB.W D0,D2
 CMP.W #3*4,D2
 BLT.S SCD1

 CMP.W #(BHEIGTH-7)*4,SCROLLY
 BGE SCD1
 ADDQ.W #1,SCROLLY
SCD1:
   CMP.W #(BHEIGTH-1)*4,GUBBY
   BGE MAIN
   ADDQ.W #1,GUBBY
 RTS
FALLEND:
 MOVE.L #READCTRL,CONTROL+2
 RTS
TESTFALL:
 BSR CSURR
 TST.B D4
 BNE.S TF1
   MOVE.W GUBBX(PC),D0
   AND.W #3,D0
   BEQ.S TF2
   TST.B D5
   BNE.S TF1
TF2:
 MOVE.L #FALL,CONTROL+2   ;FALL=TRUE
TF1:
 RTS

SCRIGHT:
; MOVE.W GUBBX(PC),D0
; AND.W #3,D0
; BNE.S SCRR2
;   BSR CSURR
;   TST.B D2
;   BNE.S CBACK
;SCRR2:

 MOVE.W SCROLLX(PC),D0
 MOVE.W GUBBX(PC),D1
 SUB.W D0,D1
 CMP.W #7*4-2,D1
 BLE.S SCRR1

 CMP.W #(BWIDTH-14)*4,SCROLLX
 BEQ SCRR1
 ADDQ.W #1,SCROLLX
SCRR1:
   CMP.W #(BWIDTH-1)*4-4,GUBBX
   BEQ.S CBACK
   ADDQ.W #1,GUBBX
 BSR TESTFALL
 RTS
CBACK:
 RTS


SCLEFT:
; MOVE.W GUBBX(PC),D0
; AND.W #3,D0
; BNE.S SCL2
;   BSR CSURR
;   TST.B D0
;   BNE.S CBACK
;SCL2:

 MOVE.W SCROLLX(PC),D0
 MOVE.W GUBBX(PC),D1
 MOVE.W D1,D2
 SUB.W D0,D2
 CMP.W #7*4,D2
 BGE.S SCL1

 TST.W SCROLLX
 BEQ SCL1
 SUBQ.W #1,SCROLLX
SCL1:
   CMP.W #4,GUBBX
   BEQ.S CBACK
   SUBQ.W #1,GUBBX
 BSR TESTFALL
 RTS

CSURR:
 MOVE.W GUBBX(PC),D0
 MOVE.W GUBBY(PC),D1
 LEA BLOCKS,A0
 LSR.W #2,D1
 MULU #BWIDTH,D1
 ADD.L D1,A0

 LSR.W #2,D0
 ADD.W D0,A0           ;A0 POINTS AT BLOCK ADRESS
 MOVE.B -1(A0),D0
 MOVE.B (A0),D1
 MOVE.B 1(A0),D2
 MOVE.B -BWIDTH(A0),D3
 MOVE.B BWIDTH(A0),D4
 MOVE.B BWIDTH+1(A0),D5
 RTS

SCROLLX: DC.W 0
SCROLLY: DC.W 0
ADDTAB: DC.L 0,L,L*2,L*3
SCROLLUPDAT:
 LEA GUBBGRAF+(8*384),A0
   MOVE.W SCROLLY,D0
   MULU #(BWIDTH*8)*4,D0
   ADD.L D0,A0
   MOVE.W SCROLLX,D0
   MOVE.W D0,D1
   AND.W #3,D0
   LSL.W #2,D0     ;*4
   LEA ADDTAB(PC),A1
   ADD.L (A1,D0.W),A0
   AND.B #-4,D1
   LSL.W #1,D1     ;*2
   ADD.W D1,A0
 MOVE.L SCREENS,A1
 ADD.L #(156*160)-24-40,A1
L@=111*(BWIDTH*8)+72
N@=0
X@=(BWIDTH*8)
 REPEAT
   MOVEM.L L@(A0),D0-D7\A2-A3
   MOVEM.L D0-D7\A2-A3,(A1)
   MOVEM.L L@-40(A0),D0-D7\A2-A3
   MOVEM.L D0-D7\A2-A3,-(A1)
   MOVEM.L L@-72(A0),D0-D7
   MOVEM.L D0-D7,-(A1)
   SUB.W #88,A1
L@=L@-X@
N@=N@+1
 UNTILEQ N@,112
 RTS


GUBBADDS: DC.L GUBBGRAF,GUBBGRAF+384,GUBBGRAF+768,GUBBGRAF+1152
GUBBX: DC.W 4
GUBBY: DC.W 4
GUBBE:
   MOVE.W GUBBX(PC),D0
   SUB.W SCROLLX(PC),D0
   MOVE.W D0,D1
   AND.W #3,D0
   LEA GUBBADDS(PC),A0
   LSL.W #2,D0      ;*4
   MOVE.L (A0,D0.W),A0
 MOVE.L SCREENS(PC),A1
   AND.B #-4,D1
   LSL.W #1,D1
   ADD.W D1,A1
 ADD.W #(44*160)+24,A1
   MOVE.W GUBBY(PC),D0
   SUB.W SCROLLY(PC),D0
   MULU #4*160,D0
   ADD.L D0,A1
N@=0
L@=0
 REPEAT
   MOVEM.L L@(A1),D0-D3
   MOVE.L (A0)+,D4
   AND.L D4,D0
   OR.L (A0)+,D0
   AND.L D4,D1
   OR.L (A0)+,D1
   MOVE.L (A0)+,D4
   AND.L D4,D2
   OR.L (A0)+,D2
   AND.L D4,D3
   OR.L (A0)+,D3
   MOVEM.L D0-D3,L@(A1)
N@=N@+1
L@=L@+160
 UNTILEQ N@,16
 RTS



START:
 CLR.L -(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SPAR+4

 MOVE.W #0,$484
 LEA $26,A0
 CLR.L $400(A0)   ;CLEAR RESET VALID

 PEA MOUSE
 MOVE.W #1,-(SP)
 MOVE.W #25,-(SP)
 TRAP #14
 ADDQ.L #8,SP

 BSR FIXREFLEX
 BSR FIXBALLS
 BSR FIXFF
 BSR FIXFONT
 BSR FIXGUBBE
 BSR CREATEAREA
 BSR ROTATEAREA

 CLR.W -(SP)     ;SETSCR
 PEA SCR1
 PEA SCR1
 MOVE.W #5,-(SP)
 TRAP #14
 ADD.L #12,SP

 IFNE EXEC,-1
   LEA $FF8240,A0
   LEA OPAL,A1
   MOVEQ #7,D0
   BSR COPY
 ENDIF

 LEA PAL,A0
 LEA $FF8240,A1
 MOVEQ #7,D0
 BSR COPY

 LEA SCR1,A0
 MOVE.W #17000,D0
CLS:
 CLR.L (A0)+
 DBRA D0,CLS

 MOVE.W #$2700,SR

 LEA MUSIC+$B80,A0
 JSR MUSIC+4

 MOVE.L $70,OVBL
 MOVE.L #VBL2,$70
 MOVE.L $118,OKEY
 MOVE.L #JOYSTICK,$118
; MOVE.B $FFFA07,MFP1
; MOVE.B $FFFA09,MFP1+1
; CLR.B $FFFA07
; CLR.B $FFFA09
 BSR INITRAST
 MOVE.W #$2300,SR
 JMP MAIN

EXIT:
 MOVE.W #$2700,SR
FLUSH:
 BTST #0,$FFFC00          ;IS A CHARACTER WAITING ?
 BEQ.S FL1                ;BR. IF NOT
 MOVE.B $FFFC02,D0        ;READ CHARACTER (& IGNORE IT)
 BRA.S FLUSH              ;CHECK FOR ANOTHER
FL1:
 MOVE.L OVBL,$70
 MOVE.L OKEY,$118
 BSR REMOVERAST
; MOVE.B MFP1,$FFFA07
; MOVE.B MFP1+1,$FFFA09
 MOVE.W #$2300,SR

 IFNE EXEC,-1
   MOVE.W #1,-(SP)
   PEA $F8000
   PEA $F8000
   MOVE.W #5,-(SP)
   TRAP #14
   ADD.L #12,SP
 ENDIF

 LEA OPAL,A0
 LEA $FF8240,A1
 MOVEQ #7,D0
 BSR COPY

 MOVE.L SPAR+4,-(SP)
 MOVE.W #$20,-(SP)
 TRAP #1
 ADDQ.L #6,SP

 PEA MOUSE+2
 MOVE.W #1,-(SP)
 MOVE.W #25,-(SP)
 TRAP #14
 ADDQ.L #8,SP

 IFEQ EXEC,-1
   move.w exitcode(pc),-(sp)
   move.w #$4c,-(sp)
   trap #1
 ENDIF
 ILLEGAL
COPY:
 MOVE.L (A0)+,(A1)+
 DBRA D0,COPY
 RTS
EXITCODE: DC.W 0
MFP1:
 DC.W 0

INITRAST:
 LEA $FC0000,A5
 MOVE.L $120,SPAR2
 MOVE.B $FFFA09,SPAR4
 MOVE.B $FFFA07,SPAR4+1
 MOVE.B $FFFA13,SPAR4+2
;   CLR.B $FFFA07
;   CLR.B $FFFA09
 MOVE.L #RASTER1,$120
 ORI.B #1,$FFFA07
 ORI.B #1,$FFFA13
 RTS

REMOVERAST:
 MOVE.B SPAR4,$FFFA09
 MOVE.B SPAR4+1,$FFFA07
 MOVE.B SPAR4+2,$FFFA13
 MOVE.L SPAR2,$120
 RTS

JOYSTICK:            ;KEYBOARD INTERRUPT
 MOVE.W D0,-(SP)
 MOVE.B $FFFC02,D0

 TST.B JOYFLAG_1
 BNE.S JOY1

 CMP.B #$FF,D0
 BEQ.S JOYSTICK_1
 MOVE.W (SP)+,D0
 BCLR #6,$FFFA11
 RTE
JOYSTICK_1:
 ST JOYFLAG_1
 MOVE.W (SP)+,D0
 BCLR #6,$FFFA11
 RTE
JOYFLAG_1:
 DC.B 0,0
JOYREAD:
 DC.B 0,0
JOY1:
 SF JOYFLAG_1
 MOVE.B D0,JOYREAD
 MOVE.W (SP)+,D0
 BCLR #6,$FFFA11
 RTE

CREATEAREA:
 LEA BLOCKGRAF,A0
 LEA GUBBGRAF+(8*384),A1
 LEA BLOCKS,A2
 MOVE.W #BHEIGTH-1,D2
CA2:
 MOVE.L A1,A4
 MOVE.W #BWIDTH-1,D1
CA1:
   MOVEQ #0,D0
   MOVE.B (A2)+,D0
   CMP.B #10,D0
   BLO.S CA3
     MOVEQ #8,D0    ;DOOR
CA3:
   LSL.L #7,D0      ;*128
   LEA (A0,D0.W),A3
N@=0
L@=0
   REPEAT
     MOVE.L (A3)+,L@(A4)
     MOVE.L (A3)+,L@+4(A4)
N@=N@+1
L@=L@+(BWIDTH*8)
   UNTILEQ N@,16
   ADDQ.W #8,A4
   DBRA D1,CA1
 ADD.W #16*(BWIDTH*8),A1
 DBRA D2,CA2
 RTS


ROTATEAREA:
 LEA GUBBGRAF+(8*384),A2
 LEA SCREENGRAF+L,A3
 MOVEQ #2,D3           ;ROT 3 SCREENS
RA1:
   MOVE.L A2,A0
   MOVE.L A3,A1
   MOVE.W #(L/4)-1,D0
   BSR COPY
   MOVE.W #(BHEIGTH*16)-1,D2  ;ROT ALL LINES
RA4:
   MOVEQ #3,D1        ;ROT 4 PIXELS
RA3:
   MOVE.L A3,A0
   MOVEQ #3,D0        ;ROT 4 BITPLANES
   MOVE #0,CCR
RA2:
N@=0
L@=BWIDTH*8-8
   REPEAT
     ROXL.W L@(A0)
L@=L@-8
N@=N@+1
   UNTILEQ N@,BWIDTH
   ADDQ.W #2,A0
   DBRA D0,RA2
   DBRA D1,RA3
   ADD.W #BWIDTH*8,A3
   DBRA D2,RA4
 ADD.L #L,A2
 MOVE.L A2,A3
 ADD.L #L,A3
 DBRA D3,RA1
 RTS




FIXFONT:
 LEA FONTGRAF,A0
 MOVE.L A0,A3
 LEA FONT,A1
 LEA FONT+10000,A2
 MOVE.W #30*32-1,D0
FXF1:
 CLR.W (A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
   CLR.B (A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   MOVE.B (A3)+,(A2)+
   CLR.B (A2)+
 DBRA D0,FXF1

 LEA BUFF1,A0
 MOVE.W #(BUFWIDTH*64)/4,D0
C1:
 CLR.L (A0)+
 DBRA D0,C1
 RTS


FIXBALLS:
 LEA BALLGX,A0        ;MAKE SPACE
 LEA BALLGRAF,A1
 MOVEQ #4,D1          ;5 ANIMATIONS
FXB2:
 MOVEQ #8,D0          ;9 LINES HIGH
FXB1:
   MOVE.L (A0)+,(A1)+
   MOVE.L (A0)+,(A1)+
   MOVE.W #-1,(A1)+
   CLR.W (A1)+
   CLR.L (A1)+
 DBRA D0,FXB1
 ADD.W #7*8,A0
 ADD.W #15*144,A1     ;MAKE SPACE FOR 16 ROTATIONS
 DBRA D1,FXB2

 LEA BALLGRAF,A2      ;ROTATE
 LEA BALLGRAF+144,A3
 MOVEQ #4,D2          ;5 ANIMATIONS
FXB5:
 MOVEQ #14,D1         ;15 COPIES
FXB4:
 MOVE.L A2,A0
 MOVE.L A3,A1
 MOVE.W #(144/4)-1,D0
 BSR COPY
 MOVE.L A3,A0
 MOVEQ #8,D0          ;9 LINES
FXB3:
   MOVE #255,CCR
   ROXR.W (A0)        ;MASK
   ROXR.W 8(A0)
   MOVE #0,CCR
   ROXR.W 2(A0)       ;PLANE 1
   ROXR.W 10(A0)
   MOVE #0,CCR
   ROXR.W 4(A0)       ;2
   ROXR.W 12(A0)
   MOVE #0,CCR
   ROXR.W 6(A0)       ;3
   ROXR.W 14(A0)
   ADD.W #16,A0
 DBRA D0,FXB3
 MOVE.L A3,A2
 ADD.W #144,A3
 DBRA D1,FXB4
 MOVE.L A3,A2
 ADD.W #144,A3
 DBRA D2,FXB5
 RTS

FIXREFLEX:
 LEA REFLEXPIC(PC),A2
 LEA REFGRAF,A3
 MOVE.L A2,A0
 MOVE.L A3,A1
 MOVE.W #399,D0
 BSR COPY

 MOVE.L A3,A2
 LEA 1600(A3),A3
 MOVEQ #18,D1
FR1:
 MOVE.L A2,A0
 MOVE.L A3,A1
 MOVE.W #399,D0
 BSR COPY
 MOVE.L A3,A0
 MOVEQ #39,D3    ;40 PIXELS HIGH
FR3:
   MOVEQ #39,D2  ;40 WORDS WIDTH
   MOVE #0,CCR
FR2:
   ROXR.W (A0)+
   DBRA D2,FR2
 DBRA D3,FR3
 MOVE.L A3,A2
 LEA 1600(A3),A3
 DBRA D1,FR1
 RTS


FIXFF:
 LEA FFDAT(PC),A0  ;REMOVE GRAFIX BUG
 MOVEQ #63,D1
FFF7:
 MOVE.W (A0)+,D0
 ADDQ.W #2,A0
 OR.W (A0)+,D0
 OR.W (A0)+,D0
 AND.W D0,-6(A0)
 DBRA D1,FFF7

 LEA FFDAT(PC),A0
 LEA FFGRAF,A1
 MOVEQ #31,D0
FFF1:
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+
 CLR.L (A1)+
 CLR.L (A1)+
 DBRA D0,FFF1

 LEA FFGRAF,A2
 LEA 1152(A2),A3
 MOVEQ #14,D2
FFF4:
 MOVE.L A2,A0
 MOVE.L A3,A1
 MOVE.W #191,D0
 BSR COPY
 MOVE.L A3,A0
 MOVEQ #31,D1
FFF3:
 MOVEQ #3,D0    ;4 PLANES
FFF2:
 MOVE #0,CCR
 ROXR.W (A0)
 ROXR.W 8(A0)
 ROXR.W 16(A0)
 ADDQ.W #2,A0
 DBRA D0,FFF2
 ADD.W #16,A0
 DBRA D1,FFF3
 MOVE.L A3,A2
 LEA 1152(A3),A3
 DBRA D2,FFF4

 LEA FFGRAF,A2
 MOVEQ #15,D3
FFF6:
 MOVE.L A2,A0
 LEA 768(A2),A1
 MOVEQ #95,D2
FFF5:
 MOVE.W (A0)+,D0
 OR.W (A0)+,D0
 OR.W (A0)+,D0
 OR.W (A0)+,D0
 NOT.W D0
 MOVE.W D0,D1
 SWAP D0
 MOVE.W D1,D0
 MOVE.L D0,(A1)+
 DBRA D2,FFF5
 ADD.W #1152,A2
 DBRA D3,FFF6
 RTS

FIXGUBBE:
 LEA GUBBGRAF(PC),A0
 LEA SCREENGRAF,A1
 MOVE.W #(160*NOSPR)/4-1,D0
 BSR COPY
 LEA SCREENGRAF,A0
 LEA GUBBGRAF(PC),A1
 MOVE.W #(NOSPR*16)-1,D0
FG1:
 MOVE.W (A0),(A1)+     ;DUPLICATE MASK
 MOVE.W (A0)+,(A1)+
 MOVE.L (A0)+,(A1)+    ;2 PLANES
 MOVE.L (A0)+,(A1)+    ;2 PLANES
 MOVE.L #-1,(A1)+
 CLR.L (A1)+
 CLR.L (A1)+
 DBRA D0,FG1

 LEA GUBBGRAF(PC),A0
 MOVEQ #(NOSPR/4)-1,D4
FG4:
 MOVEQ #0,D1
 MOVEQ #3,D3
FG3:
 MOVEQ #15,D2
FG2:
     MOVE.W D1,D5
     TST.W D5
     BEQ.S FG6
     SUBQ.W #1,D5
FG5:
     MOVE #255,CCR
     ROXR.W (A0)
     ROXR.W 12(A0)
     DBRA D5,FG5
FG6:
     MOVE.W (A0),2(A0)
     MOVE.W 12(A0),14(A0)
     ADDQ.W #4,A0
   MOVE.W (A0),D0
   SWAP D0
   MOVE.W 12(A0),D0
   LSR.L D1,D0
   MOVE.W D0,12(A0)
   SWAP D0
   MOVE.W D0,(A0)
   MOVE.W 2(A0),D0
   SWAP D0
   MOVE.W 14(A0),D0
   LSR.L D1,D0
   MOVE.W D0,14(A0)
   SWAP D0
   MOVE.W D0,2(A0)
   MOVE.W 4(A0),D0
   SWAP D0
   MOVE.W 16(A0),D0
   LSR.L D1,D0
   MOVE.W D0,16(A0)
   SWAP D0
   MOVE.W D0,4(A0)
   MOVE.W 6(A0),D0
   SWAP D0
   MOVE.W 18(A0),D0
   LSR.L D1,D0
   MOVE.W D0,18(A0)
   SWAP D0
   MOVE.W D0,6(A0)
   ADD.W #20,A0
   DBRA D2,FG2
 ADDQ.W #4,D1
 DBRA D3,FG3
 DBRA D4,FG4
 RTS

OKEY: DC.L 0,0
OHBL: DC.L 0
SPAR: DS.L 8,0
SPAR1: DC.L 0
SPAR2: DC.L 0
SPAR3: DC.L 0
SPAR4: DC.L 0
SPAR5: DC.W 0
OMFP:
 DC.W 0
PAL3:
 DC.W $000,$777,$557,$237,$004,$060,$050,$040
 DC.W $777,$777,$557,$237,$004,$060,$050,$040
PAL2:
 DC.W $000,$777,$557,$237,$004,$643,$532,$421
 DC.W $070,$777,$557,$237,$004,$643,$532,$421
PAL:
 DC.W $000,$333,$555,$777,$300,$500,$700,$030
 DC.W $050,$070,$003,$005,$007,$330,$550,$770
OPAL:
 DS.W 16,0
OVBL:
 DC.L 0

MOUSE:
 DC.B $12,$14,$14,8

SCREENS:
 DC.L SCR1,SCR2

CLOCK:
 DC.W 0,0

A=32
C=33
D=34
E=35
BLOCKS:
 DS.B BWIDTH,1
 DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
 DC.B 1,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1
 DC.B 1,2,2,0,2,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0,0,3,3,0,0,0,0,0,0,0,5,6,7,0,0,1
 DC.B 1,0,0,0,0,0,0,0,0,D,0,0,0,0,4,4,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,1
 DC.B 1,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,0,0,0,0,1,1,1,0,0,0,0,0,E,0,0,0,0,0,0,1
 DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,2,2,2,2,2,2,0,0,0,0,1
 DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,2,2,0,0,0,1
 DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,C,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
 DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
 DC.B 1,0,A,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
 DS.B BWIDTH,1
 ALIGN.W

ASCII:
 DC.B 'WELCOME TO THE MAIN MENU FOR THE RETURN OF FLEXIBLE FRONT DEMO   '
 DC.B 'EIGTH OF SEPTEMBER NINETEEN NINTY    SORRY NO NUMBERS OR SPECIAL CHARACTERS IN THIS UGLY FONT   '
 DC.B 'USE CURSOR KEYS OR JOYSTICK TO CONTROL THE HAPPY FACE IN THE WORLD OF BLOCKY GRAPHICS   '
 DC.B 'PRESS FIRE OR SPACE WHEN CLOSE TO A DOOR TO ENTER DEMO SCREENS   '
 DC.B 'THIS MENU WAS CODED AND DESIGNED BY STALIN    I HOPE THIS DEMO WORKS ON ALL ST BECAUSE I HAVENT BEEN ABLE TO TEST IT   '
 DC.B 'NOW IM GOING TO WATCH A VIDEO FILM CALLED STREET TRASH    ARE THERE ANY GOOD HORROR AND GORE VHS SWAPPERS IN SWEDEN    '
 DC.B '   I GIVE UP    IT IS NOT POSSIBLE TO WRITE TEXT WITHOUT SPECIAL CHARACTERS     READ THE LITTLE SCROLLTEXT INSTEAD    '
 DC.B 'TIME TO WRAP             '
 DC.B 0
 ALIGN.W

DUMSTRING:
 DC.B '     GOOO GOO GAA GAA  THIS IS THE TEXT YOU SEE WHEN YOU ARE NOT POSITIONED ON A DOOR    PRETTY BORING TO READ   '
 DC.B ' BOOO BAHHH        '
 DC.B 0
 ALIGN.W

ASCIIS1:
 DC.B ' EINSTURZENDE NEUBAUTEN PARALLAX SCROLL SCREEN  CODE AND GRAFIX BY STALIN  '
 DC.B 'PRESS FIRE TO LOAD     '
 DC.B 0
 ALIGN.W

ASCIIS2:
 DC.B ' MEGA BIG FF SCREEN   CODE AND GRAFIX BY STALIN   LIKE IT OR NOT    '
 DC.B 0
 ALIGN.W

ASCIIS3:
 DC.B ' STRANGE LOOKING BITPLANES FROM OUTER SPACE SCREEN  CODE AND GRAFIX BY THE NEVER TIRING STALIN    '
 DC.B 0
 ALIGN.W

ASCIIS4:
 DC.B ' TWO DIMENSIONAL LIFE SCREEN   WRITTEN AND PRODUCED BY THE COCA COLA KID  '
 DC.B 'USE CURSOR INSERT AND RETURN KEYS TO CONTROL YOUR LIFE    '
 DC.B 0
 ALIGN.W


SASCII:
 DC.B 'THIS IS THE SMALL SCROLLER IN THE MAIN MENU OF THE FLEXIBLE FRONT '
 DC.B "COMEBACK DEMO... WELL IT'S NOT REALLY A COMEBACK DEMO, BECAUSE I DON'T THINK I WILL MAKE ANY MORE DEMOS. "
 DC.B "(HAVE YOU HEARD THAT BEFORE?)  THESE DAYS YOU HAVE TO WORK LIKE A MADMAN TO MAKE A DECENT DEMOSCREEN. "
 DC.B "I SHOULD WRITE SOME GREETINGS HERE, BUT I HAVEN'T KEPT MYSELF UP TO DATE WITH DEMOSWAPPING SO I CAN'T "
 DC.B "SAY WHICH DEMOGROUPS THAT ARE THE BEST ANYMORE. ONE PROGRAMMER THAT HAVE IMPRESSED VERY MUCH ON ME IS THE "
 DC.B "INCREDIBLE ZIGGY STARDUST FROM THE OVERLANDERS. YOUR SCREENS ARE GREAT, ZIGGY! "
 DC.B "SOME MORE NAMES THAT SPRINGS TO MIND:  THE LOST BOYS,  THE STARFIRES (BRILL FULLSCREEN),  THE ALLIANCE,  "
 DC.B "THE CAREBEARS,  SYNC,  OMEGA,  PHALLANX...     SOME FRIENDS: EARTHLIGHT,  JO+MARTIN+VILLE G,  BILBO,  BEAR OF BB,  "
 DC.B "DAN OF NIGHTBREED (WHERE ARE YOU?)      "
 DC.B "FORGIVE ME FOR FORGETTING ALL OTHERS.  PROGRAMS USED TO MAKE THIS DEMO:  ASSEMPRO ASSEMBLER (YES, I STILL USE IT, "
 DC.B "EVEN THOUGH I SEEM TO BE THE ONLY ONE!),  ART STUDIO,  DEGAS ELITE,  GFA BASIC,  AUTOMATION PACKER.   "
 DC.B "LETTERS, LETTERS, LETTERS... I HAVE BEEN TOTALLY DROWNED IN LETTERS EVER SINCE I WAS STUPID ENOUGH TO "
 DC.B "WRITE THAT I WOULD GIVE AWAY MY SOURCES. I DO MY BEST TO ANSWER THEM, BUT I KNOW SOME OF YOU HAVE BEEN WAITING 4 "
 DC.B "MONTHS AND MORE. PLEASE FORGIVE ME, BUT REMEMBER I DO THIS WITHOUT ASKING MONEY FOR IT. ALSO REMEMBER THAT I DO "
 DC.B "ABSOLUTELY NOT SWAP ANY GAMES.      "
 DC.B "GOOD NEWS, SKINNY PUPPY WILL SOON RELEASE A NEW ALBUM!!! GREAT HUH? I KNOW SOME OF YOU THINK SO...       "
 DC.B "DO YOU SWAP GORE/SPLATTER VHS FILMS?  SEND ME A LIST IF YOU DO... SAME ADRESS AS USUAL. (SEE SOWATT)   "
 DC.B "THIS DEMO IS IN FILE FORMAT SO THAT IT CAN BE UPLOADED IN A BBS. PLEASE SPREAD IT FREELY. "
 DC.B "   SIMPLY... ENJOY!!!      LONG LIVE THE ATARI AND ALL THE GREAT DEMO GROUPS!!!        "
 DC.B "GO SEE TOTAL RECALL, BEST ARNIE FILM AFTER TERMINATOR!      "
 DC.B "SCROLLTEXT RESTART           "
 DC.B 0
 ALIGN.W

BLOCKGRAF:
 IBYTES MENU.DAT

UPFONT:
 IBYTES FILLFONT.DAT

SMALLFONT:
 IBYTES SMALLFNT.DAT

REFSIN:
 IBYTES REFLEX.SIN
 IBYTES REFLEX.SIN,80
 DC.W -1

FFY:
 IBYTES FFY.SIN
 DC.W 0

FFX:
 IBYTES FFX.SIN,160
 DC.W 0
 ALIGN.W

MUSIC:
 IBYTES JUG.IMG,$3B88

GUBBGRAF:
 IBYTES GUBBE.DAT      ;EXPANDS

FFDAT:
 IBYTES FF.DAT

REFLEXPIC:
 IBYTES REFLEX.PIC

FONTGRAF:
 DS.B 32*8,0           ;SPACE CHARACTER
 IBYTES FONT6432.DAT

BALLGX:
 IBYTES BALLS.DAT

SCREENGRAF EQU GUBBGRAF+(NOSPR*384)
FONT EQU SCREENGRAF+(4*L)
BUFF1 EQU SCREENGRAF+(4*L)+20000
BALLGRAF EQU SCREENGRAF+(4*L)+26000
REFGRAF EQU SCREENGRAF+(4*L)+38000
FFGRAF EQU SCREENGRAF+(4*L)+70000
 END

 