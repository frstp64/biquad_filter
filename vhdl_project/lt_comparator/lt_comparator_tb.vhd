--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:54:20 04/05/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/lt_comparator/lt_comparator_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: lt_comparator
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
 
ENTITY lt_comparator_tb IS
END lt_comparator_tb;
 
ARCHITECTURE behavior OF lt_comparator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant SIGNAL_LENGTH_test : integer := 8;
    COMPONENT lt_comparator
	 GENERIC (SIGNAL_LENGTH: positive);
    PORT(
         input_a : IN  std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
         input_b : IN  std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
         is_less_than : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal input_a : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal input_b : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');

 	--Outputs
   signal is_less_than : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lt_comparator 
	GENERIC MAP (SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          input_a => input_a,
          input_b => input_b,
          is_less_than => is_less_than
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      -- insert stimulus here 
		input_a <= "00000110";
		input_b <= "00000111";
		wait for 100 ns;
		input_a <= "00000111";
		input_b <= "00000110";
		
		wait for 100 ns;
		input_a <= "00000111";
		input_b <= "00000111";
		
		
		

      wait;
   end process;

END;
