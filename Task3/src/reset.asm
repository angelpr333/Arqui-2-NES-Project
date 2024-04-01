.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX $2000
  STX $2001
  STX $4010
  BIT $2002
vblankwait:
  BIT $2002
  BPL vblankwait

	LDX #$00
	LDA #$FF
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

	; initialize zero-page values
	LDA #$40
	STA player_x
	LDA #$a0
	STA player_y
	LDA #$a0
	STA player2_x
	LDA #$a0
	STA player2_y
	LDA #$40
	STA player3_x
	LDA #$78
	STA player3_y
	LDA #$a0
	STA player4_x
	LDA #$78
	STA player4_y
	

vblankwait2:
  BIT $2002
  BPL vblankwait2
  JMP main
.endproc
