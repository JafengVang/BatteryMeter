.text
.global  set_batt_from_ports
        
## ENTRY POINT FOR REQUIRED FUNCTION
set_batt_from_ports:
        ## assembly instructions here

        ## a useful technique for this problem
        # load global variable into register
        # Check the C type of the variable
        #    char / short / int / long
        # and use one of
        #    movb / movw / movl / movq 
        # and appropriately sized destination register

        # takes in a pointer to a batt_struct %rdi as an argument
        movw    BATT_VOLTAGE_PORT(%rip), %dx # accesses the global variable which is a short
        cmpw    $0, %dx # checks to see if volts is less than zero
        jl      .BATT_NEGATIVE
        sarw    $1, %dx # divide volts by 2
        movw    %dx, (%rdi) # sets mlvolts in batt_struct 
        subw    $3000, %dx # turns mlvolts to percentage 
        sarw    $3, %dx # divide volts by 8
        cmpw    $0, %dx # checks if percentage is less than or equal to zero
        jle     .ZERO_PERCENT
        cmpw    $100, %dx # checks if percentage is greater than or equal to 100
        jge     .ABOVE_100
        movb    %dl, 2(%rdi) # sets the percentage in batt_struct
        jmp     .BATT_STATUS                                                   
.ZERO_PERCENT:
        movb    $0, 2(%rdi) # moves 0 to percentage
        jmp     .BATT_STATUS
.ABOVE_100:
        movb    $100, 2(%rdi) # moves 100 to percentage
.BATT_STATUS:
        movb    BATT_STATUS_PORT(%rip), %cl # accesses global variable which is a char
        movb    $1, %al 
        salb    $4, %al # shifts left by 4 
        andb    %al, %cl # checks if 4th bit is set
        jz     .NOT_SET # if (%cl != 0)
        movb    $1, 3(%rdi) # sets the mode to 1 for percentage in the struct
        movl    $0, %eax # sets return value back to zero
        ret
.NOT_SET:
        movb    $2, 3(%rdi) # sets the mode to 2 for the volts in the struct
        movl    $0, %eax # sets return value back to zero
        ret
.BATT_NEGATIVE:
        movl    $1, %eax # returns 1 if volts is negative
        ret
### Change to definint semi-global variables used with the next function 
### via the '.data' directive
.data
	
// my_int:                         # declare location an single integer named 'my_int'
//         .int 1234               # value 1234

// other_int:                      # declare another int accessible via name 'other_int'
//         .int 0b0101             # binary value as per C

// my_array:                       # declare multiple ints sequentially starting at location
//         .int 10                 # 'my_array' for an array. Each are spaced 4 bytes from the
//         .int 0x00014            # next and can be given values using the same prefixes as 
//         .int 0b11110            # are understood by gcc.

masks_int: # bit masks for digits 0-9
        .int 0b0111111 # 0
        .int 0b0000110 # 1
        .int 0b1011011 # 2
        .int 0b1001111 # 3
        .int 0b1100110 # 4
        .int 0b1101101 # 5
        .int 0b1111101 # 6
        .int 0b0000111 # 7
        .int 0b1111111 # 8
        .int 0b1101111 # 9


## WARNING: Don't forget to switch back to .text as below
## Otherwise you may get weird permission errors when executing 
.text
.global  set_display_from_batt

## ENTRY POINT FOR REQUIRED FUNCTION
set_display_from_batt:  
    ## assembly instructions here

	## two useful techniques for this problem
    ##    movl    my_int(%rip),%eax    # load my_int into register eax
    ##    leaq    my_array(%rip),%rdx  # load pointer to beginning of my_array into rdx
        
        # takes in packed struct %rdi and integer pointer %rsi as arguments
        leaq    masks_int(%rip), %rcx # load pointer to beginning of masks_int into %rcx
        movq    $0, %r8 # clears all bits in display holder
        movl    $0, (%rsi) # makes sure display pointer is clear
        movq    %rdi, %r9 # moves batt_struct to %r9
        sarq    $24, %r9 # shift right by 24 to access mode bits
        andq    $0xFF, %r9 # masks the 8 bits for mode
        cmpq    $1, %r9 # checks if mode is 1
        je      .SET_PERCENT_BIT
        cmpq    $2, %r9 # checks if mode is 2
        je      .SET_VOLTS_BITS
        movl    $1, %eax # if mode is not 1 or 2 then return 1
        ret
.SET_PERCENT_BIT:
        movl    $1, %edx # sets the 0th bit for percentage
        sall    $0, %edx
        orl     %edx, %r8d

        movq    %rdi, %r10 # moves batt_struct to %r10
        sarq    $16, %r10 # shift right by 16 to access percentage bits
        andq    $0xFF, %r10 # masks the 8 bits for percentage

        cmpq    $100, %r10 # checks if percentage is 100a
        je      .DISPLAY_100
        cmpq    $0, %r10 # checks if percentage is 0
        je      .DISPLAY_0
        cmpq    $10, %r10 # checks if percentage only has 1 digit 0-9
        jl      .ZERO_TO_10

        movq    %r10, %rax # sets %rax to percentage
        movq    $0, %rdx 
        cqto                # sets up division for 2nd digit
        movq    $10, %r11
        idivq   %r11 # percent / 10
        cqto    
        movq    $10, %r11
        idivq   %r11 # (percent / 10) % 10
        movl    (%rcx,%rdx,4), %edx # uses remainder to know which masks index to access
        sall    $10, %edx # shift left by 10 for 2nd digit
        orl     %edx, %r8d # ORs the mask into the display holder

        movq    %r10, %rax # resets %rax to percentage
        movq    $0, %rdx
        cqto                # sets up division for 3rd digit
        movq    $10, %r11
        idivq   %r11 # percent % 10
        movl    (%rcx,%rdx,4), %edx # uses remainder to know which masks index to access
        sall    $3, %edx # shift left by 3 for 3rd digit
        orl     %edx, %r8d # ORs the mask into the display holder

        jmp     .SET_BATT_METER_BITS
