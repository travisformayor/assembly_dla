; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/28/24
; Description: The Helpers Module. Contains helper utility functions

.386P
.model flat

.code
; === WORD random_num(max_range: WORD) ===
; Description: 
;   Generates a random number within a specified range
;   Parameters: Maximum end of the range (min is 0)
;   Return: Randomly selected number (within the range)
; Registers:
;   EAX - Maximum range for the random number
;   EBX - Random number generated (return value)
;   EDX - Temporary storage for return pointer
random_num PROC
    pop edx         ; Save the return address
    pop eax         ; Save maximum range in EAX
    push edx        ; Restore return address

    ; Generate a random number and store in EBX

    ret
random_num ENDP
