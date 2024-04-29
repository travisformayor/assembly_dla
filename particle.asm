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
extern write_string: near

.data
    ; Set constants
    xAxis EQU 50       ; Size of the grid's x-axis
    yAxis EQU 50       ; Size of the grid's y-axis
    numParticles EQU 10 ; Number of particles

    xPositions DWORD numParticles dup(?) ; array of x position for each particle
    yPositions DWORD numParticles dup(?) ; array of y position for each particle
    particleStatus BYTE numParticles dup(0) ; array of particle satus. 0 = unstuck (default), 1 = stuck
    particleIndex DWORD 0 ; current index position when looping particles
    ; totalUnstuckParticles DWORD 1000 ; Track how many particles are still unstuck

    screenBuffer BYTE xAxis * yAxis dup(' ') ; Initialize buffer with spaces

.code
; Sets up the screen buffer by filling it with space characters and adding border
init_screen_buffer PROC
    mov ecx, xAxis * yAxis       ; Total number of characters in the buffer
    lea edi, [screenBuffer]      ; Pointer to the start of the buffer
    mov al, ' '                  ; Space character to fill the buffer
    rep stosb                    ; Fill the buffer with spaces
    ret
init_screen_buffer ENDP

; Draws a single particle and its status into the buffer at its position
; Parameters: index (DWORD) of the particle in arrays
; Registers:
;   EAX - Index of the particle
;   EBX - x position of the particle
;   ECX - y position of the particle
;   EDX - Used for status character
;   ESI - Used for linear index of 2D location in screenBuffer
draw_particle PROC
    pop edx             ; Retrieve the return address
    pop eax             ; Get the index of the particle
    push edx            ; Restore the return address for ret

    ; Get the x and y position of the particle from the arrays
    mov ebx, [xPositions + eax*4]  ; Multiply index by 4 because it's a DWORD array
    mov ecx, [yPositions + eax*4]

    ; Store the particles status character in dl
    xor edx, edx                   ; Zero out EDX. DL is the lower 8-bits of EDX
    mov dl, [particleStatus + eax] ; Retrieve the the status byte (0 or 1)
    cmp dl, 0                      ; Compare if particle is unstuck (0)
    je display_unstuck
    mov dl, '*'                    ; Replace 1 with char for stuck particle
    jmp update_buffer

display_unstuck:
    mov dl, '-'                    ; Replace 0 with char for unstuck particle

update_buffer:
    ; Calculate index for a linear version of a 2D array
    ; Linear Index = (Y * W) + X 
    mov esi, ecx                   ; Store y position in ESI
    imul esi, esi, xAxis           ; ESI = y * width
    add esi, ebx                   ; ESI = y * width + x
    mov [screenBuffer + esi], dl   ; Place character in buffer at index

    ret
draw_particle ENDP

; Writes the entire screen buffer to the console
write_screen_buffer PROC
    pusha                   ; Save all registers
    lea eax, [screenBuffer]
    mov ecx, xAxis * yAxis  ; Number of characters in the buffer
    push ecx                ; Number of characters to write
    push eax                ; Address of the buffer
    call write_string       ; Output the buffer
    popa                    ; Restore all registers
    ret
write_screen_buffer ENDP

; Refreshes the display based on current particle states
refresh_display PROC
    call init_screen_buffer        ; Clear the screen buffer before updating

    mov particleIndex, 0            ; Initialize loop counter (particle index)

loop_start:
    push particleIndex              ; Add index parameter to draw_particle call
    call draw_particle              ; Draw the particle at the index

    inc particleIndex               ; Increment the particle index
    cmp particleIndex, numParticles ; Compare current index with total particles
    jl loop_start                   ; Loop until all particles are processed

    call write_screen_buffer        ; Write the entire updated buffer to the console

    ret
refresh_display ENDP

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