# Cyborg Swarm Control Simulation

This MATLAB program simulates a swarm of 20 cyborgs (1 leader and 19 followers) moving toward a goal. The simulation generates an animation (`animation.mp4`) showing the swarm's behavior over time.

## Program Overview

1. **Leader Movement**:
   - Continuously moves towards the goal, guiding followers.

2. **Follower Control**:
   - Alternates between stimulated and random motion based on the number of nearby agents.

3. **Output**:
   - Generates an animation (`animation.mp4`) showing follower (blue) and leader (red) positions over time.

## Running the Simulation

1. Copy the code into a `.m` file.
2. Run the file in MATLAB.
3. The video `animation.mp4` will be saved in the working directory.

## Requirements

1. MATLAB
2. `VideoWriter` support for video output

