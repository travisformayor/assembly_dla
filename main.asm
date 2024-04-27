; Travis Uhrig
; CSC2025 Final Project
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The main module. Manages setting initial state of 
; all the particles, and updates positions and refreshes the display

.386P
.model flat

; External functions
extern   _ExitProcess@4: near

; Program variables
.data
    ; Particle Arrays
    xPositions WORD 1000 dup(?) ; x position for each particle
    yPositions WORD 1000 dup(?) ; y position for each particle
    particleStates BYTE 1000 dup(0) ; 0 = unstuck, 1 = stuck. Start all as unstuck.
    totalUnstuckParticles WORD 1000 ; Track how many particles are still unstuck
    particleIndex WORD 0 ; current index position when looping particles

.code
main PROC near
; Registers:
;   EBX - Loop counter for particles
;   EDX - Temporary storage
; Description
;   Calls init_particles, then loops main_loop grow DLA
_main:

_main_loop:
    ; Updates all particle positions and states
    ; Refreshes the display

_end_main_loop:

    ; TODO: Listen for a keypress to exit the program
    ; push  0
    ; call  _ExitProcess@4

main ENDP

init_particles PROC near
; void init_particles()
; Registers:
;   EAX - Used to store random values for positions
;   EBX - Used as counter for loop iterations
; Description:
;   Loop the particles and initialize positions
;   Set one particle as stuck to act as the growth starting point
;   No parameters expected, directly modifies global data
_init_particles:

init_particles ENDP

END