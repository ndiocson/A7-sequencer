----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:57:56 AM
-- Design Name: Clock Divider
-- Module Name: Clock_Divider - Behavioral
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

entity Clock_Divider is
    Generic (
            CLK_FREQ        : integer := 10000000;      -- on-board clock frequency (default 10 MHz)
            CLK_OUT_FREQ    : integer := 1              -- desired clock frequency (default 1 Hz)
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end Clock_Divider;

architecture Behavioral of Clock_Divider is

-- clk_period:              Period for on-board clock frequency
-- clk_out_period:          Period for new clock, given frequency
-- max_count:               Number of cycles in on-board clock to represent one new clock cycle
constant clk_period         : real := Real(1 / CLK_FREQ);
constant clk_out_period     : real := Real(1 / CLK_OUT_FREQ);
constant max_count          : integer := integer(clk_out_period / clk_period);

-- count:                   Internal integer signal to keep track of current count
-- new_clk:                 Internal std_logic signal used to drive clk_out
signal count                : integer := 0;
signal new_clk              : std_logic := '0';

begin
    
    -- Drives clk_out output with internal new_clk signal
    clk_out <= new_clk;
    
    -- Process that counts the number of on-board clock cycles needed 
    -- to generate a new clock of the given input frequency
    count_proc: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (count >= max_count or reset = '1') then
                count <= 0;
                new_clk <= not new_clk;
            else
                count <= count + 1;
            end if;
        end if;
    end process count_proc;  

end Behavioral;