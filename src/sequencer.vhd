library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Sequencer is
    Generic (
            N_STEPS             : positive := 4;
            STEP_TIME           : time := 500 ms;
            REST_TIME           : time := 500 ms
            );
    Port (
            clk, reset, pause   : in std_logic;
            switch              : in std_logic_vector(N_STEPS - 1 downto 0);
            out_freq            : out std_logic_vector(31 downto 0)
            );
    
    subtype step is integer range 0 to 2*N_STEPS - 1;   -- steps are even, rests are odd
end entity Sequencer;

architecture Behavioral of Sequencer is

-- new_clk:             
-- curr_step:                      
signal new_clk          : std_logic;
signal curr_step        : step := 0;

begin
    
    -- Instantiate Clock_Divider with default actual generic values
    new_clock: entity work.Clock_Divider(Behavioral)
                Generic Map (CLK_FREQ => open, CLK_OUT_FREQ => open)
                Port Map(clk => clk, reset => reset, clk_out => new_clk);
    
    output_note: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            -- Based on the current step as an index, output the corresponding note
        end if;
    end process output_note;
    
    -- Increment the curr_step index every clock cycle
    step_tracker: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            if (curr_step = step'high) then
                curr_step <= step'low;
            else
                curr_step <= curr_step + 1;
            end if;
        end if;
    end process step_tracker;
    
    note_assign: process(new_clk) is
    begin
        if (rising_edge(new_clk)) then
            -- Concurrently assign not values to internal signals
        end if;
    end process note_assign;
    
end Behavioral;
