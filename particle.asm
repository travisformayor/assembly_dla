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
    extern stuckCount:DWORD

    particleIndex DWORD 0 ; current index position when looping particles

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
    ; xor particleIndex, particleIndex    ; particleIndex = 0 (loop counter)
    mov particleIndex, 0  ; Particle loop counter = 0
    mov ebx, [particleIndex]  ; Save particleIndex to EBX

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

    ; Overwrite the first particle. Center it and set to stuck
    mov byte ptr [particleStatus], 1 ; Set the first particle as stuck
    inc stuckCount
    ; Set the stuck particle in the middle of the grid
    mov eax, xAxis      ; Load xAxis into eax
    xor edx, edx        ; Clear edx for division
    mov ecx, 2          ; Set divisor to 2
    div ecx             ; result in eax, remainder in edx
    mov [xPositions + 0*4], eax  ; Set x to the middle of the grid
    mov eax, yAxis      ; Load xAxis into eax
    xor edx, edx        ; Clear edx for division
    mov ecx, 2          ; Set divisor to 2
    div ecx             ; result in eax, remainder in edx
    mov [yPositions + 0*4], eax  ; Set y to the middle of the grid

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
;   EAX - 
random_wiggle PROC
    ; Handle return address and parameters
    pop edx             ; Pop return address off the stack
    pop ebx             ; Pop particle index into EBX
    push edx            ; Push return address back onto the stack for ret

    ; Skip moving the particle if stuck
    mov al, byte ptr [particleStatus + ebx]  ; Load the status byte at the index into dl
    cmp al, 1                      ; Compare if particle is unstuck (0)
    je _dont_move

    mov particleIndex, ebx ; Save particleIndex to protect the value

    ; Pick a random movement direction(1 = up, 2 = down, 3 = left, 4 = right)
    push 4              ; 4 possible directions
    call random_num     ; Call random_num to get a direction, result in EAX
    ; add esp, 4          ; Clean up the stack after call

    ; Compare to determine which direction was picked
    cmp eax, 1
    je _move_up
    cmp eax, 2
    je _move_down
    cmp eax, 3
    je _move_left
    cmp eax, 4
    je _move_right

_move_up: ; Move particle up
    mov ebx, [particleIndex]  ; Save particleIndex to EBX
    mov ecx, [yPositions + ebx*4]  ; Load current y-coordinate into ECX
    dec ecx                        ; Decrement y to move up (grid printed top-down)
    cmp ecx, 1                     ; Check if move is out-of-bounds
    jl _dont_move                  ; Stop if new y < 1 (row 0 is the border)
    mov [yPositions + ebx*4], ecx  ; Safe to move. Update y-value
    jmp _check_stuck               ; Check if touching a stuck particle

_move_down: ; Move particle down
    mov ebx, [particleIndex]  ; Save particleIndex to EBX
    mov ecx, [yPositions + ebx*4]  ; Load current y-coordinate into ECX
    inc ecx                        ; Increment y to move down
    cmp ecx, yAxis - 1             ; Check if move is out-of-bounds
    jge _dont_move                 ; Stop if new y >= yAxis-1 (last row is the border)
    mov [yPositions + ebx*4], ecx  ; Safe to move. Update y-value
    jmp _check_stuck               ; Check if touching a stuck particle

_move_left: ; Move particle left
    mov ebx, [particleIndex]  ; Save particleIndex to EBX
    mov ecx, [xPositions + ebx*4]  ; Load current x-coordinate into ECX
    dec ecx                        ; Decrement x to move left
    cmp ecx, 1                     ; Check if move is out-of-bounds
    jl _dont_move                  ; Stop if new x < 1 (column 0 is the border)
    mov [xPositions + ebx*4], ecx  ; Safe to move. Update x-value
    jmp _check_stuck               ; Check if touching a stuck particle

_move_right: ; Move particle right
    mov ebx, [particleIndex]  ; Save particleIndex to EBX
    mov ecx, [xPositions + ebx*4]  ; Load current x-coordinate into ECX
    inc ecx                        ; Increment x to move right
    cmp ecx, xAxis - 2             ; Check if move is out-of-bounds
    jge _dont_move                 ; Stop if new x >= xAxis-2 (last columns are border and newline)
    mov [xPositions + ebx*4], ecx  ; Safe to move. Update x-value
    jmp _check_stuck               ; Check if touching a stuck particle

_check_stuck:
    ; Check if the particle is touching a stuck particles
    push particleIndex                       ; Pass particle index
    call check_touching
    ; pop particleIndex                        ; Restore index
    cmp eax, 1                     ; Check if any adjacent particles are stuck
    jne _dont_stick

    ; Set the particle as stuck
    mov ebx, [particleIndex]  ; Save particleIndex to EBX
    mov byte ptr [particleStatus + ebx], 1  ; Set the status at index EBX to 1 (stuck)
    inc stuckCount

