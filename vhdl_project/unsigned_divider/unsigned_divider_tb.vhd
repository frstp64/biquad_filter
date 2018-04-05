--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:57:42 04/05/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/unsigned_divider/unsigned_divider_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: unsigned_divider
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
 
ENTITY unsigned_divider_tb IS
END unsigned_divider_tb;
 
ARCHITECTURE behavior OF unsigned_divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    constant SIGNAL_LENGTH_test : integer := 8;
    COMPONENT unsigned_divider
	 GENERIC(SIGNAL_LENGTH: positive);
    PORT(
         dividend : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         divisor : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         op_ready : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         quotient : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         output_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal dividend : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal divisor : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal op_ready : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';

 	--Outputs
   signal quotient : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);
   signal output_ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: unsigned_divider
	GENERIC MAP (SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          dividend => dividend,
          divisor => divisor,
          op_ready => op_ready,
          clk => clk,
          reset => reset,
          enable => enable,
          quotient => quotient,
          output_ready => output_ready
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
	   reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		reset <= '0';
		enable <= '1';

      -- insert stimulus here 
		wait for clk_period;
		dividend <= "01010101";
		divisor <=  "00000001";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);
		
		divisor <=  "00000010";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);
		
		divisor <=  "00000011";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);

      wait;
   end process;

END;
