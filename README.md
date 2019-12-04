# Arty A7-35T Sequencer

### Sequencer Overview

A typical sequencer can be described as timeline that loops across a defined number of 'steps' that can either play a note, or a rest. Each step can play a range of notes, corresponding to a sinusoidal wave of a given frequency. When the sequencer is running, frequency values for each step can be assigned to play a tune.

![Sequencer Simulation for 4 steps](https://github.com/ndiocson/A7-sequencer/blob/master/pictures/Sequencer_Simulation_1.JPG)

### UART Communication

A UART will be used to control the FPGA with the connected computer. The main features for this interaction will include:

* Initializing the number of steps in the sequence
* Assigning new frequency values to steps
* Selecting the type of wave form to use (square, sine, sawtooth, etc.)

![UART Simulation between UART_Rx and UART_Tx for 9600 baud](https://github.com/ndiocson/fpga-sequencer/blob/master/pictures/UART_Simulation_1.JPG)

### Square Wave Generator

The Square Wave Generator generates a note to be played by a given step. When a frequency value is assigned to a given step, the Square Wave Generator will output a corresponding square wave to represent the note to be played.

![Square_Wave_Gen Simulation for 3 notes (220 Hz, 440 Hz, 880 Hz, separated by 3 rests](https://github.com/ndiocson/fpga-sequencer/blob/master/pictures/Square_Wave_Gen_Simulation_1.JPG)
