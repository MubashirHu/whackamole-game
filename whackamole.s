;;Mubashir Hussain
;;Lab project - whack-a-mole game
;;2020/12/3
;;ENSE 352

;;; Directives
	PRESERVE8
	THUMB        
;;; Equates
INITIAL_MSP	EQU		0x20001000	; Initial Main Stack Pointer Value
;PORT A GPIO - Base Addr: 0x40010800
GPIOA_CRL	EQU		0x40010800	; (0x00) Port Configuration Register for Port 0 to port 7
GPIOA_CRH	EQU		0x40010804	; (0x04) Port Configuration Register  for port 8 to port 15
GPIOA_IDR	EQU		0x40010808	; (0x08) Port Input Data Register
GPIOA_ODR	EQU		0x4001080C	; (0x0C) Port Output Data Register

;PORT B GPIO - Base Addr: 0x40010C00
GPIOB_CRL	EQU		0x40010C00	; (0x00) Port Configuration Register for Port 0 to port 7
GPIOB_CRH	EQU		0x40010C04	; (0x04) Port Configuration Register for port 8 to port 15
GPIOB_IDR	EQU		0x40010C08	; (0x08) Port Input Data Register
GPIOB_ODR	EQU		0x40010C0C	; (0x0C) Port Output Data Register
	
RCC_APB2ENR	EQU		0x40021018	; APB2 Peripheral Clock Enable Register 

;------------------------------
; 	  Delay timers used		   |
;------------------------------
WaitingTimeSpeed EQU 250000;   |
BeforeGamestart EQU	6000000;   |
proficiencySignal EQU 10000000;|
;------------------------------
;		GAME SETTINGS		 |
;----------------------------
PrelimWait	EQU	5000000;     |
ReactTime	EQU	400000;      |
DecrementAmount EQU 3000;    |
NumCycles EQU 16;             |
WinningSignalTime EQU 250000;|
LosingSignalTime EQU 300000; |
;----------------------------
;   AMOUNT OF TIMES TO FLASH |
;----------------------------
WinningFlashAmount EQU 20;   |
LosingFlashAmount EQU 16;    |
;----------------------------

; Vector Table Mapped to Address 0 at Reset
            AREA    RESET, Data, READONLY
            EXPORT  __Vectors

__Vectors	DCD		INITIAL_MSP			; stack pointer value when stack is empty
        	DCD		Reset_Handler		; reset vector
			
            AREA    MYCODE, CODE, READONLY
			EXPORT	Reset_Handler
			ENTRY
			
Reset_Handler PROC
	
;; the entire contents of the game are within this loop
mainLoop 

		BL GPIO_ClockInit
		BL GPIO_init
		BL waiting
		BL playing 
		
		B mainLoop
		ENDP
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
;;; Use Case 2: A state where the LED's move about in a certain pattern
;;;				waiting for user response for the game to start
;;;	Require 
;;;		r6 : for accessing a specific area in memory i.e CRL/CRH etc
;;;		r1 : for reading the memory location in r6
;;; 	r2 : to store the respective odr bit pattern to turn on an LED
;;;		r5 : to be used as the timer value for the delay's
;;; Promise
;;;		to output the respective ODR value for each of the LED's into the address 
;;; 	store in r6, Also, by using the r5 (timer) I can branch to a subroutine to 
;;;		pause between each transition. In between these transitions I wait for user response
	ALIGN
waiting PROC
	
	;before goes left to right, clear led
	bl reset_Led
	;turn on led1 , A0
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0001
	orr r2,r2,r1
	str r2,[r6]
	ldr r5, = WaitingTimeSpeed
	bl Delay
	bl check_Response

	;turn on led2 , A1
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0002
	orr r2,r2,r1
	str r2,[r6]
	ldr R5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;turn on led3 , A2
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0010
	orr r2,r2,r1
	str r2,[r6]
	ldr r5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;turn on led4 , B0 
	ldr r6,=GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0x0001
	orr r2,r2,r1
	str r2,[r6]
	ldr r5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;before goes right to left, clear led
	bl reset_Led
	
	;turn on led4 , B0 
	ldr r6,=GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0x0001
	orr r2,r2,r1
	str r2,[r6]
	ldr r5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;turn on led3 , A2
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0010
	orr r2,r2,r1
	str r2,[r6]
	ldr R5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;turn on led2 , A1
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0002
	orr r2,r2,r1
	str r2,[r6]
	ldr R5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	;turn on led1 , A0
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0001
	orr r2,r2,r1
	str r2,[r6]
	ldr R5, = WaitingTimeSpeed
	bl Delay
	bl check_Response
	
	B waiting  ;; loop again to the begining because there's no response
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; A timer for a delay. This delay is what allows allows the pattern to look more fluid
;;;	rather then all the lights turning on at once
;;;	Require 
;;;		r5: to be used as the timer value for the delay's
;;; Promise
;;;		Once the timer has ran out, it will branch back to where it was called through link register
	ALIGN
