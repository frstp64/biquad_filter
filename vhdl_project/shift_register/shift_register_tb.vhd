--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:26:22 04/05/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/shift_register/shift_register_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: shift_register
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
 
ENTITY shift_register_tb IS
END shift_register_tb;
 
ARCHITECTURE behavior OF shift_register_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant SIGNAL_LENGTH_test : integer := 8;
	 
    COMPONENT shift_register
	 GENERIC(SIGNAL_LENGTH: positive);
    PORT(
         serial_in : IN  std_logic;
         parallel_in : IN  std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
         load : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         serial_out : OUT  std_logic;
         parallel_out : OUT  std_logic_vector(SIGNAL_LENGTH_test-1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal serial_in : std_logic := '0';
   signal parallel_in : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal load : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';

 	--Outputs
   signal serial_out : std_logic;
   signal parallel_out : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: shift_register 
	GENERIC MAP ( SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          serial_in => serial_in,
          parallel_in => parallel_in,
          load => load,
          clk => clk,
          reset => reset,
          enable => enable,
          serial_out => serial_out,
          parallel_out => parallel_out
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

      wait for clk_period*10;

      -- insert stimulus here 
		enable <= '1';
		serial_in <= '1';
		load <= '0';
		parallel_in <= "01010101";
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		load <= '1';
		wait for clk_period*3;
		load <= '0';

      wait;
   end process;

END;
