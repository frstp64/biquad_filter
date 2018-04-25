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
    generic ( SIGNAL_LENGTH: positive := 8);
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
           change_input : out  STD_LOGIC;
           temporary_overflow : out  STD_LOGIC);
end biquad_filter;

architecture flow_arch of biquad_filter is

constant INTERNAL_VARIABLE_LENGTH: integer := 2*SIGNAL_LENGTH     +2; -- to verify
constant CLOCK_DIVISION_VALUE: integer := INTERNAL_VARIABLE_LENGTH + 4;

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

 COMPONENT signed_multiplier
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

 COMPONENT signed_divider
 generic ( SIGNAL_LENGTH: positive);
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
 
 COMPONENT signed_inverter
 generic ( SIGNAL_LENGTH: positive);
 PORT(
		input_value : IN  std_logic_vector(SIGNAL_LENGTH-1 downto 0);
		output_value : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
 END COMPONENT;
 
component nbitregister
	 generic(SIGNAL_LENGTH: integer);
    Port ( pre_op, clk, rst : in  STD_LOGIC;
           op_a : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           q,qb : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0)
			  );
end component;

component clock_divider
    Generic ( division_factor: positive);
    Port ( clk_in : in  STD_LOGIC;
           en : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end component; 

-- mainly expander outputs, except for output_expanded.
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

-- registers outputs
signal input_previous_0 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_previous_1 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_previous_2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_previous_1 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_previous_2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);

-- computation_results
signal input_times_b0_mul : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_times_b0 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_p1_times_b1_mul : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_p1_times_b1 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_p2_times_b2_mul : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal input_p2_times_b2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_p1_times_a1_mul : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_p1_times_a1 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_p2_times_a2_mul : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal output_p2_times_a2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);

signal results_b0_b1 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal results_b0_b1_b2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal results_a1_a2 : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);
signal results_a1_a2_inv : STD_LOGIC_VECTOR(INTERNAL_VARIABLE_LENGTH-1 downto 0);

signal op_ready_global: std_logic;

--for input_times_b0_mul_component : signed_multiplier use entity
--			work.signed_multiplier(wallace_tree);
--
--for input_p1_times_b1_mul_component : signed_multiplier use entity
--			work.signed_multiplier(wallace_tree);
--			
--for input_p2_times_b2_mul_component : signed_multiplier use entity
--			work.signed_multiplier(wallace_tree);
--
--for output_p1_times_a1_mul_component : signed_multiplier use entity
--			work.signed_multiplier(wallace_tree);
--
--for output_p2_times_a2_mul_component : signed_multiplier use entity
--			work.signed_multiplier(wallace_tree);
--
--for input_times_b0_div_component : signed_divider use entity
--         work.signed_divider(n_plus_2_clock_cycles);
--         --work.signed_divider(cheat_divider);
--
--for input_p1_times_b1_div_component : signed_divider use entity
--         work.signed_divider(n_plus_2_clock_cycles);
--         --work.signed_divider(cheat_divider);
--
--for input_p2_times_b2_div_component : signed_divider use entity
--         work.signed_divider(n_plus_2_clock_cycles);
--         --work.signed_divider(cheat_divider);
--
--for output_p1_times_a1_div_component : signed_divider use entity
--         work.signed_divider(n_plus_2_clock_cycles);
--         --work.signed_divider(cheat_divider);
--
--for output_p2_times_a2_div_component : signed_divider use entity
--         work.signed_divider(n_plus_2_clock_cycles);
--         --work.signed_divider(cheat_divider);


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
		 in_value => parameter_A2_div,
		 out_value => A2_div_expanded);

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

input_expander: signed_expander 
generic map (IN_LENGTH => SIGNAL_LENGTH,
				 OUT_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 in_value => input_signal,
		 out_value => input_expanded);

output_contracter: signed_contracter
generic map (IN_LENGTH => INTERNAL_VARIABLE_LENGTH,
				 OUT_LENGTH => SIGNAL_LENGTH)
PORT MAP (
		 in_value => output_expanded,
		 out_value => output_signal,
		 overflow => temporary_overflow);


-- previous values registers TODO

input_prev_0_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
		 PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => input_expanded,
		 q => input_previous_0,
		 qb => open
	  );

input_prev_1_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
		 PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => input_previous_0,
		 q => input_previous_1,
		 qb => open
	  );

input_prev_2_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
		 PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => input_previous_1,
		 q => input_previous_2,
		 qb => open
	  );

