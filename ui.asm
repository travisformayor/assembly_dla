; Travis Uhrig, CSC2025
; DLA (Diffusion-Limited Aggregation) in Assembly
; ----------------------------
; Date: 04/28/24
; Description: The UI Module. Contains functions to update the 
; screen by drawing each particle's current position

.386P
.model flat

.code
; === void refresh_display() ===
; Description:
;   Loops drawing all of the particles to update the screen.
; Parameters: None, directly accesses global data
; Registers:
;   EBX - Loop counter for particles
refresh_display PROC

    ret
refresh_display ENDP

; === void draw_particle(x: WORD, y: WORD, state: BYTE) ===
; Description:
;   Draws a particle at a given location. Uses a different symbol 
;   if the state is unstuck (0) or stuck (1).
; Parameters: x position, y position, stuck state (0 or 1)
; Registers:
;   EAX - x position of the particle
;   EBX - y position of the particle
;   ECX - Stuck state
;   EDX - Return pointer
show_particle PROC
    pop edx         ; Save the return address
    pop eax         ; Save x position in EAX
    pop ebx         ; Save y position in EBX
    pop ecx         ; Save stuck state in ECX
    push edx        ; Restore return address

    ; Draw the particle on the display

    ret
show_particle ENDP
