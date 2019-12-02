----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/05/2019 07:13:15 AM
-- Design Name: Sequencer Testbench
-- Module Name: Sequencer_Tb - Test
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

entity Sequencer_Tb is
end entity Sequencer_Tb;

architecture Test of Sequencer_Tb is

-- Sequencer Component Declaration
component Sequencer is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            SEQ_FREQ        : positive := 4;        -- frequency of the sequencer (default: 4 Hz)
            N_STEPS         : positive := 4;        -- number of steps in sequencer (default: 4 steps)
            BAUD_RATE       : positive := 9600;     -- rate of transmission (default: 9600 baud)
            FREQ_WIDTH      : positive := 32;       -- width of frequency input (default: 32 bits)
            STEP_TIME       : time := 500 ms;
            REST_TIME       : time := 500 ms
            );
    Port (
            clk, reset      : in std_logic;
            strt, stop      : in std_logic;
            input_stream    : in std_logic;
            step_ready      : in std_logic_vector(N_STEPS downto 1);
            step_out        : out std_logic_vector(N_STEPS downto 1);
            out_wave        : out std_logic
            );
end component Sequencer;

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
-- SEQ_FREQ:            Sequencer frequency
-- N_STEPS:             Number of steps in sequencer
-- BAUD_RATE:           9600 bits per second
-- FREQ_WIDTH:          Number of bits to represent note frequencies
constant CLK_PERIOD     : time := 10 ns;
constant CLK_FREQ       : positive := 1E8;
constant SEQ_FREQ       : positive := 20;
constant N_STEPS        : positive := 4;
constant BAUD_RATE      : positive := 9600;
constant FREQ_WIDTH     : positive := 32;

-- freq_arr:    std_logic_vector array of length N_STEPS used to represent the frequency of each step
type freq_arr is array (1 to N_STEPS) of std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- data_stream:         Signal to be transmitted to and received from 
signal data_stream     : std_logic := '1';

-- Input Signals
signal clk, reset       : std_logic := '0';
signal strt, stop       : std_logic := '0';
signal transmit         : std_logic := '0';
signal step_ready       : std_logic_vector(N_STEPS downto 1);
signal step_out         : std_logic_vector(N_STEPS downto 1);
signal tx_data          : std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- Output Signal
signal out_wave         : std_logic := '0';

begin
    
    -- Instantiates device under test
    DUT: Sequencer
        Generic Map (CLK_FREQ => CLK_FREQ, SEQ_FREQ => SEQ_FREQ, N_STEPS => N_STEPS, BAUD_RATE => BAUD_RATE, FREQ_WIDTH => FREQ_WIDTH, STEP_TIME => open, REST_TIME => open)
        Port Map (clk => clk, reset => reset, strt => strt, stop => stop, input_stream => data_stream, step_ready => step_ready, step_out => step_out, out_wave => out_wave);
    
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
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(4, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(1, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(3, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(2, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 1065 ms;
        
        tx_data <= std_logic_vector(to_unsigned(1, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(3, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(2, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 10 ms;
        tx_data <= std_logic_vector(to_unsigned(4, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        wait for 10 ms;        
        tx_data <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait;
    end process send_bits;
    
    -- Process to sitmulate input signals of DUT
    stimulus: process is
    begin
    
        step_ready <= (others => '1');
        wait for 100 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 300 ms;
        stop <= '1';
        wait for 20 ms;
        stop <= '0';
        
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 80 ms;
        step_ready <= "1010";
        
        wait for 360 ms;
        reset <= '1';
        wait for 20 ms;
        reset <= '0';
        
        wait for 80 ms;
        step_ready <= "0101";
        
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait;
    end process stimulus;
    
end architecture Test;