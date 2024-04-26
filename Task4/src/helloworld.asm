.include "constants.inc"
.include "header.inc"
.import reset_handler
.import read_controller1
.export main

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_x2: .res 1
player_y2: .res 1
player_x3: .res 1
player_y3: .res 1
player_x4: .res 1
player_y4: .res 1
player_x5: .res 1
player_y5: .res 1
player_x6: .res 1
player_y6: .res 1
player_dir: .res 1
animation_frame: .res 1
frame_counter: .res 1
pad1: .res 1
TEMP_X: .res 1
TEMP_Y: .res 1
TEMP_INDEX: .res 1
collision_flag: .res 1
scroll_offset: .res 1
middle_screen_x: .res 128
.exportzp player_x, player_y, player_x2, player_y2, player_x3, player_y3, player_x4, player_y4, player_x5, player_y5, player_x6, player_y6, pad1

.segment "CODE"
.proc irq_handler
  RTI
.endproc


.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA


  JSR read_controller1

  LDA player_x
  STA $2005    ; Horizontal scroll value

  JSR update_player
  JSR draw_player

  LDA #$00
  STA $2005 
  RTI
.endproc

.proc main
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #%10000000 
  STA PPUCTRL
load_palettes:
  LDA palettes,X
  STA $2007
  INX
  CPX #$20
  BNE load_palettes

  ; Set nametable
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
  LDY #$00
  JSR load_background_mega  ; Load the mega tile background

   ; Set nametable
  LDA #$24
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
  LDY #$00
  JSR load_background_mega1  ; Load the mega tile background

  ; Set attribute table
  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$00
  LDY #$00

load_attribute:
  LDA attribute, x
  STA $2007
  INX
  CPX #$08
  BNE load_attribute

  LDA #%00011110  ; turn on screen
  STA PPUMASK
  JMP forever
new_Name:
  JSR message
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
  LDA #$00
  STA PPUCTRL
  STA PPUMASK
  LDA #%10000000
  STA PPUCTRL

  
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
  LDY #$00
  JSR load_background_mega2

  LDA #$24
  STA $2006
  LDA #$00
  STA $2006
  LDX #$00
  LDY #$00
  JSR load_background_mega3  

  LDA #$23
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$00
  LDY #$00

  
  LDA #%00011110  ; turn on screen
  STA PPUMASK
forever:
  LDA player_x
  CMP #$F8
  BEQ new_Name
  JMP forever
.endproc


.proc message
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$58
  STA $0211
  LDA #$59
  STA $0215
  LDA #$5A
  STA $0219
  LDA #$5B
  STA $021D
  LDA #$5C
  STA $0221

  LDA player_y2
  STA $0210
  LDA player_x2
  STA $0213

  LDA player_y3
  STA $0214
  LDA player_x3
  STA $0217

  LDA player_y4
  STA $0218
  LDA player_x4
  STA $021b

  LDA player_y5
  STA $021c
  LDA player_x5
  STA $021f
  
  LDA player_y6
  STA $0220
  LDA player_x6
  STA $0223

  LDA #$03       
  STA $0212      
  STA $0216      
  STA $021A     
  STA $021E    
  STA $0222     

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc



.proc update_player
  PHP                     
  PHA                     
  TXA                      
  PHA                     
  TYA                    
  PHA                  

  LDA pad1              
  ORA pad1                 
  BEQ no_movement0       

  LDA pad1
  AND #BTN_LEFT
  BEQ not_left
  LDA player_x
  CMP #$01      
  BCC not_left 
  SEC             
  SBC #$01      
  STA TEMP_X        
  LDA player_y
  STA TEMP_Y              
  JSR check_mega_tile    
  BCS not_left     
  DEC player_x     
  LDA #$01              
  STA player_dir
  JMP update_animation

not_left:

  LDA pad1
  AND #BTN_RIGHT
  BEQ not_right
  LDA player_x
  CLC            
  ADC #$01       
  STA TEMP_X             
  LDA player_y
  STA TEMP_Y             
  JSR check_mega_tile    
  BCS not_right        
  INC player_x           
  LDA #$00           
  STA player_dir
  JMP update_animation

no_movement0:
  BEQ no_movement       

