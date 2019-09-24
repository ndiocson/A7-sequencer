# Arty-A7 Sequencer

### Project Goal
The goal of this project will be to create a sequencer implemented on an Arty-A7 FPGA development board. The majority of the program's functionality will be procedd on the board using the provided GPIO switches and buttons.

### Sequencer Design
A basic overview of a sequencer describes a timeline that loops across a defined number of 'steps' that can either play a note, or rest. Each step can play a range of notes, each corresponding to a sinusoidal wave of differing frequencies. Thus, when the sequencer is running, the notes assigned to each available step will be played in a 'sequence', forming a tune. Each step can be edited during the sequence to a different note to alter the overall melody.

### Sequencer Loop

The Sequencer Loop defines the process that continuously loops through each step an undefined number of times. This process should be able to be paused and replayed at any given moment within the loop. The process can also be reset to begin again at the initial step. When the loop is running, it is defined to be ON; otherwise, the loop is OFF.

### Note Assignment

The functionality of 'Note Assignment' defines the process which assigns a note to a given step within the Sequencer Loop. Regardless if the Sequencer Loop is ON or OFF, a given step may be reassigned to any available note and is subsequently reflected in the next cycle of the Sequencer Loop. Each step is either in the 'READY' or 'UNREADY' state to indicate if a note frequency value can be assigned to a given step. Each note is defined as a number that represent the frequency of the square wave to be generated at the corresponding step.

### Square Wave Generator

The Square Wave Generator generates each note to be played by a given step. As each step is assigned with a frequency that represents a note, the Square Wave Generator takes that frequency and passes the corresponding square wave as an output.

The timings for each step and the space between each step within the Sequencer Loop should be predefined. For now, we will consider both step and step space to be equal at 500ms each. We note that with the implementation of the GUI, the constraints for both step and step space may be changed to the user’s desire.

Bringing the design modules together, we can consider the simple case for a 4-step Sequencer. When the FPGA is initially turned on, the sequencer is set to start at the initial step of the sequencer loop, and the loop is currently in the ‘OFF’ state. Additionally, each of the four steps of the sequencer are initialized to ‘0’ to represent a pause.

When the sequence start button is pressed, the loop transitions to the ‘ON’ state and starts at the initial step of the sequencer. Each step of the sequencer holds a value that represents the frequency of their note, which is passed to the Square Wave Generator. In the case of starting the loop with pre-initialized steps, all of the steps are assigned to pauses. Therefore, the first step passes a ‘0’ frequency square wave to the output speaker device for 500ms. After this time has passed, the loop increments to the first step space which does not generate a wave at all, and also lasts 500ms. Once the step space has passed, the second step of the loop is reached.

During the sequence loop, note values can be reassigned to any available step at any given time. However, it is noted that the note assigned will not be reflected within the corresponding step until the next sequencer cycle.

