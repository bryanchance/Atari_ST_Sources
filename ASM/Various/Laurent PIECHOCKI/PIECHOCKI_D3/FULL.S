main:
 clr.w   -(a7)
 move.w  #$20,-(a7)
 trap    #1
 addq.l  #6,a7
 move.w  #$2700,sr
 move.l  #$70000,a0
 moveq   #0,d0
 move.l  #$ed6e,d1
 move.l  d0,d2
 move.l  d1,d3
 move.w  #$273,d7
fillscreen:
 moveq   #$d,d6
 subq.l  #$6,a0
fillline:
 movem.l d0-d3,-(a0)
 dbra    d6,fillline
 dbra    d7,fillscreen
 lea     230-204(a0),a0
 move.l  a0,d0
 lsr.l   #8,d0
 lea     $ffff8200,a0
 movep.w d0,1(a0)
 lea     vsync(pc),a0
 move.l  a0,$70.w
 moveq   #$0,d0
 lea     $ffff800a.w,a0
 movep.w d0,7(a0)
 moveq   #$2,d1
 lea     $ffff820a.w,a0
 lea     $ffff8260.w,a1
 move.b  d1,(a0)
 move.b  d0,(a1)
 stop    #$2300
 stop    #$2300
 move.w  #$2700,sr
 move.w  #$594,d4
fullscreen:
 dbra    d4,fullscreen
 move.b  d0,(a0)
 moveq   #$1a,d4
 lsr.l   d4,d0
 move.w  #$111,d3
 move.b  d1,(a0)
 lsr.l   d4,d4
 moveq   #24,d0
 sub.b   $ffff8209.w,d0
 lsr.l   d0,d0
 moveq   #19,d4
scanline:
 dbra    d4,scanline
 move.b  d0,(a0)
 moveq   #$2,d1
 move.b  d1,(a0)
 cmp.w   #$3d,d3