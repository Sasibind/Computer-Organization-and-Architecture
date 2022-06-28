%include "io.mac"

.DATA
	filename	db	'input.txt',0
	out1		db	'child output',0
	out2		db	'parent output',0
	inp		dd	0
	temp		dd	0
	temp2		dd	0
.UDATA
	descreptor	resd	1

.CODE	
	.STARTUP
	
	;//////////////creating a file/////////////////
	
	mov	EAX,8
	mov	EBX,filename
	mov	ECX,0777
	int	0x80
	mov	[descreptor],EAX

	GetInt [inp]
	mov 	EBX,[inp]
	mov	[temp],EBX
	
	;///////////////writing into file///////////////
	call write

	;moving file pointer to the end of the file
	call changepointer

	saving_nums:
		
		GetInt	[temp]
		
		call	write
		call	changepointer
		sub	EBX,1	
		cmp	EBX,0
		je	savingDone
		jmp	saving_nums

	savingDone:
		;//////////close file/////////////////////
		mov	EAX,6
		mov	EBX,[descreptor]
		int	0x80
		;//////////openfile///////////////////////
		mov	EAX,5
		mov	EBX,filename
		mov	ECX,2
		mov	EDX,0777
		int	0x80
		
		mov	[descreptor],EAX	;File descriptor
		
		call	mmap2						;Mmaping file into memory
		
		call	fork
		cmp	EAX,0
		je	child
	
	parent:							;calling parent but initially holding it so that we call child first and later parent
		call	wait_for_child
		mov 	EAX,2
		parent_loop_1_begin:
			cmp	EAX,[inp]				;run this loop n times
			jg	parent_loop_1_end
			IMUL	ECX,EAX,4
			call	changepointer2			;jump to a specific point in the file instead of the end
			call 	read
			mov	EDX,[temp]				;save number
			
			mov	EBX,EAX
			dec	EBX					;put in in EBX and run nested loop so you don't affect big loop
			parent_loop_2_begin:
				cmp	EBX,0				;run loop n times
				je	parent_loop_2_end

				IMUL	ECX,EBX,4
				call	changepointer2		;again jumping to specific point and reading
				call 	read
				mov	ECX,[temp]			;save number
				
				cmp	ECX,EDX			;compare
				jle	parent_loop_2_end

				mov	ECX,EBX			;rewrite the values if needed using write
				inc	ECX
				IMUL	ECX,ECX,4
				call 	changepointer2
				call 	write
				dec	EBX
				jmp	parent_loop_2_begin
			parent_loop_2_end:
			inc 	EBX					;move ahead and point to next line
			IMUL	ECX,EBX,4
			call 	changepointer2
			mov	[temp],EDX
			call 	write
			
			inc 	EAX
			jmp	parent_loop_1_begin

		parent_loop_1_end:
		mov 	EAX,1						;print out the newly modified file contents
		PutStr	out2
		nwln
		print_loop:
			cmp	EAX,[inp]				;run loop n times
			jg	print_loop_end
			IMUL  ECX,EAX,4
			call	changepointer2			;point to each line, read and print its contents
			call	read
			PutInt	[temp]
			nwln
			inc 	EAX
			jmp	print_loop
		print_loop_end:
		jmp 	return					;when done, jump to end of main
	
	child:							;waiting for child to complete first and then process the parent
		mov	EDX,0
		mov	[temp2],EDX
		mov	EBX,[inp]
		inc 	EBX						;save n in EBX and run loop on it
		child_loop_begin:
			
			cmp	EBX,1					;run loop n times
			je 	child_loop_end
			dec 	EBX
			IMUL	ECX,EBX,4
			call 	changepointer2			;read each line's contents and add to temp2
			call 	read
			mov	EDX,[temp]
			add 	[temp2],EDX
			jmp 	child_loop_begin
		
		child_loop_end:
		PutStr	out1
		nwln
		PutInt	[temp2]				;print out sum
		
		nwln
		jmp	return

	return:
		mov	EAX,6
		mov	EBX,[descreptor]
		int	0x80
.EXIT
	
	changepointer:				;changing pointer to the end so that we can write everything to a new line
		push	 EAX
		push	 EBX
		push	 ECX
		push   EDX
	
		mov	EAX,19
		mov	EBX,[descreptor]
		mov	ECX,0
		mov 	EDX,2
		int	0x80

		pop	EDX
		pop	ECX
		pop	EBX
		pop	EAX
		ret

	changepointer2:				;point to a specific line in the input file
		push EAX
		push EBX
		push EDX
	
		mov	EAX,19
		mov	EBX,[descreptor]
		mov 	EDX,0
		int	0x80

		pop	EDX
		pop	EBX
		pop	EAX
		ret
	read:						;Function to read data from kernel
		push EAX
 		push EBX
 		push ECX
 		push EDX
 
 		mov EAX,3
 		mov EBX,[descreptor]
 		mov ECX,temp
 		mov EDX,4
 		int 0x80
 
 		pop EDX
 		pop ECX
 		pop EBX
 		pop EAX
		ret
	write:					;Function to write into input.txt file
		push EAX
 		push EBX
 		push ECX
 		push EDX
 
   		mov             EAX, 4
    		mov             EBX, [descreptor]
    		mov             ECX, temp
    		mov             EDX,4
    		int             0x80
    
 		pop EDX
 		pop ECX
 		pop EBX
 		pop EAX
    		ret
	
	mmap2:					;using mmap2 to 
		
		mov	EAX,192
		mov	EBX,0
		mov	ECX,4096
		mov	EDX,0x1
		mov	ESI,0x2
		mov	EDI,[descreptor]
		mov	EBP,0
		int	0x80
		ret
	fork:						;creating a fork
		mov	EAX,2
		int	0x80
		ret
	wait_for_child:				;pausing parent program till child completes
		mov	EAX,7
		mov	EBX,-1
		mov	ECX,0
		mov	EDX,0
		int	0x80
		ret