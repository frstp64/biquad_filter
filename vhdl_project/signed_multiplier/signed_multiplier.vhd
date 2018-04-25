----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:27:28 03/23/2018 
-- Design Name: 
-- Module Name:    signed_multiplier - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signed_multiplier is
 generic ( SIGNAL_LENGTH: positive);
 PORT(
		input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		clk : IN  std_logic;
		reset : IN  std_logic;
		en : IN  std_logic;
		output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
end signed_multiplier;

architecture wallace_tree of signed_multiplier is

component unsigned_multiplier
PORT(
input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
clk : IN  std_logic;
reset : IN  std_logic;
en : IN  std_logic;
output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
);
end component;

 COMPONENT signed_inverter
 generic ( SIGNAL_LENGTH: positive);
 PORT(
		input_value : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		output_value : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
 END COMPONENT;
 
signal unsigned_A: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal unsigned_B: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal input_A_inverted: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal input_B_inverted: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal unsigned_output: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal unsigned_output_inverted: STD_LOGIC_VECTOR(SIGNAL_LENGTH-1 downto 0);
signal output_sign: std_logic;
begin


input_a_inverter: signed_inverter
generic map (SIGNAL_LENGTH => SIGNAL_LENGTH)
PORT MAP (
		 input_value => input_A,
		 output_value => input_A_inverted
	  );
	  
input_b_inverter: signed_inverter
generic map (SIGNAL_LENGTH => SIGNAL_LENGTH)
PORT MAP (
		 input_value => input_B,
		 output_value => input_B_inverted
	  );
	  
output_inverter: signed_inverter
generic map (SIGNAL_LENGTH => SIGNAL_LENGTH)
PORT MAP (
		 input_value => unsigned_output,
		 output_value => unsigned_output_inverted
	  );
	  
unsigned_A <= input_A_inverted when input_A(SIGNAL_LENGTH-1) = '1' else input_A;
unsigned_B <= input_B_inverted when input_B(SIGNAL_LENGTH-1) = '1' else input_B;

output_sign <= input_A(SIGNAL_LENGTH-1) xor input_B(SIGNAL_LENGTH-1);

UM: unsigned_multiplier
PORT map(
		input_A => unsigned_A,
		input_B => unsigned_B,
		clk => clk,
		reset => reset,
		en => en,
		output => unsigned_output
	  );

output <= unsigned_output_inverted when output_sign = '1' else unsigned_output;


end wallace_tree;