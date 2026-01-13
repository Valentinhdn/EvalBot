		AREA	|.text|, CODE, READONLY
		ENTRY
		EXPORT	__main

; =======================
; DEFINITIONS

GPIO_BUMPER_L	EQU 0x02
GPIO_BUMPER_R	EQU 0x01
GPIO_BP1		EQU 0x40
GPIO_BP2		EQU 0x80
		
		; --- IMPORTS BUMPER, LED, SWITCH, MOTEUR ---
        IMPORT  BUMPER_init
        IMPORT  BUMPER_read
        IMPORT  LED_init
        IMPORT  LED1_ON
        IMPORT  LED1_OFF
        IMPORT  LED2_ON
        IMPORT  LED2_OFF
        IMPORT  Clock_Enable
        IMPORT  SWITCH_init
        IMPORT  SWITCH_read
        IMPORT  MOTEUR_INIT
        IMPORT  MOTEUR_DROIT_ON
        IMPORT  MOTEUR_DROIT_OFF
        IMPORT  MOTEUR_DROIT_AVANT
        IMPORT  MOTEUR_DROIT_ARRIERE
        IMPORT  MOTEUR_GAUCHE_ON
        IMPORT  MOTEUR_GAUCHE_OFF
        IMPORT  MOTEUR_GAUCHE_AVANT
        IMPORT  MOTEUR_GAUCHE_ARRIERE
         
        ; --- IMPORTS AUDIO ---
		IMPORT  Sound_Init
		IMPORT  SoundScore
		IMPORT  MusicVictory
		IMPORT  MusicVictoryFinal
		IMPORT  MusicDefeat
		IMPORT	Sound_Countdown_Bip
		IMPORT	Sound_Countdown_Go
		IMPORT	Sound_Sirene_Pin
		IMPORT	Sound_Sirene_Pon
		IMPORT  PlayNote
		IMPORT  Wait_Sound

; =======================
; Initialisation config matérielle
__main
			BL Clock_Enable
			BL Sound_Init
			BL LED_init
			BL BUMPER_init
			BL SWITCH_init
			BL MOTEUR_INIT
			
			; Désactiver puis activer moteurs pour partir propre
			BL MOTEUR_DROIT_OFF
			BL MOTEUR_GAUCHE_OFF
			
			; Initialisation Variables Globales
			MOV R7, #1		; Manche 1
			MOV R5, #1		; Objectif 1
			MOV R4, #0		; Score 0
			
			; on va au lobby du jeu
			B lobby

; =======================
; Menu lancement de partie 
lobby
			; Animation de leds
			BL LED1_ON
			BL WAIT2_JEU
			BL LED1_OFF
			BL WAIT2_JEU
			BL LED2_ON
			BL WAIT2_JEU
			BL LED2_OFF
			BL WAIT2_JEU
			
			; lecture état et test du switch 1
			BL SWITCH_read
			TST R1, #GPIO_BP1
			; si appuie sur BP1, alors on démarre le jeu
			BEQ demarrer_jeux
			
			; si appuie sur BP2, alors mode pompier activé
			TST	R1, #GPIO_BP2
			BEQ	mode_pompier
			
			; sinon on attend le lancement du jeu
			B lobby
			
; =======================
; Mode pompier
mode_pompier
			BL	MOTEUR_DROIT_ON
			BL	MOTEUR_GAUCHE_ON
			
			BL	MOTEUR_DROIT_AVANT
			BL	MOTEUR_GAUCHE_ARRIERE

loop_sirene
			; LED1 + sons pompier (pin)
			BL	LED2_OFF
			BL	LED1_ON
			
			BL	Sound_Sirene_Pin
			
			; Condition d'arrêt avec BP2
			BL	SWITCH_read
			TST	R1, #GPIO_BP2
			BEQ	stop_pompier
			
			; LED2 + son pompier (pon)
			BL	LED2_ON
			BL	LED1_OFF
			
			BL	Sound_Sirene_Pon
			
			; condition d'arrêt avec BP2
			BL	SWITCH_read
			TST	R1, #GPIO_BP2
			BEQ	stop_pompier
			
			B	loop_sirene
			
stop_pompier
			BL	MOTEUR_DROIT_OFF
			BL	MOTEUR_GAUCHE_OFF
			BL	LED1_OFF
			BL	LED2_OFF
			
			BL	WAIT2_JEU
			B	lobby

; =======================
; Demarrage manche
; jeu BUMPER SMASH
demarrer_jeux

			; son Bip -> compte à rebourd avant le début du jeu et du timer 
			BL	Sound_Countdown_Bip
			BL	Sound_Countdown_Bip
			BL	Sound_Countdown_Bip
			
			; son Go -> annonce le lancement du jeu et du timer
			BL	Sound_Countdown_Go
			
			; Initialisation du jeu
			MOV R4, #0			; Reset score


			; calcul objectif : R5 = 1 + 2*(Manche-1) 
			; l'idée c'est d'incrémenter l'objectif de +2 à chaque manche
			MOV R0, R7
			SUB R0, R0, #1		; R0 = manche - 1
			MOV R1, #2
			MUL R0, R0, R1		; R0 = 2*(manche-1)
			MOV R5, #1			; objectif de base
			ADD R5, R5, R0		; R5 = 1 + 2*(manche-1)
			

			; Chronomètre de 15s pour la condition de défaite
			; 150 tics * 0.1s = 15 secondes
			LDR R9, =150
			
			B avancer

