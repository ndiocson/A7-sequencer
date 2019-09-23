library IEEE;
use IEEE.std_logic_1164.all;

entity clock_div is
    Generic (
            CLK_FREQ    : integer := 100000000; -- 10MHz on-board clock frequency
            BIT_DEPTH   : integer := 27
            );
    Port (
            clk         : in bit;
            reset       : in std_logic;
            freq        : std_logic_vector(2 downto 0);
            clk_out     : out bit
         );
end entity clock_div;

architecture divide of clock_div is

begin
    
end architecture divide;
