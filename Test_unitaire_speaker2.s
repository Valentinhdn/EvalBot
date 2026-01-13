;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Test Unitaire Audio (Sound_config.s)

GPIO_BP1		EQU 0x40	; BP1
GPIO_BP2		EQU 0x80	; BP2

	AREA	|.text|, CODE, READONLY
	ENTRY
	EXPORT	__main
        
	IMPORT	Clock_Enable
	IMPORT	SWITCH_init
	IMPORT	SWITCH_read
	IMPORT	Sound_Init
	IMPORT	Sound_Countdown_Bip
	IMPORT	Sound_Countdown_Go
	IMPORT	Sound_Sirene_Pin
	IMPORT	Sound_Sirene_Pon


__main

	BL	Clock_Enable
	BL	SWITCH_init
	BL	Sound_Init

loop
	BL	SWITCH_read
	TST	R1, #GPIO_BP1      
	BEQ	test_PinPon			; Joue son pompier (pin-pon) si switch1 est actionné
	TST	R1, #GPIO_BP2
	BEQ	test_BipGo			; Joue son compte à rebours (bip-bip-bip-go) si switch2 est actionné
	
	B	loop

; =======================
; Branchements

test_PinPon
	BL	Sound_Sirene_Pin
	BL	Sound_Sirene_Pon
	BL	Sound_Sirene_Pin
	BL	Sound_Sirene_Pon
	B	loop

test_BipGo
	BL	Sound_Countdown_Bip
	BL	Sound_Countdown_Bip
	BL	Sound_Countdown_Bip
	BL	Sound_Countdown_Go
	B	loop

	END