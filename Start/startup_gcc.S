/* Minimal GNU assembler startup for STM32F1 (Cortex-M3) */
.syntax unified
.cpu cortex-m3
.thumb

/* ========== 向量表 — 必须在独立的数据段 ========== */
.section .isr_vector,"a",%progbits
.global g_pfnVectors
g_pfnVectors:
.word   __stack
.word   Reset_Handler
.word   NMI_Handler
.word   HardFault_Handler
.word   MemManage_Handler
.word   BusFault_Handler
.word   UsageFault_Handler
.word   0
.word   0
.word   0
.word   0
.word   SVC_Handler
.word   DebugMon_Handler
.word   0
.word   PendSV_Handler
.word   SysTick_Handler

/* Fill remaining IRQ vectors with Default_Handler */
.rept 64
.word Default_Handler
.endr

/* ========== 处理函数 — 必须在 .text 段，否则 Thumb 位丢失 ========== */
.section .text.Reset_Handler,"ax",%progbits
.thumb_func
.global Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
    bl SystemInit
    /* Copy .data from Flash to RAM */
    ldr r0, =__data_start
    ldr r1, =__data_end
    ldr r2, =__data_load
.Ldata_loop:
    cmp r0, r1
    bcs .Ldata_done
    ldr r3, [r2], #4
    str r3, [r0], #4
    b .Ldata_loop
.Ldata_done:
    /* Zero .bss section */
    ldr r0, =__bss_start
    ldr r1, =__bss_end
    mov r2, #0
.Lbss_loop:
    cmp r0, r1
    bge .Lbss_done
    str r2, [r0], #4
    b .Lbss_loop
.Lbss_done:
    bl main
    b .

/* ========== 弱声明中断处理 ========== */
.weak NMI_Handler
.weak HardFault_Handler
.weak MemManage_Handler
.weak BusFault_Handler
.weak UsageFault_Handler
.weak SVC_Handler
.weak DebugMon_Handler
.weak PendSV_Handler
.weak SysTick_Handler

.set NMI_Handler, Default_Handler
.set HardFault_Handler, Default_Handler
.set MemManage_Handler, Default_Handler
.set BusFault_Handler, Default_Handler
.set UsageFault_Handler, Default_Handler
.set SVC_Handler, Default_Handler
.set DebugMon_Handler, Default_Handler
.set PendSV_Handler, Default_Handler
.set SysTick_Handler, Default_Handler

.section .text.Default_Handler,"ax",%progbits
.thumb_func
.global Default_Handler
.type Default_Handler, %function
Default_Handler:
    b .
