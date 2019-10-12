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
            clk, reset          : in std_logic;
            strt, stop          : in std_logic;
            step_on             : in std_logic_vector(N_STEPS - 1 downto 0);
            step_out            : out std_logic_vector(N_STEPS - 1 downto 0);
            out_wave            : out std_logic
            );
end component Sequencer;

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;
constant N_STEPS        : positive := 4;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal strt             : std_logic := '0';
signal stop             : std_logic := '0';
signal step_on          : std_logic_vector(N_STEPS - 1 downto 0);
signal step_out         : std_logic_vector(N_STEPS - 1 downto 0);

-- Output Signal
signal out_wave         : std_logic := '0';

begin
    
    -- Instantiates device under test
    DUT: entity work.Sequencer(Behavioral)
        Generic Map (N_STEPS => N_STEPS, STEP_TIME => open, REST_TIME => open)
        Port Map (clk => clk, reset => reset, strt => strt, stop => stop, step_on => step_on, step_out => step_out, out_wave => out_wave);
    
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
        step_on <= "1111";
        wait for 350 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        wait for 400 ms;
        stop <= '1';
        wait for 20 ms;
        stop <= '0';
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        wait for 1000 ms;
        reset <= '1';
        wait for 20 ms;
        reset <= '0';
        wait for 300 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        wait;
    end process stimulus;
    
end Test;
