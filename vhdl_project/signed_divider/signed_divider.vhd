----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:38:13 03/23/2018 
-- Design Name: 
-- Module Name:    signed_divider - Behavioral 
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

entity signed_divider is
 generic ( SIGNAL_LENGTH: positive:=32);
 PORT(
		input_A : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		input_B : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		op_ready : IN std_logic;
		clk : IN  std_logic;
		reset : IN  std_logic;
		en : IN  std_logic;
		two_sign_delays : IN std_logic;
		output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
end signed_divider;

architecture n_plus_2_clock_cycles of signed_divider is

component unsigned_divider
    Generic (SIGNAL_LENGTH: positive);
    Port ( dividend : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           divisor : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
			  op_ready : in STD_LOGIC; -- MUST BE PULSED!
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           quotient : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
			  output_ready: out STD_LOGIC);
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
signal output_sign_gated: std_logic;
signal output_sign_gated_prev: std_logic;
signal op_ready_signal: std_logic;
signal output_ready_signal: std_logic;


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
	  
UD: unsigned_divider
Generic map(SIGNAL_LENGTH => SIGNAL_LENGTH)
PORT map(
		dividend => unsigned_A,
		divisor => unsigned_B,
		op_ready => op_ready_signal,
		clk => clk,
		reset => reset,
		enable => en,
		quotient => unsigned_output,
		output_ready => output_ready_signal
	  );
	  
unsigned_A <= input_A_inverted when input_A(SIGNAL_LENGTH-1) = '1' else input_A;
unsigned_B <= input_B_inverted when input_B(SIGNAL_LENGTH-1) = '1' else input_B;

output_sign <= input_A(SIGNAL_LENGTH-1) xor input_B(SIGNAL_LENGTH-1);

process(clk, reset, en, output_ready_signal)
begin
    if (reset = '1') then
	     output_sign_gated_prev <= '0';
	     output_sign_gated <= '0';
	 elsif (rising_edge(clk) and en = '1' and output_ready_signal = '1' and two_sign_delays = '1') then
	     output_sign_gated_prev <= output_sign;
	     output_sign_gated <= output_sign_gated_prev;
	 elsif (rising_edge(clk) and en = '1' and output_ready_signal = '1' and two_sign_delays = '0') then
	     output_sign_gated_prev <= output_sign;
	     output_sign_gated <= output_sign;
	 end if;
	 
end process;
op_ready_signal <= op_ready;

output <= unsigned_output_inverted when output_sign_gated = '1' else unsigned_output;
end n_plus_2_clock_cycles;