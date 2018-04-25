.PC02
.DEFINE EQU	=
.DEFINE DB	.BYTE
.DEFINE DW	.WORD
.DEFINE DS	.RES
.DEFINE ORG	.ORG
.DEFINE STKCHK  1
.DEFINE TMRCHK  1
;**********************************************************
;*
;* SYSTEM ROUTINES AND LOCATIONS
;*
;**********************************************************
;*
;* MONITOR SPECIAL LOCATIONS AND PRODOS MLI
;*
CSWL	EQU	$36
CSWH	EQU	$37
PROMPTCHAR EQU	$33
PRODOS	EQU	$BF00
MACHID	EQU	$BF98
;*
;* HARDWARE ADDRESSES
;*
KEYBD	EQU	$C000
CLRKBD	EQU	$C010
SPKR	EQU	$C030
ROMIN	EQU	$C081
LCBNK2	EQU	$C083
LCBNK1	EQU	$C08B
ALTZPOFF EQU	$C008
ALTZPON EQU	$C009
ALTRAMRDOFF	EQU	$C002
ALTRAMRDON	EQU	$C003
ALTRAMWROFF	EQU	$C004
ALTRAMWRON	EQU	$C005
;*
;* AUXMEM ACCESS MACROS
;*
.IF	IS65C02
.MACRO	AUXZP_ACCESS_ON
	STA	ALTZPON		; TURN ON ALT ZP AND LC
.ENDMACRO
.MACRO	AUXZP_ACCESS_OFF
	STA	ALTZPOFF	; TURN OFF ALT ZP AND LC
.ENDMACRO
.MACRO	AUXMEM_RDACCESS_ON
	STA	ALTRAMRDON
.ENDMACRO
.MACRO	AUXMEM_RDACCESS_OFF
	STA	ALTRAMRDOFF
.ENDMACRO
.MACRO	AUXMEM_WRACCESS_ON
	STA	ALTRAMWRON
.ENDMACRO
.MACRO	AUXMEM_WRACCESS_OFF
	STA	ALTRAMWROFF
.ENDMACRO
.ELSE
.MACRO	AUXZP_ACCESS_ON
	SEI			; TURN INTERRUPTS OFF
	STA	ALTZPON		; TURN ON ALT ZP AND LC
.ENDMACRO
.MACRO	AUXZP_ACCESS_OFF
	STA	ALTZPOFF	; TURN OFF ALT ZP AND LC
	CLI			; TURN INTERRUPTS BACK ON
.ENDMACRO
.MACRO	AUXMEM_RDACCESS_ON
	SEI
	STA	ALTRAMRDON
.ENDMACRO
.MACRO	AUXMEM_RDACCESS_OFF
	STA	ALTRAMRDOFF
	CLI
.ENDMACRO
.MACRO	AUXMEM_WRACCESS_ON
	SEI
	STA	ALTRAMWRON
.ENDMACRO
.MACRO	AUXMEM_WRACCESS_OFF
	STA	ALTRAMWROFF
	CLI
.ENDMACRO
.ENDIF
;*
;* SIMPLIFUED ACCESS MACROS
;*
.IF	IS65C02
.MACRO	LDA_IPC
	LDA	(PC)
.ENDMACRO
.MACRO	LDA_ITMPL
	LDA	(TMP)
.ENDMACRO
.MACRO	LDA_ITMPH
	LDY	#$01
	LDA	(TMP),Y
.ENDMACRO
.MACRO	LDA0
	LDA	#$00
.ENDMACRO
.MACRO	STA_ITMPL
	STA	(TMP)
.ENDMACRO
.MACRO	STA_ITMPH
	LDY	#$01
	STA	(TMP),Y
.ENDMACRO
.MACRO	ST0	ADDR
	STZ	ADDR
.ENDMACRO
.MACRO	CLRY
.ENDMACRO
.ELSE
.MACRO	LDA_IPC
	LDA	(PC),Y
.ENDMACRO
.MACRO	LDA_ITMPL
	LDA	(TMP),Y
.ENDMACRO
.MACRO	LDA_ITMPH
	INY
	LDA	(TMP),Y
	DEY
.ENDMACRO
.MACRO	LDA0
	TYA
.ENDMACRO
.MACRO	STA_ITMPL
	STA	(TMP),Y
.ENDMACRO
.MACRO	STA_ITMPH
	INY
	STA	(TMP),Y
	DEY
.ENDMACRO
.MACRO	ST0	ADDR
	STY	ADDR
.ENDMACRO
.MACRO	CLRY
	LDY	#$00
.ENDMACRO
.ENDIF

;**********************************************************
;*
;* VM ZERO PAGE LOCATIONS
;*
;**********************************************************
ESTKSZ	EQU	$20
ESTK	EQU	$C0
ESTKL	EQU	ESTK
ESTKH	EQU	ESTK+ESTKSZ/2
VMZP	EQU	ESTK+ESTKSZ
FRMP	EQU	VMZP+$00
FRMPL	EQU	FRMP
FRMPH	EQU	FRMP+1
PC	EQU	VMZP+$02
PCL	EQU	PC
PCH	EQU	PC+1
TICK	EQU	VMZP+$04
ESP	EQU	VMZP+$05

