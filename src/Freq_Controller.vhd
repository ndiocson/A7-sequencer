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
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            FREQ_WIDTH      : positive := 32
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
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            TRAN_BITS       : positive := 8
            );
    Port (
            clk, reset      : in std_logic;
            input_stream    : in std_logic;
            rx_bits         : out std_logic_vector(TRAN_BITS - 1 downto 0)
            );
end component UART_Rx;

-- rx_bits:         Internal signal vector to hold received bits from data_stream
signal rx_bits      : std_logic_vector(FREQ_WIDTH - 1 downto 0) := (others => '1');

begin

    -- Instantiates a UART Receiver to collect the bits representing the note frequency value
    receiver: UART_Rx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, input_stream => input_stream, rx_bits => rx_bits);
    
    -- Process to output received frequency bits when ready input is set to '1'
    read_stream: process(clk, reset, ready) is
    begin
        if (reset = '1') then
            note_freq <= (others => '1');
        elsif (rising_edge(clk)) then
            if (ready = '1') then
                note_freq <= rx_bits;
            end if;
        end if;
    end process;
    
end architecture Behavioral;