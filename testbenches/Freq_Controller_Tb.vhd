----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/13/2019 11:55:19 PM
-- Design Name: Frequency Controller Testbench
-- Module Name: Freq_Controller_Tb - Test
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

entity Freq_Controller_Tb is
end entity Freq_Controller_Tb;

architecture Test of Freq_Controller_Tb is

-- Freq_Controller Component Declaration
component Freq_Controller is
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
end component Freq_Controller;

-- UART_Tx Component Declaration
component UART_Tx is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            TRAN_BITS       : positive := 8         -- number of transmission bits (defualt: 8)
            );
    Port (
            clk, reset      : in std_logic;
            transmit        : in std_logic;
            tx_data         : in std_logic_vector(TRAN_BITS - 1 downto 0);
            output_stream   : out std_logic
            );
end component UART_Tx;

-- CLK_PERIOD:          Simulated clock period
-- CLK_FREQ:            Clock frequency
-- BAUD_RATE:           9600 bits per second
-- FREQ_WIDTH:          Number of bits to represent note frequencies
constant CLK_PERIOD     : time := 100 ns;
constant CLK_FREQ       : positive := 1E8;
constant BAUD_RATE      : positive := 9600;
constant FREQ_WIDTH     : positive := 32;

-- data_stream:         Signal to be transmitted to and received from 
signal data_stream     : std_logic := '1';

-- Input Signals
signal clk, reset       : std_logic := '0';
signal ready            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_data          : std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- Output Signal
signal note_freq        : std_logic_vector(FREQ_WIDTH - 1 downto 0);

begin
    
    -- Instantiates device under test
    DUT: Freq_Controller
        Generic Map (CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, FREQ_WIDTH => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, input_stream => data_stream, ready => ready, note_freq => note_freq);
    
    -- Instantiates a UART Transmitter to send the bits to the stream
    transmitter: UART_Tx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => FREQ_WIDTH)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_data => tx_data, output_stream => data_stream);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to transmit note frequencies through UART_Tx
    send_bits: process is
    begin
        
        wait for 25 ms;
        tx_data <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 25 ms;
        tx_data <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 25 ms;
        tx_data <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait;
    end process send_bits;
    
    -- Process to sitmulate input signals of DUT
    stimulus: process is
    begin
        
        wait for 20 ms;
        ready <= '1';
        wait for 10 ms;
        ready <= '0';
        
        wait for 15 ms;
        ready <= '1';
        wait for 10 ms;
        ready <= '0';
        
        wait for 15 ms;
        ready <= '1';
        wait for 10 ms;
        ready <= '0';
        
        wait for 15 ms;
        reset <= '1';
        wait for 5 ms;
        reset <= '0';
        
        wait;
    end process stimulus;

end architecture Test;