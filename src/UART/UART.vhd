----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/24/2019 07:50:13 AM
-- Design Name: UART
-- Module Name: UART - Behavioral
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

entity UART is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            TRAN_BITS       : positive := 8         -- number of transmission bits (defualt: 8)
            );
    Port (
            clk, reset      : in std_logic;
            transmit        : in std_logic;
            tx_data         : in std_logic_vector(TRAN_BITS - 1 downto 0);
            rx_data         : out std_logic_vector(TRAN_BITS - 1 downto 0);
            Rx              : in std_logic;
            Tx              : out std_logic 
            );
end entity UART;

architecture Behavioral of UART is

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

begin

    -- Instantiates a UART receiver
    Rx_module: UART_Rx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, input_stream => Rx, rx_data => rx_data);

    -- Instantiates a UART transmitter
    Tx_module: UART_Tx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => TRAN_BITS)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_data => tx_data, output_stream => Tx);

end architecture Behavioral;