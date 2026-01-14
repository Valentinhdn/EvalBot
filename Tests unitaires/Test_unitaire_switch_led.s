	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	; programme - Test unitaire : Switchs, Leds (on allume une allume selon le switch appuyé)
GPIO_BUMPER_L       EQU 0x01      ; Bumper Gauche broche 0 
GPIO_BUMPER_R       EQU 0x02 	  ; Bumper Droit broche 1
GPIO_BP1			EQU 0x40	  ; bouton poussoir 1 broche 6
GPIO_BP2			EQU 0x80	  ; bouton poussoir 2 broche 7


		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
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
	; initialisation de la config matérielle
    BL Clock_Enable
    BL LED_init
    BL SWITCH_init

loop
	; lecture et test état du switch1
    BL SWITCH_read
    TST R1, #GPIO_BP1 
	; si appuie, led1 allumée
    BEQ led1_on
led1_off
	; led1 éteinte
    BL LED1_OFF
    B check_bp2
led1_on
	; led1 allumée
    BL LED1_ON
    B  check_bp2
check_bp2
	; test état switch2
	TST R1, #GPIO_BP2
	; si appuie, led2 allumée
	BEQ led2_on
led2_off
	; led2 éteinte
	BL LED2_OFF
	; on reboucle à loop pour recommencer
	B  loop
led2_on
	; led2 allumée
	BL LED2_ON
	; on reboucle à loop pour recommencer
	B loop
