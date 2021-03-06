*******
* Write disc number to disc STE version
******
*

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldstack

COUNT		equ	1	;number of sectors to write
START_TRACK	equ	80


write_loop	move.w	#1,-(sp)	;no. sectors to write
		move.w	#1,-(sp)	;side
		move.w	#0,-(sp)	;track
		move.w	#1,-(sp)	;sector
		clr.w	-(sp)		;floppy drive A
		clr.l	-(sp)		;reserved
		move.l	#blank,-(sp)	;buffer to write from
		move.w	#9,-(sp)
		trap	#14
		lea	20(sp),sp

		move.l	d7,d0
		bsr	printn

		move.l	oldstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)
		trap	#1

;************************************
;* Print out any number in any base *
;*     D0.L=number / D1.L=base      *
;*         Uses D0, D1, A0          *
;************************************
printn
	move.l	#10,d1		;decimal
	LEA buffer(PC),A0	A0=buffer
	CLR.L (A0)+		Zero buffer
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+
	CLR.L (A0)+       A0->buffer end
loop1
	DIVU D1,D0        D0 DIV D1
	SWAP D0           D0.low=remainder
	ADDI #'0',D0      Make into digit
	CMPI #'9',D0      Digit or letter?
	BLE ok
	ADDQ #7,D0        Make into letter
ok
	MOVE.B D0,-(A0)   Store character
	CLR D0
	SWAP D0           D0.low=quotient
	BNE loop1         Another one?
loop2
	MOVE.L A0,-(A7)
	pea	at
	MOVE	#9,-(A7)	Print string
	TRAP	#1		GEMDOS 9
	ADDQ.L	#6,A7		Tidy stack

_conws
	MOVE #9,-(A7)	Print string
	TRAP #1		GEMDOS 9
	ADDQ.L #6,A7	Tidy stack
	RTS
buffer
	DS.L 5		Number$ - 20 digits
	DC.B 0		Buffer end marker
	EVEN

at	dc.b	27,'Y',32+0,32+0,"Writing track: ",27,'Y',32+0,32+15

oldstack	dc.l	0

blank		dc.b	"DSK1"
		dcb.l	18*512/4,"POV!"
