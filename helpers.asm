; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/28/24
; Description: The Helpers Module. Contains helper utility functions.

.386P
.model flat

includelib ntdll.lib

extern _RtlRandomEx@4:near      ; For random_num (Rtl = Run-Time Library)
extern _GetStdHandle@4: near    ; For console_log
extern _WriteConsoleA@20: near  ; For console_log

.data
    seed dd 12345678h       ; Seed value for RtlRandomEx     
    outputHandle  dd 0      ; Console output habndler
    written       dd ?      ; Number of characters written to the console
    newLine       db 10     ; 10 = "\n" character which creates a newline

.code
; === DWORD random_num(max_range: DWORD) ===
; Description:
;   Generates a random number from 1 to max_range
;   Result can include 1 or max_range
; Parameters: Maximum end of the range (min is 1)
; Return: Random number within the range, returned in EBX
; Registers:
;   EAX - Unscaled random number, then used to return scaled random number returned
;   ECX - The max_range for use during division
;   EDX - Stores return address, then stores the division remainder
random_num PROC
    ; RtlRandom modifies EAX, ECX, and EDX so needs to be called before saving parameters
    ; RtlRandom saves the unscaled random number in EAX
    push offset seed    ; Push the address of the seed for RtlRandomEx
    call _RtlRandomEx@4 ; RtlRandomEx is called, cleans up its parameter (the pushed seed)

    ; Now can access the parameter
    pop edx             ; Pop return address off the stack
    pop ecx             ; Pop max_range parameter into ECX
    push edx            ; Push return address back onto the stack for ret

    ; Scale the random number (EAX) by dividing it by max range (ECX)
    ; The remainder is the scaled result
    xor edx, edx        ; Clear EDX for division
    div ecx             ; Divide EAX by ECX, result in EAX, remainder in EDX

    inc edx             ; +1 to return a value between 1 and max_range
    mov eax, edx        ; Move remainder to EAX to return the scaled random number
    ret                 ; Return to caller
random_num ENDP

; === void write_integer(integer: DWORD) ===
; Description:
;   Writes an integer to the console by first converting it to a string
; Parameters:
;   integer - Integer to convert and write
; Registers:
;   EAX - Integer to convert and used in division
;   EBX - ASCII conversion and stores start of the string
;   ECX - Calculate the string length
;   EDX - Return address and division remainder
write_integer PROC
    pop edx                 ; Retrieve the return address from the stack
    pop eax                 ; Get the integer to convert from the stack
    push edx                ; Add the return address back to the stack for ret

    sub esp, 12             ; Allocate buffer for string conversion
    lea ebx, [esp + 11]     ; Set EBX to the end of the buffer

    mov ecx, 10             ; Set base 10 for conversion

convert_loop:
    xor edx, edx            ; Clear EDX for div
    div ecx                 ; Divide EAX by 10, remainder in EDX
    add dl, '0'             ; Convert remainder to ASCII character
    dec ebx                 ; Move back in the buffer
    mov [ebx], dl           ; Store ASCII character
    test eax, eax           ; Check if more digits remain
    jnz convert_loop        ; Continue if there are more digits

    ; Calculate the length of the string
    lea eax, [ebx]          ; Set EAX to the start of the numeric string
    mov ecx, esp            ; ECX points to the start of the buffer
    add ecx, 12             ; Adjust ECX to the end of the buffer space
    dec ecx                 ; Move back to the last character (null terminator)
    sub ecx, eax            ; Calculate the length of the string
    push ecx                ; Number of characters to write
    push eax                ; Address of the string
    call write_string       ; Output the string
    add esp, 12             ; Clean up the buffer space

    ret
write_integer ENDP

; === void write_string(string_address: DWORD, num_chars: DWORD) ===
; Description:
;   Writes a string to the console
; Parameters:
;   string_address - Address of the string to write
;   num_chars - Number of characters to write
; Registers:
;   EAX - Used for storing the output handle
;   ECX - Address of the string
;   EDX - Return address
write_string PROC near
    ; Check if the output handle is set up
    mov eax, outputHandle       ; Load the current value of outputHandle
    test eax, eax               ; Test is outputHandle is not zero
    jnz output_already_set      ; If not zero, output is already set, skip the rest

    ; If outputHandle is zero, get and save the output handle
    push -11                    ; -11 = standard output handle constant
    call _GetStdHandle@4
    mov outputHandle, eax
output_already_set:

    pop edx                 ; Retrieve the return address
    pop ecx                 ; Get the address of the string
    pop eax                 ; Get the number of characters
    push edx                ; Restore the return address for ret

    push 0                  ; Null for WriteConsoleA
    push offset written     ; Logging num chars written (required)
    push eax                ; Number of characters to write
    push ecx                ; String to write
    push outputHandle
    call _WriteConsoleA@20

    ret
write_string ENDP

; === void new_line() ===
; Description:
;   Outputs a newline character to the console
; Parameters: None
; Registers: None
new_line PROC
    push 1                  ; newline character has a length of 1
    push offset newLine     ; Push address of the newline string
    call write_string 
    ret
new_line ENDP

END