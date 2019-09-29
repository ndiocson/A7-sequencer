----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:56:08 AM
-- Design Name: Sequencer
-- Module Name: Sequencer - Behavioral
-- Project Name: N-Step Sequencer
-- Target Devices: Arty-A7
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
use IEEE.numeric_std.all;

entity Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset, pause   : in std_logic;
            switch              : in std_logic_vector(N_STEPS - 1 downto 0);
            out_wave            : out std_logic
            );
    
    subtype step is integer range 0 to N_STEPS - 1;
    type step_arr is array (step) of std_logic;
    type freq_arr is array (step) of std_logic_vector(31 downto 0);
end entity Sequencer;

architecture Behavioral of Sequencer is

-- new_clk:             Internal std_logic signal used as system clock      
-- curr_step:           Internal step signal used to track position in sequencer
-- step_note:           Internal signal array of indicies representing each step wave
-- note_freq:           Internal signal array of frequencies corresponding to each step          
signal new_clk          : std_logic;
signal curr_step        : step := 0;
signal step_wave        : step_arr := (others => '0');
signal note_freq        : freq_arr := (others => (others => '0'));

begin
    
    -- Instantiates Clock_Divider with default actual generic values
    new_clock: entity work.Clock_Divider(Behavioral)
                Generic Map (CLK_FREQ => open, CLK_OUT_FREQ => open)
                Port Map(clk => clk, reset => reset, clk_out => new_clk);
                
    -- Instatiates N_STEPS Square_Wave_Gen models for each step within the sequencer
    -- TODO: implement a fix for steps of 0 Hz frequency values (should act as rests)
    generate_waves: for index in 0 to N_STEPS - 1 generate
        square_wave: entity work.Square_Wave_Gen(Behavioral)
                Port Map(clk => clk, reset => reset, freq => note_freq(index), out_wave => step_wave(index));
    end generate generate_waves;

    -- Concurrently assigns note frequency values to each element in steps array
    -- TODO: note frequency values to be determined by buttons on fpga; hard-coded to 220 Hz for now    
    note_assign: for index in note_freq'range generate
        note_freq(index) <= std_logic_vector(to_unsigned(220, note_freq(index)'length))
                        when rising_edge(new_clk) else (others => '0');
    end generate note_assign;
    
    -- Uses the curr_step signal index to apply square wave of corresponding note frequency driven by Sqaure_Wave_Gen
    output_note: process(curr_step) is
    begin
        out_wave <= step_wave(curr_step);
    end process output_note;
    
    -- Increments the curr_step index signal every clock cycle
    step_tracker: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            if (curr_step = step'high) then
                curr_step <= step'low;
            else
                curr_step <= curr_step + 1;
            end if;
        end if;
    end process step_tracker;
    
end architecture Behavioral;