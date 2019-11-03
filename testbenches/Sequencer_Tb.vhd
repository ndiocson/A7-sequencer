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
end Sequencer_Tb;

architecture Test of Sequencer_Tb is

-- Sequencer Component Declaration
component Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            FREQ_WIDTH          : positive := 32;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset          : in std_logic;
            strt, stop          : in std_logic;
            step_ready          : in std_logic_vector(N_STEPS downto 1);
            note_stream         : in std_logic_vector(N_STEPS downto 1);
            step_out            : out std_logic_vector(N_STEPS downto 1);
            out_wave            : out std_logic
            );
end component Sequencer;

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
-- BAUD_RATE:           9600 bits per second
-- BIT_CNT:             Number of clock cycles to represent a bit
-- SAMPLE_CNT           Number of clock cycles to sample a bit
-- FREQ_WIDTH:          
-- N_STEPS:             Number of steps in sequencer
constant CLK_PERIOD     : time := 100 ns;
constant BAUD_RATE      : positive := 9600;
constant BIT_CNT        : positive := 1040;
constant SAMPLE_CNT     : positive := 520;
constant FREQ_WIDTH     : positive := 32;
constant N_STEPS        : positive := 4;

-- freq_arr:            std_logic_vector array of length N_STEPS used to represent the frequency of each step
type freq_arr is array (1 to N_STEPS) of std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- Input Signals
signal clk              : std_logic := '0';
signal reset            : std_logic := '0';
signal strt             : std_logic := '0';
signal stop             : std_logic := '0';
signal transmit         : std_logic := '0';
signal step_ready       : std_logic_vector(N_STEPS downto 1);
signal note_stream      : std_logic_vector(N_STEPS downto 1);
signal step_out         : std_logic_vector(N_STEPS downto 1);
signal note_freq        : freq_arr := (others => (others => '1'));

-- Output Signal
signal out_wave         : std_logic := '0';

begin
    
    -- Instantiates device under test
    DUT: Sequencer
        Generic Map (N_STEPS => N_STEPS, STEP_TIME => open, REST_TIME => open)
        Port Map (clk => clk, reset => reset, strt => strt, stop => stop, step_ready => step_ready, note_stream => note_stream, step_out => step_out, out_wave => out_wave);
    
    gen_transmitters: for index in 1 to N_STEPS generate
        transmitter: UART_Tx
            Generic Map (BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => FREQ_WIDTH)
            Port Map (clk => clk, reset => reset, transmit => transmit, tx_bits => note_freq(index), output_stream => note_stream(index));
    end generate gen_transmitters;
    
    -- Drives input clk signal
    drive_clk: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process drive_clk;
    
    -- Process to transmit note frequencies through UART_Tx
    note_assign: process is
    begin
        
        wait for 250 ms;
        note_freq(4) <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 100 ms;
        note_freq(1) <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 200 ms;
        note_freq(3) <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 150 ms;
        note_freq(2) <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 500 ms;
        note_freq(1) <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
        
        wait for 100 ms;
        note_freq(3) <= std_logic_vector(to_unsigned(220, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 200 ms;
        note_freq(2) <= std_logic_vector(to_unsigned(440, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';        
        
        wait for 150 ms;
        note_freq(4) <= std_logic_vector(to_unsigned(880, FREQ_WIDTH));
        transmit <= '1';
        wait for 20 us;
        transmit <= '0';
    end process note_assign;
    
    -- Process to sitmulate input signals of DUT
    stimulus: process is
    begin
        step_ready <= (others => '1');
        wait for 100 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 330 ms;
        stop <= '1';
        wait for 20 ms;
        stop <= '0';
        
        wait for 200 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        
        wait for 1000 ms;
        reset <= '1';
        wait for 20 ms;
        reset <= '0';
        
        wait for 300 ms;
        strt <= '1';
        wait for 20 ms;
        strt <= '0';
        wait;
    end process stimulus;
    
end Test;