TMP	EQU	VMZP+$0A
TMPL	EQU	TMP
TMPH	EQU	TMP+1
TMPX	EQU	TMP+2
NPARMS	EQU	TMPL
FRMSZ	EQU	TMPH
DVSIGN	EQU	TMPX
JSROP	EQU	VMZP+$0D

	ORG	$D000
;*
;* OPCODE TABLE
;*
OPTBL:	DW	ZERO,ADD,SUB,MUL,DIV,DIVMOD,INCR,DECR		; 00 02 04 06 08 0A 0C 0E
	DW	NEG,COMP,BAND,IOR,XOR,SHL,SHR,IDXW		; 10 12 14 16 18 1A 1C 1E
	DW	NOT,LOR,LAND,LA,LLA,CB,CW,SWAP			; 20 22 24 26 28 2A 2C 2E
	DW	DROP,DUP,PUSH,PULL,SKPLT,SKPGT,SKPEQ,SKPNE	; 30 32 34 36 38 3A 3C 3E
	DW	ISEQ,ISNE,ISGT,ISLT,ISGE,ISLE,SKPFLS,SKPTRU	; 40 42 44 46 48 4A 4C 4E
	DW	SKIP,ISKIP,CALL,ICAL,ENTER,LEAVE,RET,INT 	; 50 52 54 56 58 5A 5C 5E
	DW	LB,LW,LLB,LLW,LAB,LAW,DLB,DLW			; 60 62 64 66 68 6A 6C 6E
	DW	SB,SW,SLB,SLW,SAB,SAW,DAB,DAW			; 70 72 74 76 78 7A 7C 7E
;*
;* OPXCODE TABLE
;*
OPXTBL: DW	ZERO,ADD,SUB,MUL,DIV,DIVMOD,INCR,DECR		; 00 02 04 06 08 0A 0C 0E
	DW	NEG,COMP,BAND,IOR,XOR,SHL,SHR,IDXW		; 10 12 14 16 18 1A 1C 1E
	DW	NOT,LOR,LAND,LAX,LLAX,CBX,CWX,SWAP		; 20 22 24 26 28 2A 2C 2E
	DW	DROP,DUP,PUSH,PULL,SKPLTX,SKPGTX,SKPEQX,SKPNEX	; 30 32 34 36 38 3A 3C 3E
	DW	ISEQ,ISNE,ISGT,ISLT,ISGE,ISLE,SKPFLSX,SKPTRUX	; 40 42 44 46 48 4A 4C 4E
	DW	SKIPX,ISKIPX,CALLX,ICAL,ENTER,LEAVE,RET,INTX	; 50 52 54 56 58 5A 5C 5E
	DW	LB,LW,LLBX,LLWX,LABX,LAWX,DLBX,DLWX		; 60 62 64 66 68 6A 6C 6E
	DW	SB,SW,SLBX,SLWX,SABX,SAWX,DABX,DAWX		; 70 72 74 76 78 7A 7C 7E
;*
;* COMMAND LOADER CODE
;*
	CLD
	CLV
	BVC	:+
	JMP	PLASMA
:
	.INCLUDE	"cmd.byte"

;***********************************************
;*
;* INTERPRETER INITIALIZATION
;*
;***********************************************
;*
;* INIT AND ENTER INTO PLASMA BYTECODE INTERPRETER
;*   X:Y:A = ADDRESS OF INITAL ENTRYPOINT
;*
PLASMA: STA	PCL
	STY	PCH
	STX	TMP
	CLD
	LDY	#$20
:	LDA	PAGE3,Y
	STA	$03D0,Y
	DEY
	BPL	:-
	LDX	#ESTKSZ/2
	INY		; LDY	#$00
	STY	TICK
	LDA	#$6C
	STA	JSROP
	LDA	#>OPTBL
	STA	JSROP+2
	LDA	TMP
	BEQ	FETCHOP
	LDA	MACHID
	AND	#$30
	CMP	#$30
	BEQ	FETCHOPX
_RTS:	RTS
_BRK:	BRK
;*
;* PAGE 3 VECTORS INTO INTERPRETER
;*
PAGE3:	BIT	$C080		; $03D0 - INTERP ENTRY
	JMP	_INTERP
	BIT	$C080		; $03D6 - INTERPX ENTRY
	JMP	_INTERPX
	BIT	$C080		; $03DC - LEAVE ENTRY
	JMP	_LEAVE
	BIT	$C080		; $03E2 - ENTER ENTRY
	JMP	_ENTER
	DW	_RTS		; $03E8 - PERIODIC VECTOR
	DW	_BRK		; $03EA - INT VECTOR
