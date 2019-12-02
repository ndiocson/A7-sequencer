----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:57:56 AM
-- Design Name: Clock Divider
-- Module Name: Clock_Divider - Behavioral
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

entity Clock_Divider is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            CLK_OUT_FREQ    : positive := 4         -- desired output frequency (default: 4 Hz)
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end Clock_Divider;

architecture Behavioral of Clock_Divider is

-- Counter Component Declaration
component Counter is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            MAX_COUNT       : positive := 520       -- maximum number of cycles to count to
            );
    Port ( 
            clk, reset      : in std_logic;
            max_reached     : out std_logic
            );
end component Counter;

-- MAX_COUNT:       Number of cycles in on-board clock to represent one new clock cycle
constant MAX_COUNT  : integer := integer(CLK_FREQ / CLK_OUT_FREQ) / 2;

-- new_clk:         Internal std_logic signal used to drive clk_out
-- toggle_clk:      Internal signal used to indicate when to toggle new_clk
signal new_clk      : std_logic := '0';
signal toggle_clk   : std_logic := '0';

begin
    
    -- Instantiates a Counter to drive the toggle_clk signal
    count_inst: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => MAX_COUNT)
        Port Map (clk => clk, reset => reset, max_reached => toggle_clk);
    
    -- Drives clk_out output with internal new_clk signal
    clk_out <= new_clk;
    
    -- Process that counts the number of on-board clock cycles needed 
    -- to generate a new clock of the given input frequency
    count_proc: process(reset, toggle_clk) is
    begin
        if (reset = '1') then
            new_clk <= '0';
        elsif (toggle_clk = '1') then
            new_clk <= not new_clk;
        end if;
    end process count_proc;  

end architecture Behavioral;