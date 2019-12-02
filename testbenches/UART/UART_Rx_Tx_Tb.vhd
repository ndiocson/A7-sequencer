----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/31/2019 07:19:03 AM
-- Design Name: UART Rx and Tx Testbench
-- Module Name: UART_Rx_Tx_Tb - Test
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

entity UART_Rx_Tx_Tb is
end entity UART_Rx_Tx_Tb;

architecture Test of UART_Rx_Tx_Tb is

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

-- CLK_PERIOD:          Simulated Clock Period
-- CLK_FREQ:            Clock frequency
-- BAUD_RATE:           9600 bits per second
-- TRAN_BITS:           Number of transmission bits
constant CLK_PERIOD     : time := 10 ns;
constant CLK_FREQ       : positive := 1E8;
constant BAUD_RATE      : positive := 9600;
constant TRAN_BITS      : positive := 32;

-- data_stream:         Signal to be transmitted to and received from by both DUTs
signal data_stream      : std_logic;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_data          : std_logic_vector(TRAN_BITS - 1 downto 0);

-- Output Signal
signal rx_data          : std_logic_vector(TRAN_BITS - 1 downto 0);

begin
    
    -- Instantiates receiver device under test
    DUT_Rx: UART_Rx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, input_stream => data_stream, rx_data => rx_data);

    -- Instantiates transmitter device under test
    DUT_Tx: UART_Tx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => TRAN_BITS)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_data => tx_data, output_stream => data_stream);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to stimulate reset signal
    reset_stim: process is
    begin
        wait for 9 ms;
        reset <= '1';
        wait for 5 us;
        reset <= '0';
        wait;
    end process reset_stim;
    
    -- Process to stimulate input signals of both DUTss
    stimulus: process is
    begin
        wait for 100 us;
        tx_data <= "01010101010101010101010101010101";
        wait for 200 us;
        transmit <= '1';
        wait for 5 us;
        transmit <= '0';
        
        wait for 500 us;
        tx_data <= "00000000000000000000000000000000";
        wait for 200 us;
        transmit <= '1';
        wait for 5 us;
        transmit <= '0';
        
        wait for 300 us;
        tx_data <= "10101010101010101010101010101010";
        wait for 100 us;
        transmit <= '1';
        wait for 5 us;
        transmit <= '0';
        wait;
    end process stimulus;

end architecture Test;