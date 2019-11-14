----------------------------------------------------------------------------------
-- Company: N/A
-- Engineer: Nick Diocson
-- 
-- Create Date: 09/21/2019 09:56:08 AM
-- Design Name: Sequencer
-- Module Name: Sequencer - Behavioral
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

entity Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            FREQ_WIDTH          : positive := 32;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset          : in std_logic;
            strt, stop          : in std_logic;
            input_stream        : in std_logic;
            step_ready          : in std_logic_vector(N_STEPS downto 1);
            step_out            : out std_logic_vector(N_STEPS downto 1);
            out_wave            : out std_logic
            );
end entity Sequencer;

architecture Behavioral of Sequencer is

-- Clock_Divider Component Declaration
component Clock_Divider is
    Generic (
            CLK_FREQ        : positive := 1E7;
            CLK_OUT_FREQ    : positive := 2
            );
    Port (
            clk, reset      : in std_logic;
            clk_out         : out std_logic
            );
end component Clock_Divider;

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

-- Freq_Controller Component Declaration
component Freq_Controller is
    Generic (
            BAUD_RATE       : positive := 9600;
            BIT_CNT         : positive := 1040;
            SAMPLE_CNT      : positive := 520;
            FREQ_WIDTH      : positive := 32
            );
    Port (
            clk             : in std_logic;
            reset           : in std_logic;
            input_stream    : in std_logic;
            ready           : in std_logic;
            note_freq       : out std_logic_vector(FREQ_WIDTH - 1 downto 0)
            );
end component Freq_Controller;

-- Square_Wave_Gen Component Declaration
component Square_Wave_Gen is
    Generic (
            CLK_FREQ        : positive := 1E7;      -- on-board clock frequency (10 MHz)
            FREQ_WIDTH      : positive := 32        -- width of frequency input
            );
    Port ( 
            clk, reset      : in std_logic;
            ready           : in std_logic;
            freq            : in std_logic_vector(FREQ_WIDTH - 1 downto 0);
            out_wave        : out std_logic
            );
end component Square_Wave_Gen;

-- step_type:       Subtype defining the range of steps including 0
-- note_type:       Subtype defining the range of notes corresponding to each valid step
-- step_arr:        std_loigc array of length N_STPES used to represent the output wave of each step
-- freq_arr:        std_logic_vector array of length N_STEPS used to represent the frequency of each step
subtype step_type is integer range 0 to N_STEPS;
subtype note_type is step_type range step_type'low + 1 to step_type'high;
type step_arr is array (note_type) of std_logic;
type freq_arr is array (note_type) of std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- CLK_FREQ:        Constant frequency of on-board clock (10 MHz for Arty A7-35T)
-- BAUD_RATE:       9600 bits per second
-- BIT_CNT:         Number of clock cycles to represent a bit
-- SAMPLE_CNT       Number of clock cycles to sample a bit
constant CLK_FREQ   : positive := 1E7;
constant BAUD_RATE  : positive := 9600;
constant BIT_CNT    : positive := 1040;
constant SAMPLE_CNT : positive := 520;

-- state:           Enumerated type to define states of simple FSM
-- p_state:         Internal state signal used to represent the present state
-- n_state:         Internal state signal used to represent the next state
type state is (idle, play, pause);
signal p_state, n_state : state := idle;

-- new_clk:         Internal std_logic signal used as system clock      
-- reset_clk:       Internal signal used to reset all Clock_Divider instances
-- rest_on:         Internal signal used to manage rest and step sequencer
signal new_clk      : std_logic := '0';
signal reset_clk    : std_logic := '1';
signal rest_on      : std_logic := '1';

-- note_rdy:        Internal signal array of indices corresponding to each step
-- note_freq:       Internal signal array of frequencies corresponding to each step
-- rx_bits:         Internal signal vector to hold received bits from data_stream
signal note_rdy     : step_arr := (others => '0');
signal note_freq    : freq_arr := (others => (others => '1'));
signal rx_bits      : std_logic_vector(FREQ_WIDTH - 1 downto 0);

-- curr_step:       Internal signal used to track current step position in sequencer
-- step_wave:       Internal signal array of indicies representing each step wave
signal curr_step    : step_type := step_type'low;
signal step_wave    : step_arr := (others => '0');

-- isValidIndex Function that returns true if given bit vector is within the step index range
function isValidIndex(index: note_type) return boolean is
variable isValid    : boolean := false;
begin
    if (index >= note_type'low and index <= note_type'high) then
        isValid := true;
    end if;
    return isValid;
