# Arty-A7 Sequencer

### Project Goal
The goal of this project will be to create a sequencer implemented on an Arty-A7 FPGA development board. The majority of the program's functionality will be procedd on the board using the provided GPIO switches and buttons.

### Sequencer Design
A basic overview of a sequencer described a timeline that loops across a defined number of 'steps' that can either play a note, or rest. Each step can play a range of notes, each corresponding to a sinusoidal wave of differing frequencies. Thus, when the sequencer is running, the notes assigned to each available step will be played in a 'sequence', forming a tune. Each step can be edited during the sequence to a different note to alter the overall melody.
