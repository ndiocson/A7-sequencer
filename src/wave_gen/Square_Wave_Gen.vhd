----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/23/2019 07:42:37 PM
-- Design Name: Square Wave Generator
-- Module Name: Square_Wave_Gen - Behavioral
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

entity Square_Wave_Gen is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            FREQ_WIDTH      : positive := 32        -- width of frequency input (default: 32 bits)
            );
    Port ( 
            clk, reset      : in std_logic;
            ready           : in std_logic;
            freq            : in std_logic_vector(FREQ_WIDTH - 1 downto 0);
            out_wave        : out std_logic
            );
end Square_Wave_Gen;

architecture Behavioral of Square_Wave_Gen is

-- count:               Internal integer signal to keep track of current count
-- max_count:           Number of cycles in on-board clock to represent one new clock cycle
-- new_clk:             Internal std_logic signal used to drive out_wave
-- valid_freq:          Internal std_logic signal to represent a valid input frequency (greater than 0 Hz)
signal count            : integer := 0;
signal max_pulse_count  : integer;
signal new_clk          : std_logic := '0';
signal valid_freq       : std_logic := '0';

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

begin

    -- Drives out_wave with internal new_clk signal
    out_wave <= new_clk;
    
    -- Drives valid_freq signal to '1' if freq is greater that 0 Hz, else '0'
    valid_freq <= isValidFreq(freq);
    
    update_count: process(clk, valid_freq) is
    begin
        if (rising_edge(clk)) then
            if (valid_freq = '1') then
                max_pulse_count <= calcPulseCount(freq);
            end if;
        end if;
    end process update_count;
      
    -- Counts the number of on-board clock cycles to generate a new clock of the given input frequency
    count_proc: process(clk, reset) is
    begin
        if (reset = '1') then
            count <= 0;
            new_clk <= '0';
        elsif (rising_edge(clk)) then
            if (ready = '0' or valid_freq = '0') then
                count <= 0;
                new_clk <= '0';
            elsif (count >= max_pulse_count) then
                count <= 0;
                new_clk <= not new_clk;
            else
                count <= count + 1;
            end if;
        end if;
    end process count_proc;
    
end architecture Behavioral;