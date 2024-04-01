.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
  LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR ;set PPU address to $3f00
  
  load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

; write sprite data
  LDX #$00
load_sprites:
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$C0 ;aumenta cantidad de sprites 1 sp es +4
  BNE load_sprites
	;top right sprite 1
   LDA PPUSTATUS  ;$214a
	LDA #$21
	STA PPUADDR
	LDA #$4a
	STA PPUADDR
	LDX #$17
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4b
	STA PPUADDR
	LDX #$18
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6a
	STA PPUADDR
	LDX #$16
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6b
	STA PPUADDR
	LDX #$0a
	STX PPUDATA

  ; sprite2
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4c
	STA PPUADDR
	LDX #$17
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4d
	STA PPUADDR
	LDX #$18
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6c
	STA PPUADDR
	LDX #$09
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6d
	STA PPUADDR
	LDX #$0a
	STX PPUDATA
  

  ;top left sprite 3
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4e
	STA PPUADDR
	LDX #$1d
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$4f
	STA PPUADDR
	LDX #$1e
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6e
	STA PPUADDR
	LDX #$1c
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6f
	STA PPUADDR
	LDX #$1b
	STX PPUDATA
  ;--------------


  ;botom right
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0a
	STA PPUADDR
	LDX #$13
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0b
	STA PPUADDR
	LDX #$14
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2a
	STA PPUADDR
	LDX #$11
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2b
	STA PPUADDR
	LDX #$12
	STX PPUDATA

  ;sprite 2
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0c
	STA PPUADDR
	LDX #$13
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0d
	STA PPUADDR
	LDX #$14
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2c
	STA PPUADDR
	LDX #$15
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2d
	STA PPUADDR
	LDX #$12
	STX PPUDATA

  ;sprite 3

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0e
	STA PPUADDR
	LDX #$20
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0f
	STA PPUADDR
	LDX #$1f
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2e
	STA PPUADDR
	LDX #$22
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2f
	STA PPUADDR
	LDX #$21
	STX PPUDATA






vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10000000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $0f, $09, $29, $36 ;marios
.byte $0f, $2d, $3d, $32 ;bg 2,3
.byte $0f, $2d, $3d, $00 ;floor
.byte $0f, $2d, $3c, $1d ; bg1

.byte $0f, $09, $29, $36 ;marios
.byte $0f, $12, $23, $27
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13



sprites:
;usar tercr byte para flip horizontal y vertical 
;famicom ch 10

;Y poss ,Tile # display, flags , X poss
;Top Left ;sprite1
.byte $58, $05, %00000000, $01 
.byte $58, $06, %00000000, $09
.byte $50, $07, %00000000, $01
.byte $50, $08, %00000000, $09

;sprite2
.byte $58, $09, %00000000, $12
.byte $58, $0A, %00000000, $1a
.byte $50, $0B, %00000000, $12
.byte $50, $0C, %00000000, $1a

;sprite3
.byte $58, $0D, %00000000, $21
.byte $58, $0E, %00000000, $29
.byte $50, $0F, %00000000, $21
.byte $50, $10, %00000000, $29
;----------------------------

;Bottom left
;sprite 1
.byte $88, $05, %01000000, $08 
.byte $88, $06, %01000000, $00
.byte $80, $07, %01000000, $08
.byte $80, $08, %01000000, $00

;sprite 2
.byte $88, $09, %01000000, $1a
.byte $88, $0A, %01000000, $12
.byte $80, $0B, %01000000, $1a
.byte $80, $0C, %01000000, $12

;sprite 3
.byte $88, $0D, %01000000, $30
.byte $88, $0E, %01000000, $28
.byte $80, $0F, %01000000, $30
.byte $80, $10, %01000000, $28

;-------------------------------

;top right
;sprite 1
;.byte $50, $17, %0000000, $51 
;.byte $50, $18, %0000000, $59
;.byte $58, $16, %0000000, $51
;.byte $58, $0A, %0000000, $58

;sprite 2

;bien, cant display it

;.byte $60, $17, %0000000, $61 
;.byte $60, $18, %0000000, $69
;.byte $68, $09, %0000000, $61
;.byte $68, $0A, %0000000, $68


;sprite 3

;esta bien, cant display it

;.byte $60, $17, %0000000, $70 
;.byte $60, $18, %0000000, $78
;.byte $68, $16, %1100000, $74
;.byte $68, $0A, %1100000, $6D

;---------------------------

;bottom right
;sprite 1
;.byte $88, $11, %0000000, $51 
;.byte $88, $12, %0000000, $59
;.byte $80, $14, %0000000, $59
;.byte $80, $13, %0000000, $51

;sprite 2
;.byte $98, $15, %0000000, $61
;.byte $98, $19, %1100000, $69
;.byte $90, $14, %0000000, $69
;.byte $90, $13, %0000000, $61


;sprite 3
;.byte $98, $12, %1100000, $6C 
;.byte $98, $11, %1100000, $74
;.byte $90, $14, %0000000, $78
;.byte $90, $13, %0000000, $70

;----------------------------
;bg sprite 1
.byte $a0, $23, %00000000, $40 

;bg sprite 2
.byte $a0, $24, %00000001, $48 

;bg sprite 3
.byte $a0, $25, %00000001, $52

;bg floor
.byte $a0, $26, %00000010, $59

;------------------------------

;bg wrld 2 sprite 1

.byte $b0, $28, %00000000, $40

.byte $b0, $29, %00000001, $48

.byte $b0, $2a, %00000001, $52

.byte $b0, $2b, %00000010, $59




.segment "CHR"
.incbin "graphics.chr"
