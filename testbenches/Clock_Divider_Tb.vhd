library IEEE;
use IEEE.std_logic_1164.all;

entity Clock_Divider_Tb is
end entity Clock_Divider_Tb;

architecture Test of Clock_Divider_Tb is

-- Clock_Divider Component Declaration
component Clock_Divider is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            CLK_OUT_FREQ    : positive := 4;        -- desired output frequency (default: 4 Hz)
            DUTY_CYCLE      : real := 0.5           -- duty cycle of output clock out of 100 (default: 50%)
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end component Clock_Divider;

-- CLK_PERIOD:          Simulated clock period
-- CLK_FREQ:            Clock frequency
-- CLK_OUT_FREQ:        Output frequency in Hz
constant CLK_PERIOD     : time := 100 ns;
constant CLK_FREQ       : positive := 1E7;
constant CLK_OUT_FREQ   : positive := 4;

-- dut_range:           Discrete range of DUTs to instantiate
subtype dut_range is integer range 0 to 10;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';

-- Output Signal
signal clk_out          : std_logic_vector(dut_range) := (others => '0');

begin

    -- Instantiates devices under test
    gen_dut: for index in dut_range generate
        DUT: Clock_Divider
            Generic Map (CLK_FREQ => CLK_FREQ, CLK_OUT_FREQ => CLK_OUT_FREQ, DUTY_CYCLE => (0.1)*index)
            Port Map (clk => clk, reset => reset, clk_out => clk_out(index));
    end generate gen_dut;

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
        
        wait for 800 ms;
        reset <= '1';
        wait for 200 ms;
        reset <= '0';
        
        wait;
    end process stimulus;

end architecture Test;