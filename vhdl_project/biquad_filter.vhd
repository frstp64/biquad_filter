----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:21:24 03/23/2018 
-- Design Name: 
-- Module Name:    biquad_filter - main_arch 
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

entity biquad_filter is
    generic ( SIGNAL_LENGTH: positive := 16);
    Port ( clk : in  STD_LOGIC;
           en : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           parameter_A1_mul : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_A1_div : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_A2_mul : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_A2_div : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B0_mul : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B0_div : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B1_mul : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B1_div : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B2_mul : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           parameter_B2_div : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           input_signal : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           output_signal : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           change_input : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           temporary_overflow : out  STD_LOGIC);
end biquad_filter;

architecture flow_arch of biquad_filter is

constant INTERNAL_VARIABLE_LENGTH: integer := 2*SIGNAL_LENGTH     +2; -- to verify

COMPONENT signed_expander
generic ( IN_LENGTH: positive;
		    OUT_LENGTH: positive );
Port ( in_value : in  STD_LOGIC_VECTOR (IN_LENGTH-1 downto 0);
	    out_value : out  STD_LOGIC_VECTOR (OUT_LENGTH-1 downto 0));
END COMPONENT;

COMPONENT signed_contracter
generic ( IN_LENGTH: positive;
			  OUT_LENGTH: positive );
PORT(
		in_value : IN  std_logic_vector(IN_LENGTH-1 downto 0);
		out_value : OUT  std_logic_vector(OUT_LENGTH-1 downto 0);
		overflow : OUT  std_logic
	  );
END COMPONENT;

signal A1_mul_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal A1_div_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal A2_mul_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal A2_div_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B0_mul_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B0_div_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B1_mul_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B1_div_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B2_mul_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal B2_div_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal  input_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_expanded : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);

begin

-- resize all the vectors here

A1_mul_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_A1_mul,
		 out_value => A1_mul_expanded);

A1_div_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_A1_div,
		 out_value => A1_div_expanded);
		 
A2_mul_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_A2_mul,
		 out_value => A2_mul_expanded);
		 
A2_div_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_A1_div,
		 out_value => A1_div_expanded);

B0_mul_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B0_mul,
		 out_value => B0_mul_expanded);

B0_div_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B0_div,
		 out_value => B0_div_expanded);

B1_mul_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B1_mul,
		 out_value => B1_mul_expanded);

B1_div_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B1_div,
		 out_value => B1_div_expanded);
		 
B2_mul_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B2_mul,
		 out_value => B2_mul_expanded);
		 
B2_div_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => parameter_B2_div,
		 out_value => B2_div_expanded);


output_contracter: signed_contracter
generic map (IN_LENGTH => INTERNAL_VARIABLE_LENGTH,
				 OUT_LENGTH => SIGNAL_LENGTH)
PORT MAP (
		 in_value => output_expanded,
		 out_value => output_signal,
		 overflow => temporary_overflow);




end flow_arch;

