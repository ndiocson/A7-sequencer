----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/19/2019 11:55:14 AM
-- Design Name: UART Transmitter
-- Module Name: UART_Tx - Behavioral
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

entity UART_Tx is
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
end entity UART_Tx;

architecture Behavioral of UART_Tx is

-- Counter Component Declaration
component Counter is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            MAX_COUNT       : positive := 520       -- maximum number of cycles to count to
            );
    Port ( 
            clk, reset      : in std_logic;
            max_reached     : out std_logic
            );
end component Counter;

-- CLK_FREQ:        Constant frequency of on-board clock (10 MHz for Arty A7-35T)
constant CLK_FREQ   : positive := 1E7;

-- state:           Enumerated type to define states of Receiver FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (idle, send_start, send_bits, send_stop);
signal p_state, n_state : state := idle;

-- tx_size:     Defines the index range of transmission bits
subtype tx_size is integer range 0 to TRAN_BITS - 1;

-- tx_init:         Internal signal used to indicate when the input_stream is ready
-- tx_strt:         Internal signal used to indicate when to start reading transmission bits
-- tx_stop:         Internal signal used to indicate when to stop reading transmission bits
-- tx_done:         Internal signal used to indicate when the input_stream is finished
signal tx_init      : std_logic := '0';
signal tx_strt      : std_logic := '0';
signal tx_stop      : std_logic := '0';
signal tx_done      : std_logic := '0';

-- curr_pos:        Internal signal used to track the current data bit to transmit
-- write_bit:       Internal signal used to indicate when to write a bit to the output_stream
-- new_write:       Internal signal used to indicate when to latch the data to be transmitted
-- tx_buffer:       Internal signal buffer to hold the data to be transmitted
signal curr_pos     : tx_size := 0;
signal write_bit    : std_logic := '0';
signal new_write    : std_logic := '1';
signal tx_buffer    : std_logic_vector(TRAN_BITS - 1 downto 0);

begin

    -- Instantiates a Counter to drive the sample_bit signal
    sample_count: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => BIT_CNT + 1)
        Port Map (clk => clk, reset => reset, max_reached => write_bit);

    -- Process to latch the data to be transmitted if the UART is ready
    latch_data: process(new_write, tx_bits) is
    begin
        if (new_write = '1') then
            tx_buffer <= tx_bits;
        end if;
    end process latch_data;

    -- Process that manages the present and next states
    state_machine: process(p_state, tx_init, tx_strt, tx_stop, tx_done) is
    begin
        case p_state is
            when idle =>  
                if (tx_init = '1') then
                    n_state <= send_start;
                else
                    n_state <= p_state;
                end if;
            when send_start =>              
                if (tx_strt = '1') then
                    n_state <= send_bits;
                else
                    n_state <= p_state;
                end if;                
            when send_bits =>
                if (tx_stop = '1') then
                    n_state <= send_stop;
                else
                    n_state <= p_state;
                end if;
            when send_stop =>
                if (tx_done = '1') then
                    n_state <= idle;
                else
                    n_state <= p_state;                
                end if;
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= idle;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
        end if;
    end process memory_elem;
    
    -- Process that transmits data bits to the output_stream depending on the state
    transmit_proc: process(p_state, transmit, write_bit) is
    begin
        case p_state is
        
            -- Drives the output_stream to '1'
            when idle =>
                new_write <= '1';
                tx_strt <= '0';
                tx_stop <= '0';
                tx_done <= '0';
                output_stream <= '1';
                curr_pos <= tx_size'low;
                if (transmit = '1') then
                    tx_init <= '1';
                else
                    tx_init <= '0';
                end if;
            
            -- Sends the start '0' bit to the output_stream
            when send_start =>
                new_write <= '0';
                tx_init <= '0';
                tx_stop <= '0';
                tx_done <= '0';
                curr_pos <= tx_size'low;
                if (write_bit = '1') then
                    output_stream <= '0';
                    tx_strt <= '1';
                else
                    tx_strt <= '0';
                end if;
            
            -- Sequentially sends the data bits to the output_stream
            when send_bits =>
                new_write <= '0';
                tx_init <= '0';
                tx_strt <= '0';
                tx_done <= '0';
                if (write_bit = '1') then
                    if (curr_pos <= tx_size'high) then
                        output_stream <= tx_buffer(curr_pos);
                        curr_pos <= curr_pos + 1;
                        tx_stop <= '0';
                    else
                        curr_pos <= tx_size'low;
                        tx_stop <= '1';
                    end if;
                end if;
            
            -- Sends the stop '1' bit to the output_stream
            when send_stop =>
                new_write <= '0';
                tx_init <= '0';
                tx_strt <= '0';
                tx_stop <= '0';
                tx_done <= '1';
                output_stream <= '1';
                curr_pos <= tx_size'low;
                
        end case;
    end process transmit_proc;
    
end architecture Behavioral;