; =======================
; Séquence principale (Avancer + vérifier collision + Timer)
avancer

			; Moteurs en avant (par défaut)
			BL MOTEUR_DROIT_ON
			BL MOTEUR_GAUCHE_ON
			BL MOTEUR_DROIT_AVANT
			BL MOTEUR_GAUCHE_AVANT

			; Vérification Bumpers
			BL BUMPER_read
			TST R0, #GPIO_BUMPER_L
			BEQ bumperL_hit
			TST R0, #GPIO_BUMPER_R
			BEQ bumperR_hit

			; SI PAS DE COLLISION -> GESTION DU TEMPS
			; On attend 0.1s
			LDR R2, =533333		; Valeur approx pour 0.1s (à ajuster selon fréquence CPU)
			BL  Wait_Sound 
			
			SUBS R9, R9, #1		; Décrémente le chrono
			BEQ defaite			; Si 0 -> TEMPS ÉCOULÉ !

			B avancer			; On boucle

; =======================
; Gestion des collisions 
bumperL_hit

			; Led 2 allumée
			BL LED2_ON
			ADD R4, R4, #1		; Score +1
			
			CMP R4, R5
			BGE fin_manche		; si score >= objectif alors manche terminée
			
			; collision donc reculer
			BL MOTEUR_DROIT_ARRIERE
			BL MOTEUR_GAUCHE_ARRIERE
			
			; Son de score si collision
			BL SoundScore
			
			BL WAIT_JEU

			; puis tourner à gauche
			BL MOTEUR_DROIT_AVANT
			BL WAIT_JEU
			
			; Led 2 éteinte
			BL LED2_OFF
			B avancer			; Retour boucle (sans décrémenter temps, bonus pour le joueur)
			
bumperR_hit

			; Led 1 allumée
			BL LED1_ON
			ADD R4, R4, #1		; Score +1
			
			CMP R4, R5
			BGE fin_manche		; si score >= objectif alors manche terminée
			
			; collision donc reculer
			BL MOTEUR_DROIT_ARRIERE
			BL MOTEUR_GAUCHE_ARRIERE
			
			; Son de score si collision
			BL SoundScore
			
			BL WAIT_JEU

			; puis tourner à droite
			BL MOTEUR_GAUCHE_AVANT
			BL WAIT_JEU
			
			; Led 1 éteinte
			BL LED1_OFF
			B avancer			; Retour boucle
         
; =======================
; Fin de manche (Victoire MANCHE)
fin_manche
			
			; on éteint proprement les moteurs
			BL MOTEUR_DROIT_OFF
			BL MOTEUR_GAUCHE_OFF
			
			; on incrémente le compteur de manche
			ADD R7, R7, #1		; manche++
			
			; si on a joué 3 manches, la partie est terminée et on a gagné
			CMP R7, #4
			BEQ fin_jeu 
			
			; Si ce n'est pas la fin du jeu, on joue la musique intermédiaire
			BL MusicVictory
			
			; et on attend que la prochaine manche se lance
			B transition_manche

; =======================
; Jeu terminé car Temps écoulé (Défaite)
defaite

			; on éteint proprement les moteurs
			BL MOTEUR_DROIT_OFF
			BL MOTEUR_GAUCHE_OFF
			
			BL MusicDefeat		; Musique de défaite
			
			; Reset total du jeu
			MOV R7, #1			; Retour manche 1
			MOV R5, #1			; Retour objectif 1
			MOV R4, #0			; Score 0
			
			B lobby				; Retour au lobby

; =======================
; Jeu terminé (Victoire FINALE)
fin_jeu
			; on éteint proprement les moteurs
			BL MOTEUR_DROIT_OFF
			BL MOTEUR_GAUCHE_OFF
			BL MusicVictoryFinal ; Musique de victoire finale après 3 manches (son plus long)
			
			; Reset du jeu au valeur par défaut
			MOV R7, #1          ; Retour manche 1
			MOV R5, #1          ; Retour objectif 1
			MOV R4, #0          ; Score 0
			
			B lobby				; Retour au lobby

; =======================
; Temporisation (WAIT) et transition de manche

transition_manche
			; Manche en attente de lancement
transition_loop

			; animation leds
			BL LED1_ON
			BL LED2_ON
			BL WAIT2_JEU
			BL LED1_OFF
			BL LED2_OFF
			BL WAIT2_JEU
			
			; lecture état et test du switch 1
			BL SWITCH_read
			TST R1, #GPIO_BP1
			; si appuie, alors on démarre la nouvelle manche
			BEQ demarrer_jeux
			; sinon on attend le lancement de la nouvelle manche
			B transition_loop


WAIT_JEU	ldr r1, =0x7FFFFF 
; Tempo pour les changements de direction moteurs (2s)
wait1		subs r1, #1
			bne wait1
			BX	LR
			
WAIT2_JEU	ldr r1, =0x0FFFFF 
; Tempo pour les animations de led(500ms)
wait2		subs r1, #1
			bne wait2
			BX	LR
		
		END