not_right:
  ; Verificar entrada para mover hacia arriba
  LDA pad1
  AND #BTN_UP
  BEQ not_up
  LDA player_y
  SEC           
  SBC #$01       
  STA TEMP_Y          
  LDA player_x
  STA TEMP_X            
  JSR check_mega_tile  
  BCS not_up             
  DEC player_y        
  LDA #$03              
  STA player_dir
  JMP update_animation

not_up:
  ; Verificar entrada para mover hacia abajo
  LDA pad1
  AND #BTN_DOWN
  BEQ reset_animation
  LDA player_y
  CLC        
  ADC #$01     
  STA TEMP_Y              
  LDA player_x
  STA TEMP_X          
  JSR check_mega_tile   
  BCS reset_animation    
  INC player_y           
  LDA #$02              
  STA player_dir
  JMP update_animation

update_animation:
  INC frame_counter     
  LDA frame_counter
  CMP #5
  BCC no_frame_update   

  LDA #0
  STA frame_counter
  LDA animation_frame
  CLC
  ADC #1
  AND #3                 
  STA animation_frame
  JMP end_update         

no_frame_update:
  JMP end_update         

reset_animation:
  LDA #0
  STA animation_frame
  STA frame_counter     
no_movement:
  LDA #0
  STA animation_frame
  STA frame_counter       

end_update:
  PLA                   
  TAY
  PLA                   
  TAX
  PLA                  
  PLP                    
  RTS                    
.endproc

.proc check_mega_tile
  CLC          
  RTS
.endproc


.proc draw_player
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_dir           
  CMP #$03                
  BEQ draw_up
  CMP #$02              
  BEQ draw_down
  CMP #$01                
  BEQ draw_left0
  CMP #$00                 
  BEQ draw_right00

draw_up:
  LDA animation_frame
  CMP #$00
  BEQ draw_animation_0000
  CMP #$01
  BEQ draw_animation_0001  
  CMP #$02
  BEQ draw_animation_0002

draw_animation_0000:
  LDA #$3C
  STA $0201
  LDA #$3D
  STA $0205
  LDA #$4C
  STA $0209
  LDA #$4D
  STA $020d
  
  JMP draw_finish000 

draw_animation_0001:
  LDA #$3E
  STA $0201
  LDA #$3F
  STA $0205
  LDA #$4E
  STA $0209
  LDA #$4F
  STA $020
  JMP draw_finish000 


draw_animation_0002:
  LDA #$50
  STA $0201
  LDA #$51
  STA $0205
  LDA #$60
  STA $0209
  LDA #$61
  STA $020d

draw_finish000:
  JMP draw_finish00

draw_left0:
 JMP draw_left

draw_right00:
 JMP draw_right0


draw_down:
  LDA animation_frame
  CMP #$00
  BEQ draw_animation_000
  CMP #$01
  BEQ draw_animation_001  
  CMP #$02
  BEQ draw_animation_002

draw_animation_000:
  LDA #$36
  STA $0201
  LDA #$37
  STA $0205
  LDA #$46
  STA $0209
  LDA #$47
  STA $020d
  
  JMP draw_finish00 

draw_animation_001:
  LDA #$38
  STA $0201
  LDA #$39
  STA $0205
  LDA #$48
  STA $0209
  LDA #$49
  STA $020d
  JMP draw_finish00 

draw_animation_002:
  LDA #$3A
  STA $0201
  LDA #$3B
  STA $0205
  LDA #$4A
  STA $0209
  LDA #$4B
  STA $020d

draw_finish00:
  JMP draw_finish0

draw_right0:
 JMP draw_right
draw_left:
  LDA animation_frame
  CMP #$00
  BEQ draw_animation_00
  CMP #$01
  BEQ draw_animation_01  
  CMP #$02
  BEQ draw_animation_02

draw_animation_00:
  LDA #$30
  STA $0201
  LDA #$31
  STA $0205
  LDA #$40
  STA $0209
  LDA #$41
  STA $020d
  
  JMP draw_finish0

draw_animation_01:
  LDA #$32
  STA $0201
  LDA #$33
  STA $0205
  LDA #$42
  STA $0209
  LDA #$43
  STA $020d
  JMP draw_finish0 


