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
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            TRAN_BITS       : positive := 8
            );
    Port (
            clk, reset      : in std_logic;
            input_stream    : in std_logic;
            rx_bits         : out std_logic_vector(TRAN_BITS - 1 downto 0)
            );
end entity UART_Rx;

architecture Behavioral of UART_Rx is

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
-- reset_count:     Internal signal used to reset counter instantiations
constant CLK_FREQ   : positive := 1E7;
signal reset_count  : std_logic := '1';

-- state:           Enumerated type to define states of Receiver FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (idle, init_read, strt_read, stop_read);
signal p_state, n_state : state := idle;

-- rx_init:         Internal signal used to indicate when the input_stream is ready
-- rx_strt:         Internal signal used to indicate when to start reading transmission bits
-- rx_stop:         Internal signal used to indicate when to stop reading transmission bits
-- rx_done:         Internal signal used to indicate when the input_stream is finished
signal rx_init      : std_logic := '0';
signal rx_strt      : std_logic := '0';
signal rx_stop      : std_logic := '0';
signal rx_done      : std_logic := '0';

-- bit_pos:         Internal signal used to track current positon of the transmission bit to sample
-- full_bit:        Internal signal used to indicate when a new bit is to be read from the input_stream
-- sample_bit:      Internal signal used to indicate when the current bit is to be sampled from the input_stream
-- out_bits:        Internal signal used to hold the transmission bits while they are read
signal bit_pos      : integer := 0;
signal full_bit     : std_logic := '0';
signal sample_bit   : std_logic := '0';
signal write_bits   : std_logic := '0';
signal out_bits     : std_logic_vector(TRAN_BITS - 1 downto 0) := (others => '0');

begin
    
    -- Instantiates a Counter to drive the full_bit signal
    bit_count: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => BIT_CNT + 1)
        Port Map (clk => clk, reset => reset_count, max_reached => full_bit);
    
    -- Instantiates a Counter to drive the sample_bit signal
    sample_count: Counter
        Generic Map (CLK_FREQ => CLK_FREQ, MAX_COUNT => SAMPLE_CNT)
        Port Map (clk => clk, reset => reset_count, max_reached => sample_bit);
        
    -- Process that manages the present and next states
    state_machine: process(p_state, rx_init, rx_strt, rx_stop, rx_done) is
    begin
        case p_state is
            when idle =>         
                if (rx_init = '1') then
                    n_state <= init_read;
                else
                    n_state <= p_state;
                end if;
            when init_read =>
                if (rx_strt = '1') then
                    n_state <= strt_read;     
                else
                    n_state <= p_state;
                end if;
            when strt_read =>
                if (rx_stop = '1') then
                    n_state <= stop_read;
                else
                    n_state <= p_state;
                end if;
            when stop_read =>
                if (rx_done = '1') then
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
    
    -- Sets rx_stop to '1' once all of the transmission bits have been sampled
    stop_read_proc: process(p_state, bit_pos) is
    begin
        if (p_state = strt_read) then
            if (bit_pos > TRAN_BITS - 1) then
                rx_stop <= '1';
            else
                rx_stop <= '0';
            end if;
        else
            rx_stop <= '0';
        end if;
    end process stop_read_proc;

    -- Process that receives data bits from the input_stream depending on the state
    receive_proc: process(p_state, input_stream, sample_bit, full_bit) is
    begin
        case p_state is
            
            -- Monitors the input_stream and sets rx_init to '1' when the transmission first goes to '0'
            when idle =>
                bit_pos <= 0;
                rx_strt <= '0';
                rx_done <= '0';
                reset_count <= '1';
                if (write_bits = '1') then
                    rx_bits <= out_bits;
                else
                    rx_bits <= (others => '0');
                end if;
                if (falling_edge(input_stream)) then
                    rx_init <= '1';
                end if;
            
            -- Sets rx_strt to '1' once the start transmission bit has been received
            when init_read =>
                rx_init <= '0';
                rx_done <= '0';
                write_bits <= '0';
                reset_count <= '0';           
                if (sample_bit = '1' and full_bit = '0') then
                    if (input_stream = '0') then
                        rx_strt <= '1';
                    end if;       
                end if;
            
            -- Sample bits until the out_bits vector is filled
            -- Increments the current bit position while sampling the input_stream
            when strt_read =>
                rx_init <= '0';
                rx_strt <= '0';
                rx_done <= '0';
                write_bits <= '0';
                reset_count <= '0';
                if (sample_bit = '1' and full_bit = '0') then
                    out_bits(bit_pos) <= input_stream;
                    bit_pos <= bit_pos + 1;
                end if;
            
            -- Set rx_done to '1' when the transmission is finished 
            when stop_read =>
                rx_init <= '0';
                rx_strt <= '0';
                reset_count <= '0';
                if (sample_bit = '1' and full_bit = '0') then
                    if (input_stream = '1') then
                        write_bits <= '1';
                        rx_done <= '1';
                    else
                        write_bits <= '0';
                        rx_done <= '1';
                    end if;
                end if;
                
        end case;
    end process receive_proc;
      
end architecture Behavioral;