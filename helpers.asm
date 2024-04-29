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
;   Generates a random number within 0 to max_range
; Parameters: Maximum end of the range (min is default 0)
; Return: Random number within the range, as EBX
; Registers:
;   EAX - Maximum range for the random number
;   EBX - Random number generated (return value)
;   EDX - Return address
;   ECX - Seed address for RtlRandom
random_num PROC
    pop edx             ; Save the return address
    pop eax             ; Save maximum range in EAX
    push edx            ; Restore return address

    lea ecx, seed       ; Load the address of the seed
    push ecx            ; Push the address of the seed
    call _RtlRandomEx@4 ; Call RtlRandomEx
    ; Now EAX holds the random number

    ; If the maximum range is provided, calculate the number within the range
    test eax, eax       ; Check if EAX is zero to avoid division error
    jz finished
    inc eax             ; Ensure range is inclusive of max_range
    xor edx, edx        ; Clear EDX before division
    div dword ptr [esp+4] ; Divide EAX by the value at ESP+4 (max_range) safely

finished:
    mov ebx, eax        ; Move the result to EBX for return
    ret
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
    call check_console_output   ; Make sure output handler is setup

    pop edx                     ; Retrieve the return address
    pop eax                     ; Get the integer to convert
    push edx                    ; Restore the return address

    sub esp, 12                 ; Allocate buffer for string conversion
    lea ebx, [esp + 11]         ; Set EBX to the end of the buffer

    mov ecx, 10                 ; Set base 10 for conversion

convert_loop:
    xor edx, edx                ; Clear EDX for div
    div ecx                     ; Divide EAX by 10, remainder in EDX
    add dl, '0'                 ; Convert remainder to ASCII character
    dec ebx                     ; Move back in the buffer
    mov [ebx], dl               ; Store ASCII character
    test eax, eax               ; Check if more digits remain
    jnz convert_loop            ; Continue if there are more digits

    ; Calculate the length of the string
    lea eax, [ebx]              ; Set EAX to the start of the numeric string
    mov ecx, esp                ; ECX points to the start of the buffer
    add ecx, 12                 ; Adjust ECX to the end of the buffer space
    dec ecx                     ; Move back to the last character (null terminator)
    sub ecx, eax                ; Calculate the length of the string
    push ecx                    ; Number of characters to write
    push eax                    ; Address of the string
    call write_string           ; Output the string
    add esp, 12                 ; Clean up the buffer space

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
    call check_console_output   ; Make sure output handler is setup

    pop edx                     ; Retrieve the return address
    pop ecx                     ; Get the address of the string
    pop eax                     ; Get the number of characters
    push edx                    ; Restore the return address for ret

    push 0                      ; Null for WriteConsoleA
    push offset written         ; Logging num chars written (required)
    push eax                    ; Number of characters to write
    push ecx                    ; String to write
    push outputHandle
    call _WriteConsoleA@20

    ret
write_string ENDP

; === void check_console_output() ===
; Description:
;   Set the console output handle if it hasn't already be set
; Parameters: None
; Registers:
;   EAX - Testing outputHandle and saving the handler
check_console_output PROC
    ; Check if the output handle is already set up
    mov eax, outputHandle       ; Load the current value of outputHandle
    test eax, eax               ; Test is outputHandle is not zero
    jnz output_already_set      ; If not zero, output is already set, skip the rest

    ; If outputHandle is zero, get and save the output handle
    push -11                    ; -11 = standard output handle constant
    call _GetStdHandle@4
    mov outputHandle, eax

output_already_set:
    ret
check_console_output ENDP

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