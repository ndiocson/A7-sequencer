----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 12/01/2019 06:21:59 AM
-- Design Name: Sequencer Demo Testbench
-- Module Name: Sequencer_Demo_Tb - Test
-- Project Name: N-Step Sequencer Board Demo
-- Target Devices: Arty A7-35T
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Sequencer_Demo_Tb is
end entity Sequencer_Demo_Tb;

architecture Test of Sequencer_Demo_Tb is

-- Sequencer Component Declaration
component Sequencer_Demo is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            SEQ_FREQ        : positive := 4;        -- frequency of the sequencer (default: 4 Hz)
            N_STEPS         : positive := 4;        -- number of steps in sequencer (default: 4 steps)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            FREQ_WIDTH      : positive := 32;       -- width of frequency input (default: 32 bits)
            NOTE_OUT        : positive := 440;      -- note frequency to be played (default: 440 Hz)
            STEP_TIME       : time := 500 ms;
            REST_TIME       : time := 500 ms
            );
    Port (
            clk, reset      : in std_logic;
            strt, stop      : in std_logic;
            step_ready      : in std_logic_vector(N_STEPS downto 1);
            step_out        : out std_logic_vector(N_STEPS downto 1);
            out_wave        : out std_logic
            );
end component Sequencer_Demo;

-- CLK_PERIOD:          Simulated clock period
-- CLK_FREQ:            Clock frequency
-- SEQ_FREQ:            Sequencer frequency
-- N_STEPS:             Number of steps in sequencer
-- BAUD_RATE:           9600 bits per second
-- FREQ_WIDTH:          Number of bits to represent note frequencies
-- NOTE_OUT:            Frequency of each note
constant CLK_PERIOD     : time := 100 ns;
constant CLK_FREQ       : positive := 1E7;
constant SEQ_FREQ       : positive := 20;
constant N_STEPS        : positive := 4;
constant BAUD_RATE      : positive := 9600;
constant FREQ_WIDTH     : positive := 32;
constant NOTE_OUT       : positive := 440;

-- Input Signals
signal clk, reset       : std_logic := '0';
signal strt, stop       : std_logic := '0';
signal step_ready       : std_logic_vector(N_STEPS downto 1);
signal step_out         : std_logic_vector(N_STEPS downto 1);

-- Output Signal
signal out_wave         : std_logic := '0';

begin

    -- Instantiates device under test
    DUT: Sequencer_Demo
        Generic Map (CLK_FREQ => CLK_FREQ, SEQ_FREQ => SEQ_FREQ, N_STEPS => N_STEPS, BAUD_RATE => BAUD_RATE, FREQ_WIDTH => FREQ_WIDTH, NOTE_OUT => NOTE_OUT, STEP_TIME => open, REST_TIME => open)
        Port Map (clk => clk, reset => reset, strt => strt, stop => stop, step_ready => step_ready, step_out => step_out, out_wave => out_wave);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to sitmulate input signals of DUT
    stimulus: process is
    begin
    
        step_ready <= (others => '1');
        wait for 100 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 300 ms;
        stop <= '1';
        wait for 20 ms;
        stop <= '0';
        
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 80 ms;
        step_ready <= "1010";
        
        wait for 360 ms;
        reset <= '1';
        wait for 20 ms;
        reset <= '0';
        
        wait for 80 ms;
        step_ready <= "0101";
        
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait;
    end process stimulus;    

end architecture Test;