.DISPLAY_100:
        movl    $1, %edx # used to access masks index for 1
        movl    (%rcx,%rdx,4), %edx
        sall    $17, %edx # shift left by 17 for 1st digit
        orl     %edx, %r8d

        movl    $0, %edx # used to access masks index for 0
        movl    (%rcx,%rdx,4), %edx
        sall    $10, %edx # shift left by 10 for 2nd digit
        orl     %edx, %r8d

        movl    $0, %edx # used to access masks index for 0
        movl    (%rcx,%rdx,4), %edx
        sall    $3, %edx # shift left by 3 for 3rd digit
        orl     %edx, %r8d

        jmp     .SET_BATT_METER_BITS
.DISPLAY_0:
        movl    $0, %edx # used to access masks index for 0
        movl    (%rcx,%rdx,4), %edx
        sall    $3, %edx 
        orl     %edx, %r8d

        jmp     .SET_BATT_METER_BITS
.ZERO_TO_10:
        movl    %r10d, %eax
        movl    $0, %edx
        cqto    
        movl    $10, %r11d
        idivl   %r11d # percentage % 10
        movl    (%rcx,%rdx,4), %edx
        sall    $3, %edx
        orl     %edx, %r8d    
        
        jmp     .SET_BATT_METER_BITS
.SET_VOLTS_BITS:
        movl    $1, %edx # sets the 1st bit for volts
        sall    $1, %edx
        orl     %edx, %r8d
        movl    $1, %edx # sets 2nd bit for decimal
        sall    $2, %edx
        orl     %edx, %r8d

        movq    %rdi, %r10 # moves batt_struct to %r10
        sarq    $0, %r10 # shift right by 0 to access mlvolts bits
        andq    $0xFFFF, %r10 # masks the 16 bits for mlvolts
        addq    $5, %r10 # add 5 to mlvolts to help with rounding

        movl    %r10d, %eax
        movl    $0, %edx
        cqto
        movl    $1000, %r11d
        idivl   %r11d # mlvolts / 1000
        cqto    
        movl    $10, %r11d
        idivl   %r11d # (mlvolts / 1000) % 10
        movl    (%rcx,%rdx,4), %edx
        sall    $17, %edx # shift left by 17 for 1st digit
        orl     %edx, %r8d

        movl    %r10d, %eax
        movl    $0, %edx
        cqto
        movl    $100, %r11d
        idivl   %r11d # mlvolts / 100
        cqto    
        movl    $10, %r11d
        idivl   %r11d # (mlvolts / 100) % 10 
        movl    (%rcx,%rdx,4), %edx
        sall    $10, %edx # shift left by 10 for 1st digit
        orl     %edx, %r8d

        movl    %r10d, %eax
        movl    $0, %edx
        cqto
        movl    $10, %r11d
        idivl   %r11d # mlvolts / 10
        cqto    
        movl    $10, %r11d
        idivl   %r11d # (mlvolts / 10) % 10
        movl    (%rcx,%rdx,4), %edx
        sall    $3, %edx # shift left by 3 for 1st digit
        orl     %edx, %r8d
.SET_BATT_METER_BITS:
        movq    %rdi, %r10 # moves batt_struct to %r10
        sarq    $16, %r10 # shift right by 16 to access percentage bits
        andq    $0xFF, %r10 # masks the 8 bits for percentage

        # incrementally sets bits 24-28 depending on percentage level
        cmpq    $5, %r10 # percent < 5
        jl      .END_BATT_DISPLAY
        movl    $1, %edx
        sall    $24, %edx # sets 24th bit
        orl     %edx, %r8d
        cmpq    $29, %r10 # percent <= 29
        jl      .END_BATT_DISPLAY
        movl    $1, %edx
        sall    $25, %edx # sets 25th bit
        orl     %edx, %r8d
        cmpq    $49, %r10 # percent <= 49
        jl      .END_BATT_DISPLAY
        movl    $1, %edx
        sall    $26, %edx # sets 26th bit
        orl     %edx, %r8d
        cmpq    $69, %r10 # percent <= 69
        jl      .END_BATT_DISPLAY
        movl    $1, %edx
        sall    $27, %edx # sets 27th bit
        orl     %edx, %r8d
        cmpq    $89, %r10 # percent < 89
        jle      .END_BATT_DISPLAY
        movl    $1, %edx
        sall    $28, %edx # sets 28th bit
        orl     %edx, %r8d
.END_BATT_DISPLAY:
        movl    %r8d, (%rsi) # moves display holder into display pointer
        movl    $0, %eax
        ret
.text
.global batt_update
        
## ENTRY POINT FOR REQUIRED FUNCTION
batt_update:
	## assembly instructions here
        subq    $8, %rsp # subtracts 8 bytes for stack pointer
        movl    $0, 0(%rsp) # creates empty batt struct
        leaq    0(%rsp), %rdi # loads empty batt struct into arg 1
        call    set_batt_from_ports
        cmpl    $1, %eax # checks if function call returns 1 which means an error
        je      .ERROR
        movq    (%rdi), %rdi # loads batt_struct pointer into arg 1
        leaq    BATT_DISPLAY_PORT(%rip), %rsi # loads global variable into arg 2
        call    set_display_from_batt
        addq    $8, %rsp # restores stack pointer
        movl    $0, %eax
        ret
.ERROR:
        addq    $8, %rsp # restores stack pointer
        movl    $1, %eax
        ret