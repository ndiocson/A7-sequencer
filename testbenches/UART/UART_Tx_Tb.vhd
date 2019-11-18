----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/29/2019 07:42:41 PM
-- Design Name: UART Tranceiver Testbench
-- Module Name: UART_Tx_Tb - Test
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

entity UART_Tx_Tb is
end entity UART_Tx_Tb;

architecture Test of UART_Tx_Tb is

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

-- Simulatted Clock Period
constant CLK_PERIOD     : time := 100 ns;

-- Number of transmission bits
constant TRAN_BITS      : integer := 8;

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_bits          : std_logic_vector(TRAN_BITS - 1 downto 0) := "00000000";

-- Output Signals
signal output_stream    : std_logic;

begin

    -- Instantiates device under test
    DUT: UART_Tx
        Generic Map(BAUD_RATE => open, BIT_CNT => open, SAMPLE_CNT => open, TRAN_BITS => TRAN_BITS)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_bits => tx_bits, output_stream => output_stream);

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
        wait for 175 us;
        transmit <= '1';
        wait for 25 us;
        transmit <= '0';
        
        wait for 1000 us;

        tx_bits <= "11111111";
        wait for 50 us;
        transmit <= '1';
        wait for 25 us;
        transmit <= '0';
        
        -- Reset Test
        wait for 500 us;
        reset <= '1';
        wait for 50 us;
        reset <= '0';
        wait for 450 us;
        
        tx_bits <= "01010101";
        wait for 50 us;
        transmit <= '1';
        wait for 25 us;
        transmit <= '0';
        wait;
    end process stimulus;

end architecture Test;
