;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Test Unitaire Audio (Sound_config.s)

GPIO_BUMPER_L	EQU 0x01	; Bumper Gauche
GPIO_BUMPER_R	EQU 0x02	; Bumper Droit
GPIO_BP1		EQU 0x40	; BP1
GPIO_BP2		EQU 0x80	; BP2

	AREA	|.text|, CODE, READONLY
	ENTRY
	EXPORT	__main
        
	IMPORT	Clock_Enable
	IMPORT	SWITCH_init
	IMPORT	SWITCH_read
	IMPORT	BUMPER_init
	IMPORT	BUMPER_read 
	IMPORT	Sound_Init
	IMPORT	SoundScore
	IMPORT	MusicVictory
	IMPORT	MusicDefeat
	IMPORT	MusicVictoryFinal


__main

	BL	Clock_Enable
	BL	SWITCH_init
	BL	BUMPER_init
	BL	Sound_Init

loop
	BL	SWITCH_read
	TST	R1, #GPIO_BP1      
	BEQ	test_victory		; Joue MusicVictory si switch1 est actionné
	TST	R1, #GPIO_BP2
	BEQ	test_defeat			; Joue MusicDefeat si switch2 est actionné


	BL	BUMPER_read
	TST	R0, #GPIO_BUMPER_L
	BEQ	test_score			; Joue SoundScore si bumper gauche est actionné
	
	TST	R0, #GPIO_BUMPER_R
	BEQ	test_endgame		; Joue MusicVictoryFinal si bumper droit est actionné
	
	B	loop

; =======================
; Branchements

test_victory
	BL	MusicVictory
	B	loop

test_defeat
	BL	MusicDefeat
	B	loop

test_score
	BL	SoundScore
	B	delay
	
test_endgame
	BL	MusicVictoryFinal
	
delay
	LDR	R2, =500000
debounce_delay
	SUBS R2, R2, #1
	BNE	debounce_delay
	B	loop


	END
