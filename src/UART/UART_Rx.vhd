----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/11/2019 11:12:20 PM
-- Design Name: UART Receiver
-- Module Name: UART_Rx - Behavioral
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

entity UART_Rx is
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
end entity UART_Rx;

architecture Behavioral of UART_Rx is

-- Counter Component Declaration
component Counter is
    Generic (
            CLK_FREQ        : positive := 1E8;      -- on-board clock frequency (default: 100 MHz)
            MAX_COUNT       : integer := 100        -- maximum number of cycles to count to (default: 100)
            );
    Port ( 
            clk, reset      : in std_logic;
            max_reached     : out std_logic
            );
end component Counter;

-- BIT_CNT:         Number of clock cycles to represent a bit
-- SAMPLE_CNT       Number of clock cycles to sample a bit
constant BIT_CNT    : positive := integer((CLK_FREQ / (16 * BAUD_RATE)) - 1);
constant SAMPLE_CNT : positive := BIT_CNT / 2;

-- state:           Enumerated type to define states of Receiver FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (idle, init_read, strt_read, stop_read);
signal p_state, n_state : state := idle;

-- bit_pos:         Internal signal used to track current positon of the transmission bit to sample
-- reset_count:     Internal signal used to reset counter instantiations
-- sample_bit:      Internal signal used to indicate when the current bit may be read from the input_stream
-- sample:          Internal signal used to indicate when the current bit may sampled during the strt_read state
-- out_bits:        Internal signal used to hold the transmission bits while they are read
signal bit_pos      : integer := 0;
signal reset_count  : std_logic := '1';
signal sample_bit   : std_logic := '0';
signal sample       : std_logic := '0';
signal out_bits     : std_logic_vector(TRAN_BITS - 1 downto 0) := (others => '0');

begin
    
    -- Instantiates a Counter to drive the sample_bit signal
    sample_count: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => SAMPLE_CNT)
        Port Map (clk => clk, reset => reset_count, max_reached => sample_bit);
        
    -- Process that receives data bits from the input_stream depending on the state
    state_machine: process(p_state, input_stream, sample_bit, sample) is
    begin
        case p_state is
            
            -- Monitors the input_stream and enters the 'init_read' state when the stream first goes to '0'
            when idle =>
                bit_pos <= 0;
                reset_count <= '1';
                n_state <= p_state;
                if (falling_edge(input_stream)) then
                    n_state <= init_read;
                end if;
            
            -- Enters the 'strt_read' state once the start bit has been received
            when init_read =>
                bit_pos <= 0;
                reset_count <= '0';           
                if (sample_bit = '1') then
                    if (input_stream = '0') then
                        n_state <= strt_read;
                    end if;
                end if;
            
            -- Samples bits until the out_bits vector is filled
            -- Increments the current bit position while sampling the input_stream
            when strt_read =>
                reset_count <= '0';
                if (bit_pos < TRAN_BITS) then
                    if (rising_edge(sample)) then
                        out_bits(bit_pos) <= input_stream;
                        bit_pos <= bit_pos + 1;
                    end if;
                else
                    n_state <= stop_read;
                end if;
            
            -- Stores the received bits once the transmission is finished 
            when stop_read =>
                bit_pos <= 0;
                reset_count <= '0';
                if (sample_bit = '1') then
                    if (input_stream = '1') then
                        rx_data <= out_bits;
                    else
                        rx_data <= (others => '0');
                    end if;
                    n_state <= idle;
                end if;
                
        end case;
    end process state_machine;
    
    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset, sample_bit) is
    begin
        if (reset = '1') then
            p_state <= idle;
        elsif (rising_edge(clk)) then
            p_state <= n_state;
            if (p_state = strt_read) then
                if (sample_bit = '1') then
                    sample <= not sample;
                end if;
            else
                sample <= '0';
            end if;
        end if;
    end process memory_elem;
    
end architecture Behavioral;