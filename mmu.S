.global _start
mmu_on_nonHYP:
	// ref: http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0363fj/Chdceeih.html
	push {r0}
	mov r0, #0
	// TLBの初期化
	// TLBIALL: CP15, CRn=c8, Op1=0, CRm=c7, Op2=0, (Rt: Ignored)
	mcr p15, 0, r0, c8, c7, 0

	// 命令キャッシュの初期化
	// ICIALLU: CP15,CRn=c7,Op1=0,CRm=c5,Op2=0, (Rt: PoU)
	// see Cortex-A TRM Table B3-49
	mcr p15, 0, r0, c7, c7, 0

	// データキャッシュの初期化
	// DCISW: CP15, CRn=c7, Op1=0, CRm=c6, Op2=2
	// see Cortex-A TRM Table B3-49
	mcr p15, 0, r0, c7, c6, 0

	// 分岐予測の初期化
	// BPIALL: CP15, CRn=c7, Op1=0, CRm=c5, Op2=6
	// see Cortex-A TRM Table B3-49
	mcr p15, 0, r0, c7, c5, 6

	// MMU, 命令キャッシュ, データキャッシュ, 分岐予測 の有効化
	// M[0], I[12], C[1], Z[11]
	// see B4.1.130 Section B4.1.130 and Figure B3-28
	movw r0,#0x1803
	mcr p15, 0, r0, c1, c0, 0

	pop {r0}
	bx lr