TMRVEC	EQU	$03E8
INTVEC	EQU	$03EA
;*
;* ENTER INTO INLINE BYTECODE
;*
_INTERP: PLA
	STA	PCL
	PLA
	STA	PCH
	LDY	#$00
	BEQ	NEXTOP
TOCKOP: JSR	TICKTOCK
FETCHOP:
.IF     TMRCHK
	DEC	TICK
	BEQ	TOCKOP
.ENDIF
	LDA_IPC
	STA	JSROP+1
	JSR	JSROP
.IF     STKCHK
	CPX	#ESTKSZ/2+1
	BCS	STKINT
.ENDIF
NEXTOP:	INC	PCL
	BNE	FETCHOP
	INC	PCH
	BNE	FETCHOP
STKINT: LDA     #$FF
INTJMP: JMP     (INTVEC)
TICKTOCK: JMP	(TMRVEC)
TMPJMP: JMP	(TMP)
;*
;* ENTER INTO EXTERNAL BYTECODE
;*
_INTERPX: PLA
        STA     TMPL
        PLA
        STA     TMPH
	LDY	#$01
	LDA     (TMP),Y
        STA	PCL
	INY
	LDA     (TMP),Y
	STA	PCH
        INY
	LDA     (TMP),Y
	TAY
	BNE	FETCHOPX
	BEQ	FETCHOP
TOCKOPX: JSR	TICKTOCK
FETCHOPX:
.IF     TMRCHK
	DEC	TICK
	BEQ	TOCKOPX
.ENDIF
	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	ORA	#$80		; SELECT OPX CODES
	STA	JSROP+1
	JSR	JSROP
.IF     STKCHK
	CPX	#ESTKSZ/2+1
	BCS	STKINT
.ENDIF
NEXTOPX: INC	PCL
	BNE	FETCHOPX
	INC	PCH
	BNE	FETCHOPX
;*
;* ADD TOS TO TOS-1
;*
ADD:	LDA	ESTKL,X
	CLC
	ADC	ESTKL+1,X
	STA	ESTKL+1,X
	LDA	ESTKH,X
	ADC	ESTKH+1,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* SUB TOS FROM TOS-1
;*
SUB:	LDA	ESTKL+1,X
	SEC
	SBC	ESTKL,X
	STA	ESTKL+1,X
	LDA	ESTKH+1,X
	SBC	ESTKH,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* SHIFT TOS-1 LEFT BY 1, ADD TO TOS-1
;*
IDXW:	LDA	ESTKL,X
	ASL
	ROL	ESTKH,X
	CLC
	ADC	ESTKL+1,X
	STA	ESTKL+1,X
	LDA	ESTKH,X
	ADC	ESTKH+1,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* MUL TOS-1 BY TOS
;*
MUL:	ST0	TMPL		; PRODL
	ST0	TMPH		; PRODH
	LDY	#$10
MUL1:	LSR	ESTKH,X		; MULTPLRH
	ROR	ESTKL,X		; MULTPLRL
	BCC	MUL2
	LDA	ESTKL+1,X	; MULTPLNDL
	CLC
	ADC	TMPL		; PRODL
	STA	TMPL
	LDA	ESTKH+1,X	; MULTPLNDH
	ADC	TMPH		; PRODH
	STA	TMPH
MUL2:	ASL	ESTKL+1,X	; MULTPLNDL
	ROL	ESTKH+1,X	; MULTPLNDH
	DEY
	BNE	MUL1
	INX
	LDA	TMPL		; PRODL
	STA	ESTKL,X
	LDA	TMPH		; PRODH
	STA	ESTKH,X
	RTS
;*
;* INTERNAL DIVIDE ALGORITHM
;*
_DIV:	LDA	ESTKH,X
	AND	#$80
	STA	DVSIGN
	BPL	_DIV1
	JSR	NEG
	INC	DVSIGN
_DIV1:	LDA	ESTKH+1,X
	BPL	_DIV2
	INX
	JSR	NEG
	DEX
	INC	DVSIGN
	BNE	_DIV3
_DIV2:	ORA	ESTKL+1,X	; DVDNDL
	BNE	_DIV3
	STA	TMPL
	STA	TMPH
	RTS
_DIV3:	LDY	#$11		; #BITS+1
	LDA	#$00
	STA	TMPL		; REMNDRL
	STA	TMPH		; REMNDRH
_DIV4:	ASL	ESTKL+1,X	; DVDNDL
	ROL	ESTKH+1,X	; DVDNDH
	DEY
	BCC	_DIV4
	STY	ESTKL-1,X
_DIV5:	ROL	TMPL		; REMNDRL
	ROL	TMPH		; REMNDRH
	LDA	TMPL		; REMNDRL
	SEC
	SBC	ESTKL,X		; DVSRL
	TAY
	LDA	TMPH		; REMNDRH
	SBC	ESTKH,X		; DVSRH
	BCC	_DIV6
	STA	TMPH		; REMNDRH
	STY	TMPL		; REMNDRL
