.section .data
newline: .ascii ""
#hold uninitialied data
.section .bss
.lcomm buffer, 255 #8 bits = character 
.lcomm buffer2, 255
.lcomm result, 255

.section .text
.global _start

_start:

    #first input
    mov $0, %rax 
    mov $0, %rdi
    mov $buffer, %rsi # buf
    mov $255, %rdx # len
    syscall

    #second word
    mov $0, %rax # write
    mov $0, %rdi # stdout
    mov $buffer2, %rsi # buf
    mov $255, %rdx # len
    syscall

    #need to make sure these are clear
    mov $buffer, %r11
    mov $buffer2, %r12
    mov $0, %rcx #total hammering distance count
    mov $0, %rax #this will be for buffer 
    mov $0, %rbx #this will be for buffer2

    load:
        movb (%r11), %al #array for a character in buffer
        movb (%r12), %bl #array for a character in buffer2
    

        #10 is ascii for \n
        #cmp = compare

        cmp $10, %al #makes sure nothing is equal to \n
        je done #je = jmp if equal, jmps to done if condition is satified 
        cmp $0, %al #checks if the array is equal to NUL
        je done
        cmp $10, %bl
        je done
        cmp $0, %bl
        je done

        xor %bl, %al


    comparing:
        cmp $0, %al #if the array equals NUL then goes to next
        je next

        shr $1, %al #shift to the righ by one
        jnc comparing #loop over if shifted bit was 0
        inc %rcx #if shifted bit was 1 add it to rcx
        jmp comparing #do it again

    next:
        #advances the array
        inc %r11
        inc %r12
        jmp load 
        #if there's no more bits in the shortest word then going 
        #to load will send the program straight to done


    done:
        mov %rcx, %rax   #moves bit count to rax
        mov $result, %rsi #stores result as a temp variable
        add $15, %rsi #turns pointer backwards
        movb $10, (%rsi) #newline

        mov $10, %rbx #tells div function to divide by 10
        mov $1, %r13 #length tracker to 1 to skip the \n


    convert:
        mov $0, %rdx #clears out rdx
        div %rbx #divides rax by rbx(10)

        add $48, %rdx #adds 0 to rdx 
        dec %rsi #decrements the counter by 1 byte
        movb %dl, (%rsi) #copies text character byte into the buffer
        inc %r13 #adds 1 to the text counter

        cmp $0, %rax
        jne convert #if not equal to NUL loop


        #prints the result
        mov $1, %rax
        mov $1, %rdi
        mov %r13, %rdx
        syscall


        mov $60, %rax # exit
        mov $0, %rdi # status
        syscall
