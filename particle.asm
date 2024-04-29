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

loop_start:
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
    jl loop_start   ; If less than, continue loop

    ; Set the first particle as stuck
    mov byte ptr [particleStatus], 1

    ret
init_particles ENDP

; === void random_wiggle(particle_index: DWORD) ===
; Description:
;   Performs random 1 position movement for a particle
;   Then checks if the particle is now touching a stuck status particle
;   If so, sets particle status as stuck as well
; Parameters: particle index
; Registers:
;   EAX - Particle index for accessing particle data
;   EBX - Used for random movement decisions
;   ECX - Loop counter
;   EDX - Return address
random_wiggle PROC
    pop edx         ; Save the return address
    pop eax         ; Save the particle index in EAX
    push edx        ; Restore return address

    ret
random_wiggle ENDP

END