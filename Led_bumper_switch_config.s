; initialisation variables système
SYSCTL_RCGC2   equ   0x400FE108 
	
GPIO_PORTD_BASE		EQU	0x40007000	
GPIO_PORTE_BASE		EQU	0x40024000
GPIO_PORTF_BASE		EQU	0x40025000	
GPIO_PORTJ_BASE		EQU	0x4003D000 
	
GPIODIR     equ 0x400 ; GPIO Direction  p417 
GPIODR2R    equ 0x500   ; R/W 0x0000.00FF GPIO 2-mA Drive Select        p428
GPIOPUR     equ 0x510   ; R/W - GPIO Pull-Up Select                     p432
GPIODEN     equ 0x51C   ; R/W - GPIO Digital E nable                    p437

; initialisation E/S 

GPIO_BUMPER_L       EQU 0x02      ; Bumper Gauche broche 1 
GPIO_BUMPER_R       EQU 0x01 	  ; Bumper Droit broche 0
GPIO_Led1			EQU	0x10	  ; led1 broche 4
GPIO_Led2			EQU	0x20	  ; led2 broche 5
GPIO_BP1			EQU 0x40	  ; bouton poussoir 1 broche 6
GPIO_BP2			EQU 0x80	  ; bouton poussoir 2 broche 7

		AREA    |.text|, CODE, READONLY
		ENTRY
		
		;; The EXPORT command specifies that a symbol can be accessed by other shared objects or executables.
		EXPORT	BUMPER_init
		EXPORT  BUMPER_read		
		EXPORT	LED_init
		EXPORT	LED1_ON
		EXPORT	LED1_OFF
		EXPORT	LED2_ON
		EXPORT	LED2_OFF			
		EXPORT  SWITCH_init
		EXPORT  SWITCH_read
		EXPORT  Clock_Enable 
			
BUMPER_init		
		;Configuration des bumpers
        ldr r6, = GPIO_PORTE_BASE+GPIODEN
        ldr r0, = GPIO_BUMPER_L | GPIO_BUMPER_R
        str r0, [r6]

		BX LR
		
BUMPER_read
		; Lecture Etat des bumpers
        ldr r6, = GPIO_PORTE_BASE + ((GPIO_BUMPER_L | GPIO_BUMPER_R) << 2)
        ldr r0, [r6]
        bx  lr

Clock_Enable
		; Activation de l'horloge pour utiliser nos registres
		ldr r6, = SYSCTL_RCGC2  
		mov r0, #0x00000038
        str r0, [r6]                   ; Enable clock sur GPIO D, E, F (0x38 == 0b00111000)
        
        ; délai obligatoire de 3 cycles
        nop
        nop
        nop
		BX LR
		
LED_init
		;Configuration des leds
		ldr r6, = GPIO_PORTF_BASE+GPIODIR    ;Activation broches comme sorties
        ldr r0, = GPIO_Led1 | GPIO_Led2
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIODEN	;Activation fonctions numériques de nos broches
        ldr r0, = GPIO_Led1 | GPIO_Led2	
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIODR2R	;Activation intensité du courant (2mA)
        ldr r0, = GPIO_Led1 | GPIO_Led2		
        str r0, [r6]
		BX LR
		
LED1_ON

		; allumer led1
		mov r3, #0xFF 
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led1<<2)  ;; @data Register = @base + (mask<<2)
		str r3, [r6]  
		BX LR
		
LED1_OFF
		; eteindre LED1
		mov r3, #0x000       					
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led1<<2)  ; @data Register = @base + (mask<<2)
		str r3, [r6]
		BX LR
		
LED2_ON

		; allumer led2
		mov r3, #0xFF 
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led2<<2)  ; @data Register = @base + (mask<<2)
		str r3, [r6]  
		BX LR
		
LED2_OFF
		; eteindre LED2
		mov r3, #0x000
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led2<<2)  ; @data Register = @base + (mask<<2)
		str r3, [r6]
		BX LR

SWITCH_init

        ; Configuration des switchs
        ldr r6, = GPIO_PORTD_BASE + GPIOPUR 	;Activation pull-up interne
        ldr r0, = GPIO_BP1 | GPIO_BP2
        str r0, [r6]


        ldr r6, = GPIO_PORTD_BASE + GPIODEN 	;Activation fonctions numériques de nos broches
        ldr r0, = GPIO_BP1 | GPIO_BP2
        str r0, [r6]

        BX LR

		
SWITCH_read
		; Lecture Etat des bumpers
        ldr r6, = GPIO_PORTD_BASE + ((GPIO_BP1 | GPIO_BP2) << 2)	; @data Register = @base + (mask<<2)
        ldr r1, [r6]
        BX LR

		
		
		NOP
		END