draw_animation_02:
  LDA #$34
  STA $0201
  LDA #$35
  STA $0205
  LDA #$44
  STA $0209
  LDA #$45
  STA $020d
  JMP draw_finish0


draw_finish0:
  JMP draw_finish

draw_right:
  LDA animation_frame
  CMP #$00
  BEQ draw_animation_0
  CMP #$01
  BEQ draw_animation_1  
  CMP #$02
  BEQ draw_animation_2
  CMP #$03

draw_animation_0:
  LDA #$0B
  STA $0201
  LDA #$0C
  STA $0205
  LDA #$09
  STA $0209
  LDA #$0A
  STA $020D
  JMP draw_finish 

draw_animation_1:
  LDA #$07
  STA $0201
  LDA #$08
  STA $0205
  LDA #$05
  STA $0209
  LDA #$06
  STA $020D
  JMP draw_finish 


draw_animation_2:
  LDA #$0F
  STA $0201
  LDA #$10
  STA $0205
  LDA #$0D
  STA $0209
  LDA #$0E
  STA $020D

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

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc




.proc load_background_mega
  LDX #$00
load_mega_loop:
  LDY #$00
load_mega_row:
  LDA megaTileMap, x    ; Load the mega tile index from the map
  ASL A                 ; Multiply by 4 because each mega tile has 4 entries
  TAY
  LDA megaTiles, y      ; Load first tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load second tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load third tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load fourth tile of mega tile
  STA $2007

  INX
  CPX #$F0             
  BNE load_mega_row
  RTS
.endproc

.proc load_background_mega1
  LDX #$00
load_mega_loop1:
  LDY #$00
load_mega_row1:
  LDA megaTileMap1, x    ; Load the mega tile index from the map
  ASL A                 ; Multiply by 4 because each mega tile has 4 entries
  TAY
  LDA megaTiles, y      ; Load first tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load second tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load third tile of mega tile
  STA $2007
  INY
  LDA megaTiles, y      ; Load fourth tile of mega tile
  STA $2007

  INX
  CPX #$F0             
  BNE load_mega_row1
  RTS
.endproc

.proc load_background_mega2
  LDX #$00
load_mega_loop2:
  LDY #$00
load_mega_row2:
  LDA megaTileMap2, x    ; Load the mega tile index from the map
  ASL A                 ; Multiply by 4 because each mega tile has 4 entries
  TAY
  LDA megaTiles2, y      ; Load first tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load second tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load third tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load fourth tile of mega tile
  STA $2007

  INX
  CPX #$F0             
  BNE load_mega_row2
  RTS
.endproc

.proc load_background_mega3
  LDX #$00
load_mega_loop3:
  LDY #$00
load_mega_row3:
  LDA megaTileMap3, x    ; Load the mega tile index from the map
  ASL A                 ; Multiply by 4 because each mega tile has 4 entries
  TAY
  LDA megaTiles2, y      ; Load first tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load second tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load third tile of mega tile
  STA $2007
  INY
  LDA megaTiles2, y      ; Load fourth tile of mega tile
  STA $2007

  INX
  CPX #$F0             
  BNE load_mega_row3
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $0f, $16, $07, $37
.byte $0f, $2b, $3c, $39
.byte $0f, $2C, $07, $13
.byte $0F, $30, $2C, $29

.byte $0f, $16, $2C, $37
.byte $0f, $30, $2C, $29
.byte $0f, $30, $2C, $29
.byte $0f, $30, $2C, $29

megaTiles:
  .byte $26, $26, $26, $26
  .byte $29, $29, $29, $29
  .byte $24, $24, $24, $24
  .byte $25, $25, $25, $25
  .byte $00, $00, $00, $00
  .byte $25, $25, $25, $25
  .byte $26, $26, $26, $26
  .byte $25, $25, $25, $25

megaTiles2:
  .byte $23, $23, $23, $23
  .byte $2b, $2b, $2b, $2b
  .byte $2a, $2a, $2a, $2a
  .byte $28, $28, $28, $28
  .byte $00, $00, $00, $00
  .byte $28, $28, $28, $28
  .byte $23, $23, $23, $23
  .byte $28, $28, $28, $28

