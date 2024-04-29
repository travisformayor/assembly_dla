; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Main Module. Calls setting initial state of 
; the particles, then loops to update positions and refresh the display.

.386P
.model flat

; External Windows functions
extern _GetStdHandle@4: near    ; For console_log
extern _WriteConsoleA@20: near  ; For console_log
extern _ExitProcess@4: near
; External Module functions
extern random_num: near
extern write_integer: near
extern write_string: near
extern new_line: near

; Global variables
.data
    ; Particle varaibles
    xPositions DWORD 1000 dup(?) ; array of x position for each particle
    yPositions DWORD 1000 dup(?) ; array of y position for each particle
    particleStatus BYTE 1000 dup(0) ; array of particle satus. 0 = unstuck (default), 1 = stuck
    totalUnstuckParticles DWORD 1000 ; Track how many particles are still unstuck
    particleIndex DWORD 0 ; current index position when looping particles

    ; outputHandle  dd ?    ; Console output handle
    testMsg    db "Test Message", 10, 0 ; Test message. adding a 10 creates a newline


.code
; === void main() ===
; Description:
;   Calls init_particles, then loops main_loop to grow and update display
; Registers:
;   EBX - Loop counter for particles
main PROC near
_main:
    ; Testing console output
    push 50
    call random_num ; Result is stored in ebx
    push ebx
    call write_integer
    
    call new_line

    push 0              ; Exit code
    call _ExitProcess@4 ; Exit the program


    ; program area:
	; call init_particles in particle module

_main_loop:
    ; Loop all particles calling random_wiggle to update position and status
    ; call refresh_display in the UI module to update the display
    ; pause between loops to animate grow

_end_main_loop:

    ; TODO: Listen for a keypress to exit the program
    ; push  0
    ; call  _ExitProcess@4

main ENDP

END