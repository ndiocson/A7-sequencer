# Arty A7-35T Sequencer

### Sequencer Design

A basic overview of a sequencer describes a timeline that loops across a defined number of 'steps' that can either play a note, or rest. Each step can play a range of notes, each corresponding to a sinusoidal wave of differing frequencies. Thus, when the sequencer is running, the notes assigned to each available step will be played in a 'sequence', forming a tune. Each step can be edited during the sequence to a different note to alter the overall melody.

### Sequencer Loop

The Sequencer Loop defines the process that continuously loops through each step an undefined number of times. This process should be able to be paused and replayed at any given moment within the loop. The process can also be reset to begin again at the initial step. When the loop is running, it is defined to be ON; otherwise, the loop is OFF.

### Note Assignment

The functionality of 'Note Assignment' defines the process which assigns a note to a given step within the Sequencer Loop. Regardless if the Sequencer Loop is ON or OFF, a given step may be reassigned to any available note and is subsequently reflected in the next cycle of the Sequencer Loop. Each step is either in the 'READY' or 'UNREADY' state to indicate if a note frequency value can be assigned to a given step. Each note is defined as a number that represent the frequency of the square wave to be generated at the corresponding step.

### Square Wave Generator

![Square_Wave_Gen Simulation for 3 notes (220 Hz, 440 Hz, 880 Hz, separated by 3 rests](https://github.com/ndiocson/fpga-sequencer/blob/master/pictures/Square_Wave_Gen_Simulation_1.JPG)

The Square Wave Generator generates each note to be played by a given step. As each step is assigned with a frequency that represents a note, the Square Wave Generator takes that frequency and passes the corresponding square wave as an output.

### UART Communication

A UART will be used to interact with the FPGA on the computer. The main features for this interaction will be:
* Initializing the number of steps in the sequence
* Assigning new frequency values to steps (while sequencer is either ON or OFF)
* Selecting the type of wave form to use (square, sine, sawtooth, etc.)
    
These features will initially be implemented using the TeraTerm console; however, the entirety of the FPGA interaction will eventually be abstracted into a GUI. 

### GUI

The GUI will feature an intuitive interface that allows the user to interact with the FPGA in any of the ways mention above. Additionally, the GUI will be able to initially plot the output wave form of the user’s choosing.

### Bringing It All Together

The timings for each step and the space between each step within the Sequencer Loop should be predefined. For now, we will consider both step and step space to be equal at 500ms each. We note that with the implementation of the GUI, the constraints for both step and step space may be changed to the user’s desire.

Bringing the design modules together, we can consider the simple case for a 4-step Sequencer. When the FPGA is initially turned on, the sequencer is set to start at the initial step of the sequencer loop, and the loop is currently in the ‘OFF’ state. Additionally, each of the four steps of the sequencer are initialized to ‘0’ to represent a pause.

When the sequence start button is pressed, the loop transitions to the ‘ON’ state and starts at the initial step of the sequencer. Each step of the sequencer holds a value that represents the frequency of their note, which is passed to the Square Wave Generator. In the case of starting the loop with pre-initialized steps, all of the steps are assigned to pauses. Therefore, the first step passes a ‘0’ frequency square wave to the output speaker device for 500ms. After this time has passed, the loop increments to the first step space which does not generate a wave at all, and also lasts 500ms. Once the step space has passed, the second step of the loop is reached.

During the sequence loop, note values can be reassigned to any available step at any given time. However, it is noted that the note assigned will not be reflected within the corresponding step until the next sequencer cycle.