Delay proc
	subs R5, #1			;counts down till 0
	bne Delay
	bx lr
	endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Through this subroutine, I branch off to the use case 3 if any of inputs (switches) have been pressed in port B
;;;	Require 
;;;		r8 : for accessing a specific area in memory i.e CRL/CRH etc for port B. Allows to get the state of the switch
;;;		r0 : for reading the memory location in r8. as well as to store the respective IDR bit pattern, 
;;;			 Also to know whether a button has been pressed or not
;;;		r5 : to contain the the respective IDR value for each of the switches for if it was to be pressed
;;; Promise
;;;		to branch to use case 3 if any of the switches have been interacted with
;;;		and if no interaction is done, then branch back to use case 2 with the link register
;;;		
	ALIGN
check_Response proc

	;SW0 black (port b4)
	ldr r8, = GPIOB_IDR	
	ldr r0, [r8]		
	mov32 r5, #0xffef ;  1110 for black switch
	orr r0, r0, r5
	cmp r0, r5	
	beq playing		
	
	;SW1 red (port b6)
	ldr r8, = GPIOB_IDR	
	ldr r0, [r8]		
	mov32 r5, #0xffbf ; 1011 for the second last nibble, for red switch
	orr r0, r0, r5
	cmp r0, r5	
	beq playing		
	
	;SW2 green (port b8)
	ldr r8, = GPIOB_IDR	
	ldr r0, [r8]		
	mov32 r5, #0xfeff ; 1110 for the 8th bit on the third nibble, for green switch
	orr r0, r0, r5
	cmp r0, r5	
	beq playing		
	
	;SW3 blue (port b9)
	ldr r8, = GPIOB_IDR	
	ldr r0, [r8]		
	mov32 r5, #0xfdff ;1101 for the 9th bit on the third nibble, for the blue switch
	orr r0, r0, r5
	cmp r0, r5	
	beq playing		
	
	bx lr 
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; Use Case 3. In this use case consists the use case 4 and 5 as well as they are end states. use case 4 is Game won and 
;;;	use case 5 is the failure state. this subroutine is entered through the interaction with the buttons from the use case 2 (waiting)
;;;	
;;;	Require 
;;;		r6 : for accessing a specific area in memory i.e CRL/CRH for I/O
;;;		r7 : Will be used to keep track of the levels or number of cycles performed
;;;		r5 : prelimWait timer and react timer
;;;		r0 : will store my random number 
;;;		r8 : has the value of the modulus that will be used to compare with the button LED interactions, whether it's correct or not

;;; Promise
;;;		contains all of the functionality of use case 3, use case 4, and use case 5
	ALIGN
playing proc
	
	;; before the game starts
	BL reset_Led 
	ldr r5,=BeforeGamestart 
	BL loop_Delay
	
	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; The main loop of use case 3 itself. Where random LED's will pop based off of values obtained from a module subroutine 
;;; in between 0 to 3. Which will then be used to turn on a respective LED. The PrelimWait is the time in between 
;;  where the user waits for an LED to pop off. 
;;;	
;;;	Require 
;;;		r5 : contains the PrelimWait timer which is the time that the user waits for the first or the following LED's to turn on.
;;; Promise
;;;		To turn on LED's continually in a random fashion 
	ALIGN
loop_Cycle proc
	
	BL reset_Led
	ldr r5,=PrelimWait
	BL loop_Delay
	BL modulus
	BL runLed
	bx lr 
 	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; this subroutine is meant to to meant to turn on an LED with respect to a number from 0 to 3 each number turning on a specific LED
