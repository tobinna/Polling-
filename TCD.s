; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018			; Set up my GPIO variables
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU 0xE0028010	

	ldr	r1,=IO1DIR				; Set up my registers as the GPIO places 
	ldr	r3,=IO1SET
	ldr r4,=IO1PIN
	ldr	r5,=IO1CLR
	ldr	r2,=0x00ff0000			
	str	r2,[r1]		
	str	r2,[r3]		
	str r2,[r4]
	str r2,[r5]
	ldr r6,=0xFF000000
	ldr r9,=0x00000000
	str r9, [r4]
	str r6, [r3]
	str r6, [r4]
	str r6, [r5]
	
	ldr	r5,=0x01000000	
	ldr r2,=0x00000000
	
poll_for_button				; Polling function that check the first four digits for any changes
	ldr	r7,=0x00100000	
	mov r9, r7
	ldr r9, [r4]
	add r8, r2, #0xfe000000	
	cmp r9, r8				; Compare the GPIO input to what the binary value of one being off
	beq add_one				; If that, then do add function
	mov r8, #0x00000000
	add r8, r2, #0xfd000000	
	cmp r9, r8				; Compare the GPIO input to what the binary value of two being off
	beq subtract_one		; If that, then do subtract function
	mov r8, #0x00000000
	add r8, r2, #0xfb000000	
	cmp r9, r8				; Compare the GPIO input to what the binary value of four being off
	beq left_shift			; If that, then do left shift function
	mov r8, #0x00000000
	add r8, r2, #0xf7000000
	cmp r9, r8				; Compare the GPIO input to what the binary value of eight being off
	beq right_shift			; If that, then do right shift function
	b poll_for_button		; If nothing, Go again!!
	
	
	
overflow_occured			; If the number has gone negative, or above maximum
	ldr r2, =0
	str r2, [r4]			; Set value to Zero and end the program
	b overflow_occured



hold_till_unpressed			; Wait until the button has been unpressed. If two buttons are pressed at once, 
	ldr r9, [r4]			; Only the first is counted
	add r7, r2, #0xff000000	; Waiting till all digits are high
	cmp r9, r7
	beq poll_for_button		; Goes back to polling function
	
	b hold_till_unpressed	; Loop around if not
	

add_one
	cmp r2, #0x00ff0000		; If currently at max
	beq overflow_occured
	add r2, r2, #0x00010000
	str r2, [r4]
	b hold_till_unpressed

subtract_one
	cmp r2, #0				; if currently at min
	beq overflow_occured
	sub r2, r2, #0x00010000
	str r2, [r4]
	b hold_till_unpressed
	
left_shift
	orr r7, r2, #0x007F0000	; If MSB is already at max, ERROR
	cmp r7, #0x00FF0000
	beq overflow_occured
	mov r2, r2, lsl #1		; Shift left
	str r2, [r4]
	b hold_till_unpressed
	
right_shift
	orr r7, r2, #0x00fe0000	; If LSB is already at min, ERROR
	cmp r7, #0x00ff0000
	beq overflow_occured
	mov r2, r2, lsr #1		; Shift right
	str r2, [r4]
	b hold_till_unpressed

	end