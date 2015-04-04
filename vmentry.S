	.global vmentry
vmentry:
	msr SP_svc, sp
	ldr r0, =0x0
	msr LR_svc, r0
	msr SPSR_svc, r0
	ldr r1, jump_to_guest
	msr ELR_hyp, r1
	ldr r1, =0x000000da
	msr SPSR_cxsf, r1
	mrc p15, 4, r0, c1, c1, 3 // HSTR = 0
	mrc p15, 4, r0, c1, c1, 2 // HCPTR = 0
	mrc p15, 4, r0, c1, c1, 1 // HDCR = 0
	eret

jump_to_guest:
	bl guest_prog
	b .

