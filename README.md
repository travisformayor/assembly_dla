# DLA (Diffusion-Limited Aggregation) in Assembly 

## Overview
Diffusion-Limited Aggregation is an algorithm that can be used in generative art to create interesting and organic structures. It uses a simple concept of particles that randomly "wiggle" until they touch and stick to a larger structure of particles (aka the "aggregate"). This creates the effect of the aggregate appearing to diffuse through the limited field of particles, hence the name. This project implements a simple version of DLA in assembly code.

## Modules
The program is organized into different modules:

### Main Module

  - `init_particles()`: Initialize all of the particles starting position and state.
    - Setting one particle to "stuck" controls where the aggregate grows from.
  - `main_loop()`: The main loop for generating particles and refreshing the display.

### Particle Module

  - `place_particle()`: Places a new particle on the grid.
  - `random_wiggle()`: Moves the particle until it sticks to the aggregate structure.

### UI Module

  - `show_particle(x, y, state)`: Displays the particle in the grid.
  - `refresh_display()`: Refreshes the display by showing all of the particles in the grid.

### Helper Module

  - `random_num()`: Generates random numbers.

## Stretch Goal

- User controls the location of the aggregate seed