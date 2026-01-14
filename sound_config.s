		AREA	|.text|, CODE, READONLY
        
		; --- EXPORTS (Fonctions accessibles depuis le Main) ---
		EXPORT  Sound_Init
		EXPORT  SoundScore
		EXPORT  MusicVictory
		EXPORT	MusicDefeat
		EXPORT	MusicVictoryFinal
			
		EXPORT	Sound_Countdown_Bip
		EXPORT	Sound_Countdown_Go
		EXPORT	Sound_Sirene_Pin
		EXPORT	Sound_Sirene_Pon
			
		EXPORT  PlayNote		; Nécessaire pour le compte à rebours
		EXPORT  Wait_Sound		; Nécessaire pour les pauses musicales


; ======================
; Definition du port J

SYSCTL_RCGC2_R	EQU	0x400FE108
GPIO_PORTJ_BASE	EQU	0x4003D000
GPIO_PORTJ_DIR	EQU	0x4003D400
GPIO_PORTJ_DEN	EQU	0x4003D51C
GPIO_PORTJ_DATA	EQU	0x4003D3FC

; =======================
; Initialisation

Sound_Init
		PUSH {R0, R1, LR}
		
		; Activation Horloge Port J
		LDR R0, =SYSCTL_RCGC2_R
		LDR R1, [R0]
		ORR R1, R1, #0x00000100
		STR R1, [R0]
		
		NOP
		NOP
		NOP
		
		; Config DIR
		LDR R0, =GPIO_PORTJ_DIR
		LDR R1, [R0]
		ORR R1, R1, #0x08
		STR R1, [R0]
		
		; Config DEN
		LDR R0, =GPIO_PORTJ_DEN
		LDR R1, [R0]
		ORR R1, R1, #0x08
		STR R1, [R0]
		
		POP {R0, R1, PC}
		
; ==================
; Son spécifique 

; R5 -> fréquence de la note
; Valeur élévée = grave
; Valeur basse = aigu

; R6 -> durée de la note
; Valeur élevée = long
; Valeur basse = court

; Compte à rebours (Bip)
Sound_Countdown_Bip
		PUSH {R2, R5, R6, LR}
		LDR R5, =2500
		LDR R6, =150
		BL  PlayNote
		LDR R2, =2000000
		BL  Wait_Sound
		POP {R2, R5, R6, PC}

; Compte à rebours (GO)
Sound_Countdown_Go
		PUSH {R5, R6, LR}
		LDR R5, =800
		LDR R6, =600
		BL  PlayNote
		POP {R5, R6, PC}

; Sirene pompier (Pin)
Sound_Sirene_Pin
		PUSH {R2, R5, R6, LR}
		LDR R5, =1500
		LDR R6, =400
		BL  PlayNote
		LDR R2, =1500000
		BL  Wait_Sound
		POP {R2, R5, R6, PC}

; Sirene pompier (Pon)
Sound_Sirene_Pon
		PUSH {R2, R5, R6, LR}
		LDR R5, =2500
		LDR R6, =300
		BL  PlayNote
		LDR R2, =1500000
		BL  Wait_Sound
		POP {R2, R5, R6, PC}

; =======================
; Melodie

; Musique pour la victoire d'une manche
MusicVictory
		PUSH {R4-R6, LR}
		
		LDR R5, =3400
		LDR R6, =200
		BL  PlayNote
		
		LDR R5, =2700
		LDR R6, =200
		BL  PlayNote
		
		LDR R5, =2270
		LDR R6, =200
		BL  PlayNote
		
		LDR R5, =1700
		LDR R6, =800
		BL  PlayNote
		
		POP {R4-R6, PC}


; Musique pour la défaite d'une manche
MusicDefeat
		PUSH {R4-R6, LR}
		
		LDR R5, =2400
		LDR R6, =400
		BL  PlayNote
		
		LDR R5, =2550
		LDR R6, =400
		BL  PlayNote
		
		LDR R5, =2700
		LDR R6, =400
		BL  PlayNote
		
		LDR R5, =2900
		LDR R6, =1000
		BL  PlayNote
		
		POP {R4-R6, PC}


; Musique lors d'une collision
SoundScore
		PUSH {R4-R6, LR}
        
		LDR R5, =2270
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =1700
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =1350
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =1135
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =850
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =675
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =567
		LDR R6, =100
		BL	PlayNote
		BL	Silence_Effect

		LDR R5, =675
		LDR R6, =800
		BL	PlayNote

		POP	{R4-R6, PC}

Silence_Effect
		PUSH {R2, LR}
		LDR R2, =50000
		BL	Wait_Sound
		POP	{R2, PC}


; Musique pour la victoire final du jeu (après les 3 manches remportées)
MusicVictoryFinal
		PUSH {R4-R6, LR}
	
		LDR R5, =2700
		LDR R6, =150
		BL	PlayNote
	
		LDR R5, =2270
		LDR R6, =150
		BL	PlayNote
	
		LDR R5, =2020
		LDR R6, =200
		BL	PlayNote
	
		LDR R5, =1350
		LDR R6, =300
		BL	PlayNote
	
		LDR R5, =2020
		LDR R6, =200
		BL	PlayNote
	
		LDR	R5, =2270
		LDR	R6, =200
		BL	PlayNote
	
		LDR	R5, =2020
		LDR	R6, =250
		BL	PlayNote
			
		LDR	R5, =1350
		LDR	R6, =600
		BL	PlayNote
	
		BL	Silence
	
		LDR	R5, =1350
		LDR	R6, =120
		BL	PlayNote
		BL	Silence
	
		LDR	R5,	=1350
		LDR	R6,	=120
		BL	PlayNote
		BL	Silence
	
		LDR	R5, =1350
		LDR	R6, =120
		BL	PlayNote
		BL	Silence
	
		LDR	R5, =1000
		LDR	R6, =1500
		BL	PlayNote
	
		POP {R4-R6, PC}

Silence
		PUSH {R1-R2, LR}
		
		LDR R1,	=GPIO_PORTJ_DATA
		LDR R2,	[R1]
		BIC R2,	R2, #0x08	; Speaker OFF
		STR R2,	[R1]
		LDR R2,	=400000
WaitSilence
		SUBS R2, R2, #1
		BNE	WaitSilence

		POP	{R1-R2, PC}



; ============
; Audio


; Entrées : R5 = délai, R6 = durée
PlayNote
		PUSH {R3, LR}
		LDR R3, =GPIO_PORTJ_DATA

PlayCycle
		; Speaker ON
		LDR R1, [R3]
		ORR R1, R1, #0x08
		STR R1, [R3]

		; Attendre
		MOV R2, R5
		BL  Wait_Sound

		; Speaker OFF
		LDR R1, [R3]
		BIC R1, R1, #0x08
		STR R1, [R3]
        
		; Attendre
		MOV R2, R5
		BL	Wait_Sound
        
		SUBS R6, R6, #1
		BNE	 PlayCycle
		
		POP {R3, PC}

Wait_Sound
		SUBS R2, R2, #1
		BNE	 Wait_Sound
		BX	 LR


		END