;;;	Once an LED is turned on, a reaction timer is started. if the timer runs out then in that case this subroutine goes to the use case 5. 
;;; which is the failed state. Also as the reaction timer is active then it is seeking user response.
;;;	
;;;	Require 
;;;		r5 : contains the ReactTime which is the total time the user has to press the right button
;;;		r9 : contains the amount that will be decreased from the ReactTime with each cycle
;;; 	r8 : contains the value that is modulated, between 0 and 3. Which is recieved from the modulus subroutine
;;; 	r6 : contains the address of the I/0 for CRL & CRH.
;;;		r1 : reads the address at r6
;;; Promise
;;;		r2 : writes to the address at r6 to turn on an LED
;;;		To turn on LED's continually in a random fashion based off of a modulated value.
;;;		where once the LED turns on the React timer will begin. and based off the number of cycles 
;;;		then the react timer will be subtracted by a multiple of DecrementAmount, making the levels difficult each time
;;;		when each of the LED's turn on then there is a moment of user response. 
	ALIGN
runLed proc
	
	ldr r5,=ReactTime
	ldr r9,=DecrementAmount
	mul r10, r7,r9
	sub r5, r5, r10 
	
	cmp r8,#0
	BEQ LED1 ;; turn on the 1st led
	
	cmp r8,#1
	BEQ LED2 ;; turn on the 2nd led
	
	cmp r8,#2
	BEQ LED3 ;; turn on the 3rd led
	
	cmp r8,#3
	BEQ LED4 ;; turn on the 4th led
	
LED1
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0001 ; A0
	orr r2,r2,r1
	str r2,[r6]
	B timer
	
LED2
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0002 ; A1
	orr r2,r2,r1
	str r2,[r6]
	B timer
	
LED3		
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0010 ; A4
	orr r2,r2,r1
	str r2,[r6]
	B timer
	
LED4		
	ldr r6,=GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0x0001 ; B0
	orr r2,r2,r1
	str r2,[r6]
	B timer

timer

	subs R5, #1 ; timer is started and being decremented at this point
	
	BL game_button_response ; user response
			
	cmp r5,#0
	BEQ failed ;if the timer runs out send to the fail state.
	
	B timer
	
	B loop_Cycle
	endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; this subroutine is meant to to meant to turn on an LED with respect to a number from 0 to 3 each number turning on a specific LED
;;;	Once an LED is turned on, a reaction timer is started. if the timer runs out then in that case this subroutine goes to the use case 5. 
;;; which is the failed state. Also as the reaction timer is active then it is seeking user response.
;;;	
;;;	Require 
;;;		r5 : contains the ReactTime which is the total time the user has to press the right button
;;;		r9 : contains the amount that will be decreased from the ReactTime with each cycle
;;; 	r8 : contains the value that is modulated, between 0 and 3. Which is recieved from the modulus subroutine
;;; 	r6 : contains the address of the I/0 for CRL & CRH.
;;;		r1 : reads the address at r6
;;; Promise
;;;		r2 : writes to the address at r6 to turn on an LED
;;;		To turn on LED's continually in a random fashion based off of a modulated value.
;;;		where once the LED turns on the React timer will begin. and based off the number of cycles 
;;;		then the react timer will be subtracted by a multiple of DecrementAmount, making the levels difficult each time
;;;		when each of the LED's turn on then there is a moment of user response. 
	ALIGN
game_button_response proc
	
	; black (port b4)
	ldr R6, = GPIOB_IDR	
	ldr R0, [R6]		
	MOV32 R6, #0xffef 
	ORR r0, r0, r6
	CMP R0, R6		
	BEQ pressed_black	
		
	; red (port b6)
	ldr R6, = GPIOB_IDR	
	ldr R0, [R6]		
	MOV32 R6, #0xffbf 
	ORR r0, r0, r6
	CMP R0, R6		
	BEQ pressed_red
		
	; green (port b8)
	ldr R6, = GPIOB_IDR	
	ldr R0, [R6]		
	MOV32 R6, #0xfeff 
	ORR r0, r0, r6
	CMP R0, R6		
	BEQ pressed_green
		
	; blue (port b9)
	ldr R6, = GPIOB_IDR	
	ldr R0, [R6]		
	MOV32 R6, #0xfdff 
	ORR r0, r0, r6
	CMP R0, R6	
	BEQ pressed_blue
	
	bx lr
	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; When this subroutine is called, it means that the black switch has been pressed and will decide whether it was the
