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

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal transmit         : std_logic := '0';
signal tx_data          : std_logic_vector(TRAN_BITS - 1 downto 0) := "00000000";

-- Output Signals
signal output_stream    : std_logic;

begin

    -- Instantiates device under test
    DUT: UART_Tx
        Generic Map(CLK_FREQ => CLK_FREQ, BAUD_RATE => BAUD_RATE, TRAN_BITS => TRAN_BITS)
        Port Map(clk => clk, reset => reset, transmit => transmit, tx_data => tx_data, output_stream => output_stream);

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

        tx_data <= "10101010";
        wait for 50 us;
        transmit <= '1';
        wait for 25 us;
        transmit <= '0';
        
        -- Reset Test
        wait for 500 us;
        reset <= '1';
        wait for 25 us;
        reset <= '0';
        wait for 450 us;
        
        tx_data <= "01010101";
        wait for 50 us;
        transmit <= '1';
        wait for 25 us;
        transmit <= '0';
        wait;
    end process stimulus;

end architecture Test;