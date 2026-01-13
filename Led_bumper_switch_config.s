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
	
GPIO_SPEAKER        EQU 0x08      ; Speaker sur Port F, Pin 3 (voisine des LEDs)

; initialisation E/S 

GPIO_BUMPER_L       EQU 0x01      ; Bumper Gauche broche 0 
GPIO_BUMPER_R       EQU 0x02 	  ; Bumper Droit broche 1
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
		EXPORT  Clock_Enable  ;Port F et Port D
			
BUMPER_init
		
		;Configuration des Bumper
        ldr r6, = GPIO_PORTE_BASE+GPIODEN
        ldr r0, = GPIO_BUMPER_L | GPIO_BUMPER_R
        str r0, [r6]

		BX LR
		
BUMPER_read

        ldr r6, = GPIO_PORTE_BASE + ((GPIO_BUMPER_L | GPIO_BUMPER_R) << 2)
        ldr r0, [r6]
        bx  lr

Clock_Enable
		
		ldr r6, = SYSCTL_RCGC2    ; registre RCGC2
		mov r0, #0x00000038
        str r0, [r6]                   ; Enable clock sur GPIO D et F où sont branchés les leds (0x28 == 0b101000)
        
        ; délai obligatoire de 3 cycles
        nop
        nop
        nop
		BX LR
		
LED_init

		ldr r6, = GPIO_PORTF_BASE+GPIODIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = GPIO_Led1 | GPIO_Led2 | GPIO_SPEAKER
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIODEN	;; Enable Digital Function 
        ldr r0, = GPIO_Led1 | GPIO_Led2	| GPIO_SPEAKER
        str r0, [r6]
		
		ldr r6, = GPIO_PORTF_BASE+GPIODR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = GPIO_Led1 | GPIO_Led2 | GPIO_SPEAKER
        str r0, [r6]
		BX LR
		
LED1_ON

		; allumer led1
		mov r3, #0xFF ;; Allume LED1
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led1<<2)  ;; @data Register = @base + (mask<<2)
		str r3, [r6]  
		BX LR
		
LED1_OFF

		mov r3, #0x000       					;; pour eteindre LED
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led1<<2)  ;; @data Register = @base + (mask<<2)
		str r3, [r6]
		BX LR
		
LED2_ON

		; allumer led1
		mov r3, #0xFF ;; Allume LED1
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led2<<2)  ;; @data Register = @base + (mask<<2)
		str r3, [r6]  
		BX LR
		
LED2_OFF

		mov r3, #0x000       					;; pour eteindre LED
		ldr r6, = GPIO_PORTF_BASE + (GPIO_Led2<<2)  ;; @data Register = @base + (mask<<2)
		str r3, [r6]
		BX LR

SWITCH_init

        ; Config BP1 pull-up
        ldr r6, = GPIO_PORTD_BASE + GPIOPUR
        ldr r0, = GPIO_BP1 | GPIO_BP2
        str r0, [r6]

        ; Enable digital
        ldr r6, = GPIO_PORTD_BASE + GPIODEN
        ldr r0, = GPIO_BP1 | GPIO_BP2
        str r0, [r6]

        BX LR

		
SWITCH_read

        ldr r6, = GPIO_PORTD_BASE + ((GPIO_BP1 | GPIO_BP2) << 2)
        ldr r1, [r6]
        BX LR

		
		
		NOP
		END