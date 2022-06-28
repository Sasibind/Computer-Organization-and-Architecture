%include "io.mac"

.UDATA
	in_string	resb	21		;reserving bits for string
.CODE
	.STARTUP
begin:
	GetStr	in_string,21	;read string
	mov		EBX,in_string	;put string in base
process_char:
	mov		AL,[EBX]		;move EBX in one char at a time
	cmp		AL,0			;if it is null
	je		done			;move to end
	cmp		AL,'0'		;not a numeric char
	jl		not_int		;move to after conversion code
	cmp		AL,'9'		;not numeric char too
	jg		not_int		;move to after conversion code
is_int:
	sub		AL,'0'		;convert to int to transform
	cmp		AL,4			;compate to create two diff cases
	jg		case_1		
case_0:					;if number is less than 5
	add		AL,AL			;then x' = (2x+5)%10
	add		AL,5			;now x = 2x+5
	cmp		AL,10			;check if x>10
	jge		greater		;if greater, move to remove extra 10
	jmp		reset_char		;move away from second case code and greater code
case_1:					;if number is greater than 4
	add		AL,AL			;then x' = (2x-4)%10
	sub		AL,4			;now x = 2x-4
	cmp		AL,10			;check if x > 10	
	jge		greater		;if greater, move to remove extra 10
	jmp		reset_char		;move away from greater code
greater:
	sub		AL,10			;this removes extra 10
reset_char:
	add		AL,'0'		;restore int to char status
not_int:
	PutCh		AL			;print char
	inc		EBX			;move to next char in EBX
	jmp		process_char	;jump back to process this char
done:
	nwln					;new line
	GetCh		CL			;need to check if all inputs over
	cmp		CL,'Y'		;terminate if user gives Y
	je		complete
	cmp		CL,'y'		;or y
	je		complete		;jump to exit
	jmp		begin			;else go back and take new string
complete:
	.EXIT