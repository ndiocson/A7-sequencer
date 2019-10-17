----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/11/2019 11:12:20 PM
-- Design Name: UART Transmitter
-- Module Name: UART_Tx - Behavioral
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
use IEEE.numeric_std.all;

entity UART_Tx is
    Generic (
            BAUD_RATE       : integer := 9600;
            BIT_FREQ_CNT    : integer := 1040;
            SAMPLE_FREQ_CNT : integer := 520;
            TRAN_BITS       : integer := 8
            );
    Port (
            reset           : in std_logic;
            tx_bits         : in std_logic_vector(TRAN_BITS - 1 downto 0);
            output_stream   : out std_logic
            );
end entity UART_Tx;

architecture Behavioral of UART_Tx is

-- CLK_FREQ:        Constant frequency of on-board clock (10 MHz for Arty A7-35T)
constant CLK_FREQ   : positive := 1E7;

begin

end architecture Behavioral;