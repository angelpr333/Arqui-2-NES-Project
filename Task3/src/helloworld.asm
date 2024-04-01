.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_dir: .res 1
player2_x: .res 1
player2_y: .res 1
player2_dir: .res 1
player3_x: .res 1
player3_y: .res 1
player3_dir: .res 1
player4_x: .res 1
player4_y: .res 1
player4_dir: .res 1
animation_frame: .res 1
frame_counter: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
.exportzp player_x, player_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y, pad1

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import read_controller1

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00

	; read controller
	JSR read_controller1

  ; update tiles *after* DMA transfer
	JSR update_player
  JSR draw_player

	STA $2005
	STA $2005
  

  RTI
.endproc

.import reset_handler
.import draw_starfield1
.import draw_objects

.export main
.proc main

  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.proc update_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  ORA pad1        ; Combine button states to check if any is pressed
  BEQ no_movement ; Skip animation update if no button is pressed

  ; If a movement button is pressed, update player position and animation frame
  LDA pad1
  AND #BTN_LEFT
  BEQ not_left
  DEC player_x
  JMP animate

not_left:
  LDA pad1
  AND #BTN_RIGHT
  BEQ not_right
  INC player_x
  JMP animate

not_right:
  LDA pad1
  AND #BTN_UP
  BEQ not_up
  DEC player_y
  JMP animate

not_up:
  LDA pad1
  AND #BTN_DOWN
  BEQ no_movement
  INC player_y

animate:
  ; Increment the animation frame to cycle through animations
  LDA animation_frame
  CLC
  ADC #1
  AND #3          ; Cycle through 4 animation frames (0-3)
  STA animation_frame

no_movement:
  ; Restore registers and return from subroutine
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc



.proc draw_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA animation_frame
  CMP #$00
  BEQ draw_animation_0
  CMP #$01
  BEQ draw_animation_1  
  CMP #$02
  BEQ draw_animation_2

draw_animation_0:

  LDA #$0B
  STA $0201
  LDA #$0C
  STA $0205
  LDA #$09
  STA $0209
  LDA #$0A
  STA $020d
  JMP draw_finish

draw_animation_1:

  LDA #$07
  STA $0201
  LDA #$08
  STA $0205
  LDA #$05
  STA $0209
  LDA #$06
  STA $020d
  JMP draw_finish


draw_animation_2:
  LDA #$0F
  STA $0201
  LDA #$10
  STA $0205
  LDA #$0D
  STA $0209
  LDA #$0E
  STA $020d
  JMP draw_finish

draw_finish:
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e


  ; store tile locations
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; store tile locations
  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213

  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f

  ;#################  Player 3
  ; store tile locations
  ; top left tile:
  LDA player3_y
  STA $0220
  LDA player3_x
  STA $0223

  ; top right tile (x + 8):
  LDA player3_y
  STA $0224
  LDA player3_x
  CLC
  ADC #$08
  STA $0227

  ; bottom left tile (y + 8):
  LDA player3_y
  CLC
  ADC #$08
  STA $0228
  LDA player3_x
  STA $022b

  ; bottom right tile (x + 8, y + 8)
  LDA player3_y
  CLC
  ADC #$08
  STA $022c
  LDA player3_x
  CLC
  ADC #$08
  STA $022f

  ;############## Player 4
  ; store tile locations
  ; top left tile:
  LDA player4_y
  STA $0230
  LDA player4_x
  STA $0233

  ; top right tile (x + 8):
  LDA player4_y
  STA $0234
  LDA player4_x
  CLC
  ADC #$08
  STA $0237

  ; bottom left tile (y + 8):
  LDA player4_y
  CLC
  ADC #$08
  STA $0238
  LDA player4_x
  STA $023b

  ; bottom right tile (x + 8, y + 8)
  LDA player4_y
  CLC
  ADC #$08
  STA $023c
  LDA player4_x
  CLC
  ADC #$08
  STA $023f

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $0f, $16, $07, $37
.byte $0f, $2b, $3c, $39
.byte $0f, $0c, $07, $13
.byte $0f, $19, $09, $29

.byte $0f, $16, $07, $37
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29
.byte $0f, $19, $09, $29

.segment "CHR"
.incbin "starfield1.chr"
