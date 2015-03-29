@ startup
	.global _start
	.align
_start:
	// IRQモードのスタックポインタ設定
	// IRQ,FIQ disable, Thumb disable, IRQ mode
	ldr	r0, =0x000000d2
	msr	cpsr, r0
	ldr	sp, =0x00008000

	// SVCモードのスタックポインタ設定
	// IRQ,FIQ disable, Thumb disable, SVC mode 
	ldr	r0, =0x000000d3
	msr	cpsr, r0
	ldr	sp, =0x06400000

	// main呼び出し
	bl main

	// 終了（無限ループ）
	b .

.global _hangup
_hangup:
	// IRQ,FIQ disable, Thumb disable, SVC mode 
	ldr	r0, =0x000000d3
	msr	cpsr, r0
	b .


_IRQ_interrupt:
	// スタックにレジスタの内容を退避させる
	stmfd	r13!, {r0-r12,lr}
	// C言語の割り込みハンドラ呼び出し
	bl	IRQ_handler
	// スタックからレジスタの内容を復元する。
	ldmfd	r13!, {r0-r12,lr}
	// 戻りアドレス修正（IRQはlr-4）して、元の実行番地に復帰
	subs	pc,lr, #4


// IRQ有効化（CPSR設定）
	.global enable_IRQ
enable_IRQ:
	mrs	r0, cpsr
	bic r0, r0, #0x80
	msr cpsr_c,r0
	bx lr

// IRQ無効化（CPSR設定）
	.global disable_IRQ
disable_IRQ:
	mrs	r0, cpsr
	ldr	r1,	=0x80
	orr r0, r0, r1
	msr	cpsr_c, r0
	bx lr

// CPSRの値を取得して返す（r0は戻り値を入れるレジスタ）
	.global getmode
getmode:
	mrs	r0, cpsr
	bx lr


.global _swi_caller
_swi_caller:
	push {lr}
	swi #0xfa
	pop {lr}
	bx lr

	.global _regdump
_regdump:
	// スタックにレジスタの内容を退避させる
	stmfd	r13!, {r0-r12,lr}

	// stack usr mode register
	push {r0-r7}
	mrs r0, r8_usr
	mrs r1, r9_usr
	mrs r2, r10_usr
	mrs r3, r11_usr
	mrs r4, r12_usr
	mrs r5, sp_usr
	mrs r6, lr_usr
	push {r0-r6}

	// stack fiq mode register
	mrs r0, r8_fiq
	mrs r1, r9_fiq
	mrs r2, r10_fiq
	mrs r3, r11_fiq
	mrs r4, r12_fiq
	mrs r5, SP_fiq
	mrs r6, LR_fiq
	push {r0-r6}
	
	// stack irq register
	// stack svc register
	// stack abt register
	// stack und register
	mrs r0, SP_irq
	mrs r1, LR_irq
	mrs r2, SP_svc
	mrs r3, LR_svc
	mrs r4, SP_abt
	mrs r5, LR_abt
	mrs r6, SP_und
	mrs r7, LR_und
	push {r0-r7}

	// stack mon register
	mrs r0, SP_mon
	mrs r1, LR_mon
	mrs r2, SP_hyp
	mrs r3, ELR_hyp
	push {r0-r3}

	// set sp start addr
	mov r0, sp

	// C言語の割り込みハンドラ呼び出し
	bl	swi_hello

	// restore stack address
	add sp, sp, #34

	// スタックからレジスタの内容を復元する。
	ldmfd	r13!, {r0-r12,lr}
	# sub	pc, lr, #4
	bx lr


// ベクターテーブル設定用
	.global  _initial_vector_start
_initial_vector_start:
	ldr	pc, _vec_Reset
	ldr	pc, _vec_Undef
	ldr	pc, _vec_SWI
	ldr	pc, _vec_PrefAbort
	ldr	pc, _vec_DataAbort
	ldr	pc, _vec_Reserved
	ldr	pc, _vec_IRQ
	ldr	pc, _vec_FIQ
_vec_Reset:		.word	_start
_vec_Undef:		.word	_hangup
_vec_SWI:		.word	_regdump
_vec_PrefAbort:	.word	_hangup
_vec_DataAbort:	.word	_hangup
_vec_Reserved:	.word	_hangup
_vec_IRQ:		.word	_IRQ_interrupt
_vec_FIQ:		.word	_hangup
	.global  _initial_vector_end
_initial_vector_end:
	mov r0,r0
// 最後に何か命令を置かないと_initial_vector_endラベルが消える
