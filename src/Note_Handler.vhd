----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 11/02/2019 01:57:16 PM
-- Design Name: Note Handler
-- Module Name: Note_Handler - Behavioral
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

entity Note_Handler is
    Generic (
            N_STEPS         : positive := 4;
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            FREQ_WIDTH      : positive := 32
            );
    Port (
            clk, reset      : in std_logic;
            note_stream     : in std_logic;
            note_index      : out std_logic_vector(FREQ_WIDTH - 1 downto 0);
            note_freq       : out std_logic_vector(FREQ_WIDTH - 1 downto 0)
            );
end entity Note_Handler;

architecture Behavioral of Note_Handler is

-- UART_Rx Component Declaration
component UART_Rx is
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
end component UART_Rx;

-- state:           Enumerated type to define two states of simple FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (rx_index, rx_freq);
signal p_state, n_state : state := rx_index;

-- out_code:    Internal signal used to represent output line of data_stream
-- rx_bits:     Internal signal vector to hold received bits from data_stream
-- rx_step:     Internal signal used to hold received bits that represent a note index
-- rx_note:     Internal signal used ot hold received bits that represent a note freq
signal out_code : std_logic := '0';
signal rx_bits  : std_logic_vector(FREQ_WIDTH - 1 downto 0);
signal rx_step  : std_logic_vector(FREQ_WIDTH - 1 downto 0);
signal rx_note  : std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- isValidIndex Function that returns true if given bit vector is within the step index range
function isValidIndex(rx_bits : std_logic_vector(FREQ_WIDTH - 1 downto 0)) return boolean is
variable isValid    : boolean := false;
variable index      : integer := to_integer(unsigned(rx_bits));
begin
    if (index >= 1 and index <= N_STEPS) then
        isValid := true;
    end if;
    return isValid;
end function isValidIndex;

begin
    
    -- Instantiates a UART Receiver to collect the bits representing the note frequency value
    receiver: UART_Rx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, input_stream => note_stream, rx_bits => rx_bits);
    
    -- Process that manages the present and next states based on internal input stream
    state_machine: process(rx_bits) is
    begin
        case p_state is
            
            when rx_index =>
                out_code <= '0';
                if (isValidIndex(rx_bits)) then
                    rx_step <= rx_bits;
                    n_state <= rx_freq;
                else
                    n_state <= p_state;
                end if;
                
            when rx_freq =>
                out_code <= '1';
                rx_note <= rx_bits;
                n_state <= rx_index;
        
        end case;
    end process state_machine;

    -- Process that handles the memory elements for the FSM
    memory_elem: process(clk, reset) is
    begin
        if (reset = '1') then
            p_state <= rx_index;
            note_index <= (0 => '1', others => '0');
            note_freq <= (others => '1');
        elsif (rising_edge(clk)) then
            p_state <= n_state;
            if (out_code = '1') then
                note_freq <= rx_note;
            else
                note_index <= rx_step;
            end if;
        end if;
    end process memory_elem;
    
end architecture Behavioral;
