	opt s-
	jmp go
john	incbin	l:\john
go	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	clr.w $ffff8240.w
	move.w #$777,$ffff825e
	pea text(pc)
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp
	move.l #$18000,d0
cc	eor.w #$7,$ffff8240.w
	subq.l #1,d0
	bne.s cc
	move.w #$2700,sr
	clr.b $fffffa07
	clr.b $fffffa09
	lea john,a0
	lea $1000,a1
aa	move.w (a0)+,(a1)+
	eor.w #$070,$ffff8240.w
	cmp.l #go,a0
	blt.s aa
	lea run,a0
	lea $f7000,a1
.1	move.w (a0)+,(a1)+
	cmp.l #$f7ff0,a1
	bne.s .1
	jmp $f7000
run	lea $1000.w,a0
	lea $2000.w,a1
	bsr depack
	lea $1000,a0
	lea $2000,a1
.1	move.w (a1)+,(a0)+
	eor.w #$700,$ffff8240.w
	cmp.l #$f7000,a1
	bne.s .1
	lea $f458e,a0
	move.l #$203c000f,(a0)+
	move.l #$ffff5380,(a0)+
	move.w #$66fc,(a0)+
	jmp $e8000

depack	movem.l	d0-a6,-(sp)
	bsr.s	getinfo		; ein Langwort holen
	bsr.s	getinfo		; gepackte L�nge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	getinfo		; ungepackte L�nge holen (original)
	move.l	d0,(sp)		; Originall�nge: sp�ter nach d0
	move.l	a1,a4		; a4 = Zielpuffer
	move.l	a1,a6
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a3		; merken f�r Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr	normal_bytes
	movem.l	(sp)+,d0-a6
	rts

getinfo:	moveq	#3,d1		; ein Langwort vom Anfang
getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,getbytes
	rts

normal_bytes:	
	bsr.s	get_1_bit
	bcc.s	test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	get_1_bit
	bcc.s	copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	direkt_tab+20(pc),a1
	moveq.l	#4,d3
nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,nextgb 	; ja: dann weiter Bits lesen
no_more:	add.l	20(a1),d1 	; Anzahl der zu �bertragenen Bytes
copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	move.b (a6),$ffff8240.w
	dbf	d1,copy_direkt	; noch ein Byte
test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schlu�

get_1_bit:add.b	d7,d7		; hole ein bit
	bne.s	bitfound		; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
bitfound:	rts	

get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
on_d0:	addx.w	d1,d1		; und �bernimm es
	dbf	d0,hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


strings:	lea.l	length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
get_length_bit:	
	bsr.s	get_1_bit
	dbcc	d2,get_length_bit	; n�chstes Bit holen
no_length_bit:	
	moveq.l	#0,d4		; d4 = �berschu�-L�nge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	no_�ber		; kein �berschu� n�tig
get_�ber: bsr.s	get_d0_bits
no_�ber:	move.b	6(a1,d2.w),d4	; Standard-L�nge zu �berschu� add.
	add.w	d1,d4		; d4 = String-L�nge-2
	beq.s	get_offset_2	; L�nge = 2: Spezielle Offset-Routine


	lea.l	more_offset(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
getoffs:	bsr.s	get_1_bit
	dbcc	d2,getoffs
	moveq.l	#0,d1		; Offset-�berschu�
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu �berschu� add.
	bpl.s	depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	depack_bytes


get_offset_2:	
	moveq.l	#0,d1		; �berschu�-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	get_1_bit
	bcc.s	less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
less_40:	bsr.s	get_d0_bits
	add.w	d2,d1		; Standard-Offset + �ber-Offset

depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,dep_b		; und noch ein Mal
	bra	normal_bytes	; Jetzt kommen wieder normale Bytes


direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-L�nge - 2 (!!!)

more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset


text	dc.b 27,'E',27,'f',27,'w'
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ CYNIX bring you:                     +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ JOHN BARNE'S EUROPEAN FOOTBALL       +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Cracked/Packed/Filed by ABSU         +",10,13
	dc.b "+ Original Supplied by SUPREME         +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++",10,13
	dc.b "+                                      +",10,13
	dc.b "+ The original of this game required 1 +",10,13
	dc.b "+ Meg of Memory so I just made this    +",10,13
	dc.b "+ single part 1 Meg file version.      +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Hi to:                               +",10,13
	dc.b "+ Replicants, Elite, ICS, Hotline/MCA, +",10,13
	dc.b "+ Superior, Vectronix, Bald Eagle,     +",10,13
	dc.b "+ Wizpop, Derek, D-Bug and Mad Vision. +",10,13
	dc.b "+                                      +",10,13
	dc.b "+ Press any key to start the game....  +",10,13
	dc.b "+                                      +",10,13
	dc.b "++++++++++++++++++++++++++++++++++++++++"
	even
	dc.w 0
