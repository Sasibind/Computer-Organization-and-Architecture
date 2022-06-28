%include "io.mac"

.CODE
	.STARTUP
	GetLInt ECX	;read the number of numbers
	mov	EBX,ECX	;store the numer someplace safe to print later
	sub	EAX,EAX ;make a zero variable

read_loop:
	GetLInt	EDX		;read the number
	add	EAX,EDX		;add the number
	cmp	ECX,1		;if we are done with the numbers
	je	reading_done	;jump out of the loop
	loop	read_loop	;otherwise loop

reading_done:
	PutLInt	EBX	;print out the safely stored number
	nwln		;newline
	PutLInt	EAX	;print out the sum
	nwln		;newline for good measure
	.EXIT