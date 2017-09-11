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
%define offset_red_count 8
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

global obdd_node_destroy
obdd_node_destroy:
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
ret

global obdd_destroy
obdd_destroy:
ret

global obdd_node_apply
obdd_node_apply:
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
	pop r12
	pop r9
	pop r8
	pop rbx
	pop rbp
	ret

global is_sat
is_sat:
ret


; AUXILIARES

global str_len
str_len:
ret

global str_copy
str_copy:
ret

global str_cmp
str_cmp:
ret
