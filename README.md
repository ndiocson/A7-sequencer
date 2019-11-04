# Arty A7-35T Sequencer

### Sequencer Overview

A basic overview of a sequencer describes a timeline that loops across a defined number of 'steps' that can either play a note, or a est. Each step can play a range of notes, corresponding to a sinusoidal wave of differing frequencies. Thus, when the sequencer is running, the notes assigned to each available step will be played in a 'sequence', forming a tune. Each step can be edited during the sequence to a different note to alter the overall melody.

### UART Communication

![UART Simulation between UART_Rx and UART_Tx for 9600 baud](https://github.com/ndiocson/fpga-sequencer/blob/master/pictures/UART_Simulation_1.JPG)

A UART will be used to control the FPGA with the connected computer. The main features for this interaction will include:

* Initializing the number of steps in the sequence
* Assigning new frequency values to steps
* Selecting the type of wave form to use (square, sine, sawtooth, etc.)

### Square Wave Generator

![Square_Wave_Gen Simulation for 3 notes (220 Hz, 440 Hz, 880 Hz, separated by 3 rests](https://github.com/ndiocson/fpga-sequencer/blob/master/pictures/Square_Wave_Gen_Simulation_1.JPG)

The Square Wave Generator generates a note to be played by a given step. When a frequency value is assigned to a given step, the Square Wave Generator will output a corresponding square wave to represent the note to be played.