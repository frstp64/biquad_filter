--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:00:47 04/10/2018
-- Design Name:   
-- Module Name:   U:/component/biquad_filter/nbit_signed_divider/nbit_signed_divider_tb.vhd
-- Project Name:  nbit_signed_divider
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: division
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
 
ENTITY nbit_signed_divider_tb IS
END nbit_signed_divider_tb;
 
ARCHITECTURE behavior OF nbit_signed_divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    CONSTANT SIGNAL_WIDTH : integer := 8;
	 
    COMPONENT division
	 GENERIC(SIGNAL_LENGTH: positive);
    PORT(
         reset : IN  std_logic;
         en : IN  std_logic;
         op_ready : IN  std_logic;
         clk : IN  std_logic;
         input_A : IN  std_logic_vector(SIGNAL_WIDTH-1 downto 0);
         input_B : IN  std_logic_vector(SIGNAL_WIDTH-1 downto 0);
         output : OUT  std_logic_vector(SIGNAL_WIDTH-1 downto 0)
        );
    END COMPONENT;
   --Inputs
   signal reset : std_logic := '0';
   signal en : std_logic := '0';
   signal op_ready : std_logic := '0';
   signal clk : std_logic := '0';
   signal input_A : std_logic_vector(SIGNAL_WIDTH-1 downto 0) := (others => '0');
   signal input_B : std_logic_vector(SIGNAL_WIDTH-1 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(SIGNAL_WIDTH-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: division
	GENERIC MAP(SIGNAL_LENGTH => SIGNAL_WIDTH)
	PORT MAP (
          reset => reset,
          en => en,
          op_ready => op_ready,
          clk => clk,
          input_A => input_A,
          input_B => input_B,
          output => output
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
		op_ready<='1';
		en<='1';
		reset<='0';
		input_A<="00001110";
		input_B<="00000011";
		wait for clk_period*100;
		
		input_A<="00001110";
		input_B<="00011011";
		wait for clk_period*100;
		
		input_A<="00111110";
		input_B<="00000011";
		wait for clk_period*100;
		
		input_A<="10111110";
		input_B<="10010011";
		wait for clk_period*100;
		
		input_A<="00111111";
		input_B<="00111111";
		wait for clk_period*100;
		
		input_A<="11100001";
		input_B<="00000011";
		wait for clk_period*100;
		
		input_A<="00001111";
		input_B<="01111111";
		wait for clk_period*100;
		
		
      wait;
   end process;

END;
