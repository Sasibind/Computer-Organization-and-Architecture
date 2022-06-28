%include "io.mac"

.CODE
	.STARTUP
input:
	sub		EBX,EBX		;making register empty
	GetInt		BX		;read m in second half
	sub		ECX,ECX		;making register empty
	GetInt		CX		;read n in second half

call_fun:
	call		ackermann	;call the function

	PutLInt		EAX		;print final answer
	nwln
	.EXIT

ackermann:
case_zero:
	cmp		BX,0		;if m > 0
	jg		case_one	;skip this case
	mov		EAX,ECX		;else ans = n + 1
	inc		EAX		;make EAX = n + 1 accordingly
	ret				;then return

case_one:
	cmp		CX,0		;if n > 0
	jg		case_two	;skip this case
	dec		BX		;else ans = a(m - 1, n + 1)
	inc		CX		;modify m and n accordingly
	call		ackermann	;and call the function

	inc		BX		;since we modified m and n, restore them
	dec		CX		;be careful of modifying them wrongly
	ret				;then return
case_two:
	push		EDX		;push EDX into the stack
	dec		CX		;since a(m, n) = a(m - 1, a(m, n - 1)), dec n first
	call		ackermann	;then calculate a(m, n - 1)
	mov		EDX,EAX		;then save val in EDX, since we need EAX
	xchg		DX,CX		;exchange n with the value, so we do not modify n accidentally
	dec		BX		;now decrease m for the other call
	call		ackermann	;calculate a(m - 1, a(m, n - 1))
	
	xchg		DX,CX		;now exchange back DX and CX, now CX has n
	inc		BX		;since we nodified m and n, set back to initial values
	inc		CX		;make sure not to modify the wrong values
	pop		EDX		;pop out EDX since we are done with it

	ret				;then return