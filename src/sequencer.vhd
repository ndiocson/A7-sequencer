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
    
    subtype step is integer range 0 to 2*N_STEPS - 1;   -- steps are even, rests are odd
    type step_arr is array (0 to N_STEPS - 1) of std_logic_vector(31 downto 0);
end entity Sequencer;

architecture Behavioral of Sequencer is

-- new_clk:             Internal std_logic signal used as system clock      
-- curr_step:           Internal step signal used to track position in sequencer
-- steps:               Internal array of frequencies corresponding to each step          
signal new_clk          : std_logic;
signal curr_step        : step := 0;
signal steps            : step_arr := (others => (others => '0'));

begin
    
    -- Instantiates Clock_Divider with default actual generic values
    new_clock: entity work.Clock_Divider(Behavioral)
                Generic Map (CLK_FREQ => open, CLK_OUT_FREQ => open)
                Port Map(clk => clk, reset => reset, clk_out => new_clk);
                
    -- Instatiates N_STEPS Square_Wave_Gen models for each step within the sequencer
    -- TODO: implement a fix for steps of 0 Hz frequency values (should act as rests)
    generate_waves: for index in 0 to N_STEPS - 1 generate
        square_wave: entity work.Square_Wave_Gen(Behavioral)
                Port Map(clk => clk, reset => reset, freq => steps(index), out_wave => out_wave);
    end generate generate_waves;
    
    -- Uses the curr_step signal index to apply corresponding note frequency through Sqaure_Wave_Gen
    output_note: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            -- Based on the current step as an index, output the corresponding note
            
        end if;
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
    
    -- Concurrently assigns note frequency values to each element in steps array
    -- TODO: apply concurrent assignments to a generic number of step elements 
    -- TODO: note frequency values to be determined by buttons on fpga; hard-coded to 220 Hz for now
    -- note_assign: process(new_clk) is
    -- begin
    --     if (rising_edge(new_clk)) then
    --         steps(0) <= std_logic_vector(to_unsigned(220, steps(0)'length));
    --         steps(1) <= std_logic_vector(to_unsigned(220, steps(1)'length));
    --         steps(2) <= std_logic_vector(to_unsigned(220, steps(2)'length));
    --         steps(3) <= std_logic_vector(to_unsigned(220, steps(3)'length));
    --     end if;
    -- end process note_assign;

    -- Concurrently assigns note frequency values to each element in steps array
    -- TODO: note frequency values to be determined by buttons on fpga; hard-coded to 220 Hz for now
    note_assign: for index in steps'length generate
        steps(index) <= std_logic_vector(to_unsigned(220, steps(index)'length)) 
                        when rising_edge(new_clk) else (others => '0');
    end generate note_assign;

end Behavioral;
