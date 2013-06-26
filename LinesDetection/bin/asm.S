	.file	"engine.c"
	.global	__divsi3
	.text
	.align	2
	.global	find_lines
	.type	find_lines, %function
find_lines:
	@ args = 20, pretend = 0, frame = 228
	@ frame_needed = 0, uses_anonymous_args = 0
	stmfd	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
	sfmfd	f4, 4, [sp]!
	sub	sp, sp, #256
	str	r2, [sp, #84]
	str	r1, [sp, #88]
	str	r0, [sp, #92]
	str	r3, [sp, #80]
	mov	r0, r1
	ldrb	r3, [sp, #348]	@ zero_extendqisi2
	mov	r1, r2
	ldr	r2, [sp, #344]
	str	r2, [sp, #76]
	str	r3, [sp, #72]
	ldr	r4, [sp, #356]
	ldr	r5, [sp, #352]	@ float
	bl	alloc_raw
	ldr	r1, [sp, #84]
	mov	r4, r4, asl #1
	add	r9, r4, #1
	str	r0, [sp, #96]
	ldr	r0, [sp, #88]
	bl	alloc_raw
	mov	r1, r5
	str	r0, [sp, #100]
	mov	r0, r9
	bl	new_gaussian
	ldr	r4, [sp, #96]
	ldr	ip, [sp, #100]
	cmp	ip, #0
	cmpne	r4, #0
	movne	r1, #0
	moveq	r1, #1
	str	r0, [sp, #104]
	beq	.L102
	cmp	r0, #0
	beq	.L102
	cmp	r9, #0
	movle	fp, r1
	ble	.L4
	mov	fp, r1
	mov	r0, r1
.L6:
	ldr	lr, [sp, #104]
	mov	r2, #0
	ldr	r1, [lr, r0, asl #2]
.L5:
	ldr	r3, [r1, r2, asl #2]
	add	r2, r2, #1
	cmp	r9, r2
	add	fp, fp, r3
	bgt	.L5
	add	r0, r0, #1
	cmp	r9, r0
	bgt	.L6
.L4:
	add	r3, r9, r9, lsr #31
	ldr	r0, [sp, #84]
	mov	r3, r3, asr #1
	rsb	r0, r3, r0
	cmp	r3, r0
	str	r3, [sp, #108]
	str	r0, [sp, #116]
	bge	.L7
	ldr	r1, [sp, #96]
	mov	r3, r3, asl #2
	add	r8, r1, r3
	ldr	r2, [sp, #88]
	ldr	r3, [sp, #108]
	ldr	sl, [sp, #92]
	rsb	r2, r3, r2
	str	r2, [sp, #188]
	str	r3, [sp, #212]
.L8:
	ldr	r2, [sp, #108]
	ldr	r3, [sp, #188]
	cmp	r2, r3
	ldrlt	r7, [sp, #108]
	movlt	r6, #0
	bge	.L16
.L14:
	cmp	r9, #0
	movle	r0, #0
	movle	r2, r0
	ble	.L10
	mov	r4, #0
	mov	r5, sl
	mov	r0, r4
.L12:
	ldr	ip, [sp, #104]
	ldr	r3, [r5, #0]
	ldr	lr, [ip, r4, asl #2]
	mov	r1, #0
	add	ip, r3, r6
.L11:
	ldrb	r2, [ip, r1]	@ zero_extendqisi2
	ldr	r3, [lr, r1, asl #2]
	add	r1, r1, #1
	cmp	r9, r1
	mla	r0, r3, r2, r0
	bgt	.L11
	add	r4, r4, #1
	cmp	r9, r4
	add	r5, r5, #4
	bgt	.L12
	mov	r2, r0
.L10:
	cmp	fp, #1
	ble	.L13
	mov	r1, fp
	bl	__divsi3
	mov	r2, r0
.L13:
	ldr	r3, [r8, #0]
	add	r6, r6, #1
	strb	r2, [r3, r7]
	ldr	lr, [sp, #188]
	add	r7, r7, #1
	cmp	r7, lr
	blt	.L14
.L16:
	ldr	r0, [sp, #212]
	ldr	r1, [sp, #116]
	add	r0, r0, #1
	cmp	r0, r1
	str	r0, [sp, #212]
	add	r8, r8, #4
	add	sl, sl, #4
	blt	.L8
.L7:
	ldr	r4, [sp, #84]
	cmp	r4, #0
	ble	.L137
	ldr	ip, [sp, #84]
	ldr	lr, [sp, #88]
	ldr	r0, [sp, #108]
	ldr	r2, [sp, #108]
	ldr	r3, [sp, #108]
	sub	ip, ip, #1
	sub	r7, lr, #1
	add	r0, r0, #1
	mov	r1, #0
	rsb	r2, r2, ip
	rsb	r3, r3, r7
	str	ip, [sp, #204]
	str	r0, [sp, #192]
	str	r1, [sp, #112]
	str	r2, [sp, #32]
	str	r3, [sp, #28]
.L28:
	ldr	ip, [sp, #112]
	ldr	r4, [sp, #192]
	ldr	lr, [sp, #32]
	ldr	r0, [sp, #88]
	cmp	r4, ip
	moveq	ip, lr
	cmp	r0, #0
	str	ip, [sp, #112]
	ble	.L20
	ldr	r1, [sp, #96]
	ldr	r2, [sp, #108]
	mov	r3, ip, asl #2
	add	r3, r1, r3
	mov	r8, #0
	rsb	sl, r2, ip
	str	r3, [sp, #120]
.L27:
	ldr	r3, [sp, #192]
	ldr	r4, [sp, #28]
	cmp	r3, r8
	moveq	r8, r4
	cmp	r9, #0
	movle	r0, #0
	movle	r2, r0
	ble	.L23
	ldr	ip, [sp, #108]
	mov	r6, #0
	rsb	r5, ip, r8
	mov	r0, r6
.L25:
	ldr	lr, [sp, #204]
	add	r3, r6, sl
	bic	r3, r3, r3, asr #31
	ldr	r1, [sp, #92]
	ldr	r2, [sp, #104]
	cmp	r3, lr
	movge	r3, lr
	ldr	r4, [r1, r3, asl #2]
	ldr	lr, [r2, r6, asl #2]
	mov	ip, #0
.L24:
	add	r3, ip, r5
	bic	r3, r3, r3, asr #31
	cmp	r3, r7
	movge	r3, r7
	ldr	r2, [lr, ip, asl #2]
	ldrb	r1, [r4, r3]	@ zero_extendqisi2
	add	ip, ip, #1
	cmp	r9, ip
	mla	r0, r2, r1, r0
	bgt	.L24
	add	r6, r6, #1
	cmp	r9, r6
	bgt	.L25
	mov	r2, r0
.L23:
	cmp	fp, #1
	ble	.L26
	mov	r1, fp
	bl	__divsi3
	mov	r2, r0
.L26:
	ldr	r4, [sp, #120]
	ldr	r3, [r4, #0]
	strb	r2, [r3, r8]
	ldr	ip, [sp, #88]
	add	r8, r8, #1
	cmp	ip, r8
	bgt	.L27
.L20:
	ldr	lr, [sp, #112]
	ldr	r0, [sp, #84]
	add	lr, lr, #1
	cmp	r0, lr
	str	lr, [sp, #112]
	bgt	.L28
	mvn	r4, #0
	mvn	r6, #1
	mov	r0, #3
	mov	r5, #0
	mov	r8, #1
	mov	r7, #2
	mov	r1, r0
	mov	r2, r4
	mov	r3, r6
	stmia	sp, {r4, r5}	@ phole stm
	str	r5, [sp, #8]
	str	r5, [sp, #12]
	str	r8, [sp, #16]
	str	r7, [sp, #20]
	str	r8, [sp, #24]
	bl	new_kernel
	mov	r3, r5
	mov	r2, r8
	str	r7, [sp, #4]
	str	r6, [sp, #12]
	str	r4, [sp, #24]
	str	r4, [sp, #0]
	str	r5, [sp, #8]
	str	r8, [sp, #16]
	str	r5, [sp, #20]
	str	r0, [sp, #128]
	mov	r0, #3
	mov	r1, r0
	bl	new_kernel
	ldr	r1, [sp, #204]
	cmp	r1, r8
	str	r0, [sp, #124]
	ble	.L29
	ldr	r2, [sp, #88]
	ldr	r3, [sp, #96]
	add	r2, r2, r4
	str	r8, [sp, #132]
	str	r2, [sp, #196]
	str	r3, [sp, #208]
.L30:
	ldr	r2, [sp, #196]
	cmp	r2, #1
	ble	.L35
	ldr	r4, [sp, #132]
	mov	sl, #1
	mov	r4, r4, asl #2
	str	r4, [sp, #68]
.L33:
	mov	r7, #0
	ldr	fp, [sp, #208]
	mov	r8, r7
	mov	r6, r7
.L31:
	ldr	ip, [sp, #128]
	ldr	r0, [sp, #124]
	ldr	lr, [ip, r6]
	ldr	r4, [r0, r6]
	ldr	r3, [fp], #4
	ldr	r5, [lr, #0]
	add	r3, r3, sl
	ldr	ip, [r4, #0]
	ldr	r1, [lr, #4]
	ldr	r2, [r4, #4]
	ldrb	r0, [r3, #-1]	@ zero_extendqisi2
	add	r1, r1, r5
	add	r2, r2, ip
	mla	r5, r1, r0, r7
	mla	ip, r2, r0, r8
	ldr	r1, [lr, #8]
	ldr	r3, [r4, #8]
	add	r6, r6, #4
	cmp	r6, #12
	mla	r8, r3, r0, ip
	mla	r7, r1, r0, r5
	bne	.L31
	mul	r3, r7, r7
	ldr	r1, [sp, #100]
	ldr	r4, [sp, #68]
	ldr	r2, [r1, r4]
	mla	r1, r8, r8, r3
	add	r4, r2, sl
	fltd	f1, r1
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L32
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L32:
	ldr	ip, [sp, #196]
	add	sl, sl, #1
	cmp	sl, ip
	fixz	r3, f0
	strb	r3, [r4, #0]
	blt	.L33
.L35:
	ldr	lr, [sp, #132]
	ldr	r1, [sp, #208]
	ldr	r0, [sp, #204]
	add	lr, lr, #1
	add	r1, r1, #4
	cmp	lr, r0
	str	lr, [sp, #132]
	str	r1, [sp, #208]
	blt	.L30
.L29:
	ldr	r4, [sp, #88]
	ldr	ip, [sp, #88]
	ldr	lr, [sp, #84]
	mov	r3, #0
	sub	r4, r4, #1
	sub	ip, ip, #2
	sub	lr, lr, #2
	str	r3, [sp, #220]
	str	r4, [sp, #44]
	str	ip, [sp, #40]
	str	lr, [sp, #36]
.L129:
	ldr	r2, [sp, #88]
	cmp	r2, #0
	ble	.L37
	ldr	r4, [sp, #220]
	ldr	ip, [sp, #100]
	sub	lr, r4, #1
	mov	r3, r4, asl #2
	mov	r0, #0
	add	r3, ip, r3
	mov	r4, r0
	mov	fp, lr
	str	r3, [sp, #136]
	str	lr, [sp, #200]
	str	r0, [sp, #224]
.L130:
	sub	r3, r4, #1
	add	r2, r4, #1
	ldr	ip, [sp, #44]
	ldr	lr, [sp, #44]
	ldr	r0, [sp, #44]
	mov	sl, #0
	bic	r3, r3, r3, asr #31
	bic	r2, r2, r2, asr #31
	bic	r1, r4, r4, asr #31
	cmp	ip, r3
	movge	ip, r3
	cmp	lr, r1
	movge	lr, r1
	cmp	r0, r2
	movge	r0, r2
	mov	r8, sl
	str	ip, [sp, #56]
	str	lr, [sp, #52]
	str	r0, [sp, #48]
	str	sl, [sp, #228]
.L39:
	ldr	r1, [sp, #204]
	bic	r3, fp, fp, asr #31
	ldr	r2, [sp, #96]
	cmp	r3, r1
	movge	r3, r1
	ldr	lr, [r2, r3, asl #2]
	ldr	ip, [sp, #124]
	ldr	r3, [sp, #128]
	ldr	r5, [ip, r8]
	ldr	r4, [r3, r8]
	ldr	r0, [sp, #56]
	ldr	r3, [r4, #0]
	ldrb	r1, [lr, r0]	@ zero_extendqisi2
	ldr	r2, [r5, #0]
	mul	r6, r3, r1
	mul	r7, r2, r1
	ldr	r1, [sp, #52]
	ldr	r2, [r5, #4]
	ldrb	ip, [lr, r1]	@ zero_extendqisi2
	ldr	r3, [r4, #4]
	mla	r1, r2, ip, r7
	ldr	r2, [sp, #48]
	mla	r0, r3, ip, r6
	ldrb	r6, [lr, r2]	@ zero_extendqisi2
	ldr	r2, [r4, #8]
	ldr	r4, [sp, #228]
	ldr	r3, [r5, #8]
	add	r1, r1, r4
	mla	r1, r3, r6, r1
	add	r8, r8, #4
	add	r0, r0, sl
	cmp	r8, #12
	str	r1, [sp, #228]
	mla	sl, r2, r6, r0
	add	fp, fp, #1
	bne	.L39
	mul	r3, sl, sl
	ldr	ip, [sp, #136]
	mov	lr, r1
	mla	r1, lr, r1, r3
	ldr	r2, [ip, #0]
	ldr	r0, [sp, #224]
	fltd	f1, r1
	add	r4, r2, r0
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L40
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L40:
	ldr	r1, [sp, #224]
	ldr	r2, [sp, #88]
	add	r1, r1, #1
	cmp	r2, r1
	str	r1, [sp, #224]
	fixz	r3, f0
	strb	r3, [r4, #0]
	ble	.L37
	ldr	r1, [sp, #224]
	ldr	r2, [sp, #40]
	cmp	r1, #2
	moveq	r1, r2
	str	r1, [sp, #224]
	mov	r4, r1
	ldr	fp, [sp, #200]
	b	.L130
.L37:
	ldr	r3, [sp, #220]
	ldr	r4, [sp, #84]
	add	r3, r3, #1
	cmp	r4, r3
	str	r3, [sp, #220]
	ble	.L138
	ldr	r0, [sp, #220]
	ldr	r1, [sp, #36]
	cmp	r0, #2
	moveq	r0, r1
	str	r0, [sp, #220]
	b	.L129
.L102:
	add	sp, sp, #256
	lfmfd	f4, 4, [sp]!
	ldmfd	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}
.L138:
	ldr	r0, [sp, #128]
	mov	r1, #3
	bl	free_kernel
	ldr	r0, [sp, #124]
	mov	r1, #3
	bl	free_kernel
	mov	lr, #0
	mov	ip, lr
.L43:
	ldr	r2, [sp, #88]
	cmp	r2, #0
	movgt	r1, #0
	ble	.L48
.L46:
	ldr	r0, [sp, #100]
	ldr	r2, [sp, #96]
	ldr	r3, [r0, ip]
	ldr	r4, [sp, #72]
	ldr	r0, [r2, ip]
	ldrb	r2, [r3, r1]	@ zero_extendqisi2
	mvn	r3, #0
	cmp	r4, r2
	movgt	r3, #0
	strb	r3, [r0, r1]
	ldr	r0, [sp, #88]
	add	r1, r1, #1
	cmp	r0, r1
	bgt	.L46
.L48:
	ldr	r1, [sp, #84]
	add	lr, lr, #1
	cmp	r1, lr
	add	ip, ip, #4
	bgt	.L43
.L18:
	ldr	r3, [sp, #88]
	ldr	r1, [sp, #84]
	mov	r0, r3
	mul	r3, r0, r3
	mov	r2, r1
	mla	r1, r2, r1, r3
	mov	fp, #0
	mov	r3, #0
	mov	r4, #0
	str	r1, [sp, #140]
	str	r3, [sp, #160]
	str	r4, [sp, #164]
	str	fp, [sp, #216]
	mov	r6, fp
	mov	r8, fp
	b	.L101
.L140:
	ldfd	f0, .L150
	ldfd	f2, [sp, #160]
	cmfe	f2, f0
	bpl	.L49
	ldfd	f3, [sp, #160]
	ldfd	f0, .L150+8
	adfd	f3, f3, f0
	stfd	f3, [sp, #160]
.L52:
	ldfd	f1, [sp, #160]
	ldfd	f0, .L150+16
	adfd	f1, f1, f0
	stfd	f1, [sp, #160]
	ldfd	f2, [sp, #160]
	ldfd	f1, .L150+24
	cmfe	f2, f1
	bpl	.L139
.L101:
	ldfd	f0, [sp, #160]
	ldfd	f1, .L150+32
	cmfe	f0, f1
	bge	.L140
.L49:
	ldr	r0, [sp, #140]
	fltd	f0, r0
	sqtd	f4, f0
	cmf	f4, f4
	beq	.L53
	stfd	f0, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
	mvfd	f4, f0
.L53:
	ldfd	f0, .L150+8
	ldfd	f1, [sp, #160]
	cmfe	f1, f0
	bls	.L141
	ldfd	f1, [sp, #160]
	ldfd	f2, .L150+32
	cmfe	f1, f2
	bhi	.L132
	ldfd	f3, [sp, #160]
	sufd	f3, f3, f0
	stfd	f3, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	cos
	ldr	r0, [sp, #84]
	ldfd	f1, .L150+40
	fltd	f2, r0
	ldfd	f3, [sp, #160]
	cmfe	f3, f1
	movhi	r0, #0
	movls	r0, #1
	str	r0, [sp, #168]
	mufd	f2, f2, f0
	stfd	f2, [sp, #144]
.L56:
	ldfd	f0, [sp, #144]
	cmfe	f0, #0
	ble	.L52
	add	r0, sp, #160
	ldmia	r0, {r0-r1}
	add	r2, sp, #248
	add	r3, sp, #240
	bl	sincos
	mov	r0, #0
	mov	r1, #0
	ldfd	f6, [sp, #248]
	str	r0, [sp, #152]
	str	r1, [sp, #156]
	ldfd	f5, [sp, #240]
	mnfd	f2, #0
	mufd	f2, f5, f2
	dvfd	f2, f2, f6
	stfd	f2, [sp, #172]
	ldr	r1, [sp, #84]
	ldr	r2, [sp, #88]
	fltd	f0, r1
	fltd	f1, r2
	mnfd	f0, f0
	mnfd	f1, f1
	mufd	f0, f6, f0
	stfd	f1, [sp, #232]
	stfd	f0, [sp, #60]
	mufd	f0, f5, f1
	ldfd	f1, [sp, #172]
	dvfd	f0, f0, f6
	stfd	f0, [sp, #180]
	ldfd	f0, [sp, #152]
	dvfd	f7, f0, f6
	adfd	f0, f1, f7
	fixz	r0, f0
	cmp	r0, #0
	ble	.L142
.L60:
	ldr	r1, [sp, #84]
	cmp	r1, r0
	ble	.L62
	mov	r4, #0
	ldfd	f0, [sp, #152]
	mnfd	f1, #0
	dvfd	f4, f0, f5
	ldfd	f2, [sp, #60]
	mufd	f0, f6, f1
	dvfd	f1, f2, f5
	dvfd	f0, f0, f5
	adfd	f1, f1, f4
	adfd	f0, f0, f4
	fixz	r2, f1
	fixz	r1, f0
.L61:
	ldfd	f3, [sp, #180]
	adfd	f0, f7, f3
	fixz	r3, f0
	cmp	r3, #0
	movle	ip, r1
	ble	.L64
	ldr	lr, [sp, #84]
	ldr	ip, [sp, #88]
	cmp	lr, r3
	movle	ip, r2
.L64:
	cmp	r1, #0
	ble	.L143
	ldr	r1, [sp, #88]
	cmp	r1, r0
	ldfled	f1, [sp, #232]
	movgt	r5, #0
	mufled	f0, f6, f1
	dvfled	f0, f0, f5
	adfled	f0, f0, f4
	fixlez	r5, f0
	bicle	r5, r5, r5, asr #31
.L67:
	cmp	r2, #0
	movle	r3, r0
	ble	.L70
	ldr	r1, [sp, #88]
	ldr	r0, [sp, #84]
	cmp	r1, r2
	movgt	r3, r0
.L70:
	ldr	r2, [sp, #168]
	cmp	r2, #0
	bne	.L71
	ldr	sl, [sp, #84]
	cmp	sl, r3
	movge	sl, r3
	cmp	r5, sl
	mvnge	r6, #0
	bge	.L73
	ldr	r0, [sp, #96]
	mov	r3, r5, asl #2
	add	r7, r0, r3
	mvn	r6, #0
	b	.L95
.L151:
	.align	2
.L150:
	.word	1074977148
	.word	2134057426
	.word	1073291771
	.word	1413754136
	.word	1068504511
	.word	-1843976422
	.word	1075388923
	.word	1413754136
	.word	1074340347
	.word	1413754136
	.word	1073928572
	.word	2134057426
	.word	1106247680
	.word	0
.L145:
	ldr	r3, [r7, #0]
	ldrb	r2, [r3, r4]	@ zero_extendqisi2
	cmp	r2, #255
	beq	.L144
	cmp	r6, #0
	blt	.L87
	ldr	r2, [sp, #216]
	rsb	r3, r2, r8
	cmp	r3, #0
	rsblt	r3, r3, #0
	mul	r1, r3, r3
	rsb	r2, fp, r6
	cmp	r2, #0
	rsblt	r2, r2, #0
	mla	r3, r2, r2, r1
	fltd	f1, r3
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L91
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L91:
	ldr	r3, [sp, #76]
	fltd	f1, r3
	cmp	r3, #0
	ldfltd	f2, .L150+48
	adfltd	f1, f1, f2
	cmfe	f0, f1
	ble	.L134
	mov	r2, r6
	ldr	r0, [sp, #80]
	mov	r1, r8
	ldr	r3, [sp, #216]
	str	fp, [sp, #0]
	bl	add_line
.L134:
	mov	r4, r8
	mvn	r6, #0
.L90:
	add	r5, r5, #1
	cmp	sl, r5
	add	r7, r7, #4
	ble	.L94
.L146:
	mov	r8, r4
.L95:
	ldr	r1, [sp, #88]
	fltd	f0, r5
	mnfd	f0, f0
	mufd	f0, f6, f0
	dvfd	f0, f0, f5
	adfd	f0, f0, f4
	fixz	r4, f0
	cmp	r1, r4
	movgt	r3, #0
	movle	r3, #1
	orrs	r3, r3, r4, lsr #31
	beq	.L145
.L87:
	add	r5, r5, #1
	cmp	sl, r5
	mov	r4, r8
	add	r7, r7, #4
	bgt	.L146
.L94:
	cmp	r6, #0
	blt	.L96
	ldr	r0, [sp, #216]
	rsb	r2, fp, r6
	rsb	r3, r0, r4
	cmp	r3, #0
	rsblt	r3, r3, #0
	mul	r1, r3, r3
	cmp	r2, #0
	rsblt	r2, r2, #0
	mla	r3, r2, r2, r1
	fltd	f1, r3
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L97
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L97:
	ldr	r1, [sp, #76]
	fltd	f1, r1
	cmp	r1, #0
	ldfltd	f2, .L150+48
	adfltd	f1, f1, f2
	cmfe	f0, f1
	ble	.L96
	ldr	r0, [sp, #80]
	mov	r1, r4
	mov	r2, r6
	ldr	r3, [sp, #216]
	str	fp, [sp, #0]
	bl	add_line
	mov	r8, r4
.L73:
	ldfd	f3, [sp, #152]
	ldfd	f0, [sp, #144]
	adfd	f3, f3, #1
	stfd	f3, [sp, #152]
	cmfe	f3, f0
	bpl	.L52
.L136:
	ldfd	f0, [sp, #152]
	ldfd	f1, [sp, #172]
	dvfd	f7, f0, f6
	adfd	f0, f1, f7
	fixz	r0, f0
	cmp	r0, #0
	bgt	.L60
.L142:
	ldfd	f2, [sp, #152]
	mnfd	f3, #0
	dvfd	f4, f2, f5
	mufd	f0, f6, f3
	dvfd	f0, f0, f5
	adfd	f0, f0, f4
	fixz	r1, f0
	ldfd	f0, [sp, #60]
	bic	r4, r1, r1, asr #31
	dvfd	f1, f0, f5
	adfd	f1, f1, f4
	fixz	r2, f1
	b	.L61
.L144:
	cmp	r6, #0
	strge	r4, [sp, #216]
	movlt	fp, r5
	strlt	r4, [sp, #216]
	movlt	r6, r5
	movge	r4, r8
	movge	fp, r5
	b	.L90
.L71:
	ldr	r7, [sp, #88]
	cmp	r7, ip
	movge	r7, ip
	cmp	r7, r4
	mvnle	r8, #0
	ble	.L73
	mov	r5, r6
	mvn	r8, #0
	b	.L83
.L148:
	ldr	lr, [sp, #96]
	ldr	r3, [lr, r6, asl #2]
	ldrb	r2, [r3, r4]	@ zero_extendqisi2
	cmp	r2, #255
	beq	.L147
	cmn	r8, #1
	beq	.L75
	ldr	r0, [sp, #216]
	rsb	r2, fp, r5
	rsb	r3, r0, r8
	cmp	r3, #0
	rsblt	r3, r3, #0
	mul	r1, r3, r3
	cmp	r2, #0
	rsblt	r2, r2, #0
	mla	r3, r2, r2, r1
	fltd	f1, r3
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L79
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L79:
	ldr	r1, [sp, #76]
	fltd	f1, r1
	cmp	r1, #0
	ldfltd	f2, .L150+48
	adfltd	f1, f1, f2
	cmfe	f0, f1
	ble	.L133
	mov	r1, r8
	ldr	r0, [sp, #80]
	mov	r2, r5
	ldr	r3, [sp, #216]
	str	fp, [sp, #0]
	bl	add_line
.L133:
	mov	r6, r5
	mvn	r8, #0
.L78:
	add	r4, r4, #1
	cmp	r7, r4
	ble	.L82
.L149:
	mov	r5, r6
.L83:
	ldr	ip, [sp, #84]
	fltd	f0, r4
	mnfd	f0, f0
	mufd	f0, f5, f0
	dvfd	f0, f0, f6
	adfd	f0, f7, f0
	fixz	r6, f0
	cmp	ip, r6
	movgt	r3, #0
	movle	r3, #1
	orrs	r3, r3, r6, lsr #31
	beq	.L148
.L75:
	add	r4, r4, #1
	cmp	r7, r4
	mov	r6, r5
	bgt	.L149
.L82:
	cmn	r8, #1
	beq	.L73
	ldr	r0, [sp, #216]
	rsb	r2, fp, r6
	rsb	r3, r0, r8
	cmp	r3, #0
	rsblt	r3, r3, #0
	mul	r1, r3, r3
	cmp	r2, #0
	rsblt	r2, r2, #0
	mla	r3, r2, r2, r1
	fltd	f1, r3
	sqtd	f0, f1
	cmf	f0, f0
	beq	.L84
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	sqrt
.L84:
	ldr	r1, [sp, #76]
	fltd	f1, r1
	cmp	r1, #0
	ldfltd	f2, .L150+48
	adfltd	f1, f1, f2
	cmfe	f0, f1
	ble	.L73
	ldr	r0, [sp, #80]
	mov	r1, r8
	mov	r2, r6
	ldr	r3, [sp, #216]
	str	fp, [sp, #0]
	bl	add_line
	ldfd	f3, [sp, #152]
	ldfd	f0, [sp, #144]
	adfd	f3, f3, #1
	stfd	f3, [sp, #152]
	cmfe	f3, f0
	bmi	.L136
	b	.L52
.L147:
	cmn	r8, #1
	movne	fp, r6
	moveq	fp, r6
	streq	r4, [sp, #216]
	moveq	r8, r4
	movne	r6, r5
	strne	r4, [sp, #216]
	b	.L78
.L96:
	ldfd	f3, [sp, #152]
	ldfd	f0, [sp, #144]
	adfd	f3, f3, #1
	mov	r8, r4
	stfd	f3, [sp, #152]
	cmfe	f3, f0
	bmi	.L136
	b	.L52
.L143:
	bic	r5, r0, r0, asr #31
	b	.L67
.L62:
	ldfd	f3, [sp, #152]
	ldfd	f1, [sp, #60]
	dvfd	f4, f3, f5
	dvfd	f0, f1, f5
	mnfd	f2, #0
	adfd	f0, f0, f4
	fixz	r2, f0
	mufd	f0, f6, f2
	bic	r4, r2, r2, asr #31
	dvfd	f0, f0, f5
	adfd	f0, f4, f0
	fixz	r1, f0
	b	.L61
.L132:
	ldfd	f0, .L152
	ldfd	f1, [sp, #160]
	sufd	f1, f0, f1
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	cos
	ldfd	f1, .L152+8
	ldfd	f2, [sp, #160]
	cmfe	f2, f1
	movhi	r0, #0
	movls	r0, #1
	ldr	r1, [sp, #88]
	str	r0, [sp, #168]
	fltd	f1, r1
	mufd	f1, f1, f0
	stfd	f1, [sp, #144]
	b	.L56
.L141:
	ldr	r2, [sp, #84]
	ldr	r4, [sp, #88]
	fltd	f2, r2
	fltd	f0, r4
	stfd	f2, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	stfd	f0, [sp, #-8]!
	ldmfd	sp!, {r2, r3}
	bl	atan2
	ldfd	f1, [sp, #160]
	sufd	f1, f1, f0
	stfd	f1, [sp, #-8]!
	ldmfd	sp!, {r0, r1}
	bl	cos
	ldfd	f1, .L152+16
	ldfd	f2, [sp, #160]
	cmfe	f2, f1
	movlt	r0, #0
	movge	r0, #1
	str	r0, [sp, #168]
	mufd	f4, f4, f0
	stfd	f4, [sp, #144]
	b	.L56
.L139:
	ldr	r0, [sp, #96]
	ldr	r1, [sp, #84]
	bl	free_raw
	ldr	r0, [sp, #100]
	ldr	r1, [sp, #84]
	bl	free_raw
	mov	r1, r9
	ldr	r0, [sp, #104]
	add	sp, sp, #256
	lfmfd	f4, 4, [sp]!
	ldmfd	sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
	b	free_kernel
.L137:
	mvn	r4, #0
	mvn	r7, #1
	mov	r0, #3
	mov	r5, #0
	mov	r6, #1
	mov	r8, #2
	mov	r2, r4
	mov	r3, r7
	mov	r1, r0
	stmia	sp, {r4, r5}	@ phole stm
	str	r5, [sp, #8]
	str	r5, [sp, #12]
	str	r6, [sp, #16]
	str	r8, [sp, #20]
	str	r6, [sp, #24]
	bl	new_kernel
	mov	r2, r6
	mov	r3, r5
	str	r4, [sp, #24]
	stmia	sp, {r4, r8}	@ phole stm
	str	r7, [sp, #12]
	str	r5, [sp, #8]
	str	r6, [sp, #16]
	str	r5, [sp, #20]
	mov	sl, r0
	mov	r0, #3
	mov	r1, r0
	bl	new_kernel
	mov	r1, #3
	mov	r4, r0
	mov	r0, sl
	bl	free_kernel
	mov	r0, r4
	mov	r1, #3
	bl	free_kernel
	b	.L18
.L153:
	.align	2
.L152:
	.word	1075388923
	.word	1413754136
	.word	1075183035
	.word	-373577867
	.word	1072243195
	.word	1413754136
	.size	find_lines, .-find_lines
	.ident	"GCC: (Debian 4.3.2-1.1) 4.3.2"
	.section	.note.GNU-stack,"",%progbits
