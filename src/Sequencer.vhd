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
            clk, reset          : in std_logic;
            strt, btn           : in std_logic;
            step                : in std_logic_vector(N_STEPS - 1 downto 0);
            out_wave            : out std_logic
            );
    
    subtype step_type is integer range 0 to N_STEPS;
    type step_arr is array (1 to N_STEPS) of std_logic;
    type freq_arr is array (1 to N_STEPS) of std_logic_vector(31 downto 0);
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

-- state:       Enumerated type to define two states of simple FSM
type state is (idle, play, pause);

-- p_state:     Internal state signal to represent present state
-- n_state:     Internal state signal to reppresent next state
signal p_state, n_state : state := idle;

-- CLK_FREQ:        Constant frequency of on-board clock (10 MHz for Arty A7-35T)
constant CLK_FREQ   : positive := 1E7;

-- new_clk:         Internal std_logic signal used as system clock      
-- curr_step:       Internal step signal used to track position in sequencer
-- step_note:       Internal signal array of indicies representing each step wave
-- note_freq:       Internal signal array of frequencies corresponding to each step
-- note_ready:      Internal signal used to check if a given note is can be assigned a frequency value
-- rest_on:         Internal signal used to manage rest and step sequencer
-- toggle_btn:      Internal signal used to toggle when btn is '1'
-- reset_clk:       Internal signal used to reset Clock_Divider instance
signal new_clk      : std_logic;
signal curr_step    : step_type;
signal step_wave    : step_arr := (others => '0');
signal note_freq    : freq_arr := (others => (others => '1'));
signal note_ready   : std_logic_vector(N_STEPS downto 1) := (others => '1');
signal rest_on      : std_logic := '1';
signal toggle_btn   : std_logic := '0';
signal reset_clk    : std_logic := '1';

begin
    
    -- Instantiates Clock_Divider with default actual generic values
    new_clock: entity work.Clock_Divider(Behavioral)
        Generic Map (CLK_FREQ => CLK_FREQ, CLK_OUT_FREQ => 4)
        Port Map (clk => clk, reset => reset_clk, clk_out => new_clk);
                
    -- Instatiates N_STEPS Square_Wave_Gen models for each step within the sequencer
    generate_waves: for index in 1 to N_STEPS generate
        square_wave: entity work.Square_Wave_Gen(Behavioral)
            Generic Map (CLK_FREQ => CLK_FREQ, FREQ_WIDTH => open)
            Port Map (clk => clk, reset => reset, freq => note_freq(index), out_wave => step_wave(index));
    end generate generate_waves;

    -- Drives internal note_ready signal with step input port of same size
    note_ready <= step;
    
    -- Toggles the internal toggle signal everytime btn is pressed
--    toggle_btn_proc: process(clk, btn) is
--    begin
--        if (rising_edge(clk)) then
--            if (rising_edge(btn)) then
--                toggle_btn <= not toggle_btn;
--            end if;
--        end if;
--    end process toggle_btn_proc;
        
    -- Process that manages the present and next states based on internal toggle signal
    state_machine: process(p_state, toggle_btn, strt) is
    begin
        case p_state is
            when idle =>
                if (strt = '1') then
                    n_state <= play;
                else
                    n_state <= idle;
                end if;
            when play =>
                reset_clk <= '0';
                if (toggle_btn = '1') then
                    n_state <= pause;
                else
                    n_state <= play;
                end if;
--            when pause =>
--                if (toggle_btn = '1') then
--                    n_state <= play;
--                else
--                    n_state <= pause;
--                end if;
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= idle;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
        end if;
    end process memory_elem;

    -- Uses the curr_step signal index to apply square wave of corresponding note frequency driven by Sqaure_Wave_Gen
    -- Outputs either a wave or a rest depending on the internal rest_on signal
    output_wave: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            if (rest_on = '1') then
                out_wave <= '0';
            else
                out_wave <= step_wave(curr_step);
            end if;
        end if;
    end process output_wave;

    -- Assigns note frequency values to each element in note_freq array
    -- If no note is assigned (frequency bit vector set to all 1's), the note is considered as a 'rest'
    -- TODO: note frequency values to be determined by buttons on fpga; hard-coded to 220 Hz for now 
    note_assign: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            if (p_state /= idle) then
                for index in 1 to N_STEPS loop
                    if (note_ready(index) = '1') then
                        note_freq(index) <= std_logic_vector(to_unsigned(220, note_freq(index)'length));
                    else
                        note_freq(index) <= (others => '1');
                    end if;
                end loop;
            end if;
        end if;
    end process note_assign;
    
    -- Increments the curr_step index signal every second clock cycle while the Sequencer is in the 'play' state
    step_tracker: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            if (p_state = play) then
                rest_on <= not rest_on;
                if (rest_on = '1') then
                    if (curr_step = step_type'high) then
                        curr_step <= 1;
                    else
                        curr_step <= curr_step + 1;
                    end if;
                end if;
            end if;
        end if;
    end process step_tracker;
    
end architecture Behavioral;