megaTileMap:
  .byte $08, $08, $08, $08, $08, $08, $08, $08
  .byte $06, $06, $06, $06, $06, $06, $06, $06  
  .byte $07, $00, $00, $00, $00, $00, $00, $0c
  .byte $07, $00, $00, $00, $00, $00, $00, $0c
  
  .byte $07, $00, $04, $04, $04, $00, $08, $0c
  .byte $07, $00, $04, $04, $04, $00, $08, $0c
  .byte $07, $00, $08, $00, $04, $00, $08, $0c
  .byte $07, $00, $08, $00, $04, $00, $08, $0c

  .byte $07, $00, $08, $00, $08, $08, $08, $08
  .byte $07, $00, $08, $00, $08, $08, $08, $08
  .byte $07, $00, $08, $00, $00, $00, $00, $0c
  .byte $07, $00, $08, $00, $00, $00, $00, $0c
  
  .byte $07, $08, $08, $04, $08, $08, $08, $0c
  .byte $07, $08, $08, $04, $08, $08, $08, $0c
  .byte $07, $00, $00, $00, $00, $00, $08, $0c
  .byte $07, $00, $00, $00, $00, $00, $08, $0c

  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  .byte $0B, $00, $08, $00, $00, $00, $00, $0c
  .byte $0B, $00, $08, $00, $00, $00, $00, $0c
  
  .byte $08, $00, $08, $00, $00, $00, $00, $0c
  .byte $08, $00, $08, $00, $00, $00, $00, $0c
  .byte $07, $00, $08, $08, $08, $08, $08, $0c
  .byte $07, $00, $08, $08, $08, $08, $08, $0c

  .byte $07, $00, $00, $00, $00, $00, $04, $0c
  .byte $07, $00, $00, $00, $00, $00, $04, $0c
  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $07, $08, $08, $08, $08, $08, $08, $08
  .byte $07, $08, $08, $08, $08, $08, $08, $08


megaTileMap1:
  .byte $08, $08, $08, $08, $08, $08, $08, $08
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $0c, $08, $04, $04, $00, $04, $04, $07
  .byte $0c, $08, $04, $04, $00, $04, $04, $07

  .byte $0c, $08, $00, $04, $04, $04, $08, $07
  .byte $0C, $08, $00, $04, $04, $04, $08, $07
  .byte $0C, $08, $00, $00, $00, $00, $08, $07
  .byte $0C, $08, $00, $00, $00, $00, $08, $07

  .byte $08, $08, $08, $08, $08, $08, $08, $07
  .byte $08, $08, $08, $08, $08, $08, $08, $07
  .byte $0c, $00, $00, $00, $00, $08, $08, $07
  .byte $0c, $00, $00, $00, $00, $08, $08, $07
  
  .byte $0c, $04, $04, $04, $04, $08, $08, $07
  .byte $0c, $04, $04, $04, $04, $08, $08, $07
  .byte $0c, $04, $00, $00, $00, $00, $00, $07
  .byte $0c, $04, $00, $00, $00, $00, $00, $07

  .byte $0c, $04, $00, $04, $04, $08, $08, $07
  .byte $0c, $04, $00, $04, $04, $08, $08, $07
  .byte $0c, $04, $04, $04, $00, $08, $00, $0b
  .byte $0c, $04, $04, $04, $00, $08, $00, $0b
  
  .byte $0c, $00, $00, $00, $00, $08, $08, $08
  .byte $0c, $00, $00, $00, $00, $08, $08, $08
  .byte $0c, $08, $08, $08, $08, $08, $08, $07
  .byte $0c, $08, $08, $08, $08, $08, $08, $07

  .byte $0c, $08, $00, $00, $00, $00, $08, $07
  .byte $0c, $08, $00, $00, $00, $00, $08, $07
  .byte $0c, $04, $04, $04, $04, $04, $04, $07
  .byte $0c, $04, $04, $04, $04, $04, $04, $07
  
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $08, $08, $08, $08, $08, $08, $08, $07
  .byte $08, $08, $08, $08, $08, $08, $08, $07

