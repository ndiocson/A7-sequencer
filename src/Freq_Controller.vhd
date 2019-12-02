----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/13/2019 11:16:15 PM
-- Design Name: Frequency Controller
-- Module Name: Freq_Controller - Behavioral
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
use IEEE.numeric_std.all;

entity Freq_Controller is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            FREQ_WIDTH      : positive := 32        -- width of frequency input (default: 32 bits)
            );
    Port (
            clk             : in std_logic;
            reset           : in std_logic;
            input_stream    : in std_logic;
            ready           : in std_logic;
            note_freq       : out std_logic_vector(FREQ_WIDTH - 1 downto 0)
            );
end entity Freq_Controller;

architecture Behavioral of Freq_Controller is

-- UART_Rx Component Declaration
component UART_Rx is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            TRAN_BITS       : positive := 8         -- number of transmission bits (defualt: 8)
            );
    Port (
            clk, reset      : in std_logic;
            input_stream    : in std_logic;
            rx_data         : out std_logic_vector(TRAN_BITS - 1 downto 0)
            );
end component UART_Rx;

-- rx_bits:         Internal signal vector to hold received bits from data_stream
signal rx_data      : std_logic_vector(FREQ_WIDTH - 1 downto 0) := (others => '1');

begin

    -- Instantiates a UART Receiver to collect the bits representing the note frequency value
    receiver: UART_Rx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, input_stream => input_stream, rx_data => rx_data);
    
    -- Process to output received frequency bits when ready input is set to '1'
    read_stream: process(clk, reset, ready) is
    begin
        if (reset = '1') then
            note_freq <= (others => '1');
        elsif (rising_edge(clk)) then
            if (ready = '1') then
                note_freq <= rx_data;
            end if;
        end if;
    end process;
    
end architecture Behavioral;