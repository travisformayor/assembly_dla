; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Particle Module. Contains functions to setup particle
; initial conditions and wiggle and update particle status (stuck or unstuck).

.386P
.model flat

; External Module functions
extern random_num: near

.data
    ; Set constants
    xAxis EQU 500       ; Size of the grid's x-axis
    yAxis EQU 500       ; Size of the grid's y-axis
    numParticles EQU 10 ; Number of particles

    xPositions DWORD numParticles dup(?) ; array of x position for each particle
    yPositions DWORD numParticles dup(?) ; array of y position for each particle
    particleStatus BYTE numParticles dup(0) ; array of particle satus. 0 = unstuck (default), 1 = stuck
    ; totalUnstuckParticles DWORD 1000 ; Track how many particles are still unstuck
    ; particleIndex DWORD 0 ; current index position when looping particles

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
    pop edx         ; Save the return address
    push edx        ; Restore return address

    ; Loop all the particle array variables
    xor ebx, ebx    ; EBX = 0 (loop counter)

loop_start:
    ; Generate random x position
    push xAxis      ; Push max_range parameter for random_num
    call random_num ; Returns random number in EAX
    mov [xPositions + ebx*4], eax  ; Store x position in array

    ; Generate random y position
    push yAxis     ; Push max_range parameter for random_num
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