end function isValidIndex;

begin
    
    -- Instantiates a Clock_Divider to drive the new_clk signal
    new_clock: Clock_Divider
        Generic Map (CLK_FREQ => CLK_FREQ, CLK_OUT_FREQ => 20)
        Port Map (clk => clk, reset => reset_clk, clk_out => new_clk);

    -- Instantiates a UART Receiver to collect the bits representing the note frequency value
    receiver: UART_Rx
        Generic Map(BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, TRAN_BITS => FREQ_WIDTH)
        Port Map (clk => clk, reset => reset, input_stream => input_stream, rx_bits => rx_bits);
    
    -- Instantiates 'N_STEPS' Freq_Controller modesl for each step within the sequencer 
    gen_freq_ctrls: for index in note_type generate
        freq_ctrl: Freq_Controller
            Generic Map (BAUD_RATE => BAUD_RATE, BIT_CNT => BIT_CNT, SAMPLE_CNT => SAMPLE_CNT, FREQ_WIDTH => FREQ_WIDTH)
            Port Map (clk => clk, reset => reset, input_stream => input_stream, ready => note_rdy(index), note_freq => note_freq(index));
    end generate gen_freq_ctrls;
    
    -- Instatiates 'N_STEPS' Square_Wave_Gen models for each step within the sequencer
    gen_waves: for index in note_type generate
        square_wave: Square_Wave_Gen
            Generic Map (CLK_FREQ => CLK_FREQ, FREQ_WIDTH => FREQ_WIDTH)
            Port Map (clk => clk, reset => reset, ready => not note_rdy(index), freq => note_freq(index), out_wave => step_wave(index));
    end generate gen_waves;
    
    -- Process that manages the present and next states based on internal toggle signal
    state_machine: process(p_state, new_clk, strt, stop) is
    begin
        case p_state is
            
            when idle =>
                reset_clk <= '1';
                curr_step <= step_type'low;
                if (strt = '1') then
                    n_state <= play;
                else
                    n_state <= idle;
                end if;
            
            when play =>
                reset_clk <= '0';
                if (stop = '1') then
                    n_state <= pause;
                    if (rest_on = '0') then
                        curr_step <= curr_step - 1;
                    end if;
                else
                    n_state <= play;
                end if;
                
                -- Increments the curr_step index signal every two clock cycles
                if (rising_edge(new_clk)) then
                    if (rest_on = '1') then
                        if (curr_step >= note_type'high) then
                            curr_step <= note_type'low;
                        else
                            curr_step <= curr_step + 1;
                        end if;
                    end if;
                end if;
            
            when pause =>
                reset_clk <= '1';
                if (strt = '1') then
                    n_state <= play;
                else
                    n_state <= pause;
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
    
    -- Process to receive and store index bits from input stream and toggle corresponding note_rdy signal
    index_handler: process(clk, rx_bits) is
    begin
        if (rising_edge(clk)) then
            if (isValidIndex(to_integer(unsigned(rx_bits)))) then
                for index in note_type loop
                    if (index = to_integer(unsigned(rx_bits))) then
                        note_rdy(index) <= '1';
                    else
                        note_rdy(index) <= '0';
                    end if;
                end loop;
            else
                note_rdy <= (others => '0');
            end if;
        end if;
    end process index_handler;
    
    -- Toggles rest_on every clock cycle
    -- Drives rest_on to '1' when sequencer is paused
    toggle_rest: process(new_clk, p_state) is
    begin
        if (p_state = play) then
            if (rising_edge(new_clk)) then
                rest_on <= not rest_on;
            end if;
        else
            rest_on <= '1';
        end if;
    end process toggle_rest;
    
    -- Lights the LED corresponding to the current step
    output_led: process(rest_on) is
    begin
        if (p_state = play) then
            step_out(curr_step) <= not rest_on;
        else
            step_out <= (others => '0');
        end if;
    end process output_led;  

    -- Uses the curr_step signal index to apply square wave of corresponding note frequency driven by Sqaure_Wave_Gen
    -- Outputs either a wave or a rest depending on the internal rest_on signal
    output_wave: process(step_wave) is
    begin
        if (p_state /= play or rest_on = '1') then
            out_wave <= '0';
        else
            if (step_ready(curr_step) = '1') then
                out_wave <= step_wave(curr_step);
            end if;
        end if;
    end process output_wave;
    
end architecture Behavioral;