;;; correct response or not
;;;	
;;;	Require 
;;;		r5 : contains the ReactTime which is the total time the user has to press the right button
;;;		r8 : as this is modulated value with a value between 0 and 3. This will be compared to the 0 as that it was it
;;;			 what is used to determine whether the correct button has been pressed or not
;;; Promise
;;;		r12 : the time at which this button was pressed, r12 will hold that value for it to be used as seed for the rng
;;;		If the button is correct, then branch to a subroutine to deal with that case. But if the wrong button is pressed then it
;;;		it will go to use case 5 which is the failed state
;;; NOTE : all of the following subroutines (pressed_red, pressed_ green, pressed_blue) have the same 'require' and 'promise' as this 
;;;		   pressed_black subroutine.
	ALIGN
pressed_black proc 
	
	mov r12, r5 ; captures the point at which this button is pressed to be used as a seed for the next random LED to pop up
	cmp r8, #0
	beq pressed_correct 
	bne failed
	
	bx lr
	endp

	ALIGN
pressed_red proc 
	
	mov r12, r5 ; captures the point at which this button is pressed to be used as a seed for the next random LED to pop up
	cmp r8, #1
	beq pressed_correct 
	bne failed

	bx lr
	endp

	ALIGN
pressed_green proc 
	
	mov r12, r5 ; captures the point at which this button is pressed to be used as a seed for the next random LED to pop up
	cmp r8, #2
	beq pressed_correct 
	bne failed
	
	bx lr
	endp

	ALIGN
pressed_blue proc
	
	mov r12, r5 ; captures the point at which this button is pressed to be used as a seed for the next random LED to pop up
	cmp r8, #3
	beq pressed_correct
	bne failed
	
	bx lr
	endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; When this subroutine is called, it means that the the correct button has has been pressed within the React_time timer
;;; . Therefore, the cycle count will be incremented. A new random # will have to be produced to turn on another LED. 
;;;	based off of the # that is produced it will have to be modulated. After modulation, it will return back to the game session
;;; by going back to loop_Cycle where that modulated # will be compared.
;;;	Require 
;;;		r12 : the time at which this button was pressed, r12 will hold that value for it to be used as seed for the rng
;;; Promise
;;;		update r7 as that it what keeps count of the level.
;;;		to produce a modulated number that will be stored in r8. return back to loop_Cycle to turn on another random LED 
;;;		based off of modulated #.
;;		
	ALIGN
pressed_correct proc

	bl cycle_Count
	bl modulus
	b loop_Cycle
	
	bx lr
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This simply keeps track of the cycles (level) that the user is on and increments if the correct button is pressed
;;;	Require 
;;;		r7: contains the value that will be incremented
;;; Promise
;;;		update r7 as that it what keeps count of the level.
;;;		compare the value of r7 with the NumCycles value stored in register 4
;;;		if the cycle count is equal to r4 then will branch to use case 4 ( game won )
	ALIGN
cycle_Count proc
	
	ldr r4,=NumCycles
	add r7, r7, #1
	cmp r7, r4
	BEQ Game_WON
	
	bx lr
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; The purpose of this subroutine is to produce a modulated # from the random number that it stored in r12.
;;;	Require 
;;;		r12: contains the random # that is based off the time in which the user pressed button.
;;; Promise
;;;		 By using register r2 and r0 to to store values from the in between steps taken to modulate the #
;;;		 in the end the modulated # will be loaded into register 8. 
;;;		
	ALIGN
modulus proc
	mov r2, #4
	udiv r0, r12, r2
	mul r0, r0, r2
	sub r0, r12, r0 
	mov r8, r0 ; r8 now holds the modulus, will be referenced too when checking if the correct button is pressed
	
	bx lr
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; USE CASE 4
;;; This is the subroutine to show that the user has beat all the levels and has won the game.
;;;	Require 
;;;		set the r5 to WinningSignalTime 
;;;		r11 contains the amount of times that the LED will flash by
;;; Promise
;;;		flash the leds on and off with respect to the value in r11. 
	ALIGN
Game_WON proc
	ldr r11,=WinningFlashAmount ;; how many times the LED will flash for the winning signal
loops

	ldr r5,=WinningSignalTime
	BL set_Led
	BL flashDelay
	
	ldr r5,=WinningSignalTime
	BL reset_Led
	BL flashDelay
	
	B loops
	
	bx lr
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This is the subroutine that turns ON all the LED's A0, A1, A4 and B0
;;;	Require 
;;;		don't require anything. as locations for the turning the LED's on are initialized in this subroutine itself
;;;		such as r6 [I/0], r1 [read], r2 [odr value, writing to I/0]
;;; Promise
;;;		flash the leds on and off with respect to the value in r11. 
	ALIGN
