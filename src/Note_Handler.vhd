----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/02/2019 01:57:16 PM
-- Design Name: Note Handler
-- Module Name: Note_Handler - Behavioral
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

entity Note_Handler is
    Generic (
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            TRAN_BITS       : positive := 32
            );
    Port (
            clk, reset      : in std_logic;
            data_stream     : in std_logic;
            note_value      : out std_logic_vector(TRAN_BITS - 1 downto 0)
            );
end entity Note_Handler;

architecture Behavioral of Note_Handler is

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
           
-- rx_bits:     Internal signal vector to hold received bits from data_stream
signal rx_bits  : std_logic_vector(TRAN_BITS - 1 downto 0);

begin
    
    -- Instantiates a UART Receiver to collect the bits representing the note frequency value
    receiver: UART_Rx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, input_stream => data_stream, rx_bits => rx_bits);

    -- Process to output received note frequency value
    latch_freq: process(rx_bits) is
    begin
        if (rx_bits = std_logic_vector(to_unsigned(0, TRAN_BITS))) then
            note_value <= (others => '1');
        else
            note_value <= rx_bits;
        end if;
    end process latch_freq;
    
end architecture Behavioral;
