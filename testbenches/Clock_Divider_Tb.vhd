----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/25/2019 09:00:38 PM
-- Design Name: Clock Divider Testbench
-- Module Name: Clock_Divider_Tb - Test
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

entity Clock_Divider_Tb is
end entity Clock_Divider_Tb;

architecture Test of Clock_Divider_Tb is

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

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';

-- Output Signal
signal clk_out          : std_logic := '0';

begin

    -- Instantiates device under test
    DUT: entity work.Clock_Divider(Behavioral)
        Generic Map (CLK_FREQ => open, CLK_OUT_FREQ => 220)
        Port Map (clk => clk, reset => reset, clk_out => clk_out);

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
        wait for 50 ms;
        reset <= '1';
        wait for 10 ms;
        reset <= '0';
        wait;
    end process stimulus;

end architecture Test;