_DIV6:	ROL	ESTKL+1,X	; DVDNDL
	ROL	ESTKH+1,X	; DVDNDH
	DEC	ESTKL-1,X
	BNE	_DIV5
	CLRY
	RTS
;*
;* DIV TOS-1 BY TOS
;*
DIV:	JSR	_DIV
	INX
	LSR	DVSIGN		; SIGN(RESULT) = (SIGN(DIVIDEND) + SIGN(DIVISOR)) & 1
	BCS	NEG
	RTS
;*
;* NEGATE TOS
;*
NEG:	LDA0
	SEC
	SBC	ESTKL,X
	STA	ESTKL,X
	LDA0
	SBC	ESTKH,X
	STA	ESTKH,X
	RTS
;*
;* DIV,MOD TOS-1 BY TOS
;*
DIVMOD: JSR	_DIV
	LDA	TMPL		; REMNDRL
	STA	ESTKL,X
	LDA	TMPH		; REMNDRH
	STA	ESTKH,X
	LDA	DVSIGN		; REMAINDER IS SIGN OF DIVIDEND
	BPL	DIVMOD1
	JSR	NEG
DIVMOD1: LSR	DVSIGN
	BCC	DIVMOD2		; DIV RESULT TOS-1
	INX
	JSR	NEG
	DEX
DIVMOD2: RTS
;*
;* INCREMENT TOS
;*
INCR:	INC	ESTKL,X
	BNE	INCR1
	INC	ESTKH,X
INCR1:	RTS
;*
;* DECREMENT TOS
;*
DECR:	LDA	ESTKL,X
	BNE	DECR1
	DEC	ESTKH,X
DECR1:	DEC	ESTKL,X
	RTS
;*
;* BITWISE COMPLIMENT TOS
;*
COMP:	LDA	#$FF
	EOR	ESTKL,X
	STA	ESTKL,X
	LDA	#$FF
	EOR	ESTKH,X
	STA	ESTKH,X
	RTS
;*
;* BITWISE AND TOS TO TOS-1
;*
BAND:	LDA	ESTKL+1,X
	AND	ESTKL,X
	STA	ESTKL+1,X
	LDA	ESTKH+1,X
	AND	ESTKH,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* INCLUSIVE OR TOS TO TOS-1
;*
IOR:	LDA	ESTKL+1,X
	ORA	ESTKL,X
	STA	ESTKL+1,X
	LDA	ESTKH+1,X
	ORA	ESTKH,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* EXLUSIVE OR TOS TO TOS-1
;*
XOR:	LDA	ESTKL+1,X
	EOR	ESTKL,X
	STA	ESTKL+1,X
	LDA	ESTKH+1,X
	EOR	ESTKH,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* SHIFT TOS-1 LEFT BY TOS
;*
SHL:	LDA	ESTKL,X
	CMP	#$08
	BCC	SHL1
	LDY	ESTKL+1,X
	STY	ESTKH+1,X
	LDY	#$00
	STY	ESTKL+1,X
	SBC	#$08
SHL1:	TAY
	BEQ	SHL3
SHL2:	ASL	ESTKL+1,X
	ROL	ESTKH+1,X
	DEY
	BNE	SHL2
SHL3:	INX
	RTS
;*
;* SHIFT TOS-1 RIGHT BY TOS
;*
SHR:	LDA	ESTKL,X
	CMP	#$08
	BCC	SHR2
	LDY	ESTKH+1,X
	STY	ESTKL+1,X
	CPY	#$80
	LDY	#$00
	BCC	SHR1
	DEY
SHR1:	STY	ESTKH+1,X
	SEC
	SBC	#$08
SHR2:	TAY
	BEQ	SHR4
	LDA	ESTKH+1,X
SHR3:	CMP	#$80
	ROR
	ROR	ESTKL+1,X
	DEY
	BNE	SHR3
	STA	ESTKH+1,X
SHR4:	INX
	RTS
;*
;* LOGICAL NOT
;*
NOT:	LDA	ESTKL,X
	ORA	ESTKH,X
	BNE	NOT1
	LDA	#$FF
	STA	ESTKL,X
	STA	ESTKH,X
	RTS
NOT1:	ST0	{ESTKL,X}
	ST0	{ESTKH,X}
	RTS
;*
;* LOGICAL AND
;*
LAND:	LDA	ESTKL,X
	ORA	ESTKH,X
	BEQ	LAND1
	LDA	ESTKL+1,X
	ORA	ESTKH+1,X
	BEQ	LAND1
	LDA	#$FF
LAND1:	STA	ESTKL+1,X
	STA	ESTKH+1,X
	INX
	RTS
;*
;* LOGICAL OR
;*
LOR:	LDA	ESTKL,X
	ORA	ESTKH,X
	ORA	ESTKL+1,X
	ORA	ESTKH+1,X
	BEQ	LOR1
	LDA	#$FF
LOR1:	STA	ESTKL+1,X
	STA	ESTKH+1,X
