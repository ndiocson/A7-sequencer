library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Clock_Divider_Tb is

end entity Clock_Divider_Tb;

architecture Test of Clock_Divider_Tb is

constant CLK_FREQ       : integer := 10000000;          -- Simulate 10 MHz on-board clock
constant CLK_PERIOD     : integer := 1 / CLK_FREQ;      -- TODO: fix type errors

constant CLK_OUT_FREQ   : integer := 1;                 -- Desired 1 Hz clock
constant CLK_OUT_PERIOD : integer := 1 / CLK_OUT_FREQ;  -- TODO: fix type errors

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';

-- Output Signal
signal clk_out          : std_logic := '0';

begin

    -- Instantiates device under test
    DUT: entity work.Clock_Divider(Behavioral)
        Generic Map (CLK_FREQ => CLK_FREQ, CLK_OUT_FREQ => CLK_OUT_FREQ)
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
    -- TODO: add stimulus
    stimulus: process is
    begin
        
    end process stimulus;

end architecture Test;