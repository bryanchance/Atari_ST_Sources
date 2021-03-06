points=900

	SECTION	TEXT

 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
* EXCEPTIONS
	MOVE.L	#SORTIE,$10	;INSTRUCTION ILLEGALE
	MOVE.L	#SORTIE,$8		;ERREUR BUS
	MOVE.L	#ENABLE,$14	;/0
	MOVE.L	#SORTIE,$C		;ERREUR D'ADRESSE

	MOVE.B	#18,$FFFFC02
	MOVE.B	#21,$FFFFFC02.W
	bsr	SAVE_RAST
	bsr	INSTAL_INTER
	move.l	#NEW_VBL,$70.w
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	MOVE.L	#SAVE_POINT,SAVE1
	MOVE.L	#SAVE_POINT2,SAVE2	
	MOVE.L	#SAVE_POINT3,SAVE3
	MOVE.L	#SAVE_POINT4,SAVE4
	MOVE.L	#SAVE_POINT5,SAVE5
	MOVE.L	#SAVE_POINT6,SAVE6
	MOVE.L	#SAVE_POINT7,SAVE7
	MOVE.L	#SAVE_POINT8,SAVE8
	lea.l colors,a0
	lea.l $FFFF9800,a1
	move.l (a0),4(a1)
	move.l (a0),8(a1)
	move.l (a0),16(a1)
	move.l (a0)+,32(a1)
	move.l (a0),12(a1)
	move.l (a0),20(a1)
	move.l (a0),24(a1)
	move.l (a0),36(a1)
	move.l (a0),40(a1)
	move.l (a0),44(a1)
	move.l (a0)+,48(a1)
	move.l (a0),28(a1)
	move.l (a0),52(a1)
	move.l (a0)+,56(a1)
	move.l (a0),60(a1)
*******
LOOP
	BSR	VBL
	MOVE.L	#$33050041,$FFFF9800		
	CLR.B	$FFFFFA1B.w
	MOVE.L	#TIMER_B,$120.w
	MOVE.B	#1,$FFFFFA21.w
	MOVE.B	#8,$FFFFA1B
	CLR	COMPT
	BSR	EFFA2	
	BSR	AFF_DOTS
	MOVEM.L	A0-A2,-(SP)		; syncro ecran
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	move.b 	affecr+3,$ffff820d.w
*	BSR	SHADE
	MOVEM.L	(SP)+,A0-A2
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
*******

	BRA	SORTIE
***************************INITIALISATIONS*********************************************************
INITS
	MOVEC.L	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	MOVE.L	#SCREEN,D0	
	ADD.L	#10000,D0
	ANDI.L	#$FFFFFF00,D0
	MOVE.L	D0,SCREEN_ADD

;		  XXXXXXXFSOPV8NNN : flags pour rezs
 	MOVE.W	#%0000000001100011,-(SP)	
	MOVE.W	#3,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.L	SCREEN_ADD,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP

	move	#50,$FFFF82A8.w		;OVER HAUT
	move	#611,$FFFF82AA.w		;BAS

 	move.l $44e.w,d0
	MOVE.L	d0,A1
	add.l	#74240*2,d0
	MOVE.L	d0,A2
	MOVE.L	A1,AFFECR
	MOVE.L	A2,WORKECR
	RTS

	
********************SOUS ROUTINES*****************************************************
ENABLE:
	RTE
SAVE_RAST:
	move.l	$120.W,OLD_HBL
	MOVE.L	$70.W,OLD_VBL
	move.b	$fFfffa1b.W,SAVE_A1B
	move.b	$fFfffa09.W,SAVE_A09
	move.b	$fFfffa21.W,SAVE_A21
	move.b	$fFfffa07.W,SAVE_A07
	move.b	$fFfffa13.W,SAVE_A13
	RTS
NEW_VBL
	addq	#1,$466.w
	rte
SHADE
	MOVE.L	SAVE1,A0		;swap zones de sauvegarde
	MOVE.L	SAVE2,A1
	MOVE.L	SAVE3,A2
	MOVE.L	SAVE4,A3
	MOVE.L	SAVE5,A4
	MOVE.L	SAVE6,A5
	MOVE.L	SAVE7,A6
	MOVE.L	SAVE8,D1
	EXG	A0,A1
	EXG	A1,A2
	EXG	A2,A3
	EXG	A3,A4
	EXG	A4,A5
	EXG	A5,A6
	EXG	A6,D1
	MOVE.L	A0,SAVE1
	MOVE.L	A1,SAVE2
	MOVE.L	A2,SAVE3
	MOVE.L	A3,SAVE4
	MOVE.L	A4,SAVE5
	MOVE.L	A5,SAVE6
	MOVE.L	A6,SAVE7
	MOVE.L	D1,SAVE8
*	addq.l 	#2,affecr
*	move.w 	affecr+2,d0
*	andi.w 	#8,d0			; si on a fait les 4 plans			
*	cmpi.w	#8,d0
*	bne.s 	trainee			; on boucle
* 	sub.w 	#8,affecr+2
*trainee
	RTS
CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts

AFF_DOTS
	MOVE.L	SAVE1,A3
	LEA	Y_TABLE,A5
	LEA	TAB,A4
	MOVE.L	WORKECR,A0	
	LEA	COORD,A1
	MOVE.W	#points,D4
	MOVE.L	#$3111,D0		;cache on
	MOVEC.L	D0,CACR
	MOVEQ	#9,D0		;pour decalages/512
PROJ
;Q
	MOVE.W	#512,D3
	MOVE.W	(A1),D1
	SUB.W	D1,D3	;512-4*ZE=Q*512
	MOVE.L	2(A1),D1
	DIVS	D3,D1	;XE*512/Q*512=X
	ADD.W	#192,D1	;X EN D1
	MOVE.L	6(A1),D2
	DIVS	D3,D2
	ADD.W	#135,D2	;Y EN D2
