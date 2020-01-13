----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:57:56 AM
-- Design Name: Clock Divider
-- Module Name: Clock_Divider - Behavioral
-- Project Name: N-Step Sequencer Board Demo
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
            DUTY_CYCLE      : integer := 50         -- duty cycle of output clock (default: 50%)
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
constant MAX_COUNT_HIGH : integer := integer((MAX_COUNT * DUTY_CYCLE) / 100);
constant MAX_COUNT_LOW  : integer := MAX_COUNT - MAX_COUNT_HIGH;

-- state:           Enumerated type to define states of simple FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (idle, count_low, count_high);
signal p_state, n_state : state := idle;

-- new_clk:         Internal signal used to drive clk_out
-- reset_high:      Internal reset signal for high pulse counter of new_clk
-- reset_low:       Internal reset signal for low pulse counter of new_clk
-- high_reached:    Internal signal used to toggle off new_clk
-- low_reached:     Internal signal used to toggle on new_clk
signal new_clk      : std_logic := '0';
signal reset_high   : std_logic := '1';
signal reset_low    : std_logic := '0';
signal high_reached : std_logic := '0';
signal low_reached  : std_logic := '0';

begin

    -- Instantiates a Counter to drive the toggle_high signal
    h_counter: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => MAX_COUNT_HIGH)
        Port Map (clk => clk, reset => reset_high, max_reached => high_reached);
        
    -- Instantiates a Counter to drive the toggle_low signal
    l_counter: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => MAX_COUNT_LOW)
        Port Map (clk => clk, reset => reset_low, max_reached => low_reached);
    
    -- Drives clk_out output with internal new_clk signal
    clk_out <= new_clk;
    
    -- Process that manages the present and next states
    state_machine: process(p_state, reset, high_reached, low_reached) is
    begin
        case p_state is
            
            when idle =>
                new_clk <= '0';
                reset_low <= '1';
                reset_high <= '1';
                if (reset = '0') then
                    n_state <= count_low;
                else
                    n_state <= idle;
                end if;
                
            when count_low =>
                new_clk <= '0';
                reset_low <= '0';
                reset_high <= '1';
                if (low_reached = '1') then
                    n_state <= count_high;
                else
                    n_state <= count_low;
                end if;
                
            when count_high =>
                new_clk <= '1';
                reset_low <= '1';
                reset_high <= '0';
                if (high_reached = '1') then
                    n_state <= count_low;
                else
                    n_state <= count_high;
                end if;
                
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= idle;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
        end if;
    end process memory_elem;
    
end architecture Behavioral;