;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Radix 2, In-Place, Decimation-In-Time FFT (fast).
; 
; Last Update 04 Feb 87   Version 1.2
;
fftr2c  macro   points,data,coef
fftr2c  ident   1,2
;
; Radix 2 Decimation in Time In-Place Fast Fourier Transform Routine
;
;    Complex input and output data
;        Real data in X memory
;        Imaginary data in Y memory
;    Normally ordered input data
;    Bit reversed output data
;       Coefficient lookup table
;        -Cosine values in X memory
;        -Sine values in Y memory
;
; Macro Call - fftr2c   points,data,coef
;
;       points     number of points (16-32768, power of 2)
;       data       start of data buffer
;       coef       start of sine/cosine table
;
; Alters Data ALU Registers
;       x1      x0      y1      y0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0      n0      m0
;       r1      n1      m1
;               n2
;
;       r4      n4      m4
;       r5      n5      m5
;       r6      n6      m6
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 6 locations on System Stack
;
; Latest Revision -  4-Feb-87
;
        move    #data,r0        ;initialize input pointer
        move    #points/4,n0    ;initialize butterflies per group
        move    n0,n4           ;initialize pointer offsets
        move    n0,n6           ;initialize coefficient offset
        move    #points-1,m0    ;initialize address modifiers
        move    m0,m1           ;for modulo(points) addressing
        move    m0,m4
        move    m0,m5
;
; Do first and second Radix 2 FFT passes
;
        move            x:(r0)+n0,x0
        tfr     x0,a    x:(r0)+n0,y1

        do      n0,_twopass
        tfr     y1,b    x:(r0)+n0,y0
        add     y0,a    x:(r0),x1                       ;ar+cr
        add     x1,b    r0,r4                           ;br+dr
        add     a,b     (r0)+n0                         ;ar'=(ar+cr)+(br+dr)
        subl    b,a     b,x:(r0)+n0                     ;br'=(ar+cr)-(br+dr)
        tfr     x0,a    a,x0            y:(r0),b
        sub     y0,a                    y:(r4)+n4,y0    ;ar-cr
        sub     y0,b    x0,x:(r0)                       ;bi-di
        add     a,b                     y:(r0)+n0,x0    ;cr'=(ar-cr)+(bi-di)
        subl    b,a     b,x:(r0)                        ;dr'=(ar-cr)-(bi-di)
        tfr     x0,a    a,x0            y:(r4),b
        add     y0,a                    y:(r0)+n0,y0    ;bi+di
        add     y0,b    x0,x:(r0)+n0                    ;ai+ci
        add     b,a                     y:(r0)+,x0      ;ai'=(ai+ci)+(bi+di)
        subl    a,b                     a,y:(r4)+n4     ;bi'=(ai+ci)-(bi+di)
        tfr     x0,a                    b,y:(r4)+n4
        sub     y0,a    x1,b                            ;ai-ci
        sub     y1,b    x:(r0)+n0,x0                    ;dr-br
        add     a,b     x:(r0)+n0,y1                    ;ci'=(ai-ci)+(dr-br)
        subl    b,a                     b,y:(r4)+n4     ;di'=(ai-ci)-(dr-br)
        tfr     x0,a                    a,y:(r4)+
_twopass
;
; Do all FFT passes but first, second and last pass
;
        move    #points/8,n0    ;initialize butterflies per group
        move    #4,n2           ;initialize groups per pass
        move    #0,m6           ;initialize coefficient address modifier
                                ;for reverse carry (bit reversed) addressing

        do      #@cvi(@log(points)/@log(2)-2.5),_end_pass
        move    #data,r0                ;initialize A input pointer
        move    r0,r4                   ;initialize A output pointer
        lua     (r0)+n0,r1      ;initialize B input pointer
        move    #coef,r6        ;initialize C input pointer
        lua     (r1)-,r5        ;initialize B output pointer
        move    n0,n1           ;initialize pointer offsets
        move    n0,n4
        move    n0,n5

        do      n2,_end_grp
        move    x:(r1),x1       y:(r6),y0       ;lookup -sine value
        move    x:(r5),a        y:(r0),b
        move    x:(r6)+n6,x0            ;lookup -cosine value


        do      n0,_end_bfy    ;Radix 2 DIT butterfly kernel with constant
        mac     x1,y0,b                         y:(r1)+,y1    ;twiddle factor
        macr    -x0,y1,b        a,x:(r5)+       y:(r0),a
        subl    b,a             x:(r0),b        b,y:(r4)
        mac     -x1,x0,b        x:(r0)+,a       a,y:(r5)
        macr    -y1,y0,b        x:(r1),x1
        subl    b,a             b,x:(r4)+       y:(r0),b
_end_bfy
        move    a,x:(r5)+n5     y:(r1)+n1,y1    ;dummy load of x1 and y1
        move    x:(r0)+n0,x1    y:(r4)+n4,y1
_end_grp
        move    n0,b1
        lsr     b       n2,a1   ;divide butterflies per group by two
        lsl     a       b1,n0   ;multiply groups per pass by two
        move            a1,n2
_end_pass
;
; Do last FFT pass
;
        move    n1,n0           ;correct pointer offset for last pass
        move    #data,r0        ;initialize A input pointer
        move    r0,r4           ;initialize A output pointer
        lua     (r0)+,r1        ;initialize B input pointer
        move    #coef,r6        ;initialize C input pointer
        lua     (r1)-n1,r5      ;initialize B output pointer
        move    x:(r1),x1       y:(r6),y0
        move    x:(r5),a        y:(r0),b

        do      n2,_lastpass    ;Radix 2 DIT butterfly kernel with one
        mac     x1,y0,b x:(r6)+n6,x0    y:(r1)+n1,y1    ;butterfly per group
        macr    -x0,y1,b        a,x:(r5)+n5     y:(r0),a
        subl    b,a     x:(r0),b        b,y:(r4)
        mac     -x1,x0,b        x:(r0)+n0,a     a,y:(r5)
        macr    -y1,y0,b        x:(r1),x1       y:(r6),y0
        subl    b,a             b,x:(r4)+n4     y:(r0),b
_lastpass
        move    a,x:(r5)+n5
        endm
