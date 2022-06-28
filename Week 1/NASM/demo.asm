%include "io.mac"

.UDATA
	string	resb	21

.CODE
	.STARTUP
choose:
	GetInt 	AX
	cmp		AX,1
	je		case_one
	cmp		AX,2
	je		case_two
case_one:
	GetStr	string
	mov		EBX,string
	sub		ECX,ECX
loop_one:
	mov		AL,[EBX]
	cmp		AL,0
	je		done
	cmp		AL,'A'
	je		next
	cmp		AL,'E'
	je		next
	cmp		AL,'I'
	je		next
	cmp		AL,'O'
	je		next
	cmp		AL,'U'
	je		next
	cmp		AL,'a'
	je		next
	cmp		AL,'e'
	je		next
	cmp		AL,'i'
	je		next
	cmp		AL,'o'
	je		next
	cmp		AL,'u'
	je		next
	inc		ECX
next:
	inc		EBX
	loop		loop_one
done:
	PutLInt	ECX
	jmp		end
case_two:
	GetInt	DX
	call		func_two
	PutLInt	EAX
	jmp		end
end:
	nwln
	.EXIT

func_two:
	cmp		DX,7
	jle		case_one_func
	cmp		DX,10
	jle		case_two_func
	jmp		case_three_func
case_one_func:
	mov		EAX,4
	ret
case_two_func:
	sub		DX,2
	call		func_two
	push		EAX
	sub		DX,1
	call		func_two
	push		EAX
	mov		EAX,2
	pop		ECX
	add		EAX,ECX
	pop		ECX
	add		EAX,ECX
	sub		ECX,ECX
	add		DX,3
	ret
case_three_func:
	sub		DX,2
	call		func_two
	add		EAX,1
	ret