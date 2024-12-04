// Constants
.equ UART_BASE, 0xff201000     // UART base address
.equ UART_CONTROL_REG_OFFSET, 4 // UART control register
.equ STACK_BASE, 0x10000000      // stack beginning

.equ NEW_LINE, 0x0A

.data
facto_numbers:
	.word 1,2,3,4,5,6,7,8,9,10,0


.global _start
.text

print_string:
    PUSH {r0-r4, lr}
    LDR r2, =UART_BASE
    _ps_loop:
        LDRB r1, [r0], #1
        CMP  r1, #0
        BEQ  _print_string

        _ps_busy_wait:
            LDR r4, [r2, #UART_CONTROL_REG_OFFSET]
            LDR r3, =0xFFFF0000
            ANDS r4, r4, r3
            BEQ _ps_busy_wait

            STR  r1, [r2]
        B    _ps_loop
    _print_string:
        POP {r0-r4, pc}

idiv:
    MOV r2, r1
    MOV r1, r0
    MOV r0, #0
    B _loop_check
    _loop:
        ADD r0, r0, #1
        SUB r1, r1, r2
    _loop_check:
        CMP r1, r2
        BHS _loop
    BX lr

print_number:
    PUSH {r0-r5, lr}
    MOV r5, #0
    _div_loop:
        ADD r5, r5, #1
        MOV r1, #10
        BL idiv
        PUSH {r1}
        CMP r0, #0
        BHI _div_loop

    _print_loop:
        POP {r0}
        LDR r2, =#UART_BASE
        ADD r0, r0, #0x30

        _print_busy_wait:
            LDR r4, [r2, #UART_CONTROL_REG_OFFSET]
            LDR r3, =0xFFFF0000
            ANDS r4, r4, r3
            BEQ _print_busy_wait

        STR r0, [r2]
        SUB r5, r5, #1
        CMP r5, #0
        BNE _print_loop

    MOV r0, #NEW_LINE
    STR r0, [r2]
    POP {r0-r5, pc}

_start:
	LDR r1, =facto_numbers

next:
	MOV r0, #1
	LDR r2, [r1] // first elem in arr = 1
	CMP r2, #0
	BEQ _end
	
	PUSH {r0, r2, lr}
	BL factorial
	BL print_number
	POP {r0, r2, lr}
	
	ADD r1, r1, #4 // go to next number in arr,
	B next

factorial:
    CMP r2, #1             // Base case: if n <= 1
    BLE return             // Return the accumulated result

    MUL r0, r0, r2         // r0 = r0 * r2 (current factorial product)
    SUB r2, r2, #1         // Decrement r2
    BL factorial           // Recursive call to factorial

return:
    POP {r0}
    BX lr                  // Return

_end:
	BAL _end

.end