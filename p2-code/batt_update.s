	.file	"batt_update.c"
	.text
	.globl	set_batt_from_ports
	.type	set_batt_from_ports, @function
set_batt_from_ports:
.LFB0:
	.cfi_startproc
	endbr64
	movzwl	BATT_VOLTAGE_PORT(%rip), %eax
	testw	%ax, %ax
	js	.L5
	sarw	%ax
	movw	%ax, (%rdi)
	cwtl
	subl	$3000, %eax
	movl	%eax, %edx
	sarl	$3, %edx
	cmpl	$807, %eax
	jg	.L6
	testl	%edx, %edx
	jns	.L3
	movl	$0, %edx
	jmp	.L3
.L6:
	movl	$100, %edx
.L3:
	movb	%dl, 2(%rdi)
	testb	$16, BATT_STATUS_PORT(%rip)
	je	.L4
	movb	$1, 3(%rdi)
	movl	$0, %eax
	ret
.L4:
	movb	$2, 3(%rdi)
	movl	$0, %eax
	ret
.L5:
	movl	$1, %eax
	ret
	.cfi_endproc
.LFE0:
	.size	set_batt_from_ports, .-set_batt_from_ports
	.globl	set_display_from_batt
	.type	set_display_from_batt, @function
set_display_from_batt:
.LFB1:
	.cfi_startproc
	endbr64
	subq	$56, %rsp
	.cfi_def_cfa_offset 64
	movq	%fs:40, %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$63, (%rsp)
	movl	$6, 4(%rsp)
	movl	$91, 8(%rsp)
	movl	$79, 12(%rsp)
	movl	$102, 16(%rsp)
	movl	$109, 20(%rsp)
	movl	$125, 24(%rsp)
	movl	$7, 28(%rsp)
	movl	$127, 32(%rsp)
	movl	$111, 36(%rsp)
	movswl	%di, %eax
	addl	$5, %eax
	movl	%edi, %ecx
	sarl	$24, %ecx
	cmpb	$1, %cl
	je	.L23
	movl	$6, (%rsi)
.L10:
	movl	%edi, %edx
	sarl	$16, %edx
	cmpw	$356, %dx
	je	.L24
	cmpw	$256, %dx
	je	.L25
	movl	%edi, %edx
	sall	$8, %edx
	sarl	$24, %edx
	leal	-10(%rdx), %r8d
	cmpb	$89, %r8b
	ja	.L14
	cmpb	$1, %cl
	je	.L26
.L14:
	testb	%dl, %dl
	jle	.L15
	cmpb	$1, %cl
	je	.L27
.L15:
	movslq	%eax, %r8
	imulq	$274877907, %r8, %rdx
	sarq	$38, %rdx
	sarl	$31, %eax
	subl	%eax, %edx
	movslq	%edx, %rcx
	imulq	$1717986919, %rcx, %rcx
	sarq	$34, %rcx
	movl	%edx, %r9d
	sarl	$31, %r9d
	subl	%r9d, %ecx
	leal	(%rcx,%rcx,4), %ecx
	addl	%ecx, %ecx
	subl	%ecx, %edx
	movl	%edx, %ecx
	imulq	$1374389535, %r8, %r9
	sarq	$37, %r9
	subl	%eax, %r9d
	movslq	%r9d, %rdx
	imulq	$1717986919, %rdx, %rdx
	sarq	$34, %rdx
	movl	%r9d, %r10d
	sarl	$31, %r10d
	subl	%r10d, %edx
	leal	(%rdx,%rdx,4), %edx
	addl	%edx, %edx
	subl	%edx, %r9d
	movl	%r9d, %edx
	imulq	$1717986919, %r8, %r8
	sarq	$34, %r8
	subl	%eax, %r8d
	movslq	%r8d, %rax
	imulq	$1717986919, %rax, %rax
	sarq	$34, %rax
	movl	%r8d, %r9d
	sarl	$31, %r9d
	subl	%r9d, %eax
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	subl	%eax, %r8d
	movl	%r8d, %eax
	movslq	%ecx, %rcx
	movl	(%rsp,%rcx,4), %ecx
	sall	$17, %ecx
	orl	(%rsi), %ecx
	movslq	%edx, %rdx
	movl	(%rsp,%rdx,4), %edx
	sall	$10, %edx
	orl	%ecx, %edx
	cltq
	movl	(%rsp,%rax,4), %eax
	sall	$3, %eax
	orl	%edx, %eax
	movl	%eax, (%rsi)
	jmp	.L12
