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
use IEEE.numeric_std.all;

entity Note_Handler_Tb is
end entity Note_Handler_Tb;

architecture Test of Note_Handler_Tb is

component Note_Handler is
    Generic (
            N_STEPS         : positive := 4;
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            FREQ_WIDTH      : positive := 32
            );
    Port (
            clk, reset      : in std_logic;
            note_stream     : in std_logic;
            note_index      : out integer;
            note_freq       : out std_logic_vector(FREQ_WIDTH - 1 downto 0)
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

-- CLK_PERIOD:          Simulatted Clock Period
-- N_STEPS:             4 steps in sequencer
-- BAUD_RATE:           9600 bits per second
-- BIT_CNT:             Number of clock cycles to represent a bit
-- SAMPLE_CNT           Number of clock cycles to sample a bit
-- FREQ_WIDTH:          Number of bits to represent note frequencies
constant CLK_PERIOD     : time := 100 ns;
constant N_STEPS        : positive := 4;
constant BAUD_RATE      : positive := 9600;
constant BIT_CNT        : positive := 1040;
constant SAMPLE_CNT     : positive := 520;
constant FREQ_WIDTH     : positive := 32;

-- data_stream:         Signal to be transmitted to and received from by both DUTs
signal note_stream      : std_logic;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_bits          : std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- Output Signal
signal note_index       : integer;
signal note_freq        : std_logic_vector(FREQ_WIDTH - 1 downto 0);

begin
    
    -- Instantiates device under test
    DUT: Note_Handler
        Generic Map (N_STEPS => N_STEPS, BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, FREQ_WIDTH => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, note_stream => note_stream, note_index => note_index, note_freq => note_freq);
        
    -- Instantiates transmitter to stimulate data_stream
    transmitter: UART_Tx
        Generic Map (BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, transmit => transmit, tx_bits => tx_bits, output_stream => note_stream);
        
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
        
        -- 220Hz note frequency
        wait for 50 ms;
        tx_bits <= std_logic_vector(to_unsigned(1, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 50 ms;
        tx_bits <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 50 ms;
        
        -- 440Hz note frequency
        tx_bits <= std_logic_vector(to_unsigned(2, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 50 ms;
        tx_bits <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        -- Tests reset signal
        wait for 25 ms;
        reset <= '1';
        wait for 20 us;
        reset <= '0';
        
        wait for 50 ms;
        
        -- 880Hz note frequency
        tx_bits <= std_logic_vector(to_unsigned(3, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 50 ms;
        tx_bits <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait;
    end process stimulus;

end architecture Test;