****AFFICHE DOTS
PLAN1
	MOVE.W	(A5,D2.W*2),D7 		; coord y
	MOVE.L	(A4,D1.W*4),D6		; coord x
	ADD.W	D6,D7
	SWAP	D6
	OR.W	D6,(A0,D7.L)	
	MOVE.W	D7,(A3)+
	ADD.W	#6*4,(A1)			;test pour scroll 
	BMI.S	NO_400			;des pts
	MOVE.W	#-500*4,(A1)
NO_400
	LEA	10(A1),A1
	DBF	D4,PROJ
	MOVE.L	#$2510,D0		;cache on
	MOVEC.L	D0,CACR
	RTS		
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	MOVE.L	WORKECR,A1
	MOVEQ.L	#0,D1
	MOVE.W	#18269,D0
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
OK
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,OK
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A0-a1
	RTS
EFFA2
	MOVE.L	WORKECR,A0		
	MOVE.W	#points/15,D7
	MOVEQ.W	#0,D2
	MOVEQ.W	#0,D5
	MOVE.L	SAVE1,A1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	15
	MOVE.W	(A1)+,D5
	MOVE.W	D2,(A0,D5.L)
	ENDR
	DBF	D7,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
INSTAL_INTER:
	MOVE	#$2700,SR
	CLR.B 	$FFFFFA1B.W	STOP TIMER B
	CLR.B 	$FFFFFA21.W	STOP TIMER B
	MOVE.B 	#%00000001,$FFFFFA07.W ;ENABLE TIMER A
	MOVE.B 	#%00000001,$FFFFFA13.W
	MOVE.B	#%01000000,$FFFFFA09.W
	MOVE	#$2300,SR
	RTS
TIMER_B:
*	MOVE.L	AFFECR,SAVE_AFFECR
*	ADDI.L	#768,ADR_SCR
*	MOVE.L	ADR_SCR,D1
*	MOVE.L	AFFECR,A0
*	ADD.L	#768*135,A0
*	ADD.L	#768*12,AFFECR
	
*	MOVE.B	AFFECR+1,$FFFF8201.W
*	MOVE.B	AFFECR+2,$FFFF8203.W
*	MOVE.B	AFFECR+3,$FFFF8209.W
*	SUB.L	D1,AFFECR
*	MOVE.W	COMPT,$ffff9800
*	MOVE.L	SAVE_AFFECR,AFFECR

	ADDQ	#1,COMPT
	CMPI	#240,COMPT
	BLE.S	.NO_END
	CLR.B	$FFFFFA1B.w
	CLR.B	$FFFFFA21.w
.NO_END	
	BCLR	#0,$FFFFFA0F.W
	RTE
**************************************************************************************
SORTIE	
	MOVE	#$2700,SR
	MOVE.B	SAVE_A09,$FFFFFA09.W
	MOVE.B	SAVE_A07,$FFFFFA07.W	
	MOVE.B	SAVE_A1B,$FFFFFA1B.W	
	MOVE.B	SAVE_A21,$FFFFFA21.W	
	MOVE.B	SAVE_A13,$FFFFFA13.W	
	MOVE.L	OLD_VBL,$70.W
	MOVE.L	OLD_HBL,$120.W
	MOVE	#$2300,SR
	CLR	$FFFF8264.W
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	SECTION	DATA
OLD_VBL		DC.L	0
OLD_HBL		DC.L	0
OLD_A09		DC.B	0
SAVE1		DC.L	0
SAVE2		DC.L	0
SAVE3		DC.L	0
SAVE4		DC.L	0
SAVE5		DC.L	0
SAVE6		DC.L	0
SAVE7		DC.L	0
SAVE8		DC.L	0
OLD_CACR		DC.L	0
SCREEN_ADD		DC.L	0
COMPT		DC.W	0
ADD_SCR		DC.L	0
ZE		DC.W	0
XE		DC.W	0
YE		DC.W	0
SAVE_AFFECR	DC.L	0
AFFECR:		DC.L 	0
WORKECR:		DC.L 	0
OLDXBIOS2:		DC.L	0
OLDMODECODE	DC.W	0
*colors		dc.l	$60200060,$80400080,$A06000A0,$C06000C0
colors		dc.l	$005F007F,$007F009F,$009F00BF,$00DF00FF
************
COORD		INCBIN	"F:STAR.INL"
**************************
Y_TABLE
OXO	SET	0
	REPT	140
	DC.W	OXO
OXO	SET	OXO+384
	ENDR
	DCB.L	500*0
TAB	
OXO	SET	0	
	REPT	24
	DC	32768,OXO,16384,OXO,8192,OXO,4096,OXO
	DC	2048,OXO,1024,OXO,512,OXO,256,OXO
	DC	128,OXO,64,OXO,32,OXO,16,OXO
	DC	8,OXO,4,OXO,2,OXO,1,OXO
OXO	SET	OXO+16
	ENDR
	SECTION	BSS
SAVE_A1B:		DS.B	1
SAVE_A21:		DS.B	1
SAVE_A07:		DS.B	1
SAVE_A09:		DS.B	1
SAVE_A13:		DS.B	1
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
SCREEN		DS.W	200000
SAVE_POINT		DS.W	4000
SAVE_POINT2	DS.W	4000
SAVE_POINT3	DS.W	4000
SAVE_POINT4	DS.W	4000
SAVE_POINT5	DS.W	4000
SAVE_POINT6	DS.W	4000
SAVE_POINT7	DS.W	4000
SAVE_POINT8	DS.W	4000
		END
