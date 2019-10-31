----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 10/11/2019 11:12:20 PM
-- Design Name: UART Receiver
-- Module Name: UART_Rx - Behavioral
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

entity UART_Rx is
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
-- rx_invl:         Internal signal used to indicate when the input_stream is invalid
signal rx_init      : std_logic := '0';
signal rx_strt      : std_logic := '0';
signal rx_stop      : std_logic := '0';
signal rx_done      : std_logic := '0';
signal rx_invl      : std_logic := '0';
   
-- full_bit:        Internal signal used to indicate when a new bit is to be read from the input_stream
-- sample_bit:      Internal signal used to indicate when the current bit is to be sampled from the input_stream
-- out_bits:        Internal signal used to hold the transmission bits while they are read
signal full_bit     : std_logic := '0';
signal sample_bit   : std_logic := '0';
signal out_bits     : std_logic_vector(TRAN_BITS - 1 downto 0) := (others => '0');

-- bit_pos:         Shared variable used to track current positon of the transmission bit to sample
-- bit_pos_sig:     Internal signal used to track current positon of the transmission bit to sample
shared variable bit_pos : integer := 0;
signal bit_pos_sig      : integer := 0;

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
    state_machine: process(p_state, rx_init, rx_strt, rx_stop, rx_done, rx_invl) is
    begin
        case p_state is
            when idle =>                    -- Start initial read when input_stream first goes to '0'
                reset_count <= '1';
                if (rx_init = '1') then
                    bit_pos := 0;
                    n_state <= init_read;
                else
                    n_state <= p_state;
                end if;
            when init_read =>               -- Stop sampling when all tranmission bits have been read
                reset_count <= '0';
                if (rx_strt = '1') then
                    n_state <= strt_read;     
                else
                    n_state <= p_state;
                end if;                
            when strt_read =>               -- Stop sampling when all tranmission bits have been read
                reset_count <= '0';
                if (rx_stop = '1') then
                    n_state <= stop_read;
                else
                    n_state <= p_state;
                end if;
            when stop_read =>               -- Finish reading input_stream when last '1' is read
                if (rx_done = '1') then
                    rx_bits <= out_bits;
                    n_state <= idle;
                elsif (rx_invl = '1') then
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
    
    -- Monitors the input_stream and sets rx_init to '1' when the transmission first goes to '0'
    idle_proc: process(input_stream) is
    begin
        if (falling_edge(input_stream)) then
            if (p_state = idle) then
                rx_init <= '1';
            end if;
        else
            rx_init <= '0';
        end if;
    end process idle_proc;
    
    -- Sets rx_strt to '1' once the start transmission bit has been received
    init_read_proc: process(sample_bit, full_bit) is
    begin
        if (sample_bit = '1' and full_bit = '0') then
            if (p_state = init_read) then
                if (input_stream = '0') then
                    rx_strt <= '1';
                end if;
            else
                rx_strt <= '0';
            end if;            
        end if;
    end process init_read_proc;

    -- If in the strt_read state, sample bits until the out_bits vector is filled
    -- If in the stop_read state, set rx_done to '1' when the transmission is finished    
    read_bits_proc: process(sample_bit, full_bit) is
    begin
        if (p_state = strt_read) then
            if (sample_bit = '1' and full_bit = '0') then
                out_bits(bit_pos) <= input_stream;
            end if;
        elsif (p_state = stop_read) then
            if (sample_bit = '1' and full_bit = '0') then
                if (input_stream = '1') then
                    rx_done <= '1';
                else
                    rx_invl <= '1';
                end if;
            end if;
        else
            rx_done <= '0';
            rx_invl <= '0';          
        end if;
    end process read_bits_proc;
    
    -- Increments the current bit position while sampling the input_stream
    increment_pos: process(sample_bit, full_bit) is
    begin
        if (p_state = strt_read) then
            if (sample_bit = '1' and full_bit = '0') then
                bit_pos := bit_pos + 1;
                bit_pos_sig <= bit_pos;
            end if;
        end if;
    end process increment_pos;     

    -- Sets rx_stop to '1' once all of the transmission bits have been sampled
    stop_read_proc: process(p_state, bit_pos_sig) is
    begin
        if (p_state = strt_read) then
            if (bit_pos > TRAN_BITS - 1) then
                rx_stop <= '1';
            else
                rx_stop <= '0';
            end if;
        end if;
    end process stop_read_proc;

end architecture Behavioral;