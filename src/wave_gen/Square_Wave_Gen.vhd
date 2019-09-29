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
            CLK_FREQ        : positive := 1E7       -- on-board clock frequency (10 MHz)
            );
    Port ( 
            clk, reset  : in std_logic;
            freq        : in std_logic_vector(31 downto 0);
            out_wave    : out std_logic
            );
end Square_Wave_Gen;

architecture Behavioral of Square_Wave_Gen is

-- count:           Internal integer signal to keep track of current count
-- new_clk:         Internal std_logic signal used to drive out_wave
-- max_count:       Number of cycles in on-board clock to represent one new clock cycle
signal count        : integer := 0;
signal new_clk      : std_logic := '0';
signal max_count    : integer := integer(CLK_FREQ / to_integer(unsigned(freq))) / 2;

begin

    -- Drives out_wave with internal new_clk signal
    out_wave <= new_clk;
    
    -- Drives max_count with freq signal
    max_count <= integer(CLK_FREQ / to_integer(unsigned(freq))) / 2;
      
    -- Process that counts the number of on-board clock cycles needed 
    -- to generate a new clock of the given input frequency
    count_proc: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                count <= 0;
                new_clk <= '0';
            elsif (count >= max_count) then
                count <= 0;
                new_clk <= not new_clk;
            else
                count <= count + 1;
            end if;
        end if;
    end process count_proc;
    
end architecture Behavioral;