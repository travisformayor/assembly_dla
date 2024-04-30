; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/28/24
; Description: The UI Module. Contains functions to update the 
; screen by drawing each particle's current position.

.386P
.model flat

; Use constants file
include constants.inc

; External Module functions
extern write_string: near

.data
    ; External global particle variables
    extern xPositions:DWORD
    extern yPositions:DWORD
    extern particleStatus:DWORD

    ; UI variables
    particleIndex DWORD 0 ; current index position when looping particles
    screenBuffer BYTE xAxis * yAxis dup(' ') ; linear version of a 2D array, filled with spaces
    ; DLA Symbols
    stuckSymbol BYTE "o"  ; Unicode for Medium Black Circle
    unstuckSymbol BYTE "."  ; Unicode for Medium Black Circle

.code
; === void refresh_display() ===
; Description:
;   Sets up the screenBuffer by clearing it then adding the  border and newline 
;   characters, then loops each particle through render_particle. 
;   Finally it displays the updated screenBuffer
; Parameters: None, directly accesses global data
; Registers:
;   TODO
refresh_display PROC
    ; Set up the screen buffer first
    ; Fill it with space characters, then add borders and newline breaks
    mov ecx, xAxis * yAxis       ; Total number of characters in the buffer
    lea edi, [screenBuffer]      ; Pointer to the start of the buffer
    mov al, ' '                  ; Space character to fill the buffer
    rep stosb                    ; Fill the buffer with spaces

    ; Add a top border
    mov ecx, xAxis               ; Number of characters in the top row
    mov edi, offset screenBuffer ; Reset pointer to the start of the buffer
    mov al, '-'                  ; Character for top border
    rep stosb                    ; Fill the top row with '-'

    ; Add a '|' at the beginning and end of each row
    xor ecx, ecx                 ; Reset counter for rows
_add_borders:
    mov edi, offset screenBuffer ; Reset pointer to the start of the buffer
    mov eax, ecx
    imul eax, eax, xAxis         ; Calculate the starting index of the current row
    add edi, eax                 ; Move edi to the correct start of the row
    mov byte ptr [edi], '|'      ; Set first character of the row to '|'
    mov byte ptr [edi + xAxis - 2], '|' ; Set second to last character to '|'
    mov byte ptr [edi + xAxis - 1], 10 ; Set last character of the row to the newLine symbol
    inc ecx                      ; Increment row counter
    cmp ecx, yAxis               ; Compare row counter with the total number of rows
    jl _add_borders               ; Continue loop if more rows are left

    ; Add a bottom border
    mov edi, offset screenBuffer ; Reset pointer to the start of the buffer
    mov eax, yAxis
    dec eax                      ; Adjust for zero-based index
    imul eax, eax, xAxis         ; Calculate the starting index of the last row
    add edi, eax                 ; Move edi to the start of the last row
    mov ecx, xAxis               ; Number of characters in the bottom row
    mov al, '-'                  ; Character for bottom border
    rep stosb                    ; Fill the bottom row with '-'
    ; End setting up screenBuffer

    ; Loop each particle and add to the screenBuffer with render_particle
    mov particleIndex, 0            ; Initialize loop counter (particle index)

_loop_start:
    push particleIndex              ; Add index parameter to render_particle call
    call render_particle              ; Draw the particle at the index

    inc particleIndex               ; Increment the particle index
    cmp particleIndex, numParticles ; Compare current index with total particles
    jl _loop_start                   ; Loop until all particles are processed

    ; Write the entire screen buffer to the console
    pusha                   ; TODO: what? Save all registers
    lea eax, [screenBuffer]
    mov ecx, xAxis * yAxis  ; Number of characters in the buffer
    push ecx                ; Number of characters to write
    push eax                ; Address of the buffer
    call write_string       ; Output the buffer
    popa                    ; Restore all registers
    ret

    ret
refresh_display ENDP

; === void render_particle(index: DWORD) ===
; Description:
;   Includes a particle into the screenBuffer at it's current location and
;   with a symbol indicating it's status (stuck or unstuck)
; Parameters: index (DWORD) of the particle in arrays
; Registers:
;   EAX - Index of the particle
;   EBX - x position of the particle
;   ECX - y position of the particle
;   EDX - Used for status character
;   ESI - Used for linear index of 2D location in screenBuffer
render_particle PROC
    pop edx             ; Retrieve the return address
    pop eax             ; Get the index of the particle
    push edx            ; Restore the return address for ret

    ; Get the x and y position of the particle from the arrays
    mov ebx, [xPositions + eax*4]  ; Multiply index by 4 because it's a DWORD array
    mov ecx, [yPositions + eax*4]

    ; Store the particles status character in dl
    xor edx, edx                            ; Zero out EDX. DL is the lower 8-bits of EDX
    mov dl, byte ptr [particleStatus + eax] ; Load the status byte at the index into dl

    cmp dl, 0               ; Compare if particle is unstuck (0)
    je _display_unstuck
    mov dl, stuckSymbol     ; Replace 1 with char for stuck particle
    jmp _update_buffer

_display_unstuck:
    mov dl, unstuckSymbol   ; Replace 0 with char for unstuck particle

_update_buffer:
    ; Calculate index for a linear version of a 2D array
    ; Linear Index = (Y * W) + X 
    mov esi, ecx                   ; Store y position in ESI
    imul esi, esi, xAxis           ; ESI = y * width
    add esi, ebx                   ; ESI = y * width + x
    mov [screenBuffer + esi], dl   ; Place character at screenBuffer index

    ret
render_particle ENDP

END