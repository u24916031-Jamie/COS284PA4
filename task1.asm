
struc State ; size 8
	.id resd 1 ; offset 0
	.isAccepting resb 1 ;offset 4
	alignb 4
endstruc
struc Transition ; size 12
	.from resd 1 ; offset 0
	.to resd 1; offset 4
	.symbol resb 1; offset 8
	alignb 4
endstruc
struc DFA ; size 32
	.states resq 1; offset 0
	.transitions resq 1; offset 8
	.numstates resd 1; offset 16
	.numTransitions resd 1; offset 20
	.startState resd 1; offset 24
	alignb 8
endstruc

section .data
	fname db "dfa1.txt", 0
	mode db "r", 0
	fmt_line1 db "%d,%d", 0
	fmt_int db " %d", 0
	fmt_comma_int db ",%d", 0
	fmt_transition db " %d,%d,%c", 0

	dfa:
	istruc DFA
		at DFA.states, dq 0
		at DFA.transitions, dq 1; offset 8
		at DFA.numstates, dd 1; offset 16
		at DFA.numTransitions, dd 1; offset 20
		at DFA.startState, dd 1; offset 24
	iend
section .bss
	buf resb 1024
	file_ptr resq 1
	numstates resd 1
	numtrans resd 1
	states resq 1
	transitions resq 1
	tempint resd 1
	tempint2 resd 1
	tempchar resb 1


; DFA* readDfa(const char* filename)
; rdi filename
extern fopen
extern fgets
extern fclose
extern fscanf
extern malloc
global readDfa
section .text
readDfa:
  	; TODO
  	push rbp
  	mov rbp, rsp

  	;mov rdi, fname
	mov rsi, mode
	call fopen
	cmp rax, 0
	je end
	mov [file_ptr], rax
	scan:
	mov rdi, [file_ptr]
	mov rsi, fmt_line1
	mov rdx, numstates
	mov rcx, numtrans
	;r8
	;r9
	xor rax, rax
	call fscanf

	mov eax, [numstates]
	mov rbx, dfa
	mov dword [rbx + DFA.numstates], eax
	mov eax, [numtrans]
	mov dword [rbx + DFA.numTransitions], eax
	mov rax, 0
	mov dword [rbx + DFA.startState], eax

	allocate:
	mov eax, [numstates]
	imul rdi, rax, 8
	call malloc
	mov [states], rax
	mov rbx, dfa
	mov [rbx + DFA.states], rax

	mov eax, [numtrans]
	mov rbx, 12
	mul rbx
	mov rdi, rax
	call malloc
	mov [transitions], rax
	mov rbx, dfa
	mov [rbx + DFA.transitions], rax

	readStates:
	mov r12, 0
	mov rdi, [file_ptr]
	mov rsi, fmt_int
	mov rdx, tempint
	;rcx
	;r8
	;r9
	xor rax, rax

	call fscanf

	mov eax, [tempint]
	mov rbx, [states]
	mov dword [rbx + r12 * 8 + State.id],  eax
	inc r12



	readStatesLoop:
	cmp r12d, [numstates]
	jge doneReadStates

	mov rdi, [file_ptr]
	mov rsi, fmt_comma_int
	mov rdx, tempint
	;rcx
	;r8
	;r9
	xor rax, rax

	call fscanf

	mov eax, [tempint]
	mov rbx, [states]
	mov dword [rbx + r12 * 8],  eax

	inc r12
	jmp readStatesLoop


	doneReadStates:
	readAccepting:

	mov rdi, [file_ptr]
	mov rsi, fmt_int
	mov rdx, tempint
	;rcx
	;r8
	;r9
	xor rax, rax
	
	call fscanf

	mov ecx, [tempint]
	mov rbx, [states]
	mov byte [rbx + rcx * 8 + State.isAccepting],  1


	readAcceptingLoop:
	mov rdi, [file_ptr]
	mov rsi, fmt_comma_int
	mov rdx, tempint
	;rcx
	;r8
	;r9
	xor rax, rax
	
	call fscanf
	
	cmp rax, 1
	jne doneAccepting
	mov ecx, [tempint]
	mov rbx, [states]
	mov byte [rbx + rcx * 8 + State.isAccepting],  1
	jmp readAcceptingLoop

	doneAccepting:
	readTransitions:
	mov r12, 0 ; counter

	cmp r12d, [numtrans]
	jge after

	mov rdi, [file_ptr]
	mov rsi, fmt_transition
	mov rdx, tempint
	mov rcx, tempint2
	mov r8, tempchar
	;r9
	xor rax, rax
	call fscanf

	mov rax, [transitions]
	imul r11, r12, 12
	mov ebx, [tempint]
	mov dword [rax + r11 + Transition.from],  ebx

	mov ebx, [tempint2]
	mov dword [rax + r11 + Transition.to],  ebx

	movzx rbx, byte [tempchar]
	mov byte [rax + r11 + Transition.symbol],  bl
	inc r12

	readTransitionsLoop:
	cmp r12d, [numtrans]
	jge after
		
	mov rdi, [file_ptr]
	mov rsi, fmt_transition
	mov rdx, tempint
	mov rcx, tempint2
	mov r8, tempchar
	;r9
	xor rax, rax
	call fscanf

	mov rax, [transitions]
	imul r11, r12, 12
	mov ebx, [tempint]
	mov dword [rax + r11 + Transition.from],  ebx

	mov ebx, [tempint2]
	mov dword [rax + r11 + Transition.to],  ebx

	movzx rbx, byte [tempchar]
	mov byte [rax + r11 + Transition.symbol],  bl
	inc r12

	jmp readTransitionsLoop


	after:
	mov rdi, [file_ptr]
	call fclose

	mov rax, dfa
	
	end:
	leave
  	ret
