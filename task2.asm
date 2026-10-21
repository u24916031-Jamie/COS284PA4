
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
	.numStates resd 1; offset 16
	.numTransitions resd 1; offset 20
	.startState resd 1; offset 24
	alignb 8
endstruc

section .data
	dfa:
	istruc DFA
		at DFA.states, dq 0
		at DFA.transitions, dq 1; offset 8
		at DFA.numStates, dd 1; offset 16
		at DFA.numTransitions, dd 1; offset 20
		at DFA.startState, dd 1; offset 24
	iend
section .bss

states resq 1
transitions resq 1
numTransitions resd 1


; bool simulateDfa(DFA* dfa, const char* input)
global simulateDfa
section .text
simulateDfa:
  ; TODO

   	push rbp
  	mov rbp, rsp
	sub rsp, 16
	mov [dfa], rdi
	mov rax, rdi
	mov rdi, [rax + DFA.states]
	mov [states], rdi
	mov rdi, [rax + DFA.transitions]
	mov [transitions], rdi
	mov rdi, [rax + DFA.numTransitions]

	mov dword[numTransitions], edi

	mov rbx, 0 ; current state

	mov rcx, 0 ; input index
	mov rdx, 0 ; transition index
	inputloop:

	movzx rax, byte [rsi + rcx]
	cmp rax, 0
	je success

	mov rdx, 0
	currentstateloop:
	cmp rdx, [numTransitions]
	jge fail

	imul r8, rdx, 12
	add r8, [transitions]
	mov r9d, dword[r8]

	cmp r9d, ebx
	jne currentstateloop2
	;from is correct, check if symbol matches
	add r8, Transition.symbol
	movzx r9, byte[r8]

	cmp r9b, al
	jne currentstateloop2

	; correct from and symbol
	sub r8, 4
	mov ebx, dword[r8]
	inc rcx
	jmp inputloop

	currentstateloop2:
	inc rdx
	jmp currentstateloop

	
	


	fail:

  xor rax, rax
  jmp end
	success:
		; check if current state is accepting
		mov rcx, [states]
		movzx rax, byte[rcx + rbx * 8 + 4]
		
	end:



  leave
  ret