output_previous_1 <= output_expanded;

--output_prev_1_register: nbitregister
--       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
--       PORT MAP (
--		 pre_op => op_ready_global,
--		 clk => clk,
--		 rst => reset,
--		 op_a => output_expanded,
--		 q => output_previous_1,
--		 qb => open
--	  );

output_prev_2_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
		 PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => output_previous_1,
		 q => output_previous_2,
		 qb => open
	  );

---- computation of multiplication/division of input/output values
-- multiplicators
input_times_b0_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_previous_0,
		input_B => B0_mul_expanded,
		clk => clk,
		reset => reset,
		en => en,
		output => input_times_b0_mul
	  );

input_p1_times_b1_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_previous_1,
		input_B => B1_mul_expanded,
		clk => clk,
		reset => reset,
		en => en,
		output => input_p1_times_b1_mul
	  );
	  
input_p2_times_b2_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_previous_2,
		input_B => B2_mul_expanded,
		clk => clk,
		reset => reset,
		en => en,
		output => input_p2_times_b2_mul
	  );
	  
output_p1_times_a1_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => output_previous_1,
		input_B => A1_mul_expanded,
		clk => clk,
		reset => reset,
		en => en,
		output => output_p1_times_a1_mul
	  );

output_p2_times_a2_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => output_previous_2,
		input_B => A2_mul_expanded,
		clk => clk,
		reset => reset,
		en => en,
		output => output_p2_times_a2_mul
	  );


-- dividers

input_times_b0_div_component: signed_divider
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_times_b0_mul,
		input_B => B0_div_expanded,
		op_ready => op_ready_global,
		clk => clk,
		reset => reset,
		en => en,
		two_sign_delays => '1',
		output => input_times_b0
	  );

input_p1_times_b1_div_component: signed_divider
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_p1_times_b1_mul,
		input_B => B1_div_expanded,
		op_ready => op_ready_global,
		clk => clk,
		reset => reset,
		en => en,
		two_sign_delays => '1',
		output => input_p1_times_b1
	  );
	  
input_p2_times_b2_div_component: signed_divider
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_p2_times_b2_mul,
		input_B => B2_div_expanded,
		op_ready => op_ready_global,
		clk => clk,
		reset => reset,
		en => en,
		two_sign_delays => '1',
		output => input_p2_times_b2
	  );
	  
output_p1_times_a1_div_component: signed_divider
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => output_p1_times_a1_mul,
		input_B => A1_div_expanded,
		op_ready => op_ready_global,
		clk => clk,
		reset => reset,
		en => en,
		two_sign_delays => '0',
		output => output_p1_times_a1
	  );
	  
output_p2_times_a2_div_component: signed_divider
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => output_p2_times_a2_mul,
		input_B => A2_div_expanded,
		op_ready => op_ready_global,
		clk => clk,
		reset => reset,
		en => en,
		two_sign_delays => '1',
		output => output_p2_times_a2
	  );

results_b0_b1_adder: signed_adder
generic map ( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 input_A => input_times_b0,
		 input_B => input_p1_times_b1,
		 clk => clk,
		 reset => reset,
		 en => en,
		 output=> results_b0_b1
	  );	  

results_b0_b1_b2_adder: signed_adder
generic map ( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 input_A => results_b0_b1,
		 input_B => input_p2_times_b2,
		 clk => clk,
		 reset => reset,
		 en => en,
		 output=> results_b0_b1_b2
	  );	  
	  
results_a1_a2_adder: signed_adder
generic map ( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 input_A => output_p1_times_a1,
		 input_B => output_p2_times_a2,
		 clk => clk,
		 reset => reset,
		 en => en,
		 output=> results_a1_a2
	  );	  

results_a1_a2_inv_inverter: signed_inverter
generic map (SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 input_value => results_a1_a2,
		 output_value => results_a1_a2_inv
	  );
	  
final_adder: signed_adder
generic map ( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT MAP (
		 input_A => results_b0_b1_b2,
		 input_B => results_a1_a2_inv,
		 clk => clk,
		 reset => reset,
		 en => en,
		 output=> output_expanded
	  );

clock_chopper_and_division: clock_divider

Generic map( division_factor => CLOCK_DIVISION_VALUE)
PORT MAP (
		 clk_in => clk,
		 en => en,
		 reset => reset,
		 clk_out => op_ready_global
	  );

change_input <= op_ready_global;

end flow_arch;

