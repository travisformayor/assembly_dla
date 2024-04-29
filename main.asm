; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/27/24
; Description: The Main Module. Calls setting initial state of 
; the particles, then loops to update positions and refresh the display.

.386P
.model flat

; Use constants file
include constants.inc

; External Windows functions
extern _GetStdHandle@4: near    ; For console_log
extern _WriteConsoleA@20: near  ; For console_log
extern _ExitProcess@4: near
; External Module functions
extern init_particles: near
extern refresh_display: near
; extern random_num: near
; extern write_integer: near
; extern new_line: near


; Global variables
.data
    ; outputHandle  dd ?    ; Console output handle
    testMsg    db "Test Message", 10, 0 ; Test message. adding a 10 creates a newline

    xPositions DWORD numParticles dup(?) ; array of x position for each particle
    yPositions DWORD numParticles dup(?) ; array of y position for each particle
    particleStatus BYTE numParticles dup(0) ; array of particle satus. 0 = unstuck (default), 1 = stuck

    ; Set vars public so particle.asm and ui.asm can access them
    public xPositions
    public yPositions
    public particleStatus

.code
; === void main() ===
; Description:
;   Calls init_particles, then loops main_loop to grow and update display
; Registers:
;   EBX - Loop counter for particles
main PROC near
_main:
  
    call init_particles     ; Setup particle starting positions and status

    call refresh_display    ; Display initial particles

    push 0                  ; Exit code
    call _ExitProcess@4     ; Exit the program


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