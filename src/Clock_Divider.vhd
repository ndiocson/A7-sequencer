----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:57:56 AM
-- Design Name: Clock Divider
-- Module Name: Clock_Divider - Behavioral
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

entity Clock_Divider is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            CLK_OUT_FREQ    : positive := 4;        -- desired output frequency (default: 4 Hz)
            DUTY_CYCLE      : real := 0.5           -- duty cycle of output clock  (default: 50%)
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end Clock_Divider;

architecture Behavioral of Clock_Divider is

-- Counter Component Declaration
component Counter is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            MAX_COUNT       : integer := 100        -- maximum number of cycles to count to (default: 100)
            );
    Port ( 
            clk, reset      : in std_logic;
            max_reached     : out std_logic
            );
end component Counter;

-- MAX_COUNT:           Total number of on-board clock cycles for a clock period
-- MAX_COUNT_HIGH:      Number of on-board clock cycled for a high pulse
-- MAX_COUNT_LOW:       Number of on-board clock cycles for a low pulse
constant MAX_COUNT      : integer := integer(CLK_FREQ / CLK_OUT_FREQ);
constant MAX_COUNT_HIGH : integer := integer(MAX_COUNT * DUTY_CYCLE);
constant MAX_COUNT_LOW  : integer := MAX_COUNT - MAX_COUNT_HIGH;

-- duty_cycle_type:   
subtype duty_cycle_type is real range 0.0 to 1.0;

-- new_clk:         Internal signal used to drive clk_out
-- init_clk:        Internal signal used to initialize new_clk
signal new_clk      : std_logic := '0';
signal init_clk     : std_logic := '1';

-- reset_high:      Internal reset signal for high pulse counter of new_clk
-- reset_low:       Internal reset signal for low pulse counter of new_clk
-- toggle_off:     Internal signal used to toggle off new_clk
-- toggle_on:      Internal signal used to toggle on new_clk
signal reset_high   : std_logic := '1';
signal reset_low    : std_logic := '0';
signal toggle_off   : std_logic := '0';
signal toggle_on    : std_logic := '0';

-- isValidDutyCycle:    Function that returns true if the given duty_cycle is within the appropriate range
function isValidDutyCycle(duty_cycle : real) return boolean is
variable isValid    : boolean := false;
begin
    if (duty_cycle > duty_cycle_type'low and duty_cycle < duty_cycle_type'high) then
        isValid := true;
    end if;
    return isValid;
end function isValidDutyCycle;

begin
    
    -- Instantiates a Counter to drive the toggle_high signal
    count_high: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => MAX_COUNT_HIGH)
        Port Map (clk => clk, reset => reset_high, max_reached => toggle_off);
        
    -- Instantiates a Counter to drive the toggle_low signal
    count_low: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => MAX_COUNT_LOW)
        Port Map (clk => clk, reset => reset_low, max_reached => toggle_on);        
    
    -- Drives clk_out output with internal new_clk signal
    clk_out <= new_clk;
    
    -- Process to conntrol internal new_clk signal based on given duty cycle
    clock_control: process(reset, toggle_off, toggle_on) is
    begin
        if (reset = '1') then
            new_clk <= '0';
            reset_high <= '1';
            reset_low <= '1';
            init_clk <= '1';
        elsif (isValidDutyCycle(DUTY_CYCLE)) then
            if (init_clk = '1') then
                reset_low <= '0';
                init_clk <= '0';
            elsif (toggle_off = '1') then
                new_clk <= '0';
                reset_high <= '1';
                reset_low <= '0';
            elsif (toggle_on = '1') then
                new_clk <= '1';
                reset_high <= '0';
                reset_low <= '1';
            end if;
        elsif (DUTY_CYCLE >= duty_cycle_type'high) then
            new_clk <= '1';
            reset_high <= '1';
            reset_low <= '1';
        else
            new_clk <= '0';
            reset_high <= '1';
            reset_low <= '1';
        end if;
    end process clock_control;
    
end architecture Behavioral;