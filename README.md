# DLA (Diffusion-Limited Aggregation) in Assembly 

## Overview
Diffusion-Limited Aggregation is an algorithm that can be used in generative art to create interesting and organic structures. It uses a simple concept of particles that randomly "wiggle" until they touch and stick to a larger structure of particles (aka the "aggregate"). This creates the effect of the aggregate appearing to diffuse through the limited field of particles, hence the name. This project implements a simple version of DLA in assembly code.

## Modules
The program is organized into different modules:

### Main Module

  - `main()`: Main calls setting up the particles, then loops for updating particles and refreshing the display.

### Particle Module

  - `init_particles()`: Initialize all of the particles starting position and status
    - All particles all start with status unstuck (0).
    - Set one particle to status stuck (1) to control where the aggregate grows from.
  - `random_wiggle()`: Moves the particle until it sticks to the aggregate structure.

### UI Module

  - `draw_particle(x, y, state)`: Displays the particle on the screen.
  - `refresh_display()`: Refreshes the display by showing all of the particles on the screen.

### Helpers Module

  - `random_num()`: Generates random numbers.
  - `write_integer()`: Writes an integer (as a string) into the console output
  - `write_string()`: Writes a string into the console output
  - `new_line()`: Writes a newline character into the console output

## Stretch Goal

- User controls the location of the aggregate seed (initial stuck particle)