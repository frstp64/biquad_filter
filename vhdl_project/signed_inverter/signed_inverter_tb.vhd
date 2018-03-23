--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:51:53 03/22/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/signed_inverter/signed_inverter_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signed_inverter
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
 
ENTITY signed_inverter_tb IS
END signed_inverter_tb;
 
ARCHITECTURE behavior OF signed_inverter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant SIGNAL_LENGTH_test : integer := 8;
    COMPONENT signed_inverter
    generic ( SIGNAL_LENGTH: positive);
    PORT(
         input_value : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         output_value : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal input_value_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');

 	--Outputs
   signal output_value_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: signed_inverter
	generic map (SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          input_value => input_value_test,
          output_value => output_value_test
        );

   -- Stimulus process
   stim_proc: process
   begin

      -- -1
      input_value_test <= (others => '1');
      wait for 100 ns;
	
      -- 0	
      input_value_test <= (others => '0');
      wait for 100 ns;
		
		-- minimum value
		input_value_test(SIGNAL_LENGTH_test-1) <= '1';
      wait for 100 ns;
		wait;
		-- finished
   end process;

END;