set_Led PROC
	
	;turn on A0, A1, A4,
	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0013
	orr r2,r2,r1
	str r2,[r6]
	
	; turn on B0
	ldr r6,=GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0x0001
	orr r2,r2,r1
	str r2,[r6]
	
	bx lr
	endp

;; END OF USE CASE 4 main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; USE CASE 5
;;; This is the subroutine to show that the user has failed to beat the game. Called either when the react timer has 
;;;	has been pressed or when the wrong button has been pressed
;;;	Require 
;;;		r7: has the cycle count which is important, as it will be used to display the score in binary
;;; Promise
;;;		To display the score that is stored r7 which is the score of the user and display it in on the LED's
;;;		At this point in the game, the value of r12 will not matter as the game has ended so it will be used  
;;; 	as the result of the AND.
;;;		r11 will store the value of how many times the score in binary will flash
	ALIGN
failed proc

	;; so the 0000
	;; the 0th bit is for b0 [lsb]
	;; the 1st bit is for a4
	;; the 2nd bit is for a1
	;; the 3rth bit is for a0 [msb]
	
	; start with all of the LED's off 
	BL reset_Led
	ldr r11,=LosingFlashAmount
	
msb
	mov r12, #0x8
	;; a0 needs to be shifted to the left three times and then ANDed with r7
	and r12, r7, #0x8
		;; if the result is a zero then keep the a0 light off
		cmp r12, #0x8
		BEQ LED1_ON
		;; if the result is a 1 then keep the a0 the light on
secondbit
	mov r12, #0x4
	;; a1 needs to be shifted to the left once and then ANDed with r7
	and r12, r7, #0x4
		;; if the result is a zero then keep the a1 light off
		;; if the result is a 1 then keep the a1 the light on
		cmp r12, #0x4
		BEQ LED2_ON
firstbit		
	mov r12, #0x2
	;; a4 needs to be shifted to the right three times and then ANDed with r7
	and r12, r7, #0x2
		;; if the result is a zero then keep the a4 light off
		;; if the result is a 1 then keep the a4 the light on
		cmp r12, #0x2
		BEQ LED3_ON
lsb	
	mov r12, #0x1
	;; b0 can stay as is and then ANDed with r7
	and r12, r7, #0x1
		;; if the result is a zero then keep the b0 light off
		;; if the result is a 1 then keep the b0 the light on
		cmp r12, #0x1
		BEQ LED4_ON
	
	ldr r5,=LosingSignalTime
	bl loop_Delay

flash_score

	BL reset_Led
	ldr r5,=LosingSignalTime
	bl loop_Delay
	sub r11, #1
	cmp r11, #0
	beq mainLoop
	
	b msb
	
LED1_ON

	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0001 ; A0
	orr r2,r2,r1
	str r2,[r6]
	B secondbit
	
LED2_ON

	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0002
	orr r2,r2,r1
	str r2,[r6]
	b firstbit
	
LED3_ON

	ldr r6,=GPIOA_ODR
	ldr r1,[r6]
	ldr r2,=0x0010 ; A4
	orr r2,r2,r1
	str r2,[r6]
	b lsb
	
LED4_ON

	ldr r6,=GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0x0001 ; B0
	orr r2,r2,r1
	str r2,[r6]
	
	;delay
	ldr r5,=LosingSignalTime
	bl loop_Delay
	
	b flash_score ;; go to the stage where the score will have to be flashed
	
	bl mainLoop ;; after the score has been flashed, goes back to USE CASE 2
	
	bx lr
	ENDP
;; END OF USE CASE 5 main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine serves the same purpose as the DELAY loop in Use case 2. Which is simply to decrement a timer till
;;; it reaches 0. But was created for scope reasons
;;;	Require 
;;;		r5: stores the timer to decrement 
;;; Promise
;;;		to reach zero and return back through the link register
	ALIGN
loop_Delay proc
	
	subs r5, #1	;makes it go down to zero
	bne loop_Delay
	
	bx lr
	endp
		
	ALIGN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine serves the same purpose as the DELAY loop in Use case 2. Which is simply to decrement a timer till
