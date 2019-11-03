----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/02/2019 03:02:45 PM
-- Design Name: Note Handler Testbench
-- Module Name: Note_Handler_Tb - Test
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

entity Note_Handler_Tb is
end entity Note_Handler_Tb;

architecture Test of Note_Handler_Tb is

component Note_Handler is
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
end component Note_Handler;

component UART_Tx is
    Generic (
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            TRAN_BITS       : positive := 8
            );
    Port (
            clk, reset      : in std_logic;
            transmit        : in std_logic;
            tx_bits         : in std_logic_vector(TRAN_BITS - 1 downto 0);
            output_stream   : out std_logic
            );
end component UART_Tx;

-- CLK_PERIOD:      Simulatted Clock Period
-- BAUD_RATE:       9600 bits per second
-- BIT_CNT:         Number of clock cycles to represent a bit
-- SAMPLE_CNT       Number of clock cycles to sample a bit
-- TRAN_BITS:       Number of transmission bits
constant CLK_PERIOD : time := 100 ns;
constant BAUD_RATE  : integer := 9600;
constant BIT_CNT    : integer := 1040;
constant SAMPLE_CNT : integer := 520;
constant TRAN_BITS  : integer := 32;

-- data_stream:     Signal to be transmitted to and received from by both DUTs
signal data_stream  : std_logic;

-- Input Signals
signal clk          : std_logic := '0';
signal reset        : std_logic := '0';
signal transmit     : std_logic := '0';
signal tx_bits      : std_logic_vector(TRAN_BITS - 1 downto 0);

-- Output Signal
signal note_value   : std_logic_vector(TRAN_BITS - 1 downto 0);

begin
    
    -- Instantiates device under test
    DUT: Note_Handler
        Generic Map (BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, data_stream => data_stream, note_value => note_value);
        
    -- Instantiates transmitter to stimulate data_stream
    transmitter: UART_Tx
        Generic Map (BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, transmit => transmit, tx_bits => tx_bits, output_stream => data_stream);
        
    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    stimulus: process is
    begin
        
        -- 220Hz note frequency
        tx_bits <= "00000000000000000000000011011100";
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 100 ms;
        
        -- 440Hz note frequency
        tx_bits <= "00000000000000000000000110111000";
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        -- Tests reset signal
        wait for 400 us;
        reset <= '1';
        wait for 20 us;
        reset <= '0';
        
        wait for 100 ms;
        
        -- 880Hz note frequency
        tx_bits <= "00000000000000000000001101110000";
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait;
    end process stimulus;

end architecture Test;
