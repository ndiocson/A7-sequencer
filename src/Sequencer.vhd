----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:56:08 AM
-- Design Name: Sequencer
-- Module Name: Sequencer - Behavioral
-- Project Name: N-Step Sequencer
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
use IEEE.numeric_std.all;

entity Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset          : in std_logic;
            strt, stop          : in std_logic;
            step_ready          : in std_logic_vector(N_STEPS - 1 downto 0);
            step_out            : out std_logic_vector(N_STEPS - 1 downto 0);
            out_wave            : out std_logic
            );
end entity Sequencer;

architecture Behavioral of Sequencer is

-- Clock_Divider Component Declaration
component Clock_Divider is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            CLK_OUT_FREQ    : positive := 2         -- desired clock frequency (default 2 Hz)
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end component Clock_Divider;

-- Square_Wave_Gen Component Declaration
component Square_Wave_Gen is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            FREQ_BITS       : positive := 32
            );
    Port ( 
            clk, reset      : in std_logic;
            freq            : in std_logic_vector(FREQ_BITS - 1 downto 0);
            out_wave        : out std_logic
            );
end component Square_Wave_Gen;

-- CLK_FREQ:        Constant frequency of on-board clock (10 MHz for Arty A7-35T)
constant CLK_FREQ   : positive := 1E7;

-- step_type:       Subtype defining the range of steps including 0
-- step_arr:        std_loigc array of length N_STPES used to represent the output wave of each step
-- freq_arr:        std_logic_vector array of length N_STEPS used to represent the frequency of each step
subtype step_type is integer range 0 to N_STEPS;
type step_arr is array (1 to N_STEPS) of std_logic;
type freq_arr is array (1 to N_STEPS) of std_logic_vector(31 downto 0);

-- state:           Enumerated type to define two states of simple FSM
type state is (idle, play, pause);

-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
signal p_state, n_state : state := idle;

-- new_clk:         Internal std_logic signal used as system clock      
-- reset_clk:       Internal signal used to reset all Clock_Divider instances
-- rest_on:         Internal signal used to manage rest and step sequencer
signal new_clk      : std_logic := '0';
signal reset_clk    : std_logic := '1';
signal rest_on      : std_logic := '1';

-- step_wave:       Internal signal array of indicies representing each step wave
-- note_freq:       Internal signal array of frequencies corresponding to each step   
-- led_out:         Internal bit vector signal used to represent when each step is being played
signal step_wave    : step_arr := (others => '0');
signal note_freq    : freq_arr := (others => (others => '1'));
signal led_out      : std_logic_vector(N_STEPS - 1 downto 0) := (others => '0');

-- curr_step:       Shared variable used to track current step position in sequencer
shared variable curr_step   : step_type := step_type'low;

begin
    
    -- Instantiates a Clock_Divider to drive the new_clk signal
    new_clock: entity work.Clock_Divider(Behavioral)
        Generic Map (CLK_FREQ => CLK_FREQ, CLK_OUT_FREQ => 8)
        Port Map (clk => clk, reset => reset_clk, clk_out => new_clk);
                
    -- Instatiates 'N_STEPS' Square_Wave_Gen models for each step within the sequencer
    generate_waves: for index in 1 to N_STEPS generate
        square_wave: entity work.Square_Wave_Gen(Behavioral)
            Generic Map (CLK_FREQ => CLK_FREQ, FREQ_WIDTH => open)
            Port Map (clk => clk, reset => reset, freq => note_freq(index), out_wave => step_wave(index));
    end generate generate_waves;
    
    -- Drives output port step_out with internal signal array led_out
    step_out <= led_out;
        
    -- Process that manages the present and next states based on internal toggle signal
    state_machine: process(p_state, strt, stop) is
    begin
        case p_state is
            when idle =>
                reset_clk <= '1';
                if (strt = '1') then
                    n_state <= play;
                    curr_step := step_type'low + 1;
                else
                    n_state <= idle;
                end if;
            when play =>
                reset_clk <= '0';
                if (stop = '1') then
                    n_state <= pause;
                    curr_step := curr_step - 1;
                else
                    n_state <= play;
                end if;
            when pause =>
                reset_clk <= '1';
                if (strt = '1') then
                    n_state <= play;
                else
                    n_state <= pause;
                end if;
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= idle;
            curr_step := step_type'low;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
        end if;
    end process memory_elem;

    -- Uses the curr_step signal index to apply square wave of corresponding note frequency driven by Sqaure_Wave_Gen
    -- Outputs either a wave or a rest depending on the internal rest_on signal
    output_wave: process(step_wave) is
    begin
        if (p_state /= play or rest_on = '1') then
            out_wave <= '0';
        else
            out_wave <= step_wave(curr_step);
        end if;
    end process output_wave;
    
    -- Outputs a '1' the the LED corresponding to the current step
    -- TODO: fix case of first step index after idle state transition
    output_led: process(p_state, rest_on) is
    begin
        if (p_state = play) then
            led_out(curr_step - 1) <= not rest_on;
        else
            led_out <= (others => '0');
        end if;
    end process output_led;
    
    -- Assigns note frequency values to each element in note_freq array
    -- If no note is assigned (frequency bit vector set to all 1's), the note is considered as a rest
    -- TODO: note frequency values to be determined by buttons on fpga; hard-coded to 220 Hz for now 
    note_assign: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (p_state /= idle) then
                for index in 1 to N_STEPS loop
                    if (step_ready(index - 1) = '1') then
                        note_freq(index) <= std_logic_vector(to_unsigned(220, note_freq(index)'length));
                    else
                        note_freq(index) <= (others => '1');
                    end if;
                end loop;
            end if;
        end if;
    end process note_assign;
    
    -- Toggles rest_on every clock cycle
    -- Drives rest_on to '1' when sequencer is paused
    toggle_rest: process(new_clk, p_state) is
    begin
        if (rising_edge(new_clk) and p_state = play) then
            rest_on <= not rest_on;
        elsif (p_state = pause) then
            rest_on <= '1';
        end if;
    end process toggle_rest;
    
    -- Increments the curr_step index signal every two clock cycles
    -- Does not increment while FSM is not in the pause or idle state
    increment_step: process(new_clk) is
    begin
        if (p_state = play) then
            if (rising_edge(new_clk)) then
                if (rest_on = '1') then
                    if (curr_step = step_type'high) then
                        curr_step := step_type'low + 1;
                    else
                        curr_step := curr_step + 1;
                    end if;
                end if;
            end if;
        end if;
    end process increment_step;
    
end architecture Behavioral;