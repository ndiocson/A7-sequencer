----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/23/2019 07:42:37 PM
-- Design Name: Square Wave Generator
-- Module Name: Square_Wave_Gen - Behavioral
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

entity Square_Wave_Gen is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            FREQ_WIDTH       : positive := 32       -- width of frequency input
            );
    Port ( 
            clk, reset      : in std_logic;
            freq            : in std_logic_vector(FREQ_WIDTH - 1 downto 0);
            out_wave        : out std_logic
            );
end Square_Wave_Gen;

architecture Behavioral of Square_Wave_Gen is

-- isValidFreq: Function that returns true if given frequency is greater than 0 Hz
function isValidFreq(freq : std_logic_vector(FREQ_WIDTH - 1 downto 0)) return std_logic is
variable is_valid_bit : std_logic := '0';
begin
    if (to_integer(unsigned(freq)) > 0) then
        is_valid_bit := '1';
    end if;
    return is_valid_bit;
end function isValidFreq;

-- calcPulseCount:  Function that returns integer value of maximum count to acheive one out wave pulse
function calcPulseCount(freq : std_logic_vector(FREQ_WIDTH - 1 downto 0)) return integer is
begin
    return integer(CLK_FREQ / to_integer(unsigned(freq))) / 2;
end function calcPulseCount;

-- state:       Enumerated type to define two states of simple FSM
type state is (idle, gen_wave);

-- p_state:     Internal state signal to represent present state
-- n_state:     Internal state signal to represent next state
signal p_state, n_state : state := idle;

-- count:       Internal integer signal to keep track of current count
-- new_clk:     Internal std_logic signal used to drive out_wave
-- valid_freq:  Internal std_logic signal to represent a valid input frequency (greater than 0 Hz)
-- max_count:   Number of cycles in on-board clock to represent one new clock cycle
signal count            : integer := 0;
signal new_clk          : std_logic := '0';
signal valid_freq       : std_logic := '0';
signal max_pulse_count  : integer;

begin

    -- Drives out_wave with internal new_clk signal
    out_wave <= new_clk;
    
    -- Drives valid_freq signal to '1' if freq is greater that 0 Hz, else '0'
    valid_freq <= isValidFreq(freq);
    
    -- Process that manages the present and next states based on the
    -- internal valid_freq signal
    state_machine: process(p_state, valid_freq) is
    begin
        case p_state is
            when idle =>
                if (valid_freq = '1') then
                    n_state <= gen_wave;
                else
                    n_state <= idle;
                end if;
            when gen_wave =>
                max_pulse_count <= calcPulseCount(freq);
                if (valid_freq = '1') then
                    n_state <= gen_wave;
                else
                    n_state <= idle;
                end if;
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements of the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= idle;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
        end if;
    end process memory_elem;
      
    -- Process that counts the number of on-board clock cycles needed 
    -- to generate a new clock of the given input frequency
    count_proc: process(clk, p_state) is
    begin
        if (p_state = gen_wave) then
            if (rising_edge(clk)) then
                if (reset = '1') then
                    count <= 0;
                    new_clk <= '0';
                elsif (count >= max_pulse_count) then
                    count <= 0;
                    new_clk <= not new_clk;
                else
                    count <= count + 1;
                end if;
            end if;
        else
            count <= 0;
            new_clk <= '0';
        end if;
    end process count_proc;
    
end architecture Behavioral;