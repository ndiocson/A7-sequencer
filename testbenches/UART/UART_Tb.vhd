----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/31/2019 07:19:03 AM
-- Design Name: UART Testbench
-- Module Name: UART_Tb - Test
-- Project Name: UART
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

entity UART_Tb is
end entity UART_Tb;

architecture Test of UART_Tb is

component UART_Rx is
    Generic (
            BAUD_RATE       : integer := 9600;
            BIT_CNT         : integer := 1040;
            SAMPLE_CNT      : integer := 520;
            TRAN_BITS       : integer := 8
            );
    Port (
            clk, reset      : in std_logic;
            input_stream    : in std_logic;
            rx_bits         : out std_logic_vector(TRAN_BITS - 1 downto 0)
            );
end component UART_Rx;

component UART_Tx is
    Generic (
            BAUD_RATE       : integer := 9600;
            BIT_CNT         : integer := 1040;
            SAMPLE_CNT      : integer := 520;
            TRAN_BITS       : integer := 8
            );
    Port (
            clk, reset      : in std_logic;
            transmit        : in std_logic;
            tx_bits         : in std_logic_vector(TRAN_BITS - 1 downto 0);
            output_stream   : out std_logic
            );
end component UART_Tx;

-- CLK_PERIOD:          Simulatted Clock Period
-- BAUD_RATE:           9600 bits per second
-- BIT_CNT:             Number of clock cycles to represent a bit
-- SAMPLE_CNT           Number of clock cycles to sample a bit
-- TRAN_BITS:           Number of transmission bits
constant CLK_PERIOD     : time := 100 ns;
constant BAUD_RATE      : integer := 9600;
constant BIT_CNT        : integer := 1040;
constant SAMPLE_CNT     : integer := 520;
constant TRAN_BITS      : integer := 32;

-- data_stream:         Signal to be transmitted to and received from by both DUTs
signal data_stream      : std_logic;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_bits          : std_logic_vector(TRAN_BITS - 1 downto 0);

-- Output Signal
signal rx_bits          : std_logic_vector(TRAN_BITS - 1 downto 0);

begin
    
    -- Instantiates receiver device under test
    DUT_Rx: UART_Rx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, input_stream => data_stream, rx_bits => rx_bits);

    -- Instantiates tranceiver device under test
    DUT_Tx: UART_Tx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => TRAN_BITS)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_bits => tx_bits, output_stream => data_stream);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to stimulate input signals of both DUTss
    stimulus: process is
    begin
        wait for 100 us;
        tx_bits <= "01010101010101010101010101010101";
        transmit <= '1';
        wait for 50 us;
        transmit <= '0';
        
        wait for 1000 us;
        tx_bits <= "00000000000000000000000000000000";
        wait for 3000 us;
        transmit <= '1';
        wait for 50 us;
        transmit <= '0';
        
--        wait for 4000 us;
--        tx_bits <= "11111111111111111111111111111111";
--        transmit <= '1';
--        wait for 50 us;
--        transmit <= '0';
        wait;
    end process stimulus;

end architecture Test;