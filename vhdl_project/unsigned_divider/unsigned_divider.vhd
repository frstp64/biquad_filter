----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:06:12 04/05/2018 
-- Design Name: 
-- Module Name:    unsigned_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity unsigned_divider is
    Generic (SIGNAL_LENGTH: positive);
    Port ( dividend : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           divisor : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
			  op_ready : in STD_LOGIC; -- MUST BE PULSED!
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           quotient : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
			  output_ready: out STD_LOGIC);
end unsigned_divider;

architecture classic_shifter of unsigned_divider is

    COMPONENT shift_register
	 GENERIC(SIGNAL_LENGTH: positive);
    PORT(
         serial_in : IN  std_logic;
         parallel_in : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         load : IN  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         serial_out : OUT  std_logic;
         parallel_out : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT lt_comparator
	 GENERIC (SIGNAL_LENGTH: positive);
    PORT(
         input_a : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         input_b : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         is_less_than : OUT  std_logic
        );
    END COMPONENT;
	 
	 COMPONENT signed_inverter
    generic ( SIGNAL_LENGTH: positive);
    PORT(
         input_value : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
         output_value : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
        );
    END COMPONENT;
	 
	 COMPONENT signed_adder
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

signal shifted_input_bit: std_logic;
signal is_less_than: std_logic;
signal is_greater_than_or_equal: std_logic;
signal shifted_substraction_result: std_logic_vector(SIGNAL_LENGTH-1 downto 0);
signal substraction_result: std_logic_vector(SIGNAL_LENGTH-1 downto 0);
signal central_parallel_output: std_logic_vector(SIGNAL_LENGTH-1 downto 0);

signal sub_ready_central_parallel_output: std_logic_vector(SIGNAL_LENGTH downto 0);
signal sub_ready_divisor: std_logic_vector(SIGNAL_LENGTH downto 0);
signal sub_ready_negative_divisor: std_logic_vector(SIGNAL_LENGTH downto 0);

signal readiness_propagation_vector: std_logic_vector(SIGNAL_LENGTH-1 downto 0);

begin

   input_container: shift_register
	GENERIC MAP ( SIGNAL_LENGTH => SIGNAL_LENGTH)
	PORT MAP (
          serial_in => '0',
          parallel_in => dividend,
          load => op_ready,
          clk => clk,
          reset => reset,
          enable => enable,
          serial_out => shifted_input_bit,
          parallel_out => OPEN
   );
	
	central_container: shift_register
	GENERIC MAP ( SIGNAL_LENGTH => SIGNAL_LENGTH)
	PORT MAP (
          serial_in => shifted_input_bit,
          parallel_in => shifted_substraction_result,
          load => is_greater_than_or_equal,
          clk => clk,
          reset => reset,
          enable => enable,
          serial_out => OPEN,
          parallel_out => central_parallel_output);


   output_container: shift_register
	GENERIC MAP ( SIGNAL_LENGTH => SIGNAL_LENGTH)
	PORT MAP (
          serial_in => is_greater_than_or_equal,
          parallel_in => (others => '0'),
          load => '0',
          clk => clk,
          reset => reset,
          enable => enable,
          serial_out => OPEN,
          parallel_out => quotient);
			 
   inverter_for_substraction: signed_inverter
	generic map (SIGNAL_LENGTH => SIGNAL_LENGTH+1)
	PORT MAP (
          input_value => sub_ready_divisor,
          output_value => sub_ready_negative_divisor
        );
		  
	actually_substracts: signed_adder
	generic map ( SIGNAL_LENGTH => SIGNAL_LENGTH+1)
	PORT MAP (
          input_A => sub_ready_central_parallel_output,
          input_B => sub_ready_negative_divisor,
          clk => clk,
          reset => reset,
          en => enable,
          output=> substraction_result
        );

	
	-- invert lt comparator output to get the greater than or equal comparator
	is_greater_than_or_equal <= not is_less_than;
	
	-- shifts and fuses the substraction output
	shifted_substraction_result <= substraction_result(SIGNAL_LENGTH-2 downto 1) & shifted_input_bit;
	
	-- sub-ready inputs for substractor (additional bit for sign)
	sub_ready_central_parallel_output <= '0' & central_parallel_output;
	sub_ready_divisor <= '0' & divisor;
	
	
	-- compares the parallel output of the central shifter and the divisor to verify if we need to substract
	temp_and_divisor_comparator: lt_comparator 
	GENERIC MAP (SIGNAL_LENGTH => SIGNAL_LENGTH)
	PORT MAP (
          input_a => central_parallel_output,
          input_b => divisor,
          is_less_than => is_less_than
   );
	
	-- propagates the op_ready up to the output
	process(clk, reset)
	begin
	    if (reset <= '1') then
		     readiness_propagation_vector <= (others => '0');
		 elsif (rising_edge(clk)) then
		     readiness_propagation_vector <= readiness_propagation_vector(SIGNAL_LENGTH-2 downto 0) & op_ready;
		 end if;
	end process;

output_ready <= readiness_propagation_vector(SIGNAL_LENGTH-1);

end classic_shifter;