_dont_stick:

_dont_move:
    ret                              ; Return to caller
random_wiggle ENDP

; === BOOL check_touching(particle_index: DWORD) ===
; Description:
;   Checks if any adjacent particles (up, down, left, right) are stuck
; Parameters: Particle index
; Return: 1 if any adjacent particle is stuck, otherwise 0
; Registers:
;   EAX - Returned bool from "is_stuck?", returned bool for this function
;   EBX - x position for each checked particle
;   ECX - Loop index for checking all particles
;   EDX - y position for each checked particle
check_touching PROC
    ; Load particle index into EBX
    pop ebx                  ; Pop return address
    pop ecx                  ; Pop particle index into ECX
    push ebx                 ; Push return address back

    ; Check left (x-1)
    ; Load x and y positions for this particle
    mov ebx, [xPositions + ecx*4]  ; x position of current particle
    mov edx, [yPositions + ecx*4]  ; y position of current particle
    dec ebx
    push ecx                  ; Preserve ECX across calls
    push edx                  ; y remains the same
    push ebx                  ; x-1
    call is_stuck             ; Check if (x-1, y) is stuck
    pop ecx                   ; Restore ECX after call
    test eax, eax             ; Check return value
    jnz _found_stuck          ; If non-zero, particle is stuck

    ; Check right (x+1)
    ; Load x and y positions for this particle
    mov ebx, [xPositions + ecx*4]  ; x position of current particle
    mov edx, [yPositions + ecx*4]  ; y position of current particle
    inc ebx                        ; x+1 
    push ecx
    push edx
    push ebx
    call is_stuck
    pop ecx
    test eax, eax
    jnz _found_stuck

    ; Check up (y-1)
    ; Load x and y positions for this particle
    mov ebx, [xPositions + ecx*4]   ; x position of current particle
    mov edx, [yPositions + ecx*4]   ; y position of current particle
    dec edx                         ; y-1
    push ecx
    push edx
    push ebx
    call is_stuck
    pop ecx
    test eax, eax
    jnz _found_stuck

    ; Check down (y+1)
    mov ebx, [xPositions + ecx*4]   ; x position of current particle
    mov edx, [yPositions + ecx*4]   ; y position of current particle
    inc edx                         ; y+1 
    push ecx
    push edx
    push ebx
    call is_stuck
    pop ecx
    test eax, eax
    jnz _found_stuck

    ; If no adjacent particles are stuck
    xor eax, eax               ; Return 0 (false)
    jmp _return

_found_stuck:
    mov eax, 1                 ; Return 1 (true)

_return:
    ret

check_touching ENDP

; === BOOL is_stuck(x: DWORD, y: DWORD) ===
; Description:
;   Searches for any stuck particles at a given (x, y) coordinates.
; Parameters: x, y coordinates passed via stack
; Return: 1 if a particle at (x, y) is stuck, otherwise 0
; Registers:
;   EAX - used for comparison and return value
;   ESI - loop counter and particle index
;   ECX - x coordinate
;   EDX - y coordinate
is_stuck PROC
    pop ebx             ; Pop return address
    pop ecx             ; Pop x coordinate into ECX
    pop edx             ; Pop y coordinate into EDX
    push ebx            ; Push return address back

    xor esi, esi        ; Use ESI for the loop index
_loop_start:
    ; Compare x coordinate
    mov eax, [xPositions + esi * 4]  ; Get x position the current index
    cmp eax, ecx                     ; Check for a match
    jne _next_index                  ; Skip (!=) if not a match for x

    ; Compare y coordinate
    mov eax, [yPositions + esi * 4]  ; Get the y position of the current index
    cmp eax, edx                     ; Check for a match
    jne _next_index                  ; Skip (!=) if not a match for y

    ; Found a match. Check if the particle is stuck
    mov al, byte ptr [particleStatus + esi]   ; Get the status of the particle
    cmp al, 1                        ; Check if it is stuck
    je _is_stuck                     ; Found a match with stuck particle

_next_index:
    inc esi                          ; Increment the index
    cmp esi, numParticles            ; Compare index against total number of particles
    jl _loop_start                   ; Loop if there are more particles to check

    ; No match found for the given coordinates
    xor eax, eax                     ; Return 0 (false)
    jmp _return

_is_stuck:
    mov eax, 1                       ; Set return value to 1 (true)

_return:
    ret                              ; Return to caller

is_stuck ENDP

END