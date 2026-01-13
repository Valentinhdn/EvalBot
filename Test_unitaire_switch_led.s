	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)
GPIO_BUMPER_L       EQU 0x01      ; Bumper Gauche broche 0 
GPIO_BUMPER_R       EQU 0x02 	  ; Bumper Droit broche 1
GPIO_BP1			EQU 0x40	  ; bouton poussoir 1 broche 6
GPIO_BP2			EQU 0x80	  ; bouton poussoir 2 broche 7


		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	BUMPER_init
		IMPORT 	BUMPER_read				
		IMPORT	LED_init
		IMPORT	LED1_ON
		IMPORT	LED1_OFF	
		IMPORT	LED2_ON
		IMPORT	LED2_OFF
		IMPORT	Clock_Enable
		IMPORT  SWITCH_init
		IMPORT  SWITCH_read


__main
    BL Clock_Enable
    BL LED_init
    BL SWITCH_init

loop
    BL SWITCH_read
    TST R1, #GPIO_BP1      ; si appuyé
    BEQ led1_on
led1_off
    BL LED1_OFF
    B check_bp2
led1_on
    BL LED1_ON
    B  check_bp2
check_bp2
	TST R1, #GPIO_BP2
	BEQ led2_on
led2_off
	BL LED2_OFF
	B  loop
led2_on
	BL LED2_ON
	B loop
