# DLA (Diffusion-Limited Aggregation) in Assembly 

## Overview
Diffusion-Limited Aggregation is an algorithm that can be used in generative art to create interesting and organic structures. It uses a simple concept of particles that randomly "wiggle" until they touch and stick to a larger structure of particles (aka the "aggregate"). This creates the effect of the aggregate appearing to diffuse through the limited field of particles, hence the name. This project implements a simple version of DLA in assembly code.

## Modules
The program is organized into different modules:

### Main Module

  - `main()`: Main calls setting up the particles, then loops for updating particles and refreshing the display.

### Particle Module

  - `init_particles()`: Initialize all of the particles starting position and status
    - All particles all start with status unstuck (0)
    - Set one particle to status stuck (1) to control where the aggregate grows from
  - `random_wiggle()`: Moves the particle until it sticks to the aggregate structure

### UI Module

  - `refresh_display()`: Refreshes the display with an updated screen buffer
  - `render_particle(index)`: Adds a particle and its status to the screen buffer
  - `check_touching(index)`: Look at a particle's neighboring coord
  - `is_stuck(x, y)`: Search for stuck particles at the given coords

### Helpers Module

  - `random_num(max_range)`: Generates random numbers
  - `write_string(string)`: Writes a string into the console output

## Stretch Goal

- User controls: repeat with seed in center, repeat with seeds on bottom row