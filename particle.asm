; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Particle Module. Contains functions to setup particle
; initial conditions and wiggle and update particle status (stuck or unstuck).

.386P
.model flat

; Use constants file
include constants.inc

; External Module functions
extern random_num: near
extern write_string: near
extern write_integer: near
extern new_line: near

.data
    ; External global particle variables
    extern xPositions:DWORD
    extern yPositions:DWORD
    extern particleStatus:DWORD

.code
; === void init_particles() ===
; Description:
;   Loops through all particles and sets their initial positions within the grid
;   Sets one particle (the first one) as stuck to act as the growth starting point
; Parameters: None, directly modifies global data
; Registers:
;   EAX - Used to store random values for positions
;   EBX - Used as counter for loop iterations
;   EDX - Return address
init_particles PROC
    ; Loop all the particle array variables
    xor ebx, ebx    ; EBX = 0 (loop counter)

_loop_start:
    ; Generate random x position
    mov eax, xAxis 
    sub eax, 3      ; xAxis - 3: remove for 0 index, border, and newLine char
    push eax
    call random_num ; Returns random number in EAX
    mov [xPositions + ebx*4], eax  ; Store x position in array

    ; Generate random y position
    mov eax, yAxis 
    sub eax, 2      ; yAxis - 2: remove for 0 index and border
    push eax
    call random_num ; Returns random number in EAX
    mov [yPositions + ebx*4], eax  ; Store y position in array

    ; Increment loop counter and compare to total particles
    inc ebx
    cmp ebx, numParticles
    jl _loop_start   ; If less than, continue loop

    ; Set the first particle as stuck
    mov byte ptr [particleStatus], 1

    ret
init_particles ENDP

; === VOID random_wiggle(particle_index: DWORD) ===
; Description:
;   Performs random 1 position movement for a particle
;   Then checks if the particle is now touching a stuck status particle
;   If so, sets particle status as stuck as well
; Parameters: Particle index
; Return: None, directly updates global data
; Registers:

random_wiggle PROC
    ; Handle return address and parameters
    pop edx             ; Pop return address off the stack
    pop ebx             ; Pop particle index into EBX
    push edx            ; Push return address back onto the stack for ret

    ; Pick a random movement direction(1 = up, 2 = down, 3 = left, 4 = right)
    push 4              ; 4 possible directions
    call random_num     ; Call random_num to get a direction, result in EAX
    ; add esp, 4          ; Clean up the stack after call

    ; Compare to determin which direction was picked
    cmp eax, 1
    je _move_up
    cmp eax, 2
    je _move_down
    cmp eax, 3
    je _move_left
    cmp eax, 4
    je _move_right
    ; jmp _dont_move

_move_up: ; Move particle up
    mov ecx, [yPositions + ebx*4]  ; Load current y-coordinate into ECX
    dec ecx                        ; Decrement y to move up (grid printed top-down)
    cmp ecx, 1                     ; Check if move is out-of-bounds
    jl _dont_move                   ; Stop if new y < 1 (row 0 is the border)
    mov [yPositions + ebx*4], ecx  ; Safe to move. Update y-value
    jmp _check_stuck                ; Check if touching a stuck particle

_move_down: ; Move particle down
    mov ecx, [yPositions + ebx*4]  ; Load current y-coordinate into ECX
    inc ecx                        ; Increment y to move down
    cmp ecx, yAxis - 1             ; Check if move is out-of-bounds
    jge _dont_move                  ; Stop if new y >= yAxis-1 (last row is the border)
    mov [yPositions + ebx*4], ecx  ; Safe to move. Update y-value
    jmp _check_stuck                ; Check if touching a stuck particle

_move_left: ; Move particle left
    mov ecx, [xPositions + ebx*4]  ; Load current x-coordinate into ECX
    dec ecx                        ; Decrement x to move left
    cmp ecx, 1                     ; Check if move is out-of-bounds
    jl _dont_move                   ; Stop if new x < 1 (column 0 is the border)
    mov [xPositions + ebx*4], ecx  ; Safe to move. Update x-value
    jmp _check_stuck                ; Check if touching a stuck particle

_move_right: ; Move particle right
    mov ecx, [xPositions + ebx*4]  ; Load current x-coordinate into ECX
    inc ecx                        ; Increment x to move right
    cmp ecx, xAxis - 2             ; Check if move is out-of-bounds
    jge _dont_move                  ; Stop if new x >= xAxis-2 (last 2 column used (border, newlin))
    mov [xPositions + ebx*4], ecx  ; Safe to move. Update x-value
    jmp _check_stuck                ; Check if touching a stuck particle

_check_stuck:
    ; TODO
    ; ; Check adjacent positions for stuck particles (assuming grid as linear array)
    ; ; This requires handling to convert 2D checks to linear array indexing
    ; ; Assume function 'is_adjacent_stuck' performs this check
    ; push ebx             ; Save index
    ; call is_adjacent_stuck
    ; pop ebx              ; Restore index
    ; cmp eax, 1
    ; je make_stuck
    ; jmp _dont_move

; make_stuck:
;     mov byte ptr [particleStatus + ebx], 1   ; Set current particle as stuck

_dont_move:
    ret                 ; Return to caller
random_wiggle ENDP

END