;;; Note : this is a use case 4 related subroutine
;;; it reaches 0. But was created here for scope reasons.
;;;	Require 
;;;		r11: stores the value which is the amount of times to flash by.  
;;; 	r5 : the timer value 
;;; Promise
;;;		Once the value in r11 reaches 0 this subroutine will branch to the proficiencyLevel subroutine to display the 
;;;		users skill level
flashDelay proc
	
	cmp r11, #0
	beq proficiencyLevel
	
	sub r11, r11, #1	;makes it go down to zero
	cmp r11, #0
	beq proficiencyLevel
	
	subs R5, #1	;makes it go down to zero
	bne loop_Delay
	endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine serves the same purpose as the DELAY loop in Use case 2. Which is simply to decrement a timer till
;;; it reaches 0. But was created here for scope reasons.
;;; Note : this is a use case 4 related subroutine
;;;	Require 
;;;		This loop does not require anything. As it is end of the game so therefore after the proficiency level is shown
;;;		it returns back to USE CASE 2
;;; Promise
;;;		To show the users skill level by keeping the 4 leds on all on at the same time for the amount defined by the equate proficiencySignal
;;; 	this time will be stored in r5.
	ALIGN
proficiencyLevel proc 
	
	;set all 4 Led's ON so that it represents that he went through 16/16 levels for 1 minute. Each LED represents 4 levels
	ldr r5,=proficiencySignal
	bl set_Led
	BL loop_Delay
	B mainLoop
	
	bx lr
	endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine Is simply to initialize the clock so power can be enabled to the ports that we are using. 
;;;	1C activates ports A through C but A & B are all we really need.
;;;	Require 
;;;		Nothing is required as this is where we initialize. But the register that are going to be used are r6 for 
;;;		accessing a specific place in memory and writing to that location through register 0.
;;; Promise
;;;		to enable the port A & B clock
	ALIGN
GPIO_ClockInit PROC
	
	ldr	r6, = RCC_APB2ENR
	mov	r0, #0x001C			; To turn on clocks for Ports A through C
	str	r0, [r6]
	BX LR
	ENDP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine Is simply to initialize the GPIO that will be used in this project which are Ports A and B.
;;;	Require 
;;;		Nothing is required as this is where we initialize. 
;;;		but r6 will be used to access the GPIO register
;;;		r0 will contain the set up port
;;; Promise
;;;		To enable the port A0, A1, A4 and B0 as outputs by placing a '3' which is 0011 at their respective locations in CRL/CRH of port A and B
;;;		the inputs do not need to be explicity set as the ports are by default inputs
;;; 	Also, it is important that the cycle counter is initialized to be 0 here. as in the beginning the 'score' should be zero.
	ALIGN
GPIO_init  PROC
	
	ldr	R6, = GPIOA_CRL
	ldr r0,[r6] ; read port C

	ldr r1,=0x00030033 ;; port [A0,A1,A4]
	orr r0,r0,r1
	ldr r1,=0xfff3ff33
	and r0, r0,r1
	str	r0, [r6] ; write port C
	

	ldr r6,=GPIOB_CRL
	ldr r0,[r6] ; read port C
	
	ldr r1,=0x00000003 ;; Port [B0]
	orr r0,r0,r1
	ldr r1,=0xfffffff3
	and r0, r0,r1
	str	r0, [r6] ;write port B
	
	mov r7,#0x0; initialize the cycle counter to be at 0
	
    BX LR
	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
;;; This subroutine is responsible of doing a reset on the OUTPUTS. so clearing the LEDs.
;;;	Require 
;;;		Nothing is required as this is where we Reset and will only produce cleared LEDs.
;;;		but r6 will be used to access the port A and B output register
;;;		r2 will contain the set up port
;;; Promise
;;;		to have a 0 on the port A [0,1,4] and B [0] ODR's so that the LED's can be cleared
	ALIGN
reset_Led PROC
	;; turns off all the LED's in port A
	ldr r6, = GPIOA_ODR 	;clears the LEDs by setting all 1's in the odr pins necessary,; pins 0, 1 ,4
	ldr r1,[r6]
	ldr r2,=0xffec ; 1110 1100
	and r2, r1 ; makes the outputs become 0 through ANDing and turns the led's off in port A
	str r2, [r6]
	
	ldr r6, = GPIOB_ODR
	ldr r1,[r6]
	ldr r2,=0xfffe ;1110 
	str r2, [r6]
	ldr r2,[r6]
	
	bx lr
	ENDP
		
	END