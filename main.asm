; Travis Uhrig
; CSC2025 Final Project
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Main Module. Calls setting initial state of 
; the particles, then loops to update positions and refresh the display

.386P
.model flat

; External functions
extern   _ExitProcess@4: near

; Program variables
.data
    ; Particle Arrays
    xPositions WORD 1000 dup(?) ; x position for each particle
    yPositions WORD 1000 dup(?) ; y position for each particle
    particleStatus BYTE 1000 dup(0) ; 0 = unstuck, 1 = stuck. Start all as unstuck.
    totalUnstuckParticles WORD 1000 ; Track how many particles are still unstuck
    particleIndex WORD 0 ; current index position when looping particles

.code
; void main()
; Description:
;   Calls init_particles, then loops main_loop grow and update display
; Registers:
;   EBX - Loop counter for particles
;   EDX - Temporary storage
main PROC near
_main:
	; call init_particles in particle module

_main_loop:
    ; Loop all particles calling random_wiggle to update position and status
    ; call refresh_display in the UI module to update the display

_end_main_loop:

    ; TODO: Listen for a keypress to exit the program
    ; push  0
    ; call  _ExitProcess@4

main ENDP

END