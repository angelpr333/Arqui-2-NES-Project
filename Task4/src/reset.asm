.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, player_x2, player_y2, player_x3, player_y3, player_x4, player_y4, player_x5, player_y5, player_x6, player_y6


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
    LDA #$02
    STA player_x
    LDA #$A0
    STA player_y
    LDA #$66
    STA player_x2
    LDA #$00
    STA player_y2
      LDA #$6E
    STA player_x3
    LDA #$00
    STA player_y3
      LDA #$76
    STA player_x4
    LDA #$00
    STA player_y4
      LDA #$7E
    STA player_x5
    LDA #$00
    STA player_y5
      LDA #$86
    STA player_x6
    LDA #$00
    STA player_y6






vblankwait2:
  BIT $2002
  BPL vblankwait2
  JMP main
.endproc