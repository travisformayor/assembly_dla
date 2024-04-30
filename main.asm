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
extern _ExitProcess@4: near
extern _Sleep@4: near
extern _GetStdHandle@4: near
extern _SetConsoleCursorPosition@8: near

; External Module functions
extern init_particles: near
extern refresh_display: near
extern random_wiggle: near
; extern random_num: near
; extern write_string: near
; extern new_line: near


; Global variables
.data
    ; outputHandle  dd ?    ; Console output handle
    testMsg    db "Test Message", 10, 0 ; Test message. adding a 10 creates a newline
    newMsg    db "New********", 10, 0 ; Test message. adding a 10 creates a newline
    outputHandle dd 0

    xPositions DWORD numParticles dup(?) ; array of x position for each particle
    yPositions DWORD numParticles dup(?) ; array of y position for each particle
    particleStatus BYTE numParticles dup(0) ; array of particle satus. 0 = unstuck (default), 1 = stuck
    particleIndex DWORD 0 ; current index position when looping particles

    wiggleIndex DWORD 0 ; current loop count as particles wiggle

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
    ; Setup the console output handle
    push -11
    call _GetStdHandle@4
    mov outputHandle, eax
  
    call init_particles     ; Setup particle starting positions and status

    call refresh_display    ; Display initial particles

    ; Call Sleep to pause (1000 milliseconds = 1 second)
    push 1000      ; Push the number of milliseconds to sleep
    call _Sleep@4  ; Call the Sleep function
    
    ; Start looping particle wiggle updates
    mov wiggleIndex, 0            ; Initialize main_loop counter
_main_loop:
    ; Loop all particles calling random_wiggle to update position and status
    ; call refresh_display in the UI module to update the display
    ; pause between loops to animate grow

    ; -- Reset the cursor to the start to overwrite the grid
    ; Set the cursor position to (0, 0)
    push 0          ; Y coordinate
    push 0          ; X coordinate
    push outputHandle
    call _SetConsoleCursorPosition@8
    ; -- Finish cursor reset

    ; Wiggle all of the particles once
    ; Loop each particle and add to the screenBuffer with draw_particle
    mov particleIndex, 0            ; Initialize particle loop counter

_loop_particles:
    push particleIndex              ; Add index parameter to draw_particle call
    call random_wiggle              ; Wiggle each particle one at a time

    inc particleIndex               ; Increment the particle index
    cmp particleIndex, numParticles ; Compare current index with total particles
    jl _loop_particles               ; Loop until all particles are processed
_end_particle_loop:

    call refresh_display    ; Display updated particles

    ; Call Sleep to pause (1000 milliseconds = 1 second)
    push 1000      ; Push the number of milliseconds to sleep
    call _Sleep@4  ; Call the Sleep function

    
    inc wiggleIndex               ; Increment the loop counter index
    cmp wiggleIndex, 10 ; Compare current index with loop goal
    jl _main_loop               ; Loop until all particles are processed

_end_main_loop:

    ; TODO: Listen for a keypress to exit the program
    push 0                  ; Exit code
    call _ExitProcess@4     ; Exit the program

main ENDP

END