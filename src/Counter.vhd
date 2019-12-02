----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/13/2019 09:58:44 AM
-- Design Name: Counter
-- Module Name: Counter - Behavioral
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

entity Counter is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            MAX_COUNT       : positive := 100       -- maximum number of cycles to count to (default: 100)
            );
    Port ( 
            clk, reset      : in std_logic;
            max_reached     : out std_logic
            );
end entity Counter;

architecture Behavioral of Counter is

-- count:       Internal signal to keep track of current count
signal count    : integer := 0;

begin
    
    -- Process to increment count variable until the MAX_COUNT has been reached
    count_proc: process(clk, reset) is
    begin
        if (reset = '1') then
            count <= 0;
            max_reached <= '0'; 
        elsif (rising_edge(clk)) then
            if (count >= MAX_COUNT) then
                count <= 0;
                max_reached <= '1';
            else
                count <= count + 1;
                max_reached <= '0';
            end if;
        end if;
    end process count_proc;

end architecture Behavioral;