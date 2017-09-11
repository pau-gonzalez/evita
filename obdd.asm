extern free
extern malloc
extern dictionary_add_entry


;/** implementar en ASM
;obdd_node* obdd_mgr_mk_node(obdd_mgr* mgr, char* var, obdd_node* high, obdd_node* low){
;	uint32_t var_ID		= dictionary_add_entry(mgr->vars_dict, var);
;	obdd_node* new_node	= malloc(sizeof(obdd_node));
;	new_node->var_ID	= var_ID;
;	new_node->node_ID	= obdd_mgr_get_next_node_ID(mgr);
;	new_node->high_obdd	= high;
;	if(high != NULL)
;		high->ref_count++;
;	new_node->low_obdd	= low;
;	if(low != NULL)
;		low->ref_count++;
;	new_node->ref_count	= 0;
;	return new_node;
;}
;**/

%define NULL 0

;OFFSETS nodo:
%define offset_var_ID 0
%define offset_node_ID 4
%define offset_ref_count 8
%define offset_high_obdd 12
%define offset_low_obdd 16

%define size_nodo 28

global obdd_mgr_mk_node

%define offset_ID 0
%define offset_greatest_node_ID 4
%define offset_greatest_var_ID 8
%define offset_true_obbd 12
%define offset_false_obbd 20
%define offset_vars_dict 28

obdd_mgr_mk_node:
; RDI contiene puntero a mgr
; RSI contiene puntero a var
; RDX contiene high
; RCX contiene low

	push rbp
	mov rbp, rsp
	push rbx
	push r8
	push r9
	push r11
	push r12
	push r13
	push r14
	sub rsp, 8

	mov rbx, rdi
	mov r8, rsi
	mov r9, rdx
	mov r12, rcx

	mov rdi, [rdi + offset_vars_dict]
	call dictionary_add_entry

	mov r13, rax
	;R13 contiene uint32_t var_ID
	mov rdi, nodo_tam
	call malloc
	mov r14, rax
	; R14 contiene obdd_node* new_node
	mov [r14 + offset_var_ID], r13
	mov rdi, rbx
	call obdd_mgr_get_next_node_ID
	mov rdi, [rax]
	mov [r14 + offset_node_ID], rdi
	mov [r14 + offset_high_obdd], r9
	cmp r9, NULL
	je .highNotNull
	add [r9 + offset_ref_count], 1
.highNotNull
	mov [r14 + offset_low_obdd], r12
	cmp r12, NULL
	je .highNotNull
	add byte [r12 + offset_ref_count], 1
.lowNotNull
	mov byte [r14 + offset_ref_count], 0
; new_node ya estaba en rax
.end
	add rsp, 8
	pop r14
	pop r13
	pop r12
	pop r11
	pop r9
	pop r8
	pop rbx
	pop rbp
	ret

	
; void obdd_node_destroy(obdd_node* node){
	; if(node->ref_count == 0){
		; if(node->high_obdd != NULL){
			; obdd_node* to_remove = node->high_obdd;
			; node->high_obdd	= NULL;
			; to_remove->ref_count--;
			; obdd_node_destroy(to_remove);
		; }
		; if(node->low_obdd != NULL){
			; obdd_node* to_remove = node->low_obdd;
			; node->low_obdd	= NULL;
			; to_remove->ref_count--;
			; obdd_node_destroy(to_remove);
		; }
		; node->var_ID	= 0;
		; node->node_ID	= 0;
		; free(node);
	; }
; }	
	
global obdd_node_destroy
obdd_node_destroy:
;RDI es puntero a node
.stackframe
	push rbp
	mov rbp, rsp
	push rbx
	push r8
	push r9