;*
;* DROP TOS
;*
DROP:	INX
	RTS
;*
;* SWAP TOS WITH TOS-1
;*
SWAP:	LDA	ESTKL,X
	LDY	ESTKL+1,X
	STA	ESTKL+1,X
	STY	ESTKL,X
	LDA	ESTKH,X
	LDY	ESTKH+1,X
	STA	ESTKH+1,X
	STY	ESTKH,X
	CLRY
	RTS
;*
;* DUPLICATE TOS
;*
DUP:	DEX
	LDA	ESTKL+1,X
	STA	ESTKL,X
	LDA	ESTKH+1,X
	STA	ESTKH,X
	RTS
;*
;* PUSH FROM EVAL STACK TO CALL STACK
;*
PUSH:	PLA
	STA	TMPH
	PLA
	STA	TMPL
	LDA	ESTKL,X
	PHA
	LDA	ESTKH,X
	PHA
	INX
	LDA	TMPL
	PHA
	LDA	TMPH
	PHA
	RTS
;*
;* PULL FROM CALL STACK TO EVAL STACK
;*
PULL:	PLA
	STA	TMPH
	PLA
	STA	TMPL
	DEX
	PLA
	STA	ESTKH,X
	PLA
	STA	ESTKL,X
	LDA	TMPL
	PHA
	LDA	TMPH
	PHA
	RTS
;*
;* CONSTANT
;*
ZERO:	DEX
	ST0	{ESTKL,X}
	ST0	{ESTKH,X}
	RTS
CB:	DEX
	INC	PCL
	BNE	CB1
	INC	PCH
CB1:	LDA_IPC
	STA	ESTKL,X
	ST0	{ESTKH,X}
	RTS
;*
;* LOAD ADDRESS - CHECK FOR DATA OR CODE SPACE
;*
LA:
CW:	DEX
	INC	PCL
	BNE	CW1
	INC	PCH
CW1:	LDA_IPC
	STA	ESTKL,X
	INC	PCL
	BNE	CW2
	INC	PCH
CW2:	LDA_IPC
	STA	ESTKH,X
	RTS
;*
;* LOAD VALUE FROM ADDRESS TAG
;*
LB:	LDA	ESTKL,X
	STA	TMPL
	LDA	ESTKH,X
	STA	TMPH
	LDA_ITMPL
	STA	ESTKL,X
	ST0	{ESTKH,X}
	RTS
LW:	LDA	ESTKL,X
	STA	TMPL
	LDA	ESTKH,X
	STA	TMPH
	LDA_ITMPL
	STA	ESTKL,X
	LDA_ITMPH
	STA	ESTKH,X
	RTS
;*
;* LOAD ADDRESS OF LOCAL FRAME OFFSET
;*
LLA:	INC	PCL
	BNE	LLA1
	INC	PCH
LLA1:	LDA_IPC
	DEX
	CLC
	ADC	FRMPL
	STA	ESTKL,X
	LDA0
	ADC	FRMPH
	STA	ESTKH,X
	RTS
;*
;* LOAD VALUE FROM LOCAL FRAME OFFSET
;*
LLB:	INC	PCL
	BNE	LLB1
	INC	PCH
LLB1:	LDA_IPC
	TAY
	DEX
	LDA	(FRMP),Y
	STA	ESTKL,X
	CLRY
	ST0	{ESTKH,X}
	RTS
LLW:	INC	PCL
	BNE	LLW1
	INC	PCH
LLW1:	LDA_IPC
	TAY
	DEX
	LDA	(FRMP),Y
	STA	ESTKL,X
	INY
	LDA	(FRMP),Y
	STA	ESTKH,X
	CLRY
	RTS
;*
;* LOAD VALUE FROM ABSOLUTE ADDRESS
;*
LAB:	INC	PCL
	BNE	LAB1
	INC	PCH
LAB1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	LAB2
	INC	PCH
LAB2:	LDA_IPC
	STA	TMPH
	LDA_ITMPL
	DEX
	STA	ESTKL,X
	ST0	{ESTKH,X}
	RTS
LAW:	INC	PCL
	BNE	LAW1
	INC	PCH
LAW1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	LAW2
	INC	PCH
LAW2:	LDA_IPC
	STA	TMPH
	LDA_ITMPL
	DEX
	STA	ESTKL,X
	LDA_ITMPH
	STA	ESTKH,X
	RTS
;*
;* STORE VALUE TO ADDRESS
;*
SB:	LDA	ESTKL+1,X
	STA	TMPL
	LDA	ESTKH+1,X
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	INX
	INX
	RTS
SW:	LDA	ESTKL+1,X
	STA	TMPL
	LDA	ESTKH+1,X
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	LDA	ESTKH,X
	STA_ITMPH
	INX
	INX
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET
;*
SLB:	INC	PCL
	BNE	SLB1
	INC	PCH
SLB1:	LDA_IPC
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INX
	CLRY
	RTS
SLW:	INC	PCL
	BNE	SLW1
	INC	PCH
