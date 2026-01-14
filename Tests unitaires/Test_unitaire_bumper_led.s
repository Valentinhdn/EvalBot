	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	; programme - Test unitaire : Bumpers, Leds (on allume une allume selon le bumper appuyé)
GPIO_BUMPER_L       EQU 0x01      ; Bumper Gauche broche 0 
GPIO_BUMPER_R       EQU 0x02 	  ; Bumper Droit broche 1


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
		IMPORT  MOTEUR_GAUCHE_OFF	
		IMPORT  MOTEUR_DROIT_OFF	
		IMPORT	MOTEUR_INIT	


__main	
		; initialisation de la config matérielle
		BL Clock_Enable
		BL LED_init
		BL BUMPER_init

loop
		; lecture et test état du bumper Left
        BL BUMPER_read      
        TST R0, #GPIO_BUMPER_L
		; si collision led1 allumée
        BEQ led1_on
led1_off
		; led1 éteinte
		BL LED1_OFF
		B check_bumperR
led1_on
		; led1 allumée
        BL LED1_ON
		B check_bumperR
check_bumperR
		; test état bumper Right
        TST R0, #GPIO_BUMPER_R
		; si collision led2 allumée
        BEQ led2_on
led2_off
		; led2 éteinte
		BL LED2_OFF
		; on reboucle à loop pour recommencer
		B loop
led2_on
		; led2 allumée
        BL LED2_ON
		; on reboucle à loop pour recommencer 
        B loop
