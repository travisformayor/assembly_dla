; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Particle Module. Contains functions to setup particle
; initial conditions and wiggle and update particle status (stuck or unstuck)

.386P
.model flat

.code
; === void init_particles() ===
; Description:
;   Loop the particles and initialize positions
;   Set one particle as stuck to act as the growth starting point
; Parameters: None, directly modifies global data
; Registers:
;   EAX - Used to store random values for positions
;   EBX - Used as counter for loop iterations
;   EDX - Return pointer
;   ESI - Index for the particle initially set as stuck
init_particles PROC

    ret
init_particles ENDP

; === void random_wiggle(particle_index: WORD) ===
; Description:
;   Performs random 1 position movement for a particle
;   Then checks if the particle is now touching a stuck status particle
;   If so, sets particle status as stuck as well
; Parameters: particle index
; Registers:
;   EAX - Particle index for accessing particle data
;   EBX - Used for random movement decisions
;   ECX - Loop counter
;   EDX - Return pointer
random_wiggle PROC
    pop edx         ; Save the return address
    pop eax         ; Save the particle index in EAX
    push edx        ; Restore return address

    ret
random_wiggle ENDP