SLW1:	LDA_IPC
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INY
	LDA	ESTKH,X
	STA	(FRMP),Y
	INX
	CLRY
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET WITHOUT POPPING STACK
;*
DLB:	INC	PCL
	BNE	DLB1
	INC	PCH
DLB1:	LDA_IPC
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	CLRY
	RTS
DLW:	INC	PCL
	BNE	DLW1
	INC	PCH
DLW1:	LDA_IPC
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INY
	LDA	ESTKH,X
	STA	(FRMP),Y
	CLRY
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS
;*
SAB:	INC	PCL
	BNE	SAB1
	INC	PCH
SAB1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	SAB2
	INC	PCH
SAB2:	LDA_IPC
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	INX
	RTS
SAW:	INC	PCL
	BNE	SAW1
	INC	PCH
SAW1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	SAW2
	INC	PCH
SAW2:	LDA_IPC
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	LDA	ESTKH,X
	STA_ITMPH
	INX
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS WITHOUT POPPING STACK
;*
DAB:	INC	PCL
	BNE	DAB1
	INC	PCH
DAB1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	DAB2
	INC	PCH
DAB2:	LDA_IPC
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	RTS
DAW:	INC	PCL
	BNE	DAW1
	INC	PCH
DAW1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	DAW2
	INC	PCH
DAW2:	LDA_IPC
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	LDA	ESTKH,X
	STA_ITMPH
	RTS
;*
;* COMPARES
;*
ISEQ:
.IF	IS65C02
	LDY	#$00
.ENDIF
	LDA	ESTKL,X
	CMP	ESTKL+1,X
	BNE	ISEQ1
	LDA	ESTKH,X
	CMP	ESTKH+1,X
	BNE	ISEQ1
	DEY
ISEQ1:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
ISNE:
.IF	IS65C02
	LDY	#$FF
.ELSE
	DEY	; LDY #$FF
.ENDIF
	LDA	ESTKL,X
	CMP	ESTKL+1,X
	BNE	ISNE1
	LDA	ESTKH,X
	CMP	ESTKH+1,X
	BNE	ISNE1
	INY
ISNE1:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
ISGE:
.IF	IS65C02
	LDY	#$00
.ELSE
	; LDY	#$00
.ENDIF
	LDA	ESTKL+1,X
	CMP	ESTKL,X
	LDA	ESTKH+1,X
	SBC	ESTKH,X
	BVC	ISGE1
	EOR	#$80
ISGE1:	BMI	ISGE2
	DEY
ISGE2:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
ISGT:
.IF	IS65C02
	LDY	#$00
.ELSE
	; LDY	#$00
.ENDIF
	LDA	ESTKL,X
	CMP	ESTKL+1,X
	LDA	ESTKH,X
	SBC	ESTKH+1,X
	BVC	ISGT1
	EOR	#$80
ISGT1:	BPL	ISGT2
	DEY
ISGT2:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
ISLE:
.IF	IS65C02
	LDY	#$00
.ELSE
	; LDY	#$00
.ENDIF
	LDA	ESTKL,X
	CMP	ESTKL+1,X
	LDA	ESTKH,X
	SBC	ESTKH+1,X
	BVC	ISLE1
	EOR	#$80
ISLE1:	BMI	ISLE2
	DEY
ISLE2:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
ISLT:
.IF	IS65C02
	LDY	#$00
.ELSE
	; LDY	#$00
.ENDIF
	LDA	ESTKL+1,X
	CMP	ESTKL,X
	LDA	ESTKH+1,X
	SBC	ESTKH,X
	BVC	ISLT1
	EOR	#$80
ISLT1:	BPL	ISLT2
	DEY
ISLT2:	STY	ESTKL+1,X
	STY	ESTKH+1,X
	INX
	CLRY
	RTS
;*
;* SKIPS
;*
SKPTRU:	INX
	LDA	ESTKH-1,X
	ORA	ESTKL-1,X
	BEQ	NOSKIP
SKIP:
.IF	IS65C02
	LDY	#$01
.ELSE
	INY ; LDY	#$01
.ENDIF
	LDA	(PC),Y
	PHA
	INY
	LDA	(PC),Y
	STA	PCH
	PLA
	STA	PCL
	PLA
	PLA
	CLRY
	JMP	FETCHOP
SKPFLS:	INX
	LDA	ESTKH-1,X
	ORA	ESTKL-1,X
	BEQ	SKIP
NOSKIP: LDA	#$02
	CLC
	ADC	PCL
	STA	PCL
	BCC	NOSK1
	INC	PCH
NOSK1: RTS
SKPEQ:	INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BNE	NOSKIP
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BEQ	SKIP
	BNE	NOSKIP
SKPNE:	INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BNE	SKIP
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BEQ	NOSKIP
	BNE	SKIP
SKPGT:	INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	LDA	ESTKH-1,X
	SBC	ESTKH,X
	BMI	SKIP
	BPL	NOSKIP
