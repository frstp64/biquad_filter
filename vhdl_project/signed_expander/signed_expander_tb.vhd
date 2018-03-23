--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:06:27 03/22/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/signed_expander_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signed_expander
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
--USE ieee.numeric_std.ALL;
 
ENTITY signed_expander_tb IS
END signed_expander_tb;
 
ARCHITECTURE behavior OF signed_expander_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant INLENGTH_test : integer := 8;
    constant OUTLENGTH_test : integer := 16;
    COMPONENT signed_expander
    generic ( IN_LENGTH: positive;
	           OUT_LENGTH: positive );
    Port ( in_value : in  STD_LOGIC_VECTOR (IN_LENGTH-1 downto 0);
           out_value : out  STD_LOGIC_VECTOR (OUT_LENGTH-1 downto 0));
    END COMPONENT;
    

   --Inputs
   signal in_value_test : std_logic_vector(INLENGTH_test-1 downto 0) := (others => '0');

 	--Outputs
   signal out_value_test : std_logic_vector(OUTLENGTH_test-1 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   --constant <clock>_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: signed_expander 
	generic map (IN_LENGTH => INLENGTH_test,
	             OUT_LENGTH => OUTLENGTH_test)
	PORT MAP (
          in_value => in_value_test,
          out_value => out_value_test
        );

   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin

      -- -1
      in_value_test <= (others => '1');
      wait for 100 ns;
	
      -- 0	
      in_value_test <= (others => '0');
      wait for 100 ns;
		
		-- minimum value
		in_value_test(INLENGTH_test-1) <= '1';
      wait for 100 ns;
		wait;
		-- finished
   end process;

END;
