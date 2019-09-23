library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

-- count:           Signal to keep track of current count
-- clk_period:      Period for on-board clock frequency
-- clk_out_period:  Period for new clock, given frequency
-- max_count:       Number of cucles in on-board clock to represent one new clock cycle
signal count            : std_logic_vector(31 downto 0) := (others => '0');
constant clk_period     : integer := to_integer(1 / CLK_FREQ);
constant clk_out_period : integer := to_integer((1 / to_integer(unsigned(freq))));
constant max_count      : std_logic_vector(31 downto 0) := std_logic_vector(unsigned(to_integer(clk_out_period / clk_period)));

begin
    
    -- Process to count number of cycles from on-board clock
    -- needed to generate new clock of given frequency
    count_proc: process(clk) is
        if (rising_edge(clk)) then
            if (count >= max_count or reset = '1') then
                count <= (others => '0');
                clk_out <= not clk_out;
            else
                count <= count + 1;
            end if;
        end if;
    end process count_proc;
    
end architecture divide;