SKPLT:	INX
	LDA	ESTKL,X
	CMP	ESTKL-1,X
	LDA	ESTKH,X
	SBC	ESTKH-1,X
	BMI	SKIP
	BPL	NOSKIP
;*
;* INDIRECT SKIP TO ADDRESS
;*
ISKIP:	PLA
	PLA
	LDA	ESTKL,X
	STA	PCL
	LDA	ESTKH,X
	STA	PCH
	INX
	JMP	FETCHOP
;*
;* EXTERNAL SYS CALL
;*
INT:	INC	PCL
	BNE	INT1
	INC	PCH
INT1:  LDA_IPC
	JSR     INTJMP
	CLRY
	RTS
;*
;* CALL INTO ABSOLUTE ADDRESS (NATIVE CODE)
;*
CALL:	INC	PCL
	BNE	CALL1
	INC	PCH
CALL1:	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	CALL2
	INC	PCH
CALL2:	LDA_IPC
	STA	TMPH
	LDA	PCH
	PHA
	LDA	PCL
	PHA
	JSR	TMPJMP
	PLA
	STA	PCL
	PLA
	STA	PCH
	CLRY
	RTS
;*
;* INDIRECT CALL TO ADDRESS (NATIVE CODE)
;*
ICAL:	LDA	ESTKL,X
	STA	TMPL
	LDA	ESTKH,X
	STA	TMPH
	INX
	LDA	PCH
	PHA
	LDA	PCL
	PHA
	JSR	TMPJMP
	PLA
	STA	PCL
	PLA
	STA	PCH
	CLRY
	RTS
;*
;* ENTER FUNCTION WITH FRAME SIZE AND PARAM COUNT
;*
_ENTER: STY     FRMSZ
        JMP     ENTER3
ENTER:	INC	PCL
	BNE	ENTER1
	INC	PCH
ENTER1: LDA_IPC
	STA	FRMSZ
	INC	PCL
	BNE	ENTER2
	INC	PCH
ENTER2: LDA_IPC
ENTER3:	STA	NPARMS
        LDA	FRMPL
	PHA
	SEC
	SBC	FRMSZ
	STA	FRMPL
	LDA	FRMPH
	PHA
	SBC	#$00
	STA	FRMPH
	LDY	#$01
	PLA
	STA	(FRMP),Y
	DEY
	PLA
	STA	(FRMP),Y
	LDA	NPARMS
	BEQ	ENTER5
	ASL
	TAY
	INY
ENTER4: LDA	ESTKH,X
	STA	(FRMP),Y
	DEY
	LDA	ESTKL,X
	STA	(FRMP),Y
	DEY
	INX
	DEC	TMPL
	BNE	ENTER4
ENTER5: LDY	#$00
	RTS
;*
;* LEAVE FUNCTION
;*
LEAVE:	PLA
	PLA
_LEAVE: LDY	#$01
	LDA	(FRMP),Y
	DEY
	PHA
	LDA	(FRMP),Y
	STA	FRMPL
	PLA
	STA	FRMPH
	RTS
RET:	PLA
	PLA
	RTS
;***********************************************
;*
;* XMOD VERSIONS OF BYTECODE OPS
;*
;***********************************************
;*
;* CONSTANT
;*
CBX:	DEX
	INC	PCL
	BNE	CBX1
	INC	PCH
CBX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	ESTKL,X
	STY	ESTKH,X
	RTS
;*
;* LOAD ADDRESS
;*
LAX:
CWX:	DEX
	INC	PCL
	BNE	CWX1
	INC	PCH
CWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	ESTKL,X
	INC	PCL
	BNE	CWX2
	INC	PCH
CWX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	ESTKH,X
	RTS
;*
;* LOAD ADDRESS OF LOCAL FRAME OFFSET
;*
LLAX:	INC	PCL
	BNE	LLAX1
	INC	PCH
LLAX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	DEX
	CLC
	ADC	FRMPL
	STA	ESTKL,X
	LDA0
	ADC	FRMPH
	STA	ESTKH,X
	RTS
;*
;* LOAD VALUE FROM LOCAL FRAME OFFSET
;*
LLBX:	INC	PCL
	BNE	LLBX1
	INC	PCH
LLBX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	DEX
	LDA	(FRMP),Y
	STA	ESTKL,X
	CLRY
	ST0	{ESTKH,X}
	RTS
LLWX:	INC	PCL
	BNE	LLWX1
	INC	PCH
LLWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	DEX
	LDA	(FRMP),Y
	STA	ESTKL,X
	INY
	LDA	(FRMP),Y
	STA	ESTKH,X
	CLRY
	RTS
;*
;* LOAD VALUE FROM ABSOLUTE ADDRESS
;*
LABX:	INC	PCL
	BNE	LABX1
	INC	PCH
LABX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	LABX2
	INC	PCH
LABX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	DEX
	LDA_ITMPL
	STA	ESTKL,X
	ST0	{ESTKH,X}
	RTS
