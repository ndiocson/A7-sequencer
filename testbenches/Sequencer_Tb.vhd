----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/05/2019 07:13:15 AM
-- Design Name: Squencer Testbench
-- Module Name: Sequencer_Tb - Test
-- Project Name: 
-- Target Devices: 
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

entity Sequencer_Tb is
end Sequencer_Tb;

architecture Test of Sequencer_Tb is

-- Sequencer Component Declaration
component Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset, pause   : in std_logic;
            step                : in std_logic_vector(N_STEPS - 1 downto 0);
            out_wave            : out std_logic
            );
end component Sequencer;

---- Clock_Divider Component Declaration
--component Clock_Divider is
--    Generic (
--            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
--            CLK_OUT_FREQ    : positive := 2         -- desired clock frequency (default 2 Hz)
--            );
--    Port (
--            clk, reset      : in std_logic;
--            clk_out         : out std_logic
--            );
--end component Clock_Divider;

---- Square_Wave_Gen Component Declaration
--component Square_Wave_Gen is
--    Generic (
--            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
--            FREQ_BITS       : positive := 32
--            );
--    Port ( 
--            clk, reset      : in std_logic;
--            freq            : in std_logic_vector(FREQ_BITS - 1 downto 0);
--            out_wave        : out std_logic
--            );
--end component Square_Wave_Gen;

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;
constant N_STEPS        : positive := 4;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal pause            : std_logic := '0';
signal step             : std_logic_vector(N_STEPS - 1 downto 0);

-- Output Signal
signal out_wave         : std_logic := '0';

begin
    
    -- Instantiates device under test
    DUT: entity work.Sequencer(Behavioral)
        Generic Map (N_STEPS => N_STEPS, STEP_TIME => open, REST_TIME => open)
        Port Map (clk => clk, reset => reset, pause => pause, step => step, out_wave => out_wave);
    
    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    stimulus: process is
    begin
        step <= "1111";
        wait;
    end process stimulus;
    
end Test;
