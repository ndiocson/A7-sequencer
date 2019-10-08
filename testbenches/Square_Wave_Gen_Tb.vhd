----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/29/2019 08:33:13 AM
-- Design Name: Square Wave Generator Testbench
-- Module Name: Square_Wave_Gen_Tb - Test
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

entity Square_Wave_Gen_Tb is
end Square_Wave_Gen_Tb;

architecture Test of Square_Wave_Gen_Tb is

-- Square_Wave_Gen Component Declaration
component Square_Wave_Gen is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            FREQ_WIDTH      : positive := 32        -- width of frequency input
            );
    Port ( 
            clk, reset      : in std_logic;
            freq            : in std_logic_vector(FREQ_WIDTH - 1 downto 0);
            out_wave        : out std_logic
            );
end component Square_Wave_Gen;

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal freq             : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(220, 32));

-- Output Signal
signal out_wave         : std_logic := '0';

begin
    
    -- Instantiates device under test
    DUT: entity work.Square_Wave_Gen(Behavioral)
        Generic Map (CLK_FREQ => open, FREQ_WIDTH => open)
        Port Map (clk => clk, reset => reset, freq => freq, out_wave => out_wave);
        
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
        freq <= (others => '1');
        wait for 40 ms;
--        reset <= '1';
        wait for 10 ms;
        freq <= std_logic_vector(to_unsigned(440, 32));
        wait for 10 ms;
--        reset <= '0';
        wait for 40 ms;
        freq <= (others => '1');
        wait for 50 ms;       
        freq <= std_logic_vector(to_unsigned(880, 32));
        wait for 50 ms;
        freq <= (others => '1');
        wait for 50 ms;        
        freq <= std_logic_vector(to_unsigned(220, 32));
        wait;
    end process stimulus;
    
end architecture Test;