LAWX:	INC	PC
	BNE	LAWX1
	INC	PCH
LAWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	LAWX2
	INC	PCH
	DEX
LAWX2:	LDA_IPC
	STA	TMPH
	LDA_ITMPL
	STA	ESTKL,X
	LDA_ITMPH
	AUXMEM_RDACCESS_OFF
	STA	ESTKH,X
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET
;*
SLBX:	INC	PCL
	BNE	SLBX1
	INC	PCH
SLBX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INX
	CLRY
	RTS
SLWX:	INC	PCL
	BNE	SLWX1
	INC	PCH
SLWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INY
	LDA	ESTKH,X
	STA	(FRMP),Y
	INX
	CLRY
	RTS
;*
;* STORE VALUE TO LOCAL FRAME OFFSET WITHOUT POPPING STACK
;*
DLBX:	INC	PCL
	BNE	DLBX1
	INC	PCH
DLBX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	CLRY
	RTS
DLWX:	INC	PCL
	BNE	DLWX1
	INC	PCH
DLWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	TAY
	LDA	ESTKL,X
	STA	(FRMP),Y
	INY
	LDA	ESTKH,X
	STA	(FRMP),Y
	CLRY
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS
;*
SABX:	INC	PCL
	BNE	SABX1
	INC	PCH
SABX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	SABX2
	INC	PCH
SABX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	INX
	RTS
SAWX:	INC	PCL
	BNE	SAWX1
	INC	PCH
SAWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	SAWX2
	INC	PCH
SAWX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	LDA	ESTKH,X
	STA_ITMPH
	INX
	RTS
;*
;* STORE VALUE TO ABSOLUTE ADDRESS WITHOUT POPPING STACK
;*
DABX:	INC	PCL
	BNE	DABX1
	INC	PCH
DABX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	DABX2
	INC	PCH
DABX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	RTS
DAWX:	INC	PCL
	BNE	DAWX1
	INC	PCH
DAWX1:	AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	DAWX2
	INC	PCH
DAWX2:	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	LDA	ESTKL,X
	STA_ITMPL
	LDA	ESTKH,X
	STA_ITMPH
	RTS
;*
;* SKIPS
;*
SKPTRUX: INX
	LDA	ESTKH-1,X
	ORA	ESTKL-1,X
	BEQ	NOSKIPX
SKIPX:
.IF	IS65C02
	LDY	#$01
.ELSE
	INY ; LDY	#$01
.ENDIF
	AUXMEM_RDACCESS_ON
	LDA_IPC
	PHA
	INY
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	PCH
	PLA
	STA	PCL
	PLA
	PLA
	CLRY
	CLRY
	JMP	FETCHOPX
SKPFLSX: INX
	LDA	ESTKH-1,X
	ORA	ESTKL-1,X
	BEQ	SKIPX
NOSKIPX: LDA	#$02
	CLC
	ADC	PCL
	STA	PCL
	BCC	NOSKX1
	INC	PCH
NOSKX1: RTS
SKPEQX:	INX
	; INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BNE	NOSKIPX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BEQ	SKIPX
	BNE	NOSKIPX
SKPNEX:	INX
	; INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BNE	SKIPX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	BEQ	NOSKIPX
	BNE	SKIPX
SKPGTX:	INX
	; INX
	LDA	ESTKL-1,X
	CMP	ESTKL,X
	LDA	ESTKH-1,X
	SBC	ESTKH,X
	BMI	SKIPX
	BPL	NOSKIPX
SKPLTX:	INX
	; INX
	LDA	ESTKL,X
	CMP	ESTKL-1,X
	LDA	ESTKH,X
	SBC	ESTKH-1,X
	BMI	SKIPX
	BPL	NOSKIPX
;*
;* INDIRECT SKIP TO ADDRESS
;*
ISKIPX:	PLA
	PLA
	LDA	ESTKL,X
	STA	PCL
	LDA	ESTKH,X
	STA	PCH
	INX
	JMP	FETCHOPX
;*
;* EXTERNAL SYS CALL
;*
INTX:	INC	PCL
	BNE	INTX1
	INC	PCH
INTX1: AUXMEM_RDACCESS_ON
	LDA_IPC
	AUXMEM_RDACCESS_OFF
	JSR     INTJMP
	CLRY
	RTS
;*
;* CALL TO ABSOLUTE ADDRESS (NATIVE CODE)
;*
CALLX:	INC	PCL
	BNE	CALLX1
	INC	PCH
CALLX1: AUXMEM_RDACCESS_ON
	LDA_IPC
	STA	TMPL
	INC	PCL
	BNE	CALLX2
	INC	PCH
CALLX2: LDA_IPC
	AUXMEM_RDACCESS_OFF
	STA	TMPH
	LDA	PCH
	PHA
	LDA	PCL
	PHA
	JSR	TMPJMP
	PLA
	STA	PCL
	PLA
	STA	PCH
	CLRY
	RTS