----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/13/2019 10:07:04 AM
-- Design Name: Counter Testbench
-- Module Name: Counter_Tb - Test
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

entity Counter_Tb is
end entity Counter_Tb;

architecture Test of Counter_Tb is

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

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';

-- Output Signal
signal max_reached      : std_logic := '0';

begin
    
    -- Instatiates device under test
    DUT: entity work.Counter(Behavioral)
        Generic Map (CLK_FREQ => open, MAX_COUNT => open)
        Port Map (clk => clk, reset => reset, max_reached => max_reached);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to sitmulate input signals of DUT
    stimulus: process is
    begin
        wait for 1040 us;
        reset <= '1';
        wait for 20 ms;
        reset <= '0';
        wait;
    end process stimulus;

end architecture Test;
