--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:41:43 03/23/2018
-- Design Name:   
-- Module Name:   U:/git/biquad_filter/vhdl_project/signed_divider/signed_divider_tb.vhd
-- Project Name:  biquad_filter
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: signed_divider
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
 
ENTITY signed_divider_tb IS
END signed_divider_tb;
 
ARCHITECTURE behavior OF signed_divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    constant SIGNAL_LENGTH_test : integer := 8;

    COMPONENT signed_divider
    generic ( SIGNAL_LENGTH: positive);
    Port (
	   input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		op_ready : IN std_logic;
		clk : IN  std_logic;
		reset : IN  std_logic;
		en : IN  std_logic;
		output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0));
    END COMPONENT;
    

   --Inputs
   signal input_A_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal input_B_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal en : std_logic := '0';
	signal op_ready: std_logic := '0';

 	--Outputs
   signal output1_test : std_logic_vector(SIGNAL_LENGTH_test-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1000 ns;
   
	for uut1 : signed_divider use entity
            work.signed_divider(n_plus_2_clock_cycles);
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut1: signed_divider
	generic map ( SIGNAL_LENGTH => SIGNAL_LENGTH_test)
	PORT MAP (
          input_A => input_A_test,
          input_B => input_B_test,
          clk => clk,
          reset => reset,
          en => en,
          output => output1_test,
			 op_ready => op_ready
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
		en <= '1';

		wait for clk_period;
		input_A_test <= "01010101";
		input_B_test <=  "00000001";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);
		
		input_B_test <=  "00000010";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);
		
		input_B_test <=  "11111011";
		op_ready <= '1';
		wait for clk_period;
		op_ready <= '0';
		wait for clk_period*(SIGNAL_LENGTH_test+2);

      wait;
   end process;

END;