megaTileMap2:
  .byte $08, $08, $08, $08, $08, $08, $08, $08
  .byte $06, $06, $06, $06, $06, $06, $06, $06  
  .byte $07, $04, $04, $00, $04, $04, $08, $0c
  .byte $07, $04, $04, $00, $04, $04, $08, $0c
  
  .byte $07, $00, $04, $04, $04, $00, $08, $0c
  .byte $07, $00, $04, $04, $04, $00, $08, $0c
  .byte $07, $00, $00, $00, $00, $00, $08, $0c
  .byte $07, $00, $00, $00, $00, $00, $08, $0c

  .byte $07, $00, $08, $08, $08, $08, $08, $08
  .byte $07, $00, $08, $08, $08, $08, $08, $08
  .byte $07, $00, $08, $00, $00, $00, $00, $0c
  .byte $07, $00, $08, $00, $00, $00, $00, $0c
  
  .byte $07, $00, $08, $04, $04, $04, $04, $0c
  .byte $07, $00, $08, $04, $04, $04, $04, $0c
  .byte $07, $00, $00, $00, $00, $00, $04, $0c
  .byte $07, $00, $00, $00, $00, $00, $04, $0c

  .byte $07, $08, $08, $04, $04, $00, $04, $0c
  .byte $07, $08, $08, $04, $04, $00, $04, $0c
  .byte $0B, $00, $08, $00, $04, $04, $04, $0c
  .byte $0B, $00, $08, $00, $04, $04, $04, $0c
  
  .byte $08, $08, $08, $00, $00, $00, $00, $0c
  .byte $08, $08, $08, $00, $00, $00, $00, $0c
  .byte $07, $00, $08, $08, $08, $08, $08, $0c
  .byte $07, $00, $08, $08, $08, $08, $08, $0c

  .byte $07, $00, $00, $00, $00, $00, $08, $0c
  .byte $07, $00, $00, $00, $00, $00, $08, $0c
  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  .byte $07, $04, $04, $04, $04, $04, $04, $0c
  
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $07, $08, $08, $08, $08, $08, $08, $08
  .byte $07, $08, $08, $08, $08, $08, $08, $08

megaTileMap3:
  .byte $08, $08, $08, $08, $08, $08, $08, $08
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $06, $08, $04, $04, $00, $04, $04, $07
  .byte $06, $08, $04, $04, $00, $04, $04, $07

  .byte $06, $08, $00, $04, $04, $04, $08, $07
  .byte $06, $08, $00, $04, $04, $04, $08, $07
  .byte $06, $08, $00, $00, $00, $00, $08, $07
  .byte $06, $08, $00, $00, $00, $00, $08, $07

  .byte $08, $08, $08, $00, $00, $00, $08, $07
  .byte $08, $08, $08, $00, $00, $00, $08, $07
  .byte $06, $00, $00, $00, $00, $08, $08, $07
  .byte $06, $00, $00, $00, $00, $08, $08, $07
  
  .byte $06, $04, $04, $04, $04, $08, $00, $07
  .byte $06, $04, $04, $04, $04, $08, $00, $07
  .byte $06, $04, $00, $00, $00, $00, $00, $07
  .byte $06, $04, $00, $00, $00, $00, $00, $07

  .byte $06, $04, $00, $04, $04, $04, $00, $07
  .byte $06, $04, $00, $04, $04, $04, $00, $07
  .byte $06, $04, $04, $04, $00, $00, $00, $0b
  .byte $06, $04, $04, $04, $00, $00, $00, $0b
  
  .byte $06, $00, $08, $08, $00, $00, $08, $08
  .byte $06, $00, $08, $08, $00, $00, $08, $08
  .byte $06, $04, $04, $04, $04, $04, $04, $07
  .byte $06, $04, $04, $04, $04, $04, $04, $07

  .byte $06, $04, $00, $00, $00, $00, $04, $07
  .byte $06, $04, $00, $00, $00, $00, $04, $07
  .byte $06, $04, $04, $04, $04, $04, $04, $07
  .byte $06, $04, $04, $04, $04, $04, $04, $07
  
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $06, $06, $06, $06, $06, $06, $06, $06
  .byte $08, $08, $08, $08, $08, $08, $08, $07
  .byte $08, $08, $08, $08, $08, $08, $08, $07

attribute:
  .byte %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000
  .byte %00000000, %00000000, %00000000, %00000000

.segment "CHR"
.incbin "graphics.chr"