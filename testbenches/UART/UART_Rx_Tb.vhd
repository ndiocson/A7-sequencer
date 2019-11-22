----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/13/2019 01:25:27 PM
-- Design Name: UART Receiver Testbench
-- Module Name: UART_Rx_Tb - Test
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

entity UART_Rx_Tb is
end entity UART_Rx_Tb;

architecture Test of UART_Rx_Tb is

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

-- CLK_PERIOD:          Simulatted Clock Period
-- TRAN_BITS:           Number of transmission bits
constant CLK_PERIOD     : time := 100 ns;
constant TRAN_BITS      : integer := 8;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal input_stream     : std_logic := '1';

-- Output Signal
signal rx_bits          : std_logic_vector(TRAN_BITS - 1 downto 0);

begin

    -- Instantiates device under test
    DUT: UART_Rx
        Generic Map(BAUD_RATE => open, BIT_CNT => open, SAMPLE_CNT => open, TRAN_BITS => TRAN_BITS)
        Port Map (clk => clk, reset => reset, input_stream => input_stream, rx_bits => rx_bits);

    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;

    -- Process to stimulate input signals of DUT
    stimulus: process is
    begin

        -- Functionality Test
        wait for 300 us;
        input_stream <= '0';
        wait for 208 us;
        input_stream <= '1';
        wait for 312 us;
        input_stream <= '0';
        wait for 208 us;
        input_stream <= '1';
        wait for 104 us;
        input_stream <= '0';
        wait for 104 us;
        input_stream <= '1'; 
        wait for 300 us;

        -- Invalid Input Stream Test
--        wait for 300 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 312 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 104 us;
--        input_stream <= '0';
--        wait for 208 us;
        
--        input_stream <= '1';
--        wait for 300 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 312 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 104 us;
--        input_stream <= '0';
--        wait for 104 us;        
--        input_stream <= '1';
--        wait for 300 us;
        
        -- Reset Test
--        wait for 300 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 312 us;
--        input_stream <= '0';
--        wait for 208 us;
--        input_stream <= '1';
--        wait for 104 us;
--        reset <= '1';
--        wait for 50 us;
--        reset <= '0';
--        input_stream <= '0';
--        wait for 104 us;
--        input_stream <= '1'; 
--        wait for 300 us;
    end process stimulus;

end architecture Test;
