library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity seqeucner is
    Generic (
            N_STEPS     : positive := 4;
            STEP_TIME   : time := 500 ms;
            REST_TIME   : time := 500 ms;
            );
    Port (
            clk         : in bit;
            reset       : in std_logic;
            sw          : in std_logic_vector(1 downto 0);
            out_freq    : out std_logic_vector(31 downto 0)
         );

    subtype step is integer range (0 to 2*N_STEPS);
end entity sequencer;

architecture behave of sequencer is

signal new_clk          : bit;
signal curr_step        : step := 0;
constant board_clk      : integer := 100000000;
constant board_clk_bits : integer := 27;
begin
    
    new_clock: entity work.clock_div(divide)
                Generic Map (board_clk, board_clk_bits);
                Port Map (clk => clk, reset => reset, freq => "101", clk_out => new_clk);

end architecture behave;