.begin
	; if(node->ref_count == 0){
	cmp [rdi + offset_ref_count], 0
	jne .end
	; if(node->high_obdd != NULL){
	cmp [rdi + offset_high_obdd], NULL
	je .compareLowObdd
	; obdd_node* to_remove = node->high_obdd;
	mov r8, [rdi + offset_high_obdd]
	; node->high_obdd	= NULL;
	mov byte [rdi + offset_high_obdd], NULL
	; to_remove->ref_count--;
	sub [r8 + offset_ref_count], 1
	; obdd_node_destroy(to_remove);
	mov rdi, r8
	call obdd_node_destroy
	; if(node->low_obdd != NULL){
.compareLowObdd
	cmp [r8 + offset_low_obdd], NULL
	je .terminar
	mov r9, [rdi + offset_low_obdd]
	mov byte [r8 + offset_low_obdd], NULL
	sub [r9 + offset_ref_count], 1
	mov rdi, r9
	call obdd_node_destroy
.terminar
	mov byte [r9 + offset_var_ID], 0
	mov byte [r9 + offset_node_ID], 0
	mov rdi, r8
	call free
.end
	pop r9
	pop r8
	pop rbx
	pop rbp
ret

; /** implementar en ASM
; obdd* obdd_create(obdd_mgr* mgr, obdd_node* root){
	; obdd* new_obdd		= malloc(sizeof(obdd));
	; new_obdd->mgr		= mgr;
	; new_obdd->root_obdd	= root;
	; return new_obdd;
; }
; **/

global obdd_create
obdd_create:
; TODO
ret

global obdd_destroy
obdd_destroy:
; TODO
ret

global obdd_node_apply
obdd_node_apply:
; TODO
ret

; /** implementar en ASM
; bool is_tautology(obdd_mgr* mgr, obdd_node* root){
	; if(is_constant(mgr, root)){
		; return is_true(mgr, root);
	; }else{
		; return is_tautology(mgr, root->high_obdd) && is_tautology(mgr, root->low_obdd);	
	; }
; }
; **/

global is_tautology
is_tautology:
; RDI puntero a mgr
; RSI puntero a raiz

;Armo stackframe
.stackframe
	push rbp
	mov rbp, rsp
	push rbx
	push r8
	push r9
	push r12
	sub rsp, 8
	

.begin
	xor r12, r12
	mov rbx, rdi
	mov r8, rsi
	; if(is_constant(mgr, root)){
	call is_constant
	cmp byte rax, 0
	je .evaluateHigh
	; return is_true(mgr, root);
.isTrue
	mov rdi, rbx
	mov rsi, r8
	call is_true
	jmp .end
	; }else{
.evaluateHigh
	; is_tautology(mgr, root->high_obdd)
	mov rsi, [r8 + offset_high_obdd]
	mov rdi, rbx
	call is_tautology
	cmp rax, 1
	; &&
	jne .end
.evaluateLow
	; is_tautology(mgr, root->low_obdd);
	mov rsi, [r8 + offset_low_obdd]
	mov rdi, rbx
	call is_tautology

.end
	add rsp, 8
	pop r12
	pop r9
	pop r8
	pop rbx
	pop rbp
	ret

global is_sat
is_sat:
; TODO
ret


; AUXILIARES

global str_len
; RDI es char* a
str_len:
	push rbp
	mov rbp, rsp
	push rbx
	push r12

	xor rbx, rbx
	mov r12, rdi
	
.ciclo
	cmp r12d, NULL
	je .end
	add ebx, 1
	lea r12, [r12 + 4]
	jmp .ciclo
.end
	mov eax, ebx	
	pop r12
	pop rbx
	pop rbp
	ret

global str_copy
str_copy:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	
	mov rbx, rdi
	xor rax, rax
	call str_len
	mov ebx, eax
	mov rdi, rax
	sar rdi, 2
	call malloc
	
.ciclo	
	cmp ebx, 0
	je .end
	mov r12, [rbx]
	mov [rax], r12
	lea rbx, [rbx + 4]
	lea rax, [rax + 4]
	sub ebx, 1
	jmp .ciclo
	
.end
	pop r12
	pop rbx
	pop rbp
	ret

global str_cmp
; RDI char* a
; RSI char* b
str_cmp:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
.ciclo	
	mov rbx, [rdi]
	mov r12, [rsi]
	cmp ebx, r12d
	jl .returnLess
	jg .returnGreater
	cmp ebx, 0
	je .returnEquals
	lea rbx, [rbx + 4]
	lea r12, [r12 + 4]
	jmp .ciclo
.returnEquals
	mov rax, 0
	jmp .end
.returnLess
	mov rax, 1
	jmp .end
.returnGreater
	mov rax,-1
.end
	pop r12
	pop rbx
	pop rbp
	ret