.L23:
	movl	$1, (%rsi)
	jmp	.L10
.L24:
	movl	(%rsi), %eax
	orl	$851448, %eax
	movl	%eax, (%rsi)
.L12:
	sall	$8, %edi
	sarl	$24, %edi
	cmpb	$4, %dil
	jle	.L16
	leal	-5(%rdi), %eax
	cmpb	$24, %al
	ja	.L17
	movl	(%rsi), %eax
	orl	$16777216, %eax
	movl	%eax, (%rsi)
.L16:
	movq	40(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L28
	movl	$0, %eax
	addq	$56, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L25:
	.cfi_restore_state
	movl	(%rsi), %eax
	orl	$504, %eax
	movl	%eax, (%rsi)
	jmp	.L12
.L26:
	imull	$103, %edx, %ecx
	sarw	$10, %cx
	movl	%edx, %eax
	sarb	$7, %al
	subl	%eax, %ecx
	movsbw	%cl, %ax
	imull	$103, %eax, %eax
	sarw	$10, %ax
	movl	%ecx, %r8d
	sarb	$7, %r8b
	subl	%r8d, %eax
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movl	%ecx, %r11d
	subl	%eax, %r11d
	leal	(%rcx,%rcx,4), %ecx
	addl	%ecx, %ecx
	subl	%ecx, %edx
	movsbq	%r11b, %rax
	movl	(%rsp,%rax,4), %eax
	sall	$10, %eax
	orl	(%rsi), %eax
	movsbq	%dl, %rdx
	movl	(%rsp,%rdx,4), %edx
	sall	$3, %edx
	orl	%edx, %eax
	movl	%eax, (%rsi)
	jmp	.L12
.L27:
	imull	$103, %edx, %eax
	sarw	$10, %ax
	movl	%edx, %ecx
	sarb	$7, %cl
	subl	%ecx, %eax
	leal	(%rax,%rax,4), %eax
	addl	%eax, %eax
	movl	%edx, %ecx
	subl	%eax, %ecx
	movsbq	%cl, %rax
	movl	(%rsp,%rax,4), %eax
	sall	$3, %eax
	orl	%eax, (%rsi)
	jmp	.L12
.L17:
	cmpb	$49, %dil
	jg	.L18
	movl	(%rsi), %eax
	orl	$50331648, %eax
	movl	%eax, (%rsi)
	jmp	.L16
.L18:
	cmpb	$69, %dil
	jg	.L19
	movl	(%rsi), %eax
	orl	$117440512, %eax
	movl	%eax, (%rsi)
	jmp	.L16
.L19:
	cmpb	$89, %dil
	jg	.L20
	movl	(%rsi), %eax
	orl	$251658240, %eax
	movl	%eax, (%rsi)
	jmp	.L16
.L20:
	cmpb	$100, %dil
	jg	.L16
	movl	(%rsi), %eax
	orl	$520093696, %eax
	movl	%eax, (%rsi)
	jmp	.L16
.L28:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE1:
	.size	set_display_from_batt, .-set_display_from_batt
	.globl	batt_update
	.type	batt_update, @function
batt_update:
.LFB2:
	.cfi_startproc
	endbr64
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movq	%fs:40, %rax
	movq	%rax, 8(%rsp)
	xorl	%eax, %eax
	movw	$-100, 4(%rsp)
	movb	$-1, 6(%rsp)
	movb	$-1, 7(%rsp)
	leaq	4(%rsp), %rdi
	call	set_batt_from_ports
	cmpl	$1, %eax
	je	.L29
	leaq	4(%rsp), %rdi
	call	set_batt_from_ports
	leaq	BATT_DISPLAY_PORT(%rip), %rsi
	movl	4(%rsp), %edi
	call	set_display_from_batt
	movl	$0, %eax
.L29:
	movq	8(%rsp), %rdx
	xorq	%fs:40, %rdx
	jne	.L33
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L33:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE2:
	.size	batt_update, .-batt_update
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
