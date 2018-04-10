--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:05:26 03/23/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/signed_multiplier/signed_multiplier_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signed_multiplier
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY signed_multiplier_tb IS
END signed_multiplier_tb;
 
ARCHITECTURE behavior OF signed_multiplier_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant SIGNAL_LENGTH_test : integer := 16;

    COMPONENT signed_multiplier
    generic ( SIGNAL_LENGTH: positive);
    PORT(
         input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic;
         en : IN  std_logic;
         output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal input_A_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal input_B_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal en : std_logic := '0';

 	--Outputs
   signal output_test1 : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
   signal output_test2 : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	for uut1 : signed_multiplier use entity
            work.signed_multiplier(cheat_multiplier);
	for uut2 : signed_multiplier use entity
            work.signed_multiplier(wallace_tree);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut1: signed_multiplier
	generic map ( SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          input_A => input_A_test,
          input_B => input_B_test,
          clk => clk,
          reset => reset,
          en => en,
          output => output_test1
        );

   uut2: signed_multiplier
	generic map ( SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          input_A => input_A_test,
          input_B => input_B_test,
          clk => clk,
          reset => reset,
          en => en,
          output => output_test2
        );
		  
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '1';
		en <= '1';

      wait for clk_period*10;

      -- insert stimulus here 
		en <= '1';
		input_A_test <= std_logic_vector(to_signed(63, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(64, input_B_test'length));
		wait for 100 ns;
		
		input_A_test <= std_logic_vector(to_signed(-3, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(4, input_B_test'length));
		wait for 100 ns;
		
		input_A_test <= std_logic_vector(to_signed(3, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(4, input_B_test'length));
		wait for 100 ns;
		
		input_A_test <= std_logic_vector(to_signed(-4, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(3, input_B_test'length));
		wait for 100 ns;
		
		input_A_test <= std_logic_vector(to_signed(-64, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(-64, input_B_test'length));
		wait for 100 ns;
		
		input_A_test <= std_logic_vector(to_signed(0, input_A_test'length));
		input_B_test <= std_logic_vector(to_signed(0, input_B_test'length));
		wait for 100 ns;
		wait;
   end process;

END;
