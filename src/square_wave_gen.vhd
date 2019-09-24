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
    Port ( 
            clk, reset  : in std_logic;
            freq        : in std_logic_vector(31 downto 0);
            out_wave    : out std_logic
            );
end Square_Wave_Gen;

architecture Behavioral of Square_Wave_Gen is

-- wave_freq:           Frequency of desired square wave 
constant wave_freq      : integer := to_integer(unsigned(freq));

-- new_clk:             Internal std_logic signal used to drive out_wave
signal new_clk          : std_logic := '0';

begin

    -- Instantiates Clock_Divider with default actual generic values
    new_clock: entity work.Clock_Divider(Behavioral)
                Generic Map (CLK_FREQ => open, CLK_OUT_FREQ => wave_freq)
                Port Map(clk => clk, reset => reset, clk_out => new_clk);
    
    -- Drives out_wave with internal new_clk signal
    out_wave <= new_clk;
    
    -- Drives new_clk to 0 if reset 
    reset_wave: process(clk) is
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                new_clk <= '0';
            end if;
        end if;
    end process reset_wave;
    
end Behavioral;