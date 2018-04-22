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
constant CLOCK_DIVISION_VALUE: integer := INTERNAL_VARIABLE_LENGTH + 3;

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

for input_times_b0_mul_component : signed_multiplier use entity
			work.signed_multiplier(wallace_tree);

for input_p1_times_b1_mul_component : signed_multiplier use entity
			work.signed_multiplier(wallace_tree);
			
for input_p2_times_b2_mul_component : signed_multiplier use entity
			work.signed_multiplier(wallace_tree);

for output_p1_times_a1_mul_component : signed_multiplier use entity
			work.signed_multiplier(wallace_tree);

for output_p2_times_a2_mul_component : signed_multiplier use entity
			work.signed_multiplier(wallace_tree);

for input_times_b0_div_component : signed_divider use entity
         work.signed_divider(n_plus_2_clock_cycles);
         --work.signed_divider(cheat_divider);

for input_p1_times_b1_div_component : signed_divider use entity
         work.signed_divider(n_plus_2_clock_cycles);
         --work.signed_divider(cheat_divider);

for input_p2_times_b2_div_component : signed_divider use entity
         work.signed_divider(n_plus_2_clock_cycles);
         --work.signed_divider(cheat_divider);

for output_p1_times_a1_div_component : signed_divider use entity
         work.signed_divider(n_plus_2_clock_cycles);
         --work.signed_divider(cheat_divider);

for output_p2_times_a2_div_component : signed_divider use entity
         work.signed_divider(n_plus_2_clock_cycles);
         --work.signed_divider(cheat_divider);


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

input_prev_1_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
		 PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => input_expanded,
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

output_prev_1_register: nbitregister
       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
       PORT MAP (
		 pre_op => op_ready_global,
		 clk => clk,
		 rst => reset,
		 op_a => output_expanded,
		 q => output_previous_2, -- fix
		 qb => open
	  );

output_previous_1 <= output_expanded;

--output_prev_2_register: nbitregister
--       GENERIC MAP(SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
--		 PORT MAP (
--		 pre_op => op_ready_global,
--		 clk => clk,
--		 rst => reset,
--		 op_a => output_previous_1,
--		 q => output_previous_2,
--		 qb => open
--	  );

---- computation of multiplication/division of input/output values
-- multiplicators
input_times_b0_mul_component: signed_multiplier
generic map( SIGNAL_LENGTH => INTERNAL_VARIABLE_LENGTH)
PORT map(
		input_A => input_expanded,
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

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:50:27 04/08/2018 
-- Design Name: 
-- Module Name:    clock_divider - Behavioral 
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

entity clock_divider is
    Generic ( division_factor: positive);
    Port ( clk_in : in  STD_LOGIC;
           en : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end clock_divider;

architecture Behavioral of clock_divider is

signal division_ring: std_logic_vector(division_factor-1 downto 0);

begin

	process (clk_in, reset)
	begin
		if reset='1' then
			division_ring <= (1 => '1', others => '0');
			clk_out <= '0';
		elsif rising_edge(clk_in) then
			if en='1' then
				division_ring <= division_ring(division_factor-2 downto 0) & division_ring(division_factor-1);
				clk_out <= division_ring(1);
			end if;
		end if;
	end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:02:20 04/07/2018 
-- Design Name: 
-- Module Name:    FA - Behavioral 
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

entity FA is
Port ( bit_a : in  STD_LOGIC;
bit_b : in STD_LOGIC;
bit_c : in STD_LOGIC;
sum_sig : out  STD_LOGIC;
carry_sig: out STD_LOGIC
);
END FA;
architecture Behavioral of FA is

begin

sum_sig <= bit_a xor bit_b xor bit_c;
carry_sig <= (bit_a and bit_b) or (bit_c and (bit_a xor bit_b));

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:00:53 04/07/2018 
-- Design Name: 
-- Module Name:    HA - Behavioral 
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

entity HA is
Port (
    bit_a : in  STD_LOGIC;
    bit_b : in STD_LOGIC;
    sum_sig : out  STD_LOGIC;
    carry_sig: out STD_LOGIC
);
END HA;

architecture Behavioral of HA is

begin
sum_sig <= bit_a xor bit_b;
carry_sig <= bit_a and bit_b;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:51:05 04/05/2018 
-- Design Name: 
-- Module Name:    lt_comparator - Behavioral 
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

entity lt_comparator is
    Generic (SIGNAL_LENGTH: positive);
    Port ( input_a : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           input_b : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           is_less_than : out  STD_LOGIC);
end lt_comparator;

architecture Behavioral of lt_comparator is

begin

is_less_than <= '1' when input_a < input_b else '0';

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity nbitregister is
	 generic(SIGNAL_LENGTH: integer :=16);
    Port ( pre_op, clk, rst : in  STD_LOGIC;
           op_a : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           q,qb : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0)
			  );
end nbitregister;
architecture arch_nbitregister of nbitregister is
begin
	process (clk, rst)
	begin
		if rst='1' then
			q<=(others => '0');
		elsif clk'event and clk='1' then
			if pre_op='1' then
				q <= op_a;
				qb <= not op_a;
			end if;
		end if;
	end process;
end arch_nbitregister;----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:07:26 04/05/2018 
-- Design Name: 
-- Module Name:    shift_register - Behavioral 
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

entity shift_register is
    generic ( SIGNAL_LENGTH: positive);
    Port ( serial_in : in  STD_LOGIC;
           parallel_in : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           load : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           serial_out : out  STD_LOGIC;
           parallel_out : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0));
end shift_register;

architecture Behavioral of shift_register is

signal internal_value: std_logic_vector(SIGNAL_LENGTH-1 downto 0);

begin

-- generic values verification
assert SIGNAL_LENGTH > 1
report "signal must be greater than 1 bit"
severity failure;


process (clk, reset, enable)
begin
    if (reset = '1') then
	     internal_value <= (others => '0');
    elsif (rising_edge(clk) and enable = '1') then
	     if (load = '0') then
		      internal_value <= internal_value (SIGNAL_LENGTH-2 downto 0) & serial_in;
		  else
		      internal_value <= parallel_in;
		  end if;
	 end if;
end process;

parallel_out <= internal_value;
serial_out <= internal_value(SIGNAL_LENGTH-1); -- not necessary, but can be convenient outside.

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:19:59 03/22/2018 
-- Design Name: 
-- Module Name:    signed_adder - combinational 
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

-- This module assumes no overflowASDasd

entity signed_adder is
    generic ( SIGNAL_LENGTH: positive);
    Port ( input_A : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           input_B : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0));
end signed_adder;

architecture combinational_ripple_carry of signed_adder is

signal a_xor_b: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal carry: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);

begin

carry(0) <= '0';

a_xor_b <= input_A xor input_b;

output <= a_xor_b xor carry;

carry(SIGNAL_LENGTH-1 downto 1) <= (input_A(SIGNAL_LENGTH-2 downto 0) and input_B(SIGNAL_LENGTH-2 downto 0) ) or ( (a_xor_b(SIGNAL_LENGTH-2 downto 0))  and carry(SIGNAL_LENGTH-2 downto 0));

end combinational_ripple_carry;



architecture combinational_carry_lookahead of signed_adder is


signal P: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal G: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal Cin: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
begin

P <= input_A xor input_B;
output <= P xor Cin;
G <= input_A and input_B;

Cin(0) <= '0';
Cin(SIGNAL_LENGTH-1 downto 1) <= G(SIGNAL_LENGTH-2 downto 0) or (P(SIGNAL_LENGTH-2 downto 0) and Cin(SIGNAL_LENGTH-2 downto 0));
end combinational_carry_lookahead;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:50:37 03/22/2018 
-- Design Name: 
-- Module Name:    signed_contracter - combinational 
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

entity signed_contracter is
    generic ( IN_LENGTH: positive;
	           OUT_LENGTH: positive);
    Port ( in_value : in  STD_LOGIC_VECTOR (IN_LENGTH-1 downto 0);
           out_value : out  STD_LOGIC_VECTOR (OUT_LENGTH-1 downto 0);
           overflow : out  STD_LOGIC);
end signed_contracter;

architecture combinational of signed_contracter is

constant zeros : std_logic_vector(IN_LENGTH-1 downto OUT_LENGTH) := (others => '0');
constant ones : std_logic_vector(IN_LENGTH-1 downto OUT_LENGTH) := (others => '1');
begin

-- generic values verification
assert IN_LENGTH > OUT_LENGTH
report "output length must be greater than input length"
severity failure;

out_value <= in_value(OUT_LENGTH-1 downto 0);

overflow <= '0' when in_value(IN_LENGTH-1 downto OUT_LENGTH) = zeros else
            '0' when in_value(IN_LENGTH-1 downto OUT_LENGTH) = ones else
				'1';
end combinational;

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
		output : OUT  std_logic_vector(SIGNAL_LENGTH-1 downto 0)
	  );
end signed_divider;

architecture cheat_divider of signed_divider is

signal signed_long_output: std_logic_vector(SIGNAL_LENGTH-1 downto 0);

constant zeros : std_logic_vector(SIGNAL_LENGTH-1 downto 0) := (others => '0');

begin

process(input_A, input_B)
begin
    case input_B is
	     when zeros => signed_long_output <= zeros;
        when others => signed_long_output <= std_logic_vector(signed(input_A) / signed(input_B));
    end case;
end process;

output <= signed_long_output(SIGNAL_LENGTH-1 downto 0);

end cheat_divider;


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
	     output_sign_gated <= '0';
	 elsif (rising_edge(clk) and en = '1' and output_ready_signal = '1') then
	     output_sign_gated <= output_sign;
	 end if;
	 
end process;
op_ready_signal <= op_ready;

output <= unsigned_output_inverted when output_sign_gated = '1' else unsigned_output;
end n_plus_2_clock_cycles;----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:53:39 03/22/2018 
-- Design Name: 
-- Module Name:    signed_expander - Behavioral 
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

entity signed_expander is
    generic ( IN_LENGTH: positive;
	           OUT_LENGTH: positive);
    Port ( in_value : in  STD_LOGIC_VECTOR (IN_LENGTH-1 downto 0);
           out_value : out  STD_LOGIC_VECTOR (OUT_LENGTH-1 downto 0));
end signed_expander;

architecture combinational of signed_expander is
signal stretched_sig_bit: STD_LOGIC_VECTOR (OUT_LENGTH-IN_LENGTH-1 downto 0);
begin

-- generic values verification
assert IN_LENGTH < OUT_LENGTH
report "output length must be greater than input length"
severity failure;



stretched_sig_bit <= (others => in_value(IN_LENGTH-1));
out_value <= stretched_sig_bit & in_value;

end combinational;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:25:08 03/22/2018 
-- Design Name: 
-- Module Name:    signed_inverter - combinatorial 
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

entity signed_inverter is
    generic ( SIGNAL_LENGTH: positive);
    Port ( input_value : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           output_value : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0));
end signed_inverter;

architecture combinational of signed_inverter is

signal inversion: std_logic_vector (SIGNAL_LENGTH-1 downto 0);
signal carry: std_logic_vector(SIGNAL_LENGTH-1 downto 0);
begin

inversion <= not input_value;

-- implicit half adders to do a simple increment
carry(0) <= '1';
output_value <= inversion xor carry;
carry(SIGNAL_LENGTH-1 downto 1) <= inversion(SIGNAL_LENGTH-2 downto 0) and carry(SIGNAL_LENGTH-2 downto 0);

end combinational;

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

architecture cheat_multiplier of signed_multiplier is

signal signed_long_output: std_logic_vector(SIGNAL_LENGTH*2-1 downto 0);

begin

signed_long_output <= std_logic_vector(signed(input_A) * signed(input_B));

output <= signed_long_output(SIGNAL_LENGTH-1 downto 0);

end cheat_multiplier;

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


end wallace_tree;----------------------------------------------------------------------------------
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
signal substraction_result_too_long: std_logic_vector(SIGNAL_LENGTH downto 0);

signal readiness_propagation_vector: std_logic_vector(SIGNAL_LENGTH+1 downto 0);

signal quotient_not_gated: std_logic_vector(SIGNAL_LENGTH-1 downto 0);
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
          parallel_out => quotient_not_gated);
			 
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
          output=> substraction_result_too_long
        );
		  
   -- remove the useless substraction result bit
	substraction_result <= substraction_result_too_long(SIGNAL_LENGTH-1 downto 0);

	
	-- invert lt comparator output to get the greater than or equal comparator
	is_greater_than_or_equal <= not is_less_than;
	
	-- shifts and fuses the substraction output
	shifted_substraction_result <= substraction_result(SIGNAL_LENGTH-2 downto 0) & shifted_input_bit;
	
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
	    if (reset = '1') then
		     readiness_propagation_vector <= (others => '0');
		 elsif (rising_edge(clk)) then
		     readiness_propagation_vector <= readiness_propagation_vector(SIGNAL_LENGTH downto 0) & op_ready;
			  --readiness_propagation_vector <= (others => '1');
		 end if;
	end process;

   process(clk, reset)
	begin
	    if (reset = '1') then
		     quotient <= (others => '0');
		 elsif (rising_edge(clk) and readiness_propagation_vector(SIGNAL_LENGTH+1) = '1') then
		     quotient <= quotient_not_gated;
		 end if;
		 
	end process;
	
output_ready <= readiness_propagation_vector(SIGNAL_LENGTH+1);

end classic_shifter;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity unsigned_multiplier is
PORT(
input_A : IN  std_logic_vector(18-1 downto 0);
input_B : IN  std_logic_vector(18-1 downto 0);
clk : IN  std_logic;
reset : IN  std_logic;
en : IN  std_logic;
output : OUT  std_logic_vector(18-1 downto 0)
);
end unsigned_multiplier;

architecture wallace_tree of unsigned_multiplier is

COMPONENT HA
Port (
    bit_a : in  STD_LOGIC;
    bit_b : in STD_LOGIC;
    sum_sig : out  STD_LOGIC;
    carry_sig: out STD_LOGIC
);
END COMPONENT;

COMPONENT FA
Port ( bit_a : in  STD_LOGIC;
bit_b : in STD_LOGIC;
bit_c : in STD_LOGIC;
sum_sig : out  STD_LOGIC;
carry_sig: out STD_LOGIC
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
signal a0_and_b0: std_logic;
signal a0_and_b1: std_logic;
signal a0_and_b2: std_logic;
signal a0_and_b3: std_logic;
signal a0_and_b4: std_logic;
signal a0_and_b5: std_logic;
signal a0_and_b6: std_logic;
signal a0_and_b7: std_logic;
signal a0_and_b8: std_logic;
signal a0_and_b9: std_logic;
signal a0_and_b10: std_logic;
signal a0_and_b11: std_logic;
signal a0_and_b12: std_logic;
signal a0_and_b13: std_logic;
signal a0_and_b14: std_logic;
signal a0_and_b15: std_logic;
signal a0_and_b16: std_logic;
signal a0_and_b17: std_logic;
signal a1_and_b0: std_logic;
signal a1_and_b1: std_logic;
signal a1_and_b2: std_logic;
signal a1_and_b3: std_logic;
signal a1_and_b4: std_logic;
signal a1_and_b5: std_logic;
signal a1_and_b6: std_logic;
signal a1_and_b7: std_logic;
signal a1_and_b8: std_logic;
signal a1_and_b9: std_logic;
signal a1_and_b10: std_logic;
signal a1_and_b11: std_logic;
signal a1_and_b12: std_logic;
signal a1_and_b13: std_logic;
signal a1_and_b14: std_logic;
signal a1_and_b15: std_logic;
signal a1_and_b16: std_logic;
signal a1_and_b17: std_logic;
signal a2_and_b0: std_logic;
signal a2_and_b1: std_logic;
signal a2_and_b2: std_logic;
signal a2_and_b3: std_logic;
signal a2_and_b4: std_logic;
signal a2_and_b5: std_logic;
signal a2_and_b6: std_logic;
signal a2_and_b7: std_logic;
signal a2_and_b8: std_logic;
signal a2_and_b9: std_logic;
signal a2_and_b10: std_logic;
signal a2_and_b11: std_logic;
signal a2_and_b12: std_logic;
signal a2_and_b13: std_logic;
signal a2_and_b14: std_logic;
signal a2_and_b15: std_logic;
signal a2_and_b16: std_logic;
signal a2_and_b17: std_logic;
signal a3_and_b0: std_logic;
signal a3_and_b1: std_logic;
signal a3_and_b2: std_logic;
signal a3_and_b3: std_logic;
signal a3_and_b4: std_logic;
signal a3_and_b5: std_logic;
signal a3_and_b6: std_logic;
signal a3_and_b7: std_logic;
signal a3_and_b8: std_logic;
signal a3_and_b9: std_logic;
signal a3_and_b10: std_logic;
signal a3_and_b11: std_logic;
signal a3_and_b12: std_logic;
signal a3_and_b13: std_logic;
signal a3_and_b14: std_logic;
signal a3_and_b15: std_logic;
signal a3_and_b16: std_logic;
signal a3_and_b17: std_logic;
signal a4_and_b0: std_logic;
signal a4_and_b1: std_logic;
signal a4_and_b2: std_logic;
signal a4_and_b3: std_logic;
signal a4_and_b4: std_logic;
signal a4_and_b5: std_logic;
signal a4_and_b6: std_logic;
signal a4_and_b7: std_logic;
signal a4_and_b8: std_logic;
signal a4_and_b9: std_logic;
signal a4_and_b10: std_logic;
signal a4_and_b11: std_logic;
signal a4_and_b12: std_logic;
signal a4_and_b13: std_logic;
signal a4_and_b14: std_logic;
signal a4_and_b15: std_logic;
signal a4_and_b16: std_logic;
signal a4_and_b17: std_logic;
signal a5_and_b0: std_logic;
signal a5_and_b1: std_logic;
signal a5_and_b2: std_logic;
signal a5_and_b3: std_logic;
signal a5_and_b4: std_logic;
signal a5_and_b5: std_logic;
signal a5_and_b6: std_logic;
signal a5_and_b7: std_logic;
signal a5_and_b8: std_logic;
signal a5_and_b9: std_logic;
signal a5_and_b10: std_logic;
signal a5_and_b11: std_logic;
signal a5_and_b12: std_logic;
signal a5_and_b13: std_logic;
signal a5_and_b14: std_logic;
signal a5_and_b15: std_logic;
signal a5_and_b16: std_logic;
signal a5_and_b17: std_logic;
signal a6_and_b0: std_logic;
signal a6_and_b1: std_logic;
signal a6_and_b2: std_logic;
signal a6_and_b3: std_logic;
signal a6_and_b4: std_logic;
signal a6_and_b5: std_logic;
signal a6_and_b6: std_logic;
signal a6_and_b7: std_logic;
signal a6_and_b8: std_logic;
signal a6_and_b9: std_logic;
signal a6_and_b10: std_logic;
signal a6_and_b11: std_logic;
signal a6_and_b12: std_logic;
signal a6_and_b13: std_logic;
signal a6_and_b14: std_logic;
signal a6_and_b15: std_logic;
signal a6_and_b16: std_logic;
signal a6_and_b17: std_logic;
signal a7_and_b0: std_logic;
signal a7_and_b1: std_logic;
signal a7_and_b2: std_logic;
signal a7_and_b3: std_logic;
signal a7_and_b4: std_logic;
signal a7_and_b5: std_logic;
signal a7_and_b6: std_logic;
signal a7_and_b7: std_logic;
signal a7_and_b8: std_logic;
signal a7_and_b9: std_logic;
signal a7_and_b10: std_logic;
signal a7_and_b11: std_logic;
signal a7_and_b12: std_logic;
signal a7_and_b13: std_logic;
signal a7_and_b14: std_logic;
signal a7_and_b15: std_logic;
signal a7_and_b16: std_logic;
signal a7_and_b17: std_logic;
signal a8_and_b0: std_logic;
signal a8_and_b1: std_logic;
signal a8_and_b2: std_logic;
signal a8_and_b3: std_logic;
signal a8_and_b4: std_logic;
signal a8_and_b5: std_logic;
signal a8_and_b6: std_logic;
signal a8_and_b7: std_logic;
signal a8_and_b8: std_logic;
signal a8_and_b9: std_logic;
signal a8_and_b10: std_logic;
signal a8_and_b11: std_logic;
signal a8_and_b12: std_logic;
signal a8_and_b13: std_logic;
signal a8_and_b14: std_logic;
signal a8_and_b15: std_logic;
signal a8_and_b16: std_logic;
signal a8_and_b17: std_logic;
signal a9_and_b0: std_logic;
signal a9_and_b1: std_logic;
signal a9_and_b2: std_logic;
signal a9_and_b3: std_logic;
signal a9_and_b4: std_logic;
signal a9_and_b5: std_logic;
signal a9_and_b6: std_logic;
signal a9_and_b7: std_logic;
signal a9_and_b8: std_logic;
signal a9_and_b9: std_logic;
signal a9_and_b10: std_logic;
signal a9_and_b11: std_logic;
signal a9_and_b12: std_logic;
signal a9_and_b13: std_logic;
signal a9_and_b14: std_logic;
signal a9_and_b15: std_logic;
signal a9_and_b16: std_logic;
signal a9_and_b17: std_logic;
signal a10_and_b0: std_logic;
signal a10_and_b1: std_logic;
signal a10_and_b2: std_logic;
signal a10_and_b3: std_logic;
signal a10_and_b4: std_logic;
signal a10_and_b5: std_logic;
signal a10_and_b6: std_logic;
signal a10_and_b7: std_logic;
signal a10_and_b8: std_logic;
signal a10_and_b9: std_logic;
signal a10_and_b10: std_logic;
signal a10_and_b11: std_logic;
signal a10_and_b12: std_logic;
signal a10_and_b13: std_logic;
signal a10_and_b14: std_logic;
signal a10_and_b15: std_logic;
signal a10_and_b16: std_logic;
signal a10_and_b17: std_logic;
signal a11_and_b0: std_logic;
signal a11_and_b1: std_logic;
signal a11_and_b2: std_logic;
signal a11_and_b3: std_logic;
signal a11_and_b4: std_logic;
signal a11_and_b5: std_logic;
signal a11_and_b6: std_logic;
signal a11_and_b7: std_logic;
signal a11_and_b8: std_logic;
signal a11_and_b9: std_logic;
signal a11_and_b10: std_logic;
signal a11_and_b11: std_logic;
signal a11_and_b12: std_logic;
signal a11_and_b13: std_logic;
signal a11_and_b14: std_logic;
signal a11_and_b15: std_logic;
signal a11_and_b16: std_logic;
signal a11_and_b17: std_logic;
signal a12_and_b0: std_logic;
signal a12_and_b1: std_logic;
signal a12_and_b2: std_logic;
signal a12_and_b3: std_logic;
signal a12_and_b4: std_logic;
signal a12_and_b5: std_logic;
signal a12_and_b6: std_logic;
signal a12_and_b7: std_logic;
signal a12_and_b8: std_logic;
signal a12_and_b9: std_logic;
signal a12_and_b10: std_logic;
signal a12_and_b11: std_logic;
signal a12_and_b12: std_logic;
signal a12_and_b13: std_logic;
signal a12_and_b14: std_logic;
signal a12_and_b15: std_logic;
signal a12_and_b16: std_logic;
signal a12_and_b17: std_logic;
signal a13_and_b0: std_logic;
signal a13_and_b1: std_logic;
signal a13_and_b2: std_logic;
signal a13_and_b3: std_logic;
signal a13_and_b4: std_logic;
signal a13_and_b5: std_logic;
signal a13_and_b6: std_logic;
signal a13_and_b7: std_logic;
signal a13_and_b8: std_logic;
signal a13_and_b9: std_logic;
signal a13_and_b10: std_logic;
signal a13_and_b11: std_logic;
signal a13_and_b12: std_logic;
signal a13_and_b13: std_logic;
signal a13_and_b14: std_logic;
signal a13_and_b15: std_logic;
signal a13_and_b16: std_logic;
signal a13_and_b17: std_logic;
signal a14_and_b0: std_logic;
signal a14_and_b1: std_logic;
signal a14_and_b2: std_logic;
signal a14_and_b3: std_logic;
signal a14_and_b4: std_logic;
signal a14_and_b5: std_logic;
signal a14_and_b6: std_logic;
signal a14_and_b7: std_logic;
signal a14_and_b8: std_logic;
signal a14_and_b9: std_logic;
signal a14_and_b10: std_logic;
signal a14_and_b11: std_logic;
signal a14_and_b12: std_logic;
signal a14_and_b13: std_logic;
signal a14_and_b14: std_logic;
signal a14_and_b15: std_logic;
signal a14_and_b16: std_logic;
signal a14_and_b17: std_logic;
signal a15_and_b0: std_logic;
signal a15_and_b1: std_logic;
signal a15_and_b2: std_logic;
signal a15_and_b3: std_logic;
signal a15_and_b4: std_logic;
signal a15_and_b5: std_logic;
signal a15_and_b6: std_logic;
signal a15_and_b7: std_logic;
signal a15_and_b8: std_logic;
signal a15_and_b9: std_logic;
signal a15_and_b10: std_logic;
signal a15_and_b11: std_logic;
signal a15_and_b12: std_logic;
signal a15_and_b13: std_logic;
signal a15_and_b14: std_logic;
signal a15_and_b15: std_logic;
signal a15_and_b16: std_logic;
signal a15_and_b17: std_logic;
signal a16_and_b0: std_logic;
signal a16_and_b1: std_logic;
signal a16_and_b2: std_logic;
signal a16_and_b3: std_logic;
signal a16_and_b4: std_logic;
signal a16_and_b5: std_logic;
signal a16_and_b6: std_logic;
signal a16_and_b7: std_logic;
signal a16_and_b8: std_logic;
signal a16_and_b9: std_logic;
signal a16_and_b10: std_logic;
signal a16_and_b11: std_logic;
signal a16_and_b12: std_logic;
signal a16_and_b13: std_logic;
signal a16_and_b14: std_logic;
signal a16_and_b15: std_logic;
signal a16_and_b16: std_logic;
signal a16_and_b17: std_logic;
signal a17_and_b0: std_logic;
signal a17_and_b1: std_logic;
signal a17_and_b2: std_logic;
signal a17_and_b3: std_logic;
signal a17_and_b4: std_logic;
signal a17_and_b5: std_logic;
signal a17_and_b6: std_logic;
signal a17_and_b7: std_logic;
signal a17_and_b8: std_logic;
signal a17_and_b9: std_logic;
signal a17_and_b10: std_logic;
signal a17_and_b11: std_logic;
signal a17_and_b12: std_logic;
signal a17_and_b13: std_logic;
signal a17_and_b14: std_logic;
signal a17_and_b15: std_logic;
signal a17_and_b16: std_logic;
signal a17_and_b17: std_logic;
signal sum_layer1_127830168_127844480: std_logic;
signal carry_layer1_127830168_127844480: std_logic;
signal sum_layer1_127830336_127844592_127846496: std_logic;
signal carry_layer1_127830336_127844592_127846496: std_logic;
signal sum_layer1_127830448_127844704_127846608: std_logic;
signal carry_layer1_127830448_127844704_127846608: std_logic;
signal sum_layer1_127830560_127844816_127846720: std_logic;
signal carry_layer1_127830560_127844816_127846720: std_logic;
signal sum_layer1_127672560_127674464: std_logic;
signal carry_layer1_127672560_127674464: std_logic;
signal sum_layer1_127830672_127844928_127846832: std_logic;
signal carry_layer1_127830672_127844928_127846832: std_logic;
signal sum_layer1_127672672_127674576_127729792: std_logic;
signal carry_layer1_127672672_127674576_127729792: std_logic;
signal sum_layer1_127830784_127845040_127846944: std_logic;
signal carry_layer1_127830784_127845040_127846944: std_logic;
signal sum_layer1_127672784_127674688_127729904: std_logic;
signal carry_layer1_127672784_127674688_127729904: std_logic;
signal sum_layer1_127830896_127845152_127847056: std_logic;
signal carry_layer1_127830896_127845152_127847056: std_logic;
signal sum_layer1_127672896_127674800_127730016: std_logic;
signal carry_layer1_127672896_127674800_127730016: std_logic;
signal sum_layer1_127731920_127721600: std_logic;
signal carry_layer1_127731920_127721600: std_logic;
signal sum_layer1_127831008_127845264_127847168: std_logic;
signal carry_layer1_127831008_127845264_127847168: std_logic;
signal sum_layer1_127673008_127674912_127730128: std_logic;
signal carry_layer1_127673008_127674912_127730128: std_logic;
signal sum_layer1_127732032_127721712_127723616: std_logic;
signal carry_layer1_127732032_127721712_127723616: std_logic;
signal sum_layer1_127831120_127845376_127847280: std_logic;
signal carry_layer1_127831120_127845376_127847280: std_logic;
signal sum_layer1_127673120_127675024_127730240: std_logic;
signal carry_layer1_127673120_127675024_127730240: std_logic;
signal sum_layer1_127732144_127721824_127723728: std_logic;
signal carry_layer1_127732144_127721824_127723728: std_logic;
signal sum_layer1_127831232_127845488_127847392: std_logic;
signal carry_layer1_127831232_127845488_127847392: std_logic;
signal sum_layer1_127673232_127675136_127730352: std_logic;
signal carry_layer1_127673232_127675136_127730352: std_logic;
signal sum_layer1_127732256_127721936_127723840: std_logic;
signal carry_layer1_127732256_127721936_127723840: std_logic;
signal sum_layer1_127635696_127637600: std_logic;
signal carry_layer1_127635696_127637600: std_logic;
signal sum_layer1_127831344_127845600_127847504: std_logic;
signal carry_layer1_127831344_127845600_127847504: std_logic;
signal sum_layer1_127673344_127675248_127730464: std_logic;
signal carry_layer1_127673344_127675248_127730464: std_logic;
signal sum_layer1_127732368_127722048_127723952: std_logic;
signal carry_layer1_127732368_127722048_127723952: std_logic;
signal sum_layer1_127635808_127637712_127713408: std_logic;
signal carry_layer1_127635808_127637712_127713408: std_logic;
signal sum_layer1_127831456_127845712_127847616: std_logic;
signal carry_layer1_127831456_127845712_127847616: std_logic;
signal sum_layer1_127673456_127675360_127730576: std_logic;
signal carry_layer1_127673456_127675360_127730576: std_logic;
signal sum_layer1_127732480_127722160_127724064: std_logic;
signal carry_layer1_127732480_127722160_127724064: std_logic;
signal sum_layer1_127635920_127637824_127713520: std_logic;
signal carry_layer1_127635920_127637824_127713520: std_logic;
signal sum_layer1_127831568_127845824_127847728: std_logic;
signal carry_layer1_127831568_127845824_127847728: std_logic;
signal sum_layer1_127673568_127675472_127730688: std_logic;
signal carry_layer1_127673568_127675472_127730688: std_logic;
signal sum_layer1_127732592_127722272_127724176: std_logic;
signal carry_layer1_127732592_127722272_127724176: std_logic;
signal sum_layer1_127636032_127637936_127713632: std_logic;
signal carry_layer1_127636032_127637936_127713632: std_logic;
signal sum_layer1_127715536_127848576: std_logic;
signal carry_layer1_127715536_127848576: std_logic;
signal sum_layer1_127831680_127845936_127847840: std_logic;
signal carry_layer1_127831680_127845936_127847840: std_logic;
signal sum_layer1_127673680_127675584_127730800: std_logic;
signal carry_layer1_127673680_127675584_127730800: std_logic;
signal sum_layer1_127732704_127722384_127724288: std_logic;
signal carry_layer1_127732704_127722384_127724288: std_logic;
signal sum_layer1_127636144_127638048_127713744: std_logic;
signal carry_layer1_127636144_127638048_127713744: std_logic;
signal sum_layer1_127715648_127848688_127850592: std_logic;
signal carry_layer1_127715648_127848688_127850592: std_logic;
signal sum_layer1_127831792_127846048_127847952: std_logic;
signal carry_layer1_127831792_127846048_127847952: std_logic;
signal sum_layer1_127673792_127675696_127730912: std_logic;
signal carry_layer1_127673792_127675696_127730912: std_logic;
signal sum_layer1_127732816_127722496_127724400: std_logic;
signal carry_layer1_127732816_127722496_127724400: std_logic;
signal sum_layer1_127636256_127638160_127713856: std_logic;
signal carry_layer1_127636256_127638160_127713856: std_logic;
signal sum_layer1_127715760_127848800_127850704: std_logic;
signal carry_layer1_127715760_127848800_127850704: std_logic;
signal sum_layer1_127831904_127846160_127848064: std_logic;
signal carry_layer1_127831904_127846160_127848064: std_logic;
signal sum_layer1_127673904_127675808_127731024: std_logic;
signal carry_layer1_127673904_127675808_127731024: std_logic;
signal sum_layer1_127732928_127722608_127724512: std_logic;
signal carry_layer1_127732928_127722608_127724512: std_logic;
signal sum_layer1_127636368_127638272_127713968: std_logic;
signal carry_layer1_127636368_127638272_127713968: std_logic;
signal sum_layer1_127715872_127848912_127850816: std_logic;
signal carry_layer1_127715872_127848912_127850816: std_logic;
signal sum_layer1_127627504_127629408: std_logic;
signal carry_layer1_127627504_127629408: std_logic;
signal sum_layer1_127832016_127846272_127848176: std_logic;
signal carry_layer1_127832016_127846272_127848176: std_logic;
signal sum_layer1_127674016_127675920_127731136: std_logic;
signal carry_layer1_127674016_127675920_127731136: std_logic;
signal sum_layer1_127733040_127722720_127724624: std_logic;
signal carry_layer1_127733040_127722720_127724624: std_logic;
signal sum_layer1_127636480_127638384_127714080: std_logic;
signal carry_layer1_127636480_127638384_127714080: std_logic;
signal sum_layer1_127715984_127849024_127850928: std_logic;
signal carry_layer1_127715984_127849024_127850928: std_logic;
signal sum_layer1_127627616_127629520_127824000: std_logic;
signal carry_layer1_127627616_127629520_127824000: std_logic;
signal sum_layer1_127846384_127848288_127674128: std_logic;
signal carry_layer1_127846384_127848288_127674128: std_logic;
signal sum_layer1_127676032_127731248_127733152: std_logic;
signal carry_layer1_127676032_127731248_127733152: std_logic;
signal sum_layer1_127722832_127724736_127636592: std_logic;
signal carry_layer1_127722832_127724736_127636592: std_logic;
signal sum_layer1_127638496_127714192_127716096: std_logic;
signal carry_layer1_127638496_127714192_127716096: std_logic;
signal sum_layer1_127849136_127851040_127627728: std_logic;
signal carry_layer1_127849136_127851040_127627728: std_logic;
signal sum_layer1_127629632_127824112: std_logic;
signal carry_layer1_127629632_127824112: std_logic;
signal sum_layer1_127848400_127674240_127676144: std_logic;
signal carry_layer1_127848400_127674240_127676144: std_logic;
signal sum_layer1_127731360_127733264_127722944: std_logic;
signal carry_layer1_127731360_127733264_127722944: std_logic;
signal sum_layer1_127724848_127636704_127638608: std_logic;
signal carry_layer1_127724848_127636704_127638608: std_logic;
signal sum_layer1_127714304_127716208_127849248: std_logic;
signal carry_layer1_127714304_127716208_127849248: std_logic;
signal sum_layer1_127851152_127627840_127629744: std_logic;
signal carry_layer1_127851152_127627840_127629744: std_logic;
signal sum_layer1_127674352_127676256_127731472: std_logic;
signal carry_layer1_127674352_127676256_127731472: std_logic;
signal sum_layer1_127733376_127723056_127724960: std_logic;
signal carry_layer1_127733376_127723056_127724960: std_logic;
signal sum_layer1_127636816_127638720_127714416: std_logic;
signal carry_layer1_127636816_127638720_127714416: std_logic;
signal sum_layer1_127716320_127849360_127851264: std_logic;
signal carry_layer1_127716320_127849360_127851264: std_logic;
signal sum_layer1_127627952_127629856_127824336: std_logic;
signal carry_layer1_127627952_127629856_127824336: std_logic;
signal sum_layer1_127676368_127731584_127733488: std_logic;
signal carry_layer1_127676368_127731584_127733488: std_logic;
signal sum_layer1_127723168_127725072_127636928: std_logic;
signal carry_layer1_127723168_127725072_127636928: std_logic;
signal sum_layer1_127638832_127714528_127716432: std_logic;
signal carry_layer1_127638832_127714528_127716432: std_logic;
signal sum_layer1_127849472_127851376_127628064: std_logic;
signal carry_layer1_127849472_127851376_127628064: std_logic;
signal sum_layer1_127629968_127824448: std_logic;
signal carry_layer1_127629968_127824448: std_logic;
signal sum_layer1_127731696_127733600_127723280: std_logic;
signal carry_layer1_127731696_127733600_127723280: std_logic;
signal sum_layer1_127725184_127637040_127638944: std_logic;
signal carry_layer1_127725184_127637040_127638944: std_logic;
signal sum_layer1_127714640_127716544_127849584: std_logic;
signal carry_layer1_127714640_127716544_127849584: std_logic;
signal sum_layer1_127851488_127628176_127630080: std_logic;
signal carry_layer1_127851488_127628176_127630080: std_logic;
signal sum_layer1_127733712_127723392_127725296: std_logic;
signal carry_layer1_127733712_127723392_127725296: std_logic;
signal sum_layer1_127637152_127639056_127714752: std_logic;
signal carry_layer1_127637152_127639056_127714752: std_logic;
signal sum_layer1_127716656_127849696_127851600: std_logic;
signal carry_layer1_127716656_127849696_127851600: std_logic;
signal sum_layer1_127628288_127630192_127824672: std_logic;
signal carry_layer1_127628288_127630192_127824672: std_logic;
signal sum_layer1_127723504_127725408_127637264: std_logic;
signal carry_layer1_127723504_127725408_127637264: std_logic;
signal sum_layer1_127639168_127714864_127716768: std_logic;
signal carry_layer1_127639168_127714864_127716768: std_logic;
signal sum_layer1_127849808_127851712_127628400: std_logic;
signal carry_layer1_127849808_127851712_127628400: std_logic;
signal sum_layer1_127630304_127824784: std_logic;
signal carry_layer1_127630304_127824784: std_logic;
signal sum_layer1_127725520_127637376_127639280: std_logic;
signal carry_layer1_127725520_127637376_127639280: std_logic;
signal sum_layer1_127714976_127716880_127849920: std_logic;
signal carry_layer1_127714976_127716880_127849920: std_logic;
signal sum_layer1_127851824_127628512_127630416: std_logic;
signal carry_layer1_127851824_127628512_127630416: std_logic;
signal sum_layer1_127637488_127639392_127715088: std_logic;
signal carry_layer1_127637488_127639392_127715088: std_logic;
signal sum_layer1_127716992_127850032_127851936: std_logic;
signal carry_layer1_127716992_127850032_127851936: std_logic;
signal sum_layer1_127628624_127630528_127825008: std_logic;
signal carry_layer1_127628624_127630528_127825008: std_logic;
signal sum_layer1_127639504_127715200_127717104: std_logic;
signal carry_layer1_127639504_127715200_127717104: std_logic;
signal sum_layer1_127850144_127852048_127628736: std_logic;
signal carry_layer1_127850144_127852048_127628736: std_logic;
signal sum_layer1_127630640_127825120: std_logic;
signal carry_layer1_127630640_127825120: std_logic;
signal sum_layer1_127715312_127717216_127850256: std_logic;
signal carry_layer1_127715312_127717216_127850256: std_logic;
signal sum_layer1_127852160_127628848_127630752: std_logic;
signal carry_layer1_127852160_127628848_127630752: std_logic;
signal sum_layer1_127717328_127850368_127852272: std_logic;
signal carry_layer1_127717328_127850368_127852272: std_logic;
signal sum_layer1_127628960_127630864_127825344: std_logic;
signal carry_layer1_127628960_127630864_127825344: std_logic;
signal sum_layer1_127850480_127852384_127629072: std_logic;
signal carry_layer1_127850480_127852384_127629072: std_logic;
signal sum_layer1_127630976_127825456: std_logic;
signal carry_layer1_127630976_127825456: std_logic;
signal sum_layer1_127852496_127629184_127631088: std_logic;
signal carry_layer1_127852496_127629184_127631088: std_logic;
signal sum_layer1_127629296_127631200_127825680: std_logic;
signal carry_layer1_127629296_127631200_127825680: std_logic;
signal sum_layer1_127631312_127825792: std_logic;
signal carry_layer1_127631312_127825792: std_logic;
signal sum_layer2_127826128_127826296: std_logic;
signal carry_layer2_127826128_127826296: std_logic;
signal sum_layer2_127672448_127826240_127826520: std_logic;
signal carry_layer2_127672448_127826240_127826520: std_logic;
signal sum_layer2_127826464_127826632_127826744: std_logic;
signal carry_layer2_127826464_127826632_127826744: std_logic;
signal sum_layer2_127826576_127826800_127826968: std_logic;
signal carry_layer2_127826576_127826800_127826968: std_logic;
signal sum_layer2_127731808_127826912_127827136: std_logic;
signal carry_layer2_127731808_127826912_127827136: std_logic;
signal sum_layer2_127827304_127827416: std_logic;
signal carry_layer2_127827304_127827416: std_logic;
signal sum_layer2_127827248_127827472_127827640: std_logic;
signal carry_layer2_127827248_127827472_127827640: std_logic;
signal sum_layer2_127827752_127827920: std_logic;
signal carry_layer2_127827752_127827920: std_logic;
signal sum_layer2_127827584_127827808_128221256: std_logic;
signal carry_layer2_127827584_127827808_128221256: std_logic;
signal sum_layer2_128221424_128221536_128221704: std_logic;
signal carry_layer2_128221424_128221536_128221704: std_logic;
signal sum_layer2_127635584_128221368_128221592: std_logic;
signal carry_layer2_127635584_128221368_128221592: std_logic;
signal sum_layer2_128221760_128221928_128222040: std_logic;
signal carry_layer2_128221760_128221928_128222040: std_logic;
signal sum_layer2_128221872_128222096_128222264: std_logic;
signal carry_layer2_128221872_128222096_128222264: std_logic;
signal sum_layer2_128222432_128222544_128222712: std_logic;
signal carry_layer2_128222432_128222544_128222712: std_logic;
signal sum_layer2_128222376_128222600_128222768: std_logic;
signal carry_layer2_128222376_128222600_128222768: std_logic;
signal sum_layer2_128222936_128223104_128223216: std_logic;
signal carry_layer2_128222936_128223104_128223216: std_logic;
signal sum_layer2_128223384_128223552: std_logic;
signal carry_layer2_128223384_128223552: std_logic;
signal sum_layer2_127715424_128223048_128223272: std_logic;
signal carry_layer2_127715424_128223048_128223272: std_logic;
signal sum_layer2_128223440_128223608_128223776: std_logic;
signal carry_layer2_128223440_128223608_128223776: std_logic;
signal sum_layer2_128223888_128224112_128224056: std_logic;
signal carry_layer2_128223888_128224112_128224056: std_logic;
signal sum_layer2_128223720_128223944_128224168: std_logic;
signal carry_layer2_128223720_128223944_128224168: std_logic;
signal sum_layer2_128224280_128224448_128224560: std_logic;
signal carry_layer2_128224280_128224448_128224560: std_logic;
signal sum_layer2_128224728_128224896_128225064: std_logic;
signal carry_layer2_128224728_128224896_128225064: std_logic;
signal sum_layer2_128224392_128224616_128224784: std_logic;
signal carry_layer2_128224392_128224616_128224784: std_logic;
signal sum_layer2_128224952_128225120_128225232: std_logic;
signal carry_layer2_128224952_128225120_128225232: std_logic;
signal sum_layer2_128196792_128196960_128197184: std_logic;
signal carry_layer2_128196792_128196960_128197184: std_logic;
signal sum_layer2_127627392_128196680_128196848: std_logic;
signal carry_layer2_127627392_128196680_128196848: std_logic;
signal sum_layer2_128197016_128197240_128197352: std_logic;
signal carry_layer2_128197016_128197240_128197352: std_logic;
signal sum_layer2_128197520_128197632_128197800: std_logic;
signal carry_layer2_128197520_128197632_128197800: std_logic;
signal sum_layer2_128198024_128197968: std_logic;
signal carry_layer2_128198024_128197968: std_logic;
signal sum_layer2_128197464_128197688_128197856: std_logic;
signal carry_layer2_128197464_128197688_128197856: std_logic;
signal sum_layer2_128198080_128198192_128198360: std_logic;
signal carry_layer2_128198080_128198192_128198360: std_logic;
signal sum_layer2_128198472_128198640_128198808: std_logic;
signal carry_layer2_128198472_128198640_128198808: std_logic;
signal sum_layer2_128198976_128199144: std_logic;
signal carry_layer2_128198976_128199144: std_logic;
signal sum_layer2_128198304_128198528_128198696: std_logic;
signal carry_layer2_128198304_128198528_128198696: std_logic;
signal sum_layer2_128198864_128199032_128199200: std_logic;
signal carry_layer2_128198864_128199032_128199200: std_logic;
signal sum_layer2_128199368_128199480_128199648: std_logic;
signal carry_layer2_128199368_128199480_128199648: std_logic;
signal sum_layer2_128199816_128200040_128199984: std_logic;
signal carry_layer2_128199816_128200040_128199984: std_logic;
signal sum_layer2_128199312_128199536_128199704: std_logic;
signal carry_layer2_128199312_128199536_128199704: std_logic;
signal sum_layer2_128199872_128200096_128200208: std_logic;
signal carry_layer2_128199872_128200096_128200208: std_logic;
signal sum_layer2_128200376_128200488_128200656: std_logic;
signal carry_layer2_128200376_128200488_128200656: std_logic;
signal sum_layer2_128225464_128225632_128225800: std_logic;
signal carry_layer2_128225464_128225632_128225800: std_logic;
signal sum_layer2_127824224_128200320_128200544: std_logic;
signal carry_layer2_127824224_128200320_128200544: std_logic;
signal sum_layer2_128225352_128225520_128225688: std_logic;
signal carry_layer2_128225352_128225520_128225688: std_logic;
signal sum_layer2_128225856_128226024_128226136: std_logic;
signal carry_layer2_128225856_128226024_128226136: std_logic;
signal sum_layer2_128226304_128226528_128226472: std_logic;
signal carry_layer2_128226304_128226528_128226472: std_logic;
signal sum_layer2_128225968_128226192_128226360: std_logic;
signal carry_layer2_128225968_128226192_128226360: std_logic;
signal sum_layer2_128226584_128226696_128226864: std_logic;
signal carry_layer2_128226584_128226696_128226864: std_logic;
signal sum_layer2_128226976_128227144_128227368: std_logic;
signal carry_layer2_128226976_128227144_128227368: std_logic;
signal sum_layer2_128226808_128227032_128227200: std_logic;
signal carry_layer2_128226808_128227032_128227200: std_logic;
signal sum_layer2_128227424_128227536_128227704: std_logic;
signal carry_layer2_128227424_128227536_128227704: std_logic;
signal sum_layer2_128227816_128227984_128228152: std_logic;
signal carry_layer2_128227816_128227984_128228152: std_logic;
signal sum_layer2_127824560_128227648_128227872: std_logic;
signal carry_layer2_127824560_128227648_128227872: std_logic;
signal sum_layer2_128228040_128228208_128228376: std_logic;
signal carry_layer2_128228040_128228208_128228376: std_logic;
signal sum_layer2_128228544_128228656_128228880: std_logic;
signal carry_layer2_128228544_128228656_128228880: std_logic;
signal sum_layer2_128228488_128228712_128228936: std_logic;
signal carry_layer2_128228488_128228712_128228936: std_logic;
signal sum_layer2_128229048_128229216_128229328: std_logic;
signal carry_layer2_128229048_128229216_128229328: std_logic;
signal sum_layer2_128254136_128254304: std_logic;
signal carry_layer2_128254136_128254304: std_logic;
signal sum_layer2_128229160_128254024_128254192: std_logic;
signal carry_layer2_128229160_128254024_128254192: std_logic;
signal sum_layer2_128254360_128254528_128254640: std_logic;
signal carry_layer2_128254360_128254528_128254640: std_logic;
signal sum_layer2_128254808_128254976: std_logic;
signal carry_layer2_128254808_128254976: std_logic;
signal sum_layer2_127824896_128254472_128254696: std_logic;
signal carry_layer2_127824896_128254472_128254696: std_logic;
signal sum_layer2_128254864_128255032_128255200: std_logic;
signal carry_layer2_128254864_128255032_128255200: std_logic;
signal sum_layer2_128255312_128255480: std_logic;
signal carry_layer2_128255312_128255480: std_logic;
signal sum_layer2_128255144_128255368_128255536: std_logic;
signal carry_layer2_128255144_128255368_128255536: std_logic;
signal sum_layer2_128255704_128255816_128255984: std_logic;
signal carry_layer2_128255704_128255816_128255984: std_logic;
signal sum_layer2_128255648_128255872_128256040: std_logic;
signal carry_layer2_128255648_128255872_128256040: std_logic;
signal sum_layer2_128256208_128256320_128256488: std_logic;
signal carry_layer2_128256208_128256320_128256488: std_logic;
signal sum_layer2_127825232_128256152_128256376: std_logic;
signal carry_layer2_127825232_128256152_128256376: std_logic;
signal sum_layer2_128256544_128256712_128256824: std_logic;
signal carry_layer2_128256544_128256712_128256824: std_logic;
signal sum_layer2_128256656_128256880_128257048: std_logic;
signal carry_layer2_128256656_128256880_128257048: std_logic;
signal sum_layer2_128256992_128257216_128257384: std_logic;
signal carry_layer2_128256992_128257216_128257384: std_logic;
signal sum_layer2_127825568_128257328_128257552: std_logic;
signal carry_layer2_127825568_128257328_128257552: std_logic;
signal sum_layer2_128257720_128257888: std_logic;
signal carry_layer2_128257720_128257888: std_logic;
signal sum_layer2_128257832_128258000: std_logic;
signal carry_layer2_128257832_128258000: std_logic;
signal sum_layer2_127825904_128245832: std_logic;
signal carry_layer2_127825904_128245832: std_logic;
signal sum_layer3_128246000_128246168: std_logic;
signal carry_layer3_128246000_128246168: std_logic;
signal sum_layer3_128246112_128246336: std_logic;
signal carry_layer3_128246112_128246336: std_logic;
signal sum_layer3_127827080_128246280_128246560: std_logic;
signal carry_layer3_127827080_128246280_128246560: std_logic;
signal sum_layer3_128246504_128246672_128246784: std_logic;
signal carry_layer3_128246504_128246672_128246784: std_logic;
signal sum_layer3_128246616_128246840_128247008: std_logic;
signal carry_layer3_128246616_128246840_128247008: std_logic;
signal sum_layer3_128246952_128247176_128247344: std_logic;
signal carry_layer3_128246952_128247176_128247344: std_logic;
signal sum_layer3_128222208_128247288_128247512: std_logic;
signal carry_layer3_128222208_128247288_128247512: std_logic;
signal sum_layer3_128247680_128247792: std_logic;
signal carry_layer3_128247680_128247792: std_logic;
signal sum_layer3_128222880_128247624_128247848: std_logic;
signal carry_layer3_128222880_128247624_128247848: std_logic;
signal sum_layer3_128248016_128248128: std_logic;
signal carry_layer3_128248016_128248128: std_logic;
signal sum_layer3_128247960_128248184_128248352: std_logic;
signal carry_layer3_128247960_128248184_128248352: std_logic;
signal sum_layer3_128248464_128248632: std_logic;
signal carry_layer3_128248464_128248632: std_logic;
signal sum_layer3_128248296_128248520_128248688: std_logic;
signal carry_layer3_128248296_128248520_128248688: std_logic;
signal sum_layer3_128248856_128248968_128249136: std_logic;
signal carry_layer3_128248856_128248968_128249136: std_logic;
signal sum_layer3_128248800_128249024_128249192: std_logic;
signal carry_layer3_128248800_128249024_128249192: std_logic;
signal sum_layer3_128249360_128249472_128249640: std_logic;
signal carry_layer3_128249360_128249472_128249640: std_logic;
signal sum_layer3_128197128_128249304_128249528: std_logic;
signal carry_layer3_128197128_128249304_128249528: std_logic;
signal sum_layer3_128249696_128249808_128262328: std_logic;
signal carry_layer3_128249696_128249808_128262328: std_logic;
signal sum_layer3_128262216_128262384_128262552: std_logic;
signal carry_layer3_128262216_128262384_128262552: std_logic;
signal sum_layer3_128262720_128262832_128263000: std_logic;
signal carry_layer3_128262720_128262832_128263000: std_logic;
signal sum_layer3_128262664_128262888_128263056: std_logic;
signal carry_layer3_128262664_128262888_128263056: std_logic;
signal sum_layer3_128263224_128263392_128263504: std_logic;
signal carry_layer3_128263224_128263392_128263504: std_logic;
signal sum_layer3_128263672_128263840: std_logic;
signal carry_layer3_128263672_128263840: std_logic;
signal sum_layer3_128263336_128263560_128263728: std_logic;
signal carry_layer3_128263336_128263560_128263728: std_logic;
signal sum_layer3_128263896_128264064_128264176: std_logic;
signal carry_layer3_128263896_128264064_128264176: std_logic;
signal sum_layer3_128264344_128264512: std_logic;
signal carry_layer3_128264344_128264512: std_logic;
signal sum_layer3_128264008_128264232_128264400: std_logic;
signal carry_layer3_128264008_128264232_128264400: std_logic;
signal sum_layer3_128264568_128264736_128264848: std_logic;
signal carry_layer3_128264568_128264736_128264848: std_logic;
signal sum_layer3_128265016_128265184: std_logic;
signal carry_layer3_128265016_128265184: std_logic;
signal sum_layer3_128264680_128264904_128265072: std_logic;
signal carry_layer3_128264680_128264904_128265072: std_logic;
signal sum_layer3_128265240_128265408_128265520: std_logic;
signal carry_layer3_128265240_128265408_128265520: std_logic;
signal sum_layer3_128265688_128265856: std_logic;
signal carry_layer3_128265688_128265856: std_logic;
signal sum_layer3_128227312_128265352_128265576: std_logic;
signal carry_layer3_128227312_128265352_128265576: std_logic;
signal sum_layer3_128265744_128265912_128266080: std_logic;
signal carry_layer3_128265744_128265912_128266080: std_logic;
signal sum_layer3_128266192_128204984: std_logic;
signal carry_layer3_128266192_128204984: std_logic;
signal sum_layer3_128228320_128266024_128204872: std_logic;
signal carry_layer3_128228320_128266024_128204872: std_logic;
signal sum_layer3_128205040_128205208_128205320: std_logic;
signal carry_layer3_128205040_128205208_128205320: std_logic;
signal sum_layer3_128228824_128205152_128205376: std_logic;
signal carry_layer3_128228824_128205152_128205376: std_logic;
signal sum_layer3_128205544_128205712_128205824: std_logic;
signal carry_layer3_128205544_128205712_128205824: std_logic;
signal sum_layer3_128205656_128205880_128206048: std_logic;
signal carry_layer3_128205656_128205880_128206048: std_logic;
signal sum_layer3_128206216_128206328_128206496: std_logic;
signal carry_layer3_128206216_128206328_128206496: std_logic;
signal sum_layer3_128206160_128206384_128206552: std_logic;
signal carry_layer3_128206160_128206384_128206552: std_logic;
signal sum_layer3_128206720_128206832_128207000: std_logic;
signal carry_layer3_128206720_128206832_128207000: std_logic;
signal sum_layer3_128206664_128206888_128207056: std_logic;
signal carry_layer3_128206664_128206888_128207056: std_logic;
signal sum_layer3_128207224_128207336_128207504: std_logic;
signal carry_layer3_128207224_128207336_128207504: std_logic;
signal sum_layer3_128207168_128207392_128207560: std_logic;
signal carry_layer3_128207168_128207392_128207560: std_logic;
signal sum_layer3_128207728_128207840: std_logic;
signal carry_layer3_128207728_128207840: std_logic;
signal sum_layer3_128207672_128207896_128208064: std_logic;
signal carry_layer3_128207672_128207896_128208064: std_logic;
signal sum_layer3_128208008_128208232_128208400: std_logic;
signal carry_layer3_128208008_128208232_128208400: std_logic;
signal sum_layer3_128257160_128208344_128208568: std_logic;
signal carry_layer3_128257160_128208344_128208568: std_logic;
signal sum_layer3_128257496_128208736_128208848: std_logic;
signal carry_layer3_128257496_128208736_128208848: std_logic;
signal sum_layer3_128257776_128123008_128123176: std_logic;
signal carry_layer3_128257776_128123008_128123176: std_logic;
signal sum_layer3_128123120_128123288: std_logic;
signal carry_layer3_128123120_128123288: std_logic;
signal sum_layer3_128123232_128123456: std_logic;
signal carry_layer3_128123232_128123456: std_logic;
signal sum_layer3_128123400_128123624: std_logic;
signal carry_layer3_128123400_128123624: std_logic;
signal sum_layer4_128123792_128123960: std_logic;
signal carry_layer4_128123792_128123960: std_logic;
signal sum_layer4_128123904_128124128: std_logic;
signal carry_layer4_128123904_128124128: std_logic;
signal sum_layer4_128124072_128124296: std_logic;
signal carry_layer4_128124072_128124296: std_logic;
signal sum_layer4_128247120_128124240_128124520: std_logic;
signal carry_layer4_128247120_128124240_128124520: std_logic;
signal sum_layer4_128247456_128124464_128124688: std_logic;
signal carry_layer4_128247456_128124464_128124688: std_logic;
signal sum_layer4_128124632_128124800_128124912: std_logic;
signal carry_layer4_128124632_128124800_128124912: std_logic;
signal sum_layer4_128124744_128124968_128125136: std_logic;
signal carry_layer4_128124744_128124968_128125136: std_logic;
signal sum_layer4_128125080_128125304_128125472: std_logic;
signal carry_layer4_128125080_128125304_128125472: std_logic;
signal sum_layer4_128125416_128125640_128125808: std_logic;
signal carry_layer4_128125416_128125640_128125808: std_logic;
signal sum_layer4_128125752_128125976_128126144: std_logic;
signal carry_layer4_128125752_128125976_128126144: std_logic;
signal sum_layer4_128262496_128126088_128126312: std_logic;
signal carry_layer4_128262496_128126088_128126312: std_logic;
signal sum_layer4_128126480_128126592: std_logic;
signal carry_layer4_128126480_128126592: std_logic;
signal sum_layer4_128263168_128126424_128126648: std_logic;
signal carry_layer4_128263168_128126424_128126648: std_logic;
signal sum_layer4_128126816_128126928: std_logic;
signal carry_layer4_128126816_128126928: std_logic;
signal sum_layer4_128126760_128237640_128237808: std_logic;
signal carry_layer4_128126760_128237640_128237808: std_logic;
signal sum_layer4_128237920_128238088: std_logic;
signal carry_layer4_128237920_128238088: std_logic;
signal sum_layer4_128237752_128237976_128238144: std_logic;
signal carry_layer4_128237752_128237976_128238144: std_logic;
signal sum_layer4_128238312_128238424_128238592: std_logic;
signal carry_layer4_128238312_128238424_128238592: std_logic;
signal sum_layer4_128238256_128238480_128238648: std_logic;
signal carry_layer4_128238256_128238480_128238648: std_logic;
signal sum_layer4_128238816_128238928_128239096: std_logic;
signal carry_layer4_128238816_128238928_128239096: std_logic;
signal sum_layer4_128238760_128238984_128239152: std_logic;
signal carry_layer4_128238760_128238984_128239152: std_logic;
signal sum_layer4_128239320_128239432_128239600: std_logic;
signal carry_layer4_128239320_128239432_128239600: std_logic;
signal sum_layer4_128239264_128239488_128239656: std_logic;
signal carry_layer4_128239264_128239488_128239656: std_logic;
signal sum_layer4_128239824_128239936_128240104: std_logic;
signal carry_layer4_128239824_128239936_128240104: std_logic;
signal sum_layer4_128205488_128239768_128239992: std_logic;
signal carry_layer4_128205488_128239768_128239992: std_logic;
signal sum_layer4_128240160_128240328_128240440: std_logic;
signal carry_layer4_128240160_128240328_128240440: std_logic;
signal sum_layer4_128205992_128240272_128240496: std_logic;
signal carry_layer4_128205992_128240272_128240496: std_logic;
signal sum_layer4_128240664_128240776: std_logic;
signal carry_layer4_128240664_128240776: std_logic;
signal sum_layer4_128240608_128240832_128241000: std_logic;
signal carry_layer4_128240608_128240832_128241000: std_logic;
signal sum_layer4_128240944_128241168_128241336: std_logic;
signal carry_layer4_128240944_128241168_128241336: std_logic;
signal sum_layer4_128241280_128241504_128241616: std_logic;
signal carry_layer4_128241280_128241504_128241616: std_logic;
signal sum_layer4_128217160_128217328_128217496: std_logic;
signal carry_layer4_128217160_128217328_128217496: std_logic;
signal sum_layer4_128208176_128217440_128217664: std_logic;
signal carry_layer4_128208176_128217440_128217664: std_logic;
signal sum_layer4_128208512_128217832_128218056: std_logic;
signal carry_layer4_128208512_128217832_128218056: std_logic;
signal sum_layer4_128208792_128218000_128218224: std_logic;
signal carry_layer4_128208792_128218000_128218224: std_logic;
signal sum_layer4_128218168_128218336: std_logic;
signal carry_layer4_128218168_128218336: std_logic;
signal sum_layer4_128218280_128218504: std_logic;
signal carry_layer4_128218280_128218504: std_logic;
signal sum_layer4_128218448_128218672: std_logic;
signal carry_layer4_128218448_128218672: std_logic;
signal sum_layer4_128218616_128218840: std_logic;
signal carry_layer4_128218616_128218840: std_logic;
signal sum_layer4_128218784_128219008: std_logic;
signal carry_layer4_128218784_128219008: std_logic;
signal sum_layer4_128123568_128218952: std_logic;
signal carry_layer4_128123568_128218952: std_logic;
signal sum_layer5_128219120_128219344: std_logic;
signal carry_layer5_128219120_128219344: std_logic;
signal sum_layer5_128219288_128219512: std_logic;
signal carry_layer5_128219288_128219512: std_logic;
signal sum_layer5_128219456_128219680: std_logic;
signal carry_layer5_128219456_128219680: std_logic;
signal sum_layer5_128219624_128219848: std_logic;
signal carry_layer5_128219624_128219848: std_logic;
signal sum_layer5_128219792_128220016: std_logic;
signal carry_layer5_128219792_128220016: std_logic;
signal sum_layer5_128125248_128219960_128220240: std_logic;
signal carry_layer5_128125248_128219960_128220240: std_logic;
signal sum_layer5_128125584_128220184_128220408: std_logic;
signal carry_layer5_128125584_128220184_128220408: std_logic;
signal sum_layer5_128125920_128220352_128220576: std_logic;
signal carry_layer5_128125920_128220352_128220576: std_logic;
signal sum_layer5_128126256_128220520_128220744: std_logic;
signal carry_layer5_128126256_128220520_128220744: std_logic;
signal sum_layer5_128220688_128220856_128220968: std_logic;
signal carry_layer5_128220688_128220856_128220968: std_logic;
signal sum_layer5_128220800_128221024_128221136: std_logic;
signal carry_layer5_128220800_128221024_128221136: std_logic;
signal sum_layer5_128315464_128315632_128315800: std_logic;
signal carry_layer5_128315464_128315632_128315800: std_logic;
signal sum_layer5_128315744_128315968_128316136: std_logic;
signal carry_layer5_128315744_128315968_128316136: std_logic;
signal sum_layer5_128316080_128316304_128316472: std_logic;
signal carry_layer5_128316080_128316304_128316472: std_logic;
signal sum_layer5_128316416_128316640_128316808: std_logic;
signal carry_layer5_128316416_128316640_128316808: std_logic;
signal sum_layer5_128316752_128316976_128317144: std_logic;
signal carry_layer5_128316752_128316976_128317144: std_logic;
signal sum_layer5_128317088_128317312_128317480: std_logic;
signal carry_layer5_128317088_128317312_128317480: std_logic;
signal sum_layer5_128317424_128317648_128317816: std_logic;
signal carry_layer5_128317424_128317648_128317816: std_logic;
signal sum_layer5_128241112_128317760_128317984: std_logic;
signal carry_layer5_128241112_128317760_128317984: std_logic;
signal sum_layer5_128241448_128318152_128318376: std_logic;
signal carry_layer5_128241448_128318152_128318376: std_logic;
signal sum_layer5_128217272_128318320_128318544: std_logic;
signal carry_layer5_128217272_128318320_128318544: std_logic;
signal sum_layer5_128217608_128318488_128318712: std_logic;
signal carry_layer5_128217608_128318488_128318712: std_logic;
signal sum_layer5_128217888_128318656_128318880: std_logic;
signal carry_layer5_128217888_128318656_128318880: std_logic;
signal sum_layer5_128318824_128318992: std_logic;
signal carry_layer5_128318824_128318992: std_logic;
signal sum_layer5_128318936_128319160: std_logic;
signal carry_layer5_128318936_128319160: std_logic;
signal sum_layer5_128319104_128319328: std_logic;
signal carry_layer5_128319104_128319328: std_logic;
signal sum_layer5_128319272_128319440: std_logic;
signal carry_layer5_128319272_128319440: std_logic;
signal sum_layer5_128331848_128332016: std_logic;
signal carry_layer5_128331848_128332016: std_logic;
signal sum_layer5_128331960_128332184: std_logic;
signal carry_layer5_128331960_128332184: std_logic;
signal sum_layer5_128332128_128332352: std_logic;
signal carry_layer5_128332128_128332352: std_logic;
signal sum_layer5_128332296_128332520: std_logic;
signal carry_layer5_128332296_128332520: std_logic;
signal sum_layer6_128332632_128332856: std_logic;
signal carry_layer6_128332632_128332856: std_logic;
signal sum_layer6_128332800_128333024: std_logic;
signal carry_layer6_128332800_128333024: std_logic;
signal sum_layer6_128332968_128333192: std_logic;
signal carry_layer6_128332968_128333192: std_logic;
signal sum_layer6_128333136_128333360: std_logic;
signal carry_layer6_128333136_128333360: std_logic;
signal sum_layer6_128333304_128333528: std_logic;
signal carry_layer6_128333304_128333528: std_logic;
signal sum_layer6_128333472_128333696: std_logic;
signal carry_layer6_128333472_128333696: std_logic;
signal sum_layer6_128333640_128333864: std_logic;
signal carry_layer6_128333640_128333864: std_logic;
signal sum_layer6_128333808_128334032: std_logic;
signal carry_layer6_128333808_128334032: std_logic;
signal sum_layer6_128333976_128334200: std_logic;
signal carry_layer6_128333976_128334200: std_logic;
signal sum_layer6_128315576_128334144_128334424: std_logic;
signal carry_layer6_128315576_128334144_128334424: std_logic;
signal sum_layer6_128315912_128334368_128334592: std_logic;
signal carry_layer6_128315912_128334368_128334592: std_logic;
signal sum_layer6_128316248_128334536_128334760: std_logic;
signal carry_layer6_128316248_128334536_128334760: std_logic;
signal sum_layer6_128316584_128334704_128334928: std_logic;
signal carry_layer6_128316584_128334704_128334928: std_logic;
signal sum_layer6_128316920_128334872_128335096: std_logic;
signal carry_layer6_128316920_128334872_128335096: std_logic;
signal sum_layer6_128317256_128335040_128335264: std_logic;
signal carry_layer6_128317256_128335040_128335264: std_logic;
signal sum_layer6_128317592_128335208_128335432: std_logic;
signal carry_layer6_128317592_128335208_128335432: std_logic;
signal sum_layer6_128317928_128335376_128335600: std_logic;
signal carry_layer6_128317928_128335376_128335600: std_logic;
signal sum_layer6_128318208_128335544_128335768: std_logic;
signal carry_layer6_128318208_128335544_128335768: std_logic;
signal sum_layer6_128335712_128335824: std_logic;
signal carry_layer6_128335712_128335824: std_logic;
signal sum_layer6_128344136_128344304: std_logic;
signal carry_layer6_128344136_128344304: std_logic;
signal sum_layer6_128344248_128344472: std_logic;
signal carry_layer6_128344248_128344472: std_logic;
signal sum_layer6_128344416_128344640: std_logic;
signal carry_layer6_128344416_128344640: std_logic;
signal sum_layer6_128344584_128344808: std_logic;
signal carry_layer6_128344584_128344808: std_logic;
signal sum_layer6_128344752_128344976: std_logic;
signal carry_layer6_128344752_128344976: std_logic;
signal sum_layer6_128344920_128345144: std_logic;
signal carry_layer6_128344920_128345144: std_logic;
signal sum_layer6_128345088_128345312: std_logic;
signal carry_layer6_128345088_128345312: std_logic;
signal sum_layer6_128345256_128345480: std_logic;
signal carry_layer6_128345256_128345480: std_logic;
signal sum_layer6_128345424_128345648: std_logic;
signal carry_layer6_128345424_128345648: std_logic;
signal sum_layer6_128345592_128345816: std_logic;
signal carry_layer6_128345592_128345816: std_logic;
signal sum_layer6_128345760_128345984: std_logic;
signal carry_layer6_128345760_128345984: std_logic;
signal sum_layer6_128332464_128345928: std_logic;
signal carry_layer6_128332464_128345928: std_logic;
signal first_vector: std_logic_vector(323 downto 0);
signal second_vector: std_logic_vector(323 downto 0);
signal output_vector: std_logic_vector(323 downto 0);

begin
HA_127826016_127826128: HA 
PORT MAP (
    bit_a => a0_and_b1,
    bit_b => a1_and_b0,
    sum_sig => sum_layer1_127830168_127844480,
    carry_sig => carry_layer1_127830168_127844480
);

FA_127826296_127826240: FA 
PORT MAP (
    bit_a => a0_and_b2,
    bit_b => a1_and_b1,
    bit_c => a2_and_b0,
    sum_sig => sum_layer1_127830336_127844592_127846496,
    carry_sig => carry_layer1_127830336_127844592_127846496
);

FA_127826520_127826464: FA 
PORT MAP (
    bit_a => a0_and_b3,
    bit_b => a1_and_b2,
    bit_c => a2_and_b1,
    sum_sig => sum_layer1_127830448_127844704_127846608,
    carry_sig => carry_layer1_127830448_127844704_127846608
);

FA_127826632_127826576: FA 
PORT MAP (
    bit_a => a0_and_b4,
    bit_b => a1_and_b3,
    bit_c => a2_and_b2,
    sum_sig => sum_layer1_127830560_127844816_127846720,
    carry_sig => carry_layer1_127830560_127844816_127846720
);

HA_127826744_127826800: HA 
PORT MAP (
    bit_a => a3_and_b1,
    bit_b => a4_and_b0,
    sum_sig => sum_layer1_127672560_127674464,
    carry_sig => carry_layer1_127672560_127674464
);

FA_127826968_127826912: FA 
PORT MAP (
    bit_a => a0_and_b5,
    bit_b => a1_and_b4,
    bit_c => a2_and_b3,
    sum_sig => sum_layer1_127830672_127844928_127846832,
    carry_sig => carry_layer1_127830672_127844928_127846832
);

FA_127827080_127827136: FA 
PORT MAP (
    bit_a => a3_and_b2,
    bit_b => a4_and_b1,
    bit_c => a5_and_b0,
    sum_sig => sum_layer1_127672672_127674576_127729792,
    carry_sig => carry_layer1_127672672_127674576_127729792
);

FA_127827304_127827248: FA 
PORT MAP (
    bit_a => a0_and_b6,
    bit_b => a1_and_b5,
    bit_c => a2_and_b4,
    sum_sig => sum_layer1_127830784_127845040_127846944,
    carry_sig => carry_layer1_127830784_127845040_127846944
);

FA_127827416_127827472: FA 
PORT MAP (
    bit_a => a3_and_b3,
    bit_b => a4_and_b2,
    bit_c => a5_and_b1,
    sum_sig => sum_layer1_127672784_127674688_127729904,
    carry_sig => carry_layer1_127672784_127674688_127729904
);

FA_127827640_127827584: FA 
PORT MAP (
    bit_a => a0_and_b7,
    bit_b => a1_and_b6,
    bit_c => a2_and_b5,
    sum_sig => sum_layer1_127830896_127845152_127847056,
    carry_sig => carry_layer1_127830896_127845152_127847056
);

FA_127827752_127827808: FA 
PORT MAP (
    bit_a => a3_and_b4,
    bit_b => a4_and_b3,
    bit_c => a5_and_b2,
    sum_sig => sum_layer1_127672896_127674800_127730016,
    carry_sig => carry_layer1_127672896_127674800_127730016
);

HA_127827920_128221256: HA 
PORT MAP (
    bit_a => a6_and_b1,
    bit_b => a7_and_b0,
    sum_sig => sum_layer1_127731920_127721600,
    carry_sig => carry_layer1_127731920_127721600
);

FA_128221424_128221368: FA 
PORT MAP (
    bit_a => a0_and_b8,
    bit_b => a1_and_b7,
    bit_c => a2_and_b6,
    sum_sig => sum_layer1_127831008_127845264_127847168,
    carry_sig => carry_layer1_127831008_127845264_127847168
);

FA_128221536_128221592: FA 
PORT MAP (
    bit_a => a3_and_b5,
    bit_b => a4_and_b4,
    bit_c => a5_and_b3,
    sum_sig => sum_layer1_127673008_127674912_127730128,
    carry_sig => carry_layer1_127673008_127674912_127730128
);

FA_128221704_128221760: FA 
PORT MAP (
    bit_a => a6_and_b2,
    bit_b => a7_and_b1,
    bit_c => a8_and_b0,
    sum_sig => sum_layer1_127732032_127721712_127723616,
    carry_sig => carry_layer1_127732032_127721712_127723616
);

FA_128221928_128221872: FA 
PORT MAP (
    bit_a => a0_and_b9,
    bit_b => a1_and_b8,
    bit_c => a2_and_b7,
    sum_sig => sum_layer1_127831120_127845376_127847280,
    carry_sig => carry_layer1_127831120_127845376_127847280
);

FA_128222040_128222096: FA 
PORT MAP (
    bit_a => a3_and_b6,
    bit_b => a4_and_b5,
    bit_c => a5_and_b4,
    sum_sig => sum_layer1_127673120_127675024_127730240,
    carry_sig => carry_layer1_127673120_127675024_127730240
);

FA_128222208_128222264: FA 
PORT MAP (
    bit_a => a6_and_b3,
    bit_b => a7_and_b2,
    bit_c => a8_and_b1,
    sum_sig => sum_layer1_127732144_127721824_127723728,
    carry_sig => carry_layer1_127732144_127721824_127723728
);

FA_128222432_128222376: FA 
PORT MAP (
    bit_a => a0_and_b10,
    bit_b => a1_and_b9,
    bit_c => a2_and_b8,
    sum_sig => sum_layer1_127831232_127845488_127847392,
    carry_sig => carry_layer1_127831232_127845488_127847392
);

FA_128222544_128222600: FA 
PORT MAP (
    bit_a => a3_and_b7,
    bit_b => a4_and_b6,
    bit_c => a5_and_b5,
    sum_sig => sum_layer1_127673232_127675136_127730352,
    carry_sig => carry_layer1_127673232_127675136_127730352
);

FA_128222712_128222768: FA 
PORT MAP (
    bit_a => a6_and_b4,
    bit_b => a7_and_b3,
    bit_c => a8_and_b2,
    sum_sig => sum_layer1_127732256_127721936_127723840,
    carry_sig => carry_layer1_127732256_127721936_127723840
);

HA_128222880_128222936: HA 
PORT MAP (
    bit_a => a9_and_b1,
    bit_b => a10_and_b0,
    sum_sig => sum_layer1_127635696_127637600,
    carry_sig => carry_layer1_127635696_127637600
);

FA_128223104_128223048: FA 
PORT MAP (
    bit_a => a0_and_b11,
    bit_b => a1_and_b10,
    bit_c => a2_and_b9,
    sum_sig => sum_layer1_127831344_127845600_127847504,
    carry_sig => carry_layer1_127831344_127845600_127847504
);

FA_128223216_128223272: FA 
PORT MAP (
    bit_a => a3_and_b8,
    bit_b => a4_and_b7,
    bit_c => a5_and_b6,
    sum_sig => sum_layer1_127673344_127675248_127730464,
    carry_sig => carry_layer1_127673344_127675248_127730464
);

FA_128223384_128223440: FA 
PORT MAP (
    bit_a => a6_and_b5,
    bit_b => a7_and_b4,
    bit_c => a8_and_b3,
    sum_sig => sum_layer1_127732368_127722048_127723952,
    carry_sig => carry_layer1_127732368_127722048_127723952
);

FA_128223552_128223608: FA 
PORT MAP (
    bit_a => a9_and_b2,
    bit_b => a10_and_b1,
    bit_c => a11_and_b0,
    sum_sig => sum_layer1_127635808_127637712_127713408,
    carry_sig => carry_layer1_127635808_127637712_127713408
);

FA_128223776_128223720: FA 
PORT MAP (
    bit_a => a0_and_b12,
    bit_b => a1_and_b11,
    bit_c => a2_and_b10,
    sum_sig => sum_layer1_127831456_127845712_127847616,
    carry_sig => carry_layer1_127831456_127845712_127847616
);

FA_128223888_128223944: FA 
PORT MAP (
    bit_a => a3_and_b9,
    bit_b => a4_and_b8,
    bit_c => a5_and_b7,
    sum_sig => sum_layer1_127673456_127675360_127730576,
    carry_sig => carry_layer1_127673456_127675360_127730576
);

FA_128224112_128224168: FA 
PORT MAP (
    bit_a => a6_and_b6,
    bit_b => a7_and_b5,
    bit_c => a8_and_b4,
    sum_sig => sum_layer1_127732480_127722160_127724064,
    carry_sig => carry_layer1_127732480_127722160_127724064
);

FA_128224056_128224280: FA 
PORT MAP (
    bit_a => a9_and_b3,
    bit_b => a10_and_b2,
    bit_c => a11_and_b1,
    sum_sig => sum_layer1_127635920_127637824_127713520,
    carry_sig => carry_layer1_127635920_127637824_127713520
);

FA_128224448_128224392: FA 
PORT MAP (
    bit_a => a0_and_b13,
    bit_b => a1_and_b12,
    bit_c => a2_and_b11,
    sum_sig => sum_layer1_127831568_127845824_127847728,
    carry_sig => carry_layer1_127831568_127845824_127847728
);

FA_128224560_128224616: FA 
PORT MAP (
    bit_a => a3_and_b10,
    bit_b => a4_and_b9,
    bit_c => a5_and_b8,
    sum_sig => sum_layer1_127673568_127675472_127730688,
    carry_sig => carry_layer1_127673568_127675472_127730688
);

FA_128224728_128224784: FA 
PORT MAP (
    bit_a => a6_and_b7,
    bit_b => a7_and_b6,
    bit_c => a8_and_b5,
    sum_sig => sum_layer1_127732592_127722272_127724176,
    carry_sig => carry_layer1_127732592_127722272_127724176
);

FA_128224896_128224952: FA 
PORT MAP (
    bit_a => a9_and_b4,
    bit_b => a10_and_b3,
    bit_c => a11_and_b2,
    sum_sig => sum_layer1_127636032_127637936_127713632,
    carry_sig => carry_layer1_127636032_127637936_127713632
);

HA_128225064_128225120: HA 
PORT MAP (
    bit_a => a12_and_b1,
    bit_b => a13_and_b0,
    sum_sig => sum_layer1_127715536_127848576,
    carry_sig => carry_layer1_127715536_127848576
);

FA_128225232_128196680: FA 
PORT MAP (
    bit_a => a0_and_b14,
    bit_b => a1_and_b13,
    bit_c => a2_and_b12,
    sum_sig => sum_layer1_127831680_127845936_127847840,
    carry_sig => carry_layer1_127831680_127845936_127847840
);

FA_128196792_128196848: FA 
PORT MAP (
    bit_a => a3_and_b11,
    bit_b => a4_and_b10,
    bit_c => a5_and_b9,
    sum_sig => sum_layer1_127673680_127675584_127730800,
    carry_sig => carry_layer1_127673680_127675584_127730800
);

FA_128196960_128197016: FA 
PORT MAP (
    bit_a => a6_and_b8,
    bit_b => a7_and_b7,
    bit_c => a8_and_b6,
    sum_sig => sum_layer1_127732704_127722384_127724288,
    carry_sig => carry_layer1_127732704_127722384_127724288
);

FA_128197184_128197240: FA 
PORT MAP (
    bit_a => a9_and_b5,
    bit_b => a10_and_b4,
    bit_c => a11_and_b3,
    sum_sig => sum_layer1_127636144_127638048_127713744,
    carry_sig => carry_layer1_127636144_127638048_127713744
);

FA_128197128_128197352: FA 
PORT MAP (
    bit_a => a12_and_b2,
    bit_b => a13_and_b1,
    bit_c => a14_and_b0,
    sum_sig => sum_layer1_127715648_127848688_127850592,
    carry_sig => carry_layer1_127715648_127848688_127850592
);

FA_128197520_128197464: FA 
PORT MAP (
    bit_a => a0_and_b15,
    bit_b => a1_and_b14,
    bit_c => a2_and_b13,
    sum_sig => sum_layer1_127831792_127846048_127847952,
    carry_sig => carry_layer1_127831792_127846048_127847952
);

FA_128197632_128197688: FA 
PORT MAP (
    bit_a => a3_and_b12,
    bit_b => a4_and_b11,
    bit_c => a5_and_b10,
    sum_sig => sum_layer1_127673792_127675696_127730912,
    carry_sig => carry_layer1_127673792_127675696_127730912
);

FA_128197800_128197856: FA 
PORT MAP (
    bit_a => a6_and_b9,
    bit_b => a7_and_b8,
    bit_c => a8_and_b7,
    sum_sig => sum_layer1_127732816_127722496_127724400,
    carry_sig => carry_layer1_127732816_127722496_127724400
);

FA_128198024_128198080: FA 
PORT MAP (
    bit_a => a9_and_b6,
    bit_b => a10_and_b5,
    bit_c => a11_and_b4,
    sum_sig => sum_layer1_127636256_127638160_127713856,
    carry_sig => carry_layer1_127636256_127638160_127713856
);

FA_128197968_128198192: FA 
PORT MAP (
    bit_a => a12_and_b3,
    bit_b => a13_and_b2,
    bit_c => a14_and_b1,
    sum_sig => sum_layer1_127715760_127848800_127850704,
    carry_sig => carry_layer1_127715760_127848800_127850704
);

FA_128198360_128198304: FA 
PORT MAP (
    bit_a => a0_and_b16,
    bit_b => a1_and_b15,
    bit_c => a2_and_b14,
    sum_sig => sum_layer1_127831904_127846160_127848064,
    carry_sig => carry_layer1_127831904_127846160_127848064
);

FA_128198472_128198528: FA 
PORT MAP (
    bit_a => a3_and_b13,
    bit_b => a4_and_b12,
    bit_c => a5_and_b11,
    sum_sig => sum_layer1_127673904_127675808_127731024,
    carry_sig => carry_layer1_127673904_127675808_127731024
);

FA_128198640_128198696: FA 
PORT MAP (
    bit_a => a6_and_b10,
    bit_b => a7_and_b9,
    bit_c => a8_and_b8,
    sum_sig => sum_layer1_127732928_127722608_127724512,
    carry_sig => carry_layer1_127732928_127722608_127724512
);

FA_128198808_128198864: FA 
PORT MAP (
    bit_a => a9_and_b7,
    bit_b => a10_and_b6,
    bit_c => a11_and_b5,
    sum_sig => sum_layer1_127636368_127638272_127713968,
    carry_sig => carry_layer1_127636368_127638272_127713968
);

FA_128198976_128199032: FA 
PORT MAP (
    bit_a => a12_and_b4,
    bit_b => a13_and_b3,
    bit_c => a14_and_b2,
    sum_sig => sum_layer1_127715872_127848912_127850816,
    carry_sig => carry_layer1_127715872_127848912_127850816
);

HA_128199144_128199200: HA 
PORT MAP (
    bit_a => a15_and_b1,
    bit_b => a16_and_b0,
    sum_sig => sum_layer1_127627504_127629408,
    carry_sig => carry_layer1_127627504_127629408
);

FA_128199368_128199312: FA 
PORT MAP (
    bit_a => a0_and_b17,
    bit_b => a1_and_b16,
    bit_c => a2_and_b15,
    sum_sig => sum_layer1_127832016_127846272_127848176,
    carry_sig => carry_layer1_127832016_127846272_127848176
);

FA_128199480_128199536: FA 
PORT MAP (
    bit_a => a3_and_b14,
    bit_b => a4_and_b13,
    bit_c => a5_and_b12,
    sum_sig => sum_layer1_127674016_127675920_127731136,
    carry_sig => carry_layer1_127674016_127675920_127731136
);

FA_128199648_128199704: FA 
PORT MAP (
    bit_a => a6_and_b11,
    bit_b => a7_and_b10,
    bit_c => a8_and_b9,
    sum_sig => sum_layer1_127733040_127722720_127724624,
    carry_sig => carry_layer1_127733040_127722720_127724624
);

FA_128199816_128199872: FA 
PORT MAP (
    bit_a => a9_and_b8,
    bit_b => a10_and_b7,
    bit_c => a11_and_b6,
    sum_sig => sum_layer1_127636480_127638384_127714080,
    carry_sig => carry_layer1_127636480_127638384_127714080
);

FA_128200040_128200096: FA 
PORT MAP (
    bit_a => a12_and_b5,
    bit_b => a13_and_b4,
    bit_c => a14_and_b3,
    sum_sig => sum_layer1_127715984_127849024_127850928,
    carry_sig => carry_layer1_127715984_127849024_127850928
);

FA_128199984_128200208: FA 
PORT MAP (
    bit_a => a15_and_b2,
    bit_b => a16_and_b1,
    bit_c => a17_and_b0,
    sum_sig => sum_layer1_127627616_127629520_127824000,
    carry_sig => carry_layer1_127627616_127629520_127824000
);

FA_128200376_128200320: FA 
PORT MAP (
    bit_a => a1_and_b17,
    bit_b => a2_and_b16,
    bit_c => a3_and_b15,
    sum_sig => sum_layer1_127846384_127848288_127674128,
    carry_sig => carry_layer1_127846384_127848288_127674128
);

FA_128200488_128200544: FA 
PORT MAP (
    bit_a => a4_and_b14,
    bit_b => a5_and_b13,
    bit_c => a6_and_b12,
    sum_sig => sum_layer1_127676032_127731248_127733152,
    carry_sig => carry_layer1_127676032_127731248_127733152
);

FA_128200656_128225352: FA 
PORT MAP (
    bit_a => a7_and_b11,
    bit_b => a8_and_b10,
    bit_c => a9_and_b9,
    sum_sig => sum_layer1_127722832_127724736_127636592,
    carry_sig => carry_layer1_127722832_127724736_127636592
);

FA_128225464_128225520: FA 
PORT MAP (
    bit_a => a10_and_b8,
    bit_b => a11_and_b7,
    bit_c => a12_and_b6,
    sum_sig => sum_layer1_127638496_127714192_127716096,
    carry_sig => carry_layer1_127638496_127714192_127716096
);

FA_128225632_128225688: FA 
PORT MAP (
    bit_a => a13_and_b5,
    bit_b => a14_and_b4,
    bit_c => a15_and_b3,
    sum_sig => sum_layer1_127849136_127851040_127627728,
    carry_sig => carry_layer1_127849136_127851040_127627728
);

HA_128225800_128225856: HA 
PORT MAP (
    bit_a => a16_and_b2,
    bit_b => a17_and_b1,
    sum_sig => sum_layer1_127629632_127824112,
    carry_sig => carry_layer1_127629632_127824112
);

FA_128226024_128225968: FA 
PORT MAP (
    bit_a => a2_and_b17,
    bit_b => a3_and_b16,
    bit_c => a4_and_b15,
    sum_sig => sum_layer1_127848400_127674240_127676144,
    carry_sig => carry_layer1_127848400_127674240_127676144
);

FA_128226136_128226192: FA 
PORT MAP (
    bit_a => a5_and_b14,
    bit_b => a6_and_b13,
    bit_c => a7_and_b12,
    sum_sig => sum_layer1_127731360_127733264_127722944,
    carry_sig => carry_layer1_127731360_127733264_127722944
);

FA_128226304_128226360: FA 
PORT MAP (
    bit_a => a8_and_b11,
    bit_b => a9_and_b10,
    bit_c => a10_and_b9,
    sum_sig => sum_layer1_127724848_127636704_127638608,
    carry_sig => carry_layer1_127724848_127636704_127638608
);

FA_128226528_128226584: FA 
PORT MAP (
    bit_a => a11_and_b8,
    bit_b => a12_and_b7,
    bit_c => a13_and_b6,
    sum_sig => sum_layer1_127714304_127716208_127849248,
    carry_sig => carry_layer1_127714304_127716208_127849248
);

FA_128226472_128226696: FA 
PORT MAP (
    bit_a => a14_and_b5,
    bit_b => a15_and_b4,
    bit_c => a16_and_b3,
    sum_sig => sum_layer1_127851152_127627840_127629744,
    carry_sig => carry_layer1_127851152_127627840_127629744
);

FA_128226864_128226808: FA 
PORT MAP (
    bit_a => a3_and_b17,
    bit_b => a4_and_b16,
    bit_c => a5_and_b15,
    sum_sig => sum_layer1_127674352_127676256_127731472,
    carry_sig => carry_layer1_127674352_127676256_127731472
);

FA_128226976_128227032: FA 
PORT MAP (
    bit_a => a6_and_b14,
    bit_b => a7_and_b13,
    bit_c => a8_and_b12,
    sum_sig => sum_layer1_127733376_127723056_127724960,
    carry_sig => carry_layer1_127733376_127723056_127724960
);

FA_128227144_128227200: FA 
PORT MAP (
    bit_a => a9_and_b11,
    bit_b => a10_and_b10,
    bit_c => a11_and_b9,
    sum_sig => sum_layer1_127636816_127638720_127714416,
    carry_sig => carry_layer1_127636816_127638720_127714416
);

FA_128227368_128227424: FA 
PORT MAP (
    bit_a => a12_and_b8,
    bit_b => a13_and_b7,
    bit_c => a14_and_b6,
    sum_sig => sum_layer1_127716320_127849360_127851264,
    carry_sig => carry_layer1_127716320_127849360_127851264
);

FA_128227312_128227536: FA 
PORT MAP (
    bit_a => a15_and_b5,
    bit_b => a16_and_b4,
    bit_c => a17_and_b3,
    sum_sig => sum_layer1_127627952_127629856_127824336,
    carry_sig => carry_layer1_127627952_127629856_127824336
);

FA_128227704_128227648: FA 
PORT MAP (
    bit_a => a4_and_b17,
    bit_b => a5_and_b16,
    bit_c => a6_and_b15,
    sum_sig => sum_layer1_127676368_127731584_127733488,
    carry_sig => carry_layer1_127676368_127731584_127733488
);

FA_128227816_128227872: FA 
PORT MAP (
    bit_a => a7_and_b14,
    bit_b => a8_and_b13,
    bit_c => a9_and_b12,
    sum_sig => sum_layer1_127723168_127725072_127636928,
    carry_sig => carry_layer1_127723168_127725072_127636928
);

FA_128227984_128228040: FA 
PORT MAP (
    bit_a => a10_and_b11,
    bit_b => a11_and_b10,
    bit_c => a12_and_b9,
    sum_sig => sum_layer1_127638832_127714528_127716432,
    carry_sig => carry_layer1_127638832_127714528_127716432
);

FA_128228152_128228208: FA 
PORT MAP (
    bit_a => a13_and_b8,
    bit_b => a14_and_b7,
    bit_c => a15_and_b6,
    sum_sig => sum_layer1_127849472_127851376_127628064,
    carry_sig => carry_layer1_127849472_127851376_127628064
);

HA_128228320_128228376: HA 
PORT MAP (
    bit_a => a16_and_b5,
    bit_b => a17_and_b4,
    sum_sig => sum_layer1_127629968_127824448,
    carry_sig => carry_layer1_127629968_127824448
);

FA_128228544_128228488: FA 
PORT MAP (
    bit_a => a5_and_b17,
    bit_b => a6_and_b16,
    bit_c => a7_and_b15,
    sum_sig => sum_layer1_127731696_127733600_127723280,
    carry_sig => carry_layer1_127731696_127733600_127723280
);

FA_128228656_128228712: FA 
PORT MAP (
    bit_a => a8_and_b14,
    bit_b => a9_and_b13,
    bit_c => a10_and_b12,
    sum_sig => sum_layer1_127725184_127637040_127638944,
    carry_sig => carry_layer1_127725184_127637040_127638944
);

FA_128228880_128228936: FA 
PORT MAP (
    bit_a => a11_and_b11,
    bit_b => a12_and_b10,
    bit_c => a13_and_b9,
    sum_sig => sum_layer1_127714640_127716544_127849584,
    carry_sig => carry_layer1_127714640_127716544_127849584
);

FA_128228824_128229048: FA 
PORT MAP (
    bit_a => a14_and_b8,
    bit_b => a15_and_b7,
    bit_c => a16_and_b6,
    sum_sig => sum_layer1_127851488_127628176_127630080,
    carry_sig => carry_layer1_127851488_127628176_127630080
);

FA_128229216_128229160: FA 
PORT MAP (
    bit_a => a6_and_b17,
    bit_b => a7_and_b16,
    bit_c => a8_and_b15,
    sum_sig => sum_layer1_127733712_127723392_127725296,
    carry_sig => carry_layer1_127733712_127723392_127725296
);

FA_128229328_128254024: FA 
PORT MAP (
    bit_a => a9_and_b14,
    bit_b => a10_and_b13,
    bit_c => a11_and_b12,
    sum_sig => sum_layer1_127637152_127639056_127714752,
    carry_sig => carry_layer1_127637152_127639056_127714752
);

FA_128254136_128254192: FA 
PORT MAP (
    bit_a => a12_and_b11,
    bit_b => a13_and_b10,
    bit_c => a14_and_b9,
    sum_sig => sum_layer1_127716656_127849696_127851600,
    carry_sig => carry_layer1_127716656_127849696_127851600
);

FA_128254304_128254360: FA 
PORT MAP (
    bit_a => a15_and_b8,
    bit_b => a16_and_b7,
    bit_c => a17_and_b6,
    sum_sig => sum_layer1_127628288_127630192_127824672,
    carry_sig => carry_layer1_127628288_127630192_127824672
);

FA_128254528_128254472: FA 
PORT MAP (
    bit_a => a7_and_b17,
    bit_b => a8_and_b16,
    bit_c => a9_and_b15,
    sum_sig => sum_layer1_127723504_127725408_127637264,
    carry_sig => carry_layer1_127723504_127725408_127637264
);

FA_128254640_128254696: FA 
PORT MAP (
    bit_a => a10_and_b14,
    bit_b => a11_and_b13,
    bit_c => a12_and_b12,
    sum_sig => sum_layer1_127639168_127714864_127716768,
    carry_sig => carry_layer1_127639168_127714864_127716768
);

FA_128254808_128254864: FA 
PORT MAP (
    bit_a => a13_and_b11,
    bit_b => a14_and_b10,
    bit_c => a15_and_b9,
    sum_sig => sum_layer1_127849808_127851712_127628400,
    carry_sig => carry_layer1_127849808_127851712_127628400
);

HA_128254976_128255032: HA 
PORT MAP (
    bit_a => a16_and_b8,
    bit_b => a17_and_b7,
    sum_sig => sum_layer1_127630304_127824784,
    carry_sig => carry_layer1_127630304_127824784
);

FA_128255200_128255144: FA 
PORT MAP (
    bit_a => a8_and_b17,
    bit_b => a9_and_b16,
    bit_c => a10_and_b15,
    sum_sig => sum_layer1_127725520_127637376_127639280,
    carry_sig => carry_layer1_127725520_127637376_127639280
);

FA_128255312_128255368: FA 
PORT MAP (
    bit_a => a11_and_b14,
    bit_b => a12_and_b13,
    bit_c => a13_and_b12,
    sum_sig => sum_layer1_127714976_127716880_127849920,
    carry_sig => carry_layer1_127714976_127716880_127849920
);

FA_128255480_128255536: FA 
PORT MAP (
    bit_a => a14_and_b11,
    bit_b => a15_and_b10,
    bit_c => a16_and_b9,
    sum_sig => sum_layer1_127851824_127628512_127630416,
    carry_sig => carry_layer1_127851824_127628512_127630416
);

FA_128255704_128255648: FA 
PORT MAP (
    bit_a => a9_and_b17,
    bit_b => a10_and_b16,
    bit_c => a11_and_b15,
    sum_sig => sum_layer1_127637488_127639392_127715088,
    carry_sig => carry_layer1_127637488_127639392_127715088
);

FA_128255816_128255872: FA 
PORT MAP (
    bit_a => a12_and_b14,
    bit_b => a13_and_b13,
    bit_c => a14_and_b12,
    sum_sig => sum_layer1_127716992_127850032_127851936,
    carry_sig => carry_layer1_127716992_127850032_127851936
);

FA_128255984_128256040: FA 
PORT MAP (
    bit_a => a15_and_b11,
    bit_b => a16_and_b10,
    bit_c => a17_and_b9,
    sum_sig => sum_layer1_127628624_127630528_127825008,
    carry_sig => carry_layer1_127628624_127630528_127825008
);

FA_128256208_128256152: FA 
PORT MAP (
    bit_a => a10_and_b17,
    bit_b => a11_and_b16,
    bit_c => a12_and_b15,
    sum_sig => sum_layer1_127639504_127715200_127717104,
    carry_sig => carry_layer1_127639504_127715200_127717104
);

FA_128256320_128256376: FA 
PORT MAP (
    bit_a => a13_and_b14,
    bit_b => a14_and_b13,
    bit_c => a15_and_b12,
    sum_sig => sum_layer1_127850144_127852048_127628736,
    carry_sig => carry_layer1_127850144_127852048_127628736
);

HA_128256488_128256544: HA 
PORT MAP (
    bit_a => a16_and_b11,
    bit_b => a17_and_b10,
    sum_sig => sum_layer1_127630640_127825120,
    carry_sig => carry_layer1_127630640_127825120
);

FA_128256712_128256656: FA 
PORT MAP (
    bit_a => a11_and_b17,
    bit_b => a12_and_b16,
    bit_c => a13_and_b15,
    sum_sig => sum_layer1_127715312_127717216_127850256,
    carry_sig => carry_layer1_127715312_127717216_127850256
);

FA_128256824_128256880: FA 
PORT MAP (
    bit_a => a14_and_b14,
    bit_b => a15_and_b13,
    bit_c => a16_and_b12,
    sum_sig => sum_layer1_127852160_127628848_127630752,
    carry_sig => carry_layer1_127852160_127628848_127630752
);

FA_128257048_128256992: FA 
PORT MAP (
    bit_a => a12_and_b17,
    bit_b => a13_and_b16,
    bit_c => a14_and_b15,
    sum_sig => sum_layer1_127717328_127850368_127852272,
    carry_sig => carry_layer1_127717328_127850368_127852272
);

FA_128257160_128257216: FA 
PORT MAP (
    bit_a => a15_and_b14,
    bit_b => a16_and_b13,
    bit_c => a17_and_b12,
    sum_sig => sum_layer1_127628960_127630864_127825344,
    carry_sig => carry_layer1_127628960_127630864_127825344
);

FA_128257384_128257328: FA 
PORT MAP (
    bit_a => a13_and_b17,
    bit_b => a14_and_b16,
    bit_c => a15_and_b15,
    sum_sig => sum_layer1_127850480_127852384_127629072,
    carry_sig => carry_layer1_127850480_127852384_127629072
);

HA_128257496_128257552: HA 
PORT MAP (
    bit_a => a16_and_b14,
    bit_b => a17_and_b13,
    sum_sig => sum_layer1_127630976_127825456,
    carry_sig => carry_layer1_127630976_127825456
);

FA_128257776_128257720: FA 
PORT MAP (
    bit_a => a14_and_b17,
    bit_b => a15_and_b16,
    bit_c => a16_and_b15,
    sum_sig => sum_layer1_127852496_127629184_127631088,
    carry_sig => carry_layer1_127852496_127629184_127631088
);

FA_128257888_128257832: FA 
PORT MAP (
    bit_a => a15_and_b17,
    bit_b => a16_and_b16,
    bit_c => a17_and_b15,
    sum_sig => sum_layer1_127629296_127631200_127825680,
    carry_sig => carry_layer1_127629296_127631200_127825680
);

HA_128258000_128245832: HA 
PORT MAP (
    bit_a => a16_and_b17,
    bit_b => a17_and_b16,
    sum_sig => sum_layer1_127631312_127825792,
    carry_sig => carry_layer1_127631312_127825792
);

HA_128245944_128246000: HA 
PORT MAP (
    bit_a => carry_layer1_127830168_127844480,
    bit_b => sum_layer1_127830336_127844592_127846496,
    sum_sig => sum_layer2_127826128_127826296,
    carry_sig => carry_layer2_127826128_127826296
);

FA_128246168_128246112: FA 
PORT MAP (
    bit_a => a3_and_b0,
    bit_b => carry_layer1_127830336_127844592_127846496,
    bit_c => sum_layer1_127830448_127844704_127846608,
    sum_sig => sum_layer2_127672448_127826240_127826520,
    carry_sig => carry_layer2_127672448_127826240_127826520
);

FA_128246336_128246280: FA 
PORT MAP (
    bit_a => carry_layer1_127830448_127844704_127846608,
    bit_b => sum_layer1_127830560_127844816_127846720,
    bit_c => sum_layer1_127672560_127674464,
    sum_sig => sum_layer2_127826464_127826632_127826744,
    carry_sig => carry_layer2_127826464_127826632_127826744
);

FA_128246560_128246504: FA 
PORT MAP (
    bit_a => carry_layer1_127830560_127844816_127846720,
    bit_b => carry_layer1_127672560_127674464,
    bit_c => sum_layer1_127830672_127844928_127846832,
    sum_sig => sum_layer2_127826576_127826800_127826968,
    carry_sig => carry_layer2_127826576_127826800_127826968
);

FA_128246672_128246616: FA 
PORT MAP (
    bit_a => a6_and_b0,
    bit_b => carry_layer1_127830672_127844928_127846832,
    bit_c => carry_layer1_127672672_127674576_127729792,
    sum_sig => sum_layer2_127731808_127826912_127827136,
    carry_sig => carry_layer2_127731808_127826912_127827136
);

HA_128246784_128246840: HA 
PORT MAP (
    bit_a => sum_layer1_127830784_127845040_127846944,
    bit_b => sum_layer1_127672784_127674688_127729904,
    sum_sig => sum_layer2_127827304_127827416,
    carry_sig => carry_layer2_127827304_127827416
);

FA_128247008_128246952: FA 
PORT MAP (
    bit_a => carry_layer1_127830784_127845040_127846944,
    bit_b => carry_layer1_127672784_127674688_127729904,
    bit_c => sum_layer1_127830896_127845152_127847056,
    sum_sig => sum_layer2_127827248_127827472_127827640,
    carry_sig => carry_layer2_127827248_127827472_127827640
);

HA_128247120_128247176: HA 
PORT MAP (
    bit_a => sum_layer1_127672896_127674800_127730016,
    bit_b => sum_layer1_127731920_127721600,
    sum_sig => sum_layer2_127827752_127827920,
    carry_sig => carry_layer2_127827752_127827920
);

FA_128247344_128247288: FA 
PORT MAP (
    bit_a => carry_layer1_127830896_127845152_127847056,
    bit_b => carry_layer1_127672896_127674800_127730016,
    bit_c => carry_layer1_127731920_127721600,
    sum_sig => sum_layer2_127827584_127827808_128221256,
    carry_sig => carry_layer2_127827584_127827808_128221256
);

FA_128247456_128247512: FA 
PORT MAP (
    bit_a => sum_layer1_127831008_127845264_127847168,
    bit_b => sum_layer1_127673008_127674912_127730128,
    bit_c => sum_layer1_127732032_127721712_127723616,
    sum_sig => sum_layer2_128221424_128221536_128221704,
    carry_sig => carry_layer2_128221424_128221536_128221704
);

FA_128247680_128247624: FA 
PORT MAP (
    bit_a => a9_and_b0,
    bit_b => carry_layer1_127831008_127845264_127847168,
    bit_c => carry_layer1_127673008_127674912_127730128,
    sum_sig => sum_layer2_127635584_128221368_128221592,
    carry_sig => carry_layer2_127635584_128221368_128221592
);

FA_128247792_128247848: FA 
PORT MAP (
    bit_a => carry_layer1_127732032_127721712_127723616,
    bit_b => sum_layer1_127831120_127845376_127847280,
    bit_c => sum_layer1_127673120_127675024_127730240,
    sum_sig => sum_layer2_128221760_128221928_128222040,
    carry_sig => carry_layer2_128221760_128221928_128222040
);

FA_128248016_128247960: FA 
PORT MAP (
    bit_a => carry_layer1_127831120_127845376_127847280,
    bit_b => carry_layer1_127673120_127675024_127730240,
    bit_c => carry_layer1_127732144_127721824_127723728,
    sum_sig => sum_layer2_128221872_128222096_128222264,
    carry_sig => carry_layer2_128221872_128222096_128222264
);

FA_128248128_128248184: FA 
PORT MAP (
    bit_a => sum_layer1_127831232_127845488_127847392,
    bit_b => sum_layer1_127673232_127675136_127730352,
    bit_c => sum_layer1_127732256_127721936_127723840,
    sum_sig => sum_layer2_128222432_128222544_128222712,
    carry_sig => carry_layer2_128222432_128222544_128222712
);

FA_128248352_128248296: FA 
PORT MAP (
    bit_a => carry_layer1_127831232_127845488_127847392,
    bit_b => carry_layer1_127673232_127675136_127730352,
    bit_c => carry_layer1_127732256_127721936_127723840,
    sum_sig => sum_layer2_128222376_128222600_128222768,
    carry_sig => carry_layer2_128222376_128222600_128222768
);

FA_128248464_128248520: FA 
PORT MAP (
    bit_a => carry_layer1_127635696_127637600,
    bit_b => sum_layer1_127831344_127845600_127847504,
    bit_c => sum_layer1_127673344_127675248_127730464,
    sum_sig => sum_layer2_128222936_128223104_128223216,
    carry_sig => carry_layer2_128222936_128223104_128223216
);

HA_128248632_128248688: HA 
PORT MAP (
    bit_a => sum_layer1_127732368_127722048_127723952,
    bit_b => sum_layer1_127635808_127637712_127713408,
    sum_sig => sum_layer2_128223384_128223552,
    carry_sig => carry_layer2_128223384_128223552
);

FA_128248856_128248800: FA 
PORT MAP (
    bit_a => a12_and_b0,
    bit_b => carry_layer1_127831344_127845600_127847504,
    bit_c => carry_layer1_127673344_127675248_127730464,
    sum_sig => sum_layer2_127715424_128223048_128223272,
    carry_sig => carry_layer2_127715424_128223048_128223272
);

FA_128248968_128249024: FA 
PORT MAP (
    bit_a => carry_layer1_127732368_127722048_127723952,
    bit_b => carry_layer1_127635808_127637712_127713408,
    bit_c => sum_layer1_127831456_127845712_127847616,
    sum_sig => sum_layer2_128223440_128223608_128223776,
    carry_sig => carry_layer2_128223440_128223608_128223776
);

FA_128249136_128249192: FA 
PORT MAP (
    bit_a => sum_layer1_127673456_127675360_127730576,
    bit_b => sum_layer1_127732480_127722160_127724064,
    bit_c => sum_layer1_127635920_127637824_127713520,
    sum_sig => sum_layer2_128223888_128224112_128224056,
    carry_sig => carry_layer2_128223888_128224112_128224056
);

FA_128249360_128249304: FA 
PORT MAP (
    bit_a => carry_layer1_127831456_127845712_127847616,
    bit_b => carry_layer1_127673456_127675360_127730576,
    bit_c => carry_layer1_127732480_127722160_127724064,
    sum_sig => sum_layer2_128223720_128223944_128224168,
    carry_sig => carry_layer2_128223720_128223944_128224168
);

FA_128249472_128249528: FA 
PORT MAP (
    bit_a => carry_layer1_127635920_127637824_127713520,
    bit_b => sum_layer1_127831568_127845824_127847728,
    bit_c => sum_layer1_127673568_127675472_127730688,
    sum_sig => sum_layer2_128224280_128224448_128224560,
    carry_sig => carry_layer2_128224280_128224448_128224560
);

FA_128249640_128249696: FA 
PORT MAP (
    bit_a => sum_layer1_127732592_127722272_127724176,
    bit_b => sum_layer1_127636032_127637936_127713632,
    bit_c => sum_layer1_127715536_127848576,
    sum_sig => sum_layer2_128224728_128224896_128225064,
    carry_sig => carry_layer2_128224728_128224896_128225064
);

FA_128249808_128262216: FA 
PORT MAP (
    bit_a => carry_layer1_127831568_127845824_127847728,
    bit_b => carry_layer1_127673568_127675472_127730688,
    bit_c => carry_layer1_127732592_127722272_127724176,
    sum_sig => sum_layer2_128224392_128224616_128224784,
    carry_sig => carry_layer2_128224392_128224616_128224784
);

FA_128262328_128262384: FA 
PORT MAP (
    bit_a => carry_layer1_127636032_127637936_127713632,
    bit_b => carry_layer1_127715536_127848576,
    bit_c => sum_layer1_127831680_127845936_127847840,
    sum_sig => sum_layer2_128224952_128225120_128225232,
    carry_sig => carry_layer2_128224952_128225120_128225232
);

FA_128262496_128262552: FA 
PORT MAP (
    bit_a => sum_layer1_127673680_127675584_127730800,
    bit_b => sum_layer1_127732704_127722384_127724288,
    bit_c => sum_layer1_127636144_127638048_127713744,
    sum_sig => sum_layer2_128196792_128196960_128197184,
    carry_sig => carry_layer2_128196792_128196960_128197184
);

FA_128262720_128262664: FA 
PORT MAP (
    bit_a => a15_and_b0,
    bit_b => carry_layer1_127831680_127845936_127847840,
    bit_c => carry_layer1_127673680_127675584_127730800,
    sum_sig => sum_layer2_127627392_128196680_128196848,
    carry_sig => carry_layer2_127627392_128196680_128196848
);

FA_128262832_128262888: FA 
PORT MAP (
    bit_a => carry_layer1_127732704_127722384_127724288,
    bit_b => carry_layer1_127636144_127638048_127713744,
    bit_c => carry_layer1_127715648_127848688_127850592,
    sum_sig => sum_layer2_128197016_128197240_128197352,
    carry_sig => carry_layer2_128197016_128197240_128197352
);

FA_128263000_128263056: FA 
PORT MAP (
    bit_a => sum_layer1_127831792_127846048_127847952,
    bit_b => sum_layer1_127673792_127675696_127730912,
    bit_c => sum_layer1_127732816_127722496_127724400,
    sum_sig => sum_layer2_128197520_128197632_128197800,
    carry_sig => carry_layer2_128197520_128197632_128197800
);

HA_128263168_128263224: HA 
PORT MAP (
    bit_a => sum_layer1_127636256_127638160_127713856,
    bit_b => sum_layer1_127715760_127848800_127850704,
    sum_sig => sum_layer2_128198024_128197968,
    carry_sig => carry_layer2_128198024_128197968
);

FA_128263392_128263336: FA 
PORT MAP (
    bit_a => carry_layer1_127831792_127846048_127847952,
    bit_b => carry_layer1_127673792_127675696_127730912,
    bit_c => carry_layer1_127732816_127722496_127724400,
    sum_sig => sum_layer2_128197464_128197688_128197856,
    carry_sig => carry_layer2_128197464_128197688_128197856
);

FA_128263504_128263560: FA 
PORT MAP (
    bit_a => carry_layer1_127636256_127638160_127713856,
    bit_b => carry_layer1_127715760_127848800_127850704,
    bit_c => sum_layer1_127831904_127846160_127848064,
    sum_sig => sum_layer2_128198080_128198192_128198360,
    carry_sig => carry_layer2_128198080_128198192_128198360
);

FA_128263672_128263728: FA 
PORT MAP (
    bit_a => sum_layer1_127673904_127675808_127731024,
    bit_b => sum_layer1_127732928_127722608_127724512,
    bit_c => sum_layer1_127636368_127638272_127713968,
    sum_sig => sum_layer2_128198472_128198640_128198808,
    carry_sig => carry_layer2_128198472_128198640_128198808
);

HA_128263840_128263896: HA 
PORT MAP (
    bit_a => sum_layer1_127715872_127848912_127850816,
    bit_b => sum_layer1_127627504_127629408,
    sum_sig => sum_layer2_128198976_128199144,
    carry_sig => carry_layer2_128198976_128199144
);

FA_128264064_128264008: FA 
PORT MAP (
    bit_a => carry_layer1_127831904_127846160_127848064,
    bit_b => carry_layer1_127673904_127675808_127731024,
    bit_c => carry_layer1_127732928_127722608_127724512,
    sum_sig => sum_layer2_128198304_128198528_128198696,
    carry_sig => carry_layer2_128198304_128198528_128198696
);

FA_128264176_128264232: FA 
PORT MAP (
    bit_a => carry_layer1_127636368_127638272_127713968,
    bit_b => carry_layer1_127715872_127848912_127850816,
    bit_c => carry_layer1_127627504_127629408,
    sum_sig => sum_layer2_128198864_128199032_128199200,
    carry_sig => carry_layer2_128198864_128199032_128199200
);

FA_128264344_128264400: FA 
PORT MAP (
    bit_a => sum_layer1_127832016_127846272_127848176,
    bit_b => sum_layer1_127674016_127675920_127731136,
    bit_c => sum_layer1_127733040_127722720_127724624,
    sum_sig => sum_layer2_128199368_128199480_128199648,
    carry_sig => carry_layer2_128199368_128199480_128199648
);

FA_128264512_128264568: FA 
PORT MAP (
    bit_a => sum_layer1_127636480_127638384_127714080,
    bit_b => sum_layer1_127715984_127849024_127850928,
    bit_c => sum_layer1_127627616_127629520_127824000,
    sum_sig => sum_layer2_128199816_128200040_128199984,
    carry_sig => carry_layer2_128199816_128200040_128199984
);

FA_128264736_128264680: FA 
PORT MAP (
    bit_a => carry_layer1_127832016_127846272_127848176,
    bit_b => carry_layer1_127674016_127675920_127731136,
    bit_c => carry_layer1_127733040_127722720_127724624,
    sum_sig => sum_layer2_128199312_128199536_128199704,
    carry_sig => carry_layer2_128199312_128199536_128199704
);

FA_128264848_128264904: FA 
PORT MAP (
    bit_a => carry_layer1_127636480_127638384_127714080,
    bit_b => carry_layer1_127715984_127849024_127850928,
    bit_c => carry_layer1_127627616_127629520_127824000,
    sum_sig => sum_layer2_128199872_128200096_128200208,
    carry_sig => carry_layer2_128199872_128200096_128200208
);

FA_128265016_128265072: FA 
PORT MAP (
    bit_a => sum_layer1_127846384_127848288_127674128,
    bit_b => sum_layer1_127676032_127731248_127733152,
    bit_c => sum_layer1_127722832_127724736_127636592,
    sum_sig => sum_layer2_128200376_128200488_128200656,
    carry_sig => carry_layer2_128200376_128200488_128200656
);

FA_128265184_128265240: FA 
PORT MAP (
    bit_a => sum_layer1_127638496_127714192_127716096,
    bit_b => sum_layer1_127849136_127851040_127627728,
    bit_c => sum_layer1_127629632_127824112,
    sum_sig => sum_layer2_128225464_128225632_128225800,
    carry_sig => carry_layer2_128225464_128225632_128225800
);

FA_128265408_128265352: FA 
PORT MAP (
    bit_a => a17_and_b2,
    bit_b => carry_layer1_127846384_127848288_127674128,
    bit_c => carry_layer1_127676032_127731248_127733152,
    sum_sig => sum_layer2_127824224_128200320_128200544,
    carry_sig => carry_layer2_127824224_128200320_128200544
);

FA_128265520_128265576: FA 
PORT MAP (
    bit_a => carry_layer1_127722832_127724736_127636592,
    bit_b => carry_layer1_127638496_127714192_127716096,
    bit_c => carry_layer1_127849136_127851040_127627728,
    sum_sig => sum_layer2_128225352_128225520_128225688,
    carry_sig => carry_layer2_128225352_128225520_128225688
);

FA_128265688_128265744: FA 
PORT MAP (
    bit_a => carry_layer1_127629632_127824112,
    bit_b => sum_layer1_127848400_127674240_127676144,
    bit_c => sum_layer1_127731360_127733264_127722944,
    sum_sig => sum_layer2_128225856_128226024_128226136,
    carry_sig => carry_layer2_128225856_128226024_128226136
);

FA_128265856_128265912: FA 
PORT MAP (
    bit_a => sum_layer1_127724848_127636704_127638608,
    bit_b => sum_layer1_127714304_127716208_127849248,
    bit_c => sum_layer1_127851152_127627840_127629744,
    sum_sig => sum_layer2_128226304_128226528_128226472,
    carry_sig => carry_layer2_128226304_128226528_128226472
);

FA_128266080_128266024: FA 
PORT MAP (
    bit_a => carry_layer1_127848400_127674240_127676144,
    bit_b => carry_layer1_127731360_127733264_127722944,
    bit_c => carry_layer1_127724848_127636704_127638608,
    sum_sig => sum_layer2_128225968_128226192_128226360,
    carry_sig => carry_layer2_128225968_128226192_128226360
);

FA_128266192_128204872: FA 
PORT MAP (
    bit_a => carry_layer1_127714304_127716208_127849248,
    bit_b => carry_layer1_127851152_127627840_127629744,
    bit_c => sum_layer1_127674352_127676256_127731472,
    sum_sig => sum_layer2_128226584_128226696_128226864,
    carry_sig => carry_layer2_128226584_128226696_128226864
);

FA_128204984_128205040: FA 
PORT MAP (
    bit_a => sum_layer1_127733376_127723056_127724960,
    bit_b => sum_layer1_127636816_127638720_127714416,
    bit_c => sum_layer1_127716320_127849360_127851264,
    sum_sig => sum_layer2_128226976_128227144_128227368,
    carry_sig => carry_layer2_128226976_128227144_128227368
);

FA_128205208_128205152: FA 
PORT MAP (
    bit_a => carry_layer1_127674352_127676256_127731472,
    bit_b => carry_layer1_127733376_127723056_127724960,
    bit_c => carry_layer1_127636816_127638720_127714416,
    sum_sig => sum_layer2_128226808_128227032_128227200,
    carry_sig => carry_layer2_128226808_128227032_128227200
);

FA_128205320_128205376: FA 
PORT MAP (
    bit_a => carry_layer1_127716320_127849360_127851264,
    bit_b => carry_layer1_127627952_127629856_127824336,
    bit_c => sum_layer1_127676368_127731584_127733488,
    sum_sig => sum_layer2_128227424_128227536_128227704,
    carry_sig => carry_layer2_128227424_128227536_128227704
);

FA_128205488_128205544: FA 
PORT MAP (
    bit_a => sum_layer1_127723168_127725072_127636928,
    bit_b => sum_layer1_127638832_127714528_127716432,
    bit_c => sum_layer1_127849472_127851376_127628064,
    sum_sig => sum_layer2_128227816_128227984_128228152,
    carry_sig => carry_layer2_128227816_128227984_128228152
);

FA_128205712_128205656: FA 
PORT MAP (
    bit_a => a17_and_b5,
    bit_b => carry_layer1_127676368_127731584_127733488,
    bit_c => carry_layer1_127723168_127725072_127636928,
    sum_sig => sum_layer2_127824560_128227648_128227872,
    carry_sig => carry_layer2_127824560_128227648_128227872
);

FA_128205824_128205880: FA 
PORT MAP (
    bit_a => carry_layer1_127638832_127714528_127716432,
    bit_b => carry_layer1_127849472_127851376_127628064,
    bit_c => carry_layer1_127629968_127824448,
    sum_sig => sum_layer2_128228040_128228208_128228376,
    carry_sig => carry_layer2_128228040_128228208_128228376
);

FA_128205992_128206048: FA 
PORT MAP (
    bit_a => sum_layer1_127731696_127733600_127723280,
    bit_b => sum_layer1_127725184_127637040_127638944,
    bit_c => sum_layer1_127714640_127716544_127849584,
    sum_sig => sum_layer2_128228544_128228656_128228880,
    carry_sig => carry_layer2_128228544_128228656_128228880
);

FA_128206216_128206160: FA 
PORT MAP (
    bit_a => carry_layer1_127731696_127733600_127723280,
    bit_b => carry_layer1_127725184_127637040_127638944,
    bit_c => carry_layer1_127714640_127716544_127849584,
    sum_sig => sum_layer2_128228488_128228712_128228936,
    carry_sig => carry_layer2_128228488_128228712_128228936
);

FA_128206328_128206384: FA 
PORT MAP (
    bit_a => carry_layer1_127851488_127628176_127630080,
    bit_b => sum_layer1_127733712_127723392_127725296,
    bit_c => sum_layer1_127637152_127639056_127714752,
    sum_sig => sum_layer2_128229048_128229216_128229328,
    carry_sig => carry_layer2_128229048_128229216_128229328
);

HA_128206496_128206552: HA 
PORT MAP (
    bit_a => sum_layer1_127716656_127849696_127851600,
    bit_b => sum_layer1_127628288_127630192_127824672,
    sum_sig => sum_layer2_128254136_128254304,
    carry_sig => carry_layer2_128254136_128254304
);

FA_128206720_128206664: FA 
PORT MAP (
    bit_a => carry_layer1_127733712_127723392_127725296,
    bit_b => carry_layer1_127637152_127639056_127714752,
    bit_c => carry_layer1_127716656_127849696_127851600,
    sum_sig => sum_layer2_128229160_128254024_128254192,
    carry_sig => carry_layer2_128229160_128254024_128254192
);

FA_128206832_128206888: FA 
PORT MAP (
    bit_a => carry_layer1_127628288_127630192_127824672,
    bit_b => sum_layer1_127723504_127725408_127637264,
    bit_c => sum_layer1_127639168_127714864_127716768,
    sum_sig => sum_layer2_128254360_128254528_128254640,
    carry_sig => carry_layer2_128254360_128254528_128254640
);

HA_128207000_128207056: HA 
PORT MAP (
    bit_a => sum_layer1_127849808_127851712_127628400,
    bit_b => sum_layer1_127630304_127824784,
    sum_sig => sum_layer2_128254808_128254976,
    carry_sig => carry_layer2_128254808_128254976
);

FA_128207224_128207168: FA 
PORT MAP (
    bit_a => a17_and_b8,
    bit_b => carry_layer1_127723504_127725408_127637264,
    bit_c => carry_layer1_127639168_127714864_127716768,
    sum_sig => sum_layer2_127824896_128254472_128254696,
    carry_sig => carry_layer2_127824896_128254472_128254696
);

FA_128207336_128207392: FA 
PORT MAP (
    bit_a => carry_layer1_127849808_127851712_127628400,
    bit_b => carry_layer1_127630304_127824784,
    bit_c => sum_layer1_127725520_127637376_127639280,
    sum_sig => sum_layer2_128254864_128255032_128255200,
    carry_sig => carry_layer2_128254864_128255032_128255200
);

HA_128207504_128207560: HA 
PORT MAP (
    bit_a => sum_layer1_127714976_127716880_127849920,
    bit_b => sum_layer1_127851824_127628512_127630416,
    sum_sig => sum_layer2_128255312_128255480,
    carry_sig => carry_layer2_128255312_128255480
);

FA_128207728_128207672: FA 
PORT MAP (
    bit_a => carry_layer1_127725520_127637376_127639280,
    bit_b => carry_layer1_127714976_127716880_127849920,
    bit_c => carry_layer1_127851824_127628512_127630416,
    sum_sig => sum_layer2_128255144_128255368_128255536,
    carry_sig => carry_layer2_128255144_128255368_128255536
);

FA_128207840_128207896: FA 
PORT MAP (
    bit_a => sum_layer1_127637488_127639392_127715088,
    bit_b => sum_layer1_127716992_127850032_127851936,
    bit_c => sum_layer1_127628624_127630528_127825008,
    sum_sig => sum_layer2_128255704_128255816_128255984,
    carry_sig => carry_layer2_128255704_128255816_128255984
);

FA_128208064_128208008: FA 
PORT MAP (
    bit_a => carry_layer1_127637488_127639392_127715088,
    bit_b => carry_layer1_127716992_127850032_127851936,
    bit_c => carry_layer1_127628624_127630528_127825008,
    sum_sig => sum_layer2_128255648_128255872_128256040,
    carry_sig => carry_layer2_128255648_128255872_128256040
);

FA_128208176_128208232: FA 
PORT MAP (
    bit_a => sum_layer1_127639504_127715200_127717104,
    bit_b => sum_layer1_127850144_127852048_127628736,
    bit_c => sum_layer1_127630640_127825120,
    sum_sig => sum_layer2_128256208_128256320_128256488,
    carry_sig => carry_layer2_128256208_128256320_128256488
);

FA_128208400_128208344: FA 
PORT MAP (
    bit_a => a17_and_b11,
    bit_b => carry_layer1_127639504_127715200_127717104,
    bit_c => carry_layer1_127850144_127852048_127628736,
    sum_sig => sum_layer2_127825232_128256152_128256376,
    carry_sig => carry_layer2_127825232_128256152_128256376
);

FA_128208512_128208568: FA 
PORT MAP (
    bit_a => carry_layer1_127630640_127825120,
    bit_b => sum_layer1_127715312_127717216_127850256,
    bit_c => sum_layer1_127852160_127628848_127630752,
    sum_sig => sum_layer2_128256544_128256712_128256824,
    carry_sig => carry_layer2_128256544_128256712_128256824
);

FA_128208792_128208736: FA 
PORT MAP (
    bit_a => carry_layer1_127715312_127717216_127850256,
    bit_b => carry_layer1_127852160_127628848_127630752,
    bit_c => sum_layer1_127717328_127850368_127852272,
    sum_sig => sum_layer2_128256656_128256880_128257048,
    carry_sig => carry_layer2_128256656_128256880_128257048
);

FA_128208848_128123008: FA 
PORT MAP (
    bit_a => carry_layer1_127717328_127850368_127852272,
    bit_b => carry_layer1_127628960_127630864_127825344,
    bit_c => sum_layer1_127850480_127852384_127629072,
    sum_sig => sum_layer2_128256992_128257216_128257384,
    carry_sig => carry_layer2_128256992_128257216_128257384
);

FA_128123176_128123120: FA 
PORT MAP (
    bit_a => a17_and_b14,
    bit_b => carry_layer1_127850480_127852384_127629072,
    bit_c => carry_layer1_127630976_127825456,
    sum_sig => sum_layer2_127825568_128257328_128257552,
    carry_sig => carry_layer2_127825568_128257328_128257552
);

HA_128123288_128123232: HA 
PORT MAP (
    bit_a => carry_layer1_127852496_127629184_127631088,
    bit_b => sum_layer1_127629296_127631200_127825680,
    sum_sig => sum_layer2_128257720_128257888,
    carry_sig => carry_layer2_128257720_128257888
);

HA_128123456_128123400: HA 
PORT MAP (
    bit_a => carry_layer1_127629296_127631200_127825680,
    bit_b => sum_layer1_127631312_127825792,
    sum_sig => sum_layer2_128257832_128258000,
    carry_sig => carry_layer2_128257832_128258000
);

HA_128123624_128123568: HA 
PORT MAP (
    bit_a => a17_and_b17,
    bit_b => carry_layer1_127631312_127825792,
    sum_sig => sum_layer2_127825904_128245832,
    carry_sig => carry_layer2_127825904_128245832
);

HA_128123736_128123792: HA 
PORT MAP (
    bit_a => carry_layer2_127826128_127826296,
    bit_b => sum_layer2_127672448_127826240_127826520,
    sum_sig => sum_layer3_128246000_128246168,
    carry_sig => carry_layer3_128246000_128246168
);

HA_128123960_128123904: HA 
PORT MAP (
    bit_a => carry_layer2_127672448_127826240_127826520,
    bit_b => sum_layer2_127826464_127826632_127826744,
    sum_sig => sum_layer3_128246112_128246336,
    carry_sig => carry_layer3_128246112_128246336
);

FA_128124128_128124072: FA 
PORT MAP (
    bit_a => sum_layer1_127672672_127674576_127729792,
    bit_b => carry_layer2_127826464_127826632_127826744,
    bit_c => sum_layer2_127826576_127826800_127826968,
    sum_sig => sum_layer3_127827080_128246280_128246560,
    carry_sig => carry_layer3_127827080_128246280_128246560
);

FA_128124296_128124240: FA 
PORT MAP (
    bit_a => carry_layer2_127826576_127826800_127826968,
    bit_b => sum_layer2_127731808_127826912_127827136,
    bit_c => sum_layer2_127827304_127827416,
    sum_sig => sum_layer3_128246504_128246672_128246784,
    carry_sig => carry_layer3_128246504_128246672_128246784
);

FA_128124520_128124464: FA 
PORT MAP (
    bit_a => carry_layer2_127731808_127826912_127827136,
    bit_b => carry_layer2_127827304_127827416,
    bit_c => sum_layer2_127827248_127827472_127827640,
    sum_sig => sum_layer3_128246616_128246840_128247008,
    carry_sig => carry_layer3_128246616_128246840_128247008
);

FA_128124688_128124632: FA 
PORT MAP (
    bit_a => carry_layer2_127827248_127827472_127827640,
    bit_b => carry_layer2_127827752_127827920,
    bit_c => sum_layer2_127827584_127827808_128221256,
    sum_sig => sum_layer3_128246952_128247176_128247344,
    carry_sig => carry_layer3_128246952_128247176_128247344
);

FA_128124800_128124744: FA 
PORT MAP (
    bit_a => sum_layer1_127732144_127721824_127723728,
    bit_b => carry_layer2_127827584_127827808_128221256,
    bit_c => carry_layer2_128221424_128221536_128221704,
    sum_sig => sum_layer3_128222208_128247288_128247512,
    carry_sig => carry_layer3_128222208_128247288_128247512
);

HA_128124912_128124968: HA 
PORT MAP (
    bit_a => sum_layer2_127635584_128221368_128221592,
    bit_b => sum_layer2_128221760_128221928_128222040,
    sum_sig => sum_layer3_128247680_128247792,
    carry_sig => carry_layer3_128247680_128247792
);

FA_128125136_128125080: FA 
PORT MAP (
    bit_a => sum_layer1_127635696_127637600,
    bit_b => carry_layer2_127635584_128221368_128221592,
    bit_c => carry_layer2_128221760_128221928_128222040,
    sum_sig => sum_layer3_128222880_128247624_128247848,
    carry_sig => carry_layer3_128222880_128247624_128247848
);

HA_128125248_128125304: HA 
PORT MAP (
    bit_a => sum_layer2_128221872_128222096_128222264,
    bit_b => sum_layer2_128222432_128222544_128222712,
    sum_sig => sum_layer3_128248016_128248128,
    carry_sig => carry_layer3_128248016_128248128
);

FA_128125472_128125416: FA 
PORT MAP (
    bit_a => carry_layer2_128221872_128222096_128222264,
    bit_b => carry_layer2_128222432_128222544_128222712,
    bit_c => sum_layer2_128222376_128222600_128222768,
    sum_sig => sum_layer3_128247960_128248184_128248352,
    carry_sig => carry_layer3_128247960_128248184_128248352
);

HA_128125584_128125640: HA 
PORT MAP (
    bit_a => sum_layer2_128222936_128223104_128223216,
    bit_b => sum_layer2_128223384_128223552,
    sum_sig => sum_layer3_128248464_128248632,
    carry_sig => carry_layer3_128248464_128248632
);

FA_128125808_128125752: FA 
PORT MAP (
    bit_a => carry_layer2_128222376_128222600_128222768,
    bit_b => carry_layer2_128222936_128223104_128223216,
    bit_c => carry_layer2_128223384_128223552,
    sum_sig => sum_layer3_128248296_128248520_128248688,
    carry_sig => carry_layer3_128248296_128248520_128248688
);

FA_128125920_128125976: FA 
PORT MAP (
    bit_a => sum_layer2_127715424_128223048_128223272,
    bit_b => sum_layer2_128223440_128223608_128223776,
    bit_c => sum_layer2_128223888_128224112_128224056,
    sum_sig => sum_layer3_128248856_128248968_128249136,
    carry_sig => carry_layer3_128248856_128248968_128249136
);

FA_128126144_128126088: FA 
PORT MAP (
    bit_a => carry_layer2_127715424_128223048_128223272,
    bit_b => carry_layer2_128223440_128223608_128223776,
    bit_c => carry_layer2_128223888_128224112_128224056,
    sum_sig => sum_layer3_128248800_128249024_128249192,
    carry_sig => carry_layer3_128248800_128249024_128249192
);

FA_128126256_128126312: FA 
PORT MAP (
    bit_a => sum_layer2_128223720_128223944_128224168,
    bit_b => sum_layer2_128224280_128224448_128224560,
    bit_c => sum_layer2_128224728_128224896_128225064,
    sum_sig => sum_layer3_128249360_128249472_128249640,
    carry_sig => carry_layer3_128249360_128249472_128249640
);

FA_128126480_128126424: FA 
PORT MAP (
    bit_a => sum_layer1_127715648_127848688_127850592,
    bit_b => carry_layer2_128223720_128223944_128224168,
    bit_c => carry_layer2_128224280_128224448_128224560,
    sum_sig => sum_layer3_128197128_128249304_128249528,
    carry_sig => carry_layer3_128197128_128249304_128249528
);

FA_128126592_128126648: FA 
PORT MAP (
    bit_a => carry_layer2_128224728_128224896_128225064,
    bit_b => sum_layer2_128224392_128224616_128224784,
    bit_c => sum_layer2_128224952_128225120_128225232,
    sum_sig => sum_layer3_128249696_128249808_128262328,
    carry_sig => carry_layer3_128249696_128249808_128262328
);

FA_128126816_128126760: FA 
PORT MAP (
    bit_a => carry_layer2_128224392_128224616_128224784,
    bit_b => carry_layer2_128224952_128225120_128225232,
    bit_c => carry_layer2_128196792_128196960_128197184,
    sum_sig => sum_layer3_128262216_128262384_128262552,
    carry_sig => carry_layer3_128262216_128262384_128262552
);

FA_128126928_128237640: FA 
PORT MAP (
    bit_a => sum_layer2_127627392_128196680_128196848,
    bit_b => sum_layer2_128197016_128197240_128197352,
    bit_c => sum_layer2_128197520_128197632_128197800,
    sum_sig => sum_layer3_128262720_128262832_128263000,
    carry_sig => carry_layer3_128262720_128262832_128263000
);

FA_128237808_128237752: FA 
PORT MAP (
    bit_a => carry_layer2_127627392_128196680_128196848,
    bit_b => carry_layer2_128197016_128197240_128197352,
    bit_c => carry_layer2_128197520_128197632_128197800,
    sum_sig => sum_layer3_128262664_128262888_128263056,
    carry_sig => carry_layer3_128262664_128262888_128263056
);

FA_128237920_128237976: FA 
PORT MAP (
    bit_a => carry_layer2_128198024_128197968,
    bit_b => sum_layer2_128197464_128197688_128197856,
    bit_c => sum_layer2_128198080_128198192_128198360,
    sum_sig => sum_layer3_128263224_128263392_128263504,
    carry_sig => carry_layer3_128263224_128263392_128263504
);

HA_128238088_128238144: HA 
PORT MAP (
    bit_a => sum_layer2_128198472_128198640_128198808,
    bit_b => sum_layer2_128198976_128199144,
    sum_sig => sum_layer3_128263672_128263840,
    carry_sig => carry_layer3_128263672_128263840
);

FA_128238312_128238256: FA 
PORT MAP (
    bit_a => carry_layer2_128197464_128197688_128197856,
    bit_b => carry_layer2_128198080_128198192_128198360,
    bit_c => carry_layer2_128198472_128198640_128198808,
    sum_sig => sum_layer3_128263336_128263560_128263728,
    carry_sig => carry_layer3_128263336_128263560_128263728
);

FA_128238424_128238480: FA 
PORT MAP (
    bit_a => carry_layer2_128198976_128199144,
    bit_b => sum_layer2_128198304_128198528_128198696,
    bit_c => sum_layer2_128198864_128199032_128199200,
    sum_sig => sum_layer3_128263896_128264064_128264176,
    carry_sig => carry_layer3_128263896_128264064_128264176
);

HA_128238592_128238648: HA 
PORT MAP (
    bit_a => sum_layer2_128199368_128199480_128199648,
    bit_b => sum_layer2_128199816_128200040_128199984,
    sum_sig => sum_layer3_128264344_128264512,
    carry_sig => carry_layer3_128264344_128264512
);

FA_128238816_128238760: FA 
PORT MAP (
    bit_a => carry_layer2_128198304_128198528_128198696,
    bit_b => carry_layer2_128198864_128199032_128199200,
    bit_c => carry_layer2_128199368_128199480_128199648,
    sum_sig => sum_layer3_128264008_128264232_128264400,
    carry_sig => carry_layer3_128264008_128264232_128264400
);

FA_128238928_128238984: FA 
PORT MAP (
    bit_a => carry_layer2_128199816_128200040_128199984,
    bit_b => sum_layer2_128199312_128199536_128199704,
    bit_c => sum_layer2_128199872_128200096_128200208,
    sum_sig => sum_layer3_128264568_128264736_128264848,
    carry_sig => carry_layer3_128264568_128264736_128264848
);

HA_128239096_128239152: HA 
PORT MAP (
    bit_a => sum_layer2_128200376_128200488_128200656,
    bit_b => sum_layer2_128225464_128225632_128225800,
    sum_sig => sum_layer3_128265016_128265184,
    carry_sig => carry_layer3_128265016_128265184
);

FA_128239320_128239264: FA 
PORT MAP (
    bit_a => carry_layer2_128199312_128199536_128199704,
    bit_b => carry_layer2_128199872_128200096_128200208,
    bit_c => carry_layer2_128200376_128200488_128200656,
    sum_sig => sum_layer3_128264680_128264904_128265072,
    carry_sig => carry_layer3_128264680_128264904_128265072
);

FA_128239432_128239488: FA 
PORT MAP (
    bit_a => carry_layer2_128225464_128225632_128225800,
    bit_b => sum_layer2_127824224_128200320_128200544,
    bit_c => sum_layer2_128225352_128225520_128225688,
    sum_sig => sum_layer3_128265240_128265408_128265520,
    carry_sig => carry_layer3_128265240_128265408_128265520
);

HA_128239600_128239656: HA 
PORT MAP (
    bit_a => sum_layer2_128225856_128226024_128226136,
    bit_b => sum_layer2_128226304_128226528_128226472,
    sum_sig => sum_layer3_128265688_128265856,
    carry_sig => carry_layer3_128265688_128265856
);

FA_128239824_128239768: FA 
PORT MAP (
    bit_a => sum_layer1_127627952_127629856_127824336,
    bit_b => carry_layer2_127824224_128200320_128200544,
    bit_c => carry_layer2_128225352_128225520_128225688,
    sum_sig => sum_layer3_128227312_128265352_128265576,
    carry_sig => carry_layer3_128227312_128265352_128265576
);

FA_128239936_128239992: FA 
PORT MAP (
    bit_a => carry_layer2_128225856_128226024_128226136,
    bit_b => carry_layer2_128226304_128226528_128226472,
    bit_c => sum_layer2_128225968_128226192_128226360,
    sum_sig => sum_layer3_128265744_128265912_128266080,
    carry_sig => carry_layer3_128265744_128265912_128266080
);

HA_128240104_128240160: HA 
PORT MAP (
    bit_a => sum_layer2_128226584_128226696_128226864,
    bit_b => sum_layer2_128226976_128227144_128227368,
    sum_sig => sum_layer3_128266192_128204984,
    carry_sig => carry_layer3_128266192_128204984
);

FA_128240328_128240272: FA 
PORT MAP (
    bit_a => sum_layer1_127629968_127824448,
    bit_b => carry_layer2_128225968_128226192_128226360,
    bit_c => carry_layer2_128226584_128226696_128226864,
    sum_sig => sum_layer3_128228320_128266024_128204872,
    carry_sig => carry_layer3_128228320_128266024_128204872
);

FA_128240440_128240496: FA 
PORT MAP (
    bit_a => carry_layer2_128226976_128227144_128227368,
    bit_b => sum_layer2_128226808_128227032_128227200,
    bit_c => sum_layer2_128227424_128227536_128227704,
    sum_sig => sum_layer3_128205040_128205208_128205320,
    carry_sig => carry_layer3_128205040_128205208_128205320
);

FA_128240664_128240608: FA 
PORT MAP (
    bit_a => sum_layer1_127851488_127628176_127630080,
    bit_b => carry_layer2_128226808_128227032_128227200,
    bit_c => carry_layer2_128227424_128227536_128227704,
    sum_sig => sum_layer3_128228824_128205152_128205376,
    carry_sig => carry_layer3_128228824_128205152_128205376
);

FA_128240776_128240832: FA 
PORT MAP (
    bit_a => carry_layer2_128227816_128227984_128228152,
    bit_b => sum_layer2_127824560_128227648_128227872,
    bit_c => sum_layer2_128228040_128228208_128228376,
    sum_sig => sum_layer3_128205544_128205712_128205824,
    carry_sig => carry_layer3_128205544_128205712_128205824
);

FA_128241000_128240944: FA 
PORT MAP (
    bit_a => carry_layer2_127824560_128227648_128227872,
    bit_b => carry_layer2_128228040_128228208_128228376,
    bit_c => carry_layer2_128228544_128228656_128228880,
    sum_sig => sum_layer3_128205656_128205880_128206048,
    carry_sig => carry_layer3_128205656_128205880_128206048
);

FA_128241112_128241168: FA 
PORT MAP (
    bit_a => sum_layer2_128228488_128228712_128228936,
    bit_b => sum_layer2_128229048_128229216_128229328,
    bit_c => sum_layer2_128254136_128254304,
    sum_sig => sum_layer3_128206216_128206328_128206496,
    carry_sig => carry_layer3_128206216_128206328_128206496
);

FA_128241336_128241280: FA 
PORT MAP (
    bit_a => carry_layer2_128228488_128228712_128228936,
    bit_b => carry_layer2_128229048_128229216_128229328,
    bit_c => carry_layer2_128254136_128254304,
    sum_sig => sum_layer3_128206160_128206384_128206552,
    carry_sig => carry_layer3_128206160_128206384_128206552
);

FA_128241448_128241504: FA 
PORT MAP (
    bit_a => sum_layer2_128229160_128254024_128254192,
    bit_b => sum_layer2_128254360_128254528_128254640,
    bit_c => sum_layer2_128254808_128254976,
    sum_sig => sum_layer3_128206720_128206832_128207000,
    carry_sig => carry_layer3_128206720_128206832_128207000
);

FA_128241616_128217160: FA 
PORT MAP (
    bit_a => carry_layer2_128229160_128254024_128254192,
    bit_b => carry_layer2_128254360_128254528_128254640,
    bit_c => carry_layer2_128254808_128254976,
    sum_sig => sum_layer3_128206664_128206888_128207056,
    carry_sig => carry_layer3_128206664_128206888_128207056
);

FA_128217272_128217328: FA 
PORT MAP (
    bit_a => sum_layer2_127824896_128254472_128254696,
    bit_b => sum_layer2_128254864_128255032_128255200,
    bit_c => sum_layer2_128255312_128255480,
    sum_sig => sum_layer3_128207224_128207336_128207504,
    carry_sig => carry_layer3_128207224_128207336_128207504
);

FA_128217496_128217440: FA 
PORT MAP (
    bit_a => carry_layer2_127824896_128254472_128254696,
    bit_b => carry_layer2_128254864_128255032_128255200,
    bit_c => carry_layer2_128255312_128255480,
    sum_sig => sum_layer3_128207168_128207392_128207560,
    carry_sig => carry_layer3_128207168_128207392_128207560
);

HA_128217608_128217664: HA 
PORT MAP (
    bit_a => sum_layer2_128255144_128255368_128255536,
    bit_b => sum_layer2_128255704_128255816_128255984,
    sum_sig => sum_layer3_128207728_128207840,
    carry_sig => carry_layer3_128207728_128207840
);

FA_128217888_128217832: FA 
PORT MAP (
    bit_a => carry_layer2_128255144_128255368_128255536,
    bit_b => carry_layer2_128255704_128255816_128255984,
    bit_c => sum_layer2_128255648_128255872_128256040,
    sum_sig => sum_layer3_128207672_128207896_128208064,
    carry_sig => carry_layer3_128207672_128207896_128208064
);

FA_128218056_128218000: FA 
PORT MAP (
    bit_a => carry_layer2_128255648_128255872_128256040,
    bit_b => carry_layer2_128256208_128256320_128256488,
    bit_c => sum_layer2_127825232_128256152_128256376,
    sum_sig => sum_layer3_128208008_128208232_128208400,
    carry_sig => carry_layer3_128208008_128208232_128208400
);

FA_128218224_128218168: FA 
PORT MAP (
    bit_a => sum_layer1_127628960_127630864_127825344,
    bit_b => carry_layer2_127825232_128256152_128256376,
    bit_c => carry_layer2_128256544_128256712_128256824,
    sum_sig => sum_layer3_128257160_128208344_128208568,
    carry_sig => carry_layer3_128257160_128208344_128208568
);

FA_128218336_128218280: FA 
PORT MAP (
    bit_a => sum_layer1_127630976_127825456,
    bit_b => carry_layer2_128256656_128256880_128257048,
    bit_c => sum_layer2_128256992_128257216_128257384,
    sum_sig => sum_layer3_128257496_128208736_128208848,
    carry_sig => carry_layer3_128257496_128208736_128208848
);

FA_128218504_128218448: FA 
PORT MAP (
    bit_a => sum_layer1_127852496_127629184_127631088,
    bit_b => carry_layer2_128256992_128257216_128257384,
    bit_c => sum_layer2_127825568_128257328_128257552,
    sum_sig => sum_layer3_128257776_128123008_128123176,
    carry_sig => carry_layer3_128257776_128123008_128123176
);

HA_128218672_128218616: HA 
PORT MAP (
    bit_a => carry_layer2_127825568_128257328_128257552,
    bit_b => sum_layer2_128257720_128257888,
    sum_sig => sum_layer3_128123120_128123288,
    carry_sig => carry_layer3_128123120_128123288
);

HA_128218840_128218784: HA 
PORT MAP (
    bit_a => carry_layer2_128257720_128257888,
    bit_b => sum_layer2_128257832_128258000,
    sum_sig => sum_layer3_128123232_128123456,
    carry_sig => carry_layer3_128123232_128123456
);

HA_128219008_128218952: HA 
PORT MAP (
    bit_a => carry_layer2_128257832_128258000,
    bit_b => sum_layer2_127825904_128245832,
    sum_sig => sum_layer3_128123400_128123624,
    carry_sig => carry_layer3_128123400_128123624
);

HA_128219176_128219120: HA 
PORT MAP (
    bit_a => carry_layer3_128246000_128246168,
    bit_b => sum_layer3_128246112_128246336,
    sum_sig => sum_layer4_128123792_128123960,
    carry_sig => carry_layer4_128123792_128123960
);

HA_128219344_128219288: HA 
PORT MAP (
    bit_a => carry_layer3_128246112_128246336,
    bit_b => sum_layer3_127827080_128246280_128246560,
    sum_sig => sum_layer4_128123904_128124128,
    carry_sig => carry_layer4_128123904_128124128
);

HA_128219512_128219456: HA 
PORT MAP (
    bit_a => carry_layer3_127827080_128246280_128246560,
    bit_b => sum_layer3_128246504_128246672_128246784,
    sum_sig => sum_layer4_128124072_128124296,
    carry_sig => carry_layer4_128124072_128124296
);

FA_128219680_128219624: FA 
PORT MAP (
    bit_a => sum_layer2_127827752_127827920,
    bit_b => carry_layer3_128246504_128246672_128246784,
    bit_c => sum_layer3_128246616_128246840_128247008,
    sum_sig => sum_layer4_128247120_128124240_128124520,
    carry_sig => carry_layer4_128247120_128124240_128124520
);

FA_128219848_128219792: FA 
PORT MAP (
    bit_a => sum_layer2_128221424_128221536_128221704,
    bit_b => carry_layer3_128246616_128246840_128247008,
    bit_c => sum_layer3_128246952_128247176_128247344,
    sum_sig => sum_layer4_128247456_128124464_128124688,
    carry_sig => carry_layer4_128247456_128124464_128124688
);

FA_128220016_128219960: FA 
PORT MAP (
    bit_a => carry_layer3_128246952_128247176_128247344,
    bit_b => sum_layer3_128222208_128247288_128247512,
    bit_c => sum_layer3_128247680_128247792,
    sum_sig => sum_layer4_128124632_128124800_128124912,
    carry_sig => carry_layer4_128124632_128124800_128124912
);

FA_128220240_128220184: FA 
PORT MAP (
    bit_a => carry_layer3_128222208_128247288_128247512,
    bit_b => carry_layer3_128247680_128247792,
    bit_c => sum_layer3_128222880_128247624_128247848,
    sum_sig => sum_layer4_128124744_128124968_128125136,
    carry_sig => carry_layer4_128124744_128124968_128125136
);

FA_128220408_128220352: FA 
PORT MAP (
    bit_a => carry_layer3_128222880_128247624_128247848,
    bit_b => carry_layer3_128248016_128248128,
    bit_c => sum_layer3_128247960_128248184_128248352,
    sum_sig => sum_layer4_128125080_128125304_128125472,
    carry_sig => carry_layer4_128125080_128125304_128125472
);

FA_128220576_128220520: FA 
PORT MAP (
    bit_a => carry_layer3_128247960_128248184_128248352,
    bit_b => carry_layer3_128248464_128248632,
    bit_c => sum_layer3_128248296_128248520_128248688,
    sum_sig => sum_layer4_128125416_128125640_128125808,
    carry_sig => carry_layer4_128125416_128125640_128125808
);

FA_128220744_128220688: FA 
PORT MAP (
    bit_a => carry_layer3_128248296_128248520_128248688,
    bit_b => carry_layer3_128248856_128248968_128249136,
    bit_c => sum_layer3_128248800_128249024_128249192,
    sum_sig => sum_layer4_128125752_128125976_128126144,
    carry_sig => carry_layer4_128125752_128125976_128126144
);

FA_128220856_128220800: FA 
PORT MAP (
    bit_a => sum_layer2_128196792_128196960_128197184,
    bit_b => carry_layer3_128248800_128249024_128249192,
    bit_c => carry_layer3_128249360_128249472_128249640,
    sum_sig => sum_layer4_128262496_128126088_128126312,
    carry_sig => carry_layer4_128262496_128126088_128126312
);

HA_128220968_128221024: HA 
PORT MAP (
    bit_a => sum_layer3_128197128_128249304_128249528,
    bit_b => sum_layer3_128249696_128249808_128262328,
    sum_sig => sum_layer4_128126480_128126592,
    carry_sig => carry_layer4_128126480_128126592
);

FA_128221136_128315464: FA 
PORT MAP (
    bit_a => sum_layer2_128198024_128197968,
    bit_b => carry_layer3_128197128_128249304_128249528,
    bit_c => carry_layer3_128249696_128249808_128262328,
    sum_sig => sum_layer4_128263168_128126424_128126648,
    carry_sig => carry_layer4_128263168_128126424_128126648
);

HA_128315576_128315632: HA 
PORT MAP (
    bit_a => sum_layer3_128262216_128262384_128262552,
    bit_b => sum_layer3_128262720_128262832_128263000,
    sum_sig => sum_layer4_128126816_128126928,
    carry_sig => carry_layer4_128126816_128126928
);

FA_128315800_128315744: FA 
PORT MAP (
    bit_a => carry_layer3_128262216_128262384_128262552,
    bit_b => carry_layer3_128262720_128262832_128263000,
    bit_c => sum_layer3_128262664_128262888_128263056,
    sum_sig => sum_layer4_128126760_128237640_128237808,
    carry_sig => carry_layer4_128126760_128237640_128237808
);

HA_128315912_128315968: HA 
PORT MAP (
    bit_a => sum_layer3_128263224_128263392_128263504,
    bit_b => sum_layer3_128263672_128263840,
    sum_sig => sum_layer4_128237920_128238088,
    carry_sig => carry_layer4_128237920_128238088
);

FA_128316136_128316080: FA 
PORT MAP (
    bit_a => carry_layer3_128262664_128262888_128263056,
    bit_b => carry_layer3_128263224_128263392_128263504,
    bit_c => carry_layer3_128263672_128263840,
    sum_sig => sum_layer4_128237752_128237976_128238144,
    carry_sig => carry_layer4_128237752_128237976_128238144
);

FA_128316248_128316304: FA 
PORT MAP (
    bit_a => sum_layer3_128263336_128263560_128263728,
    bit_b => sum_layer3_128263896_128264064_128264176,
    bit_c => sum_layer3_128264344_128264512,
    sum_sig => sum_layer4_128238312_128238424_128238592,
    carry_sig => carry_layer4_128238312_128238424_128238592
);

FA_128316472_128316416: FA 
PORT MAP (
    bit_a => carry_layer3_128263336_128263560_128263728,
    bit_b => carry_layer3_128263896_128264064_128264176,
    bit_c => carry_layer3_128264344_128264512,
    sum_sig => sum_layer4_128238256_128238480_128238648,
    carry_sig => carry_layer4_128238256_128238480_128238648
);

FA_128316584_128316640: FA 
PORT MAP (
    bit_a => sum_layer3_128264008_128264232_128264400,
    bit_b => sum_layer3_128264568_128264736_128264848,
    bit_c => sum_layer3_128265016_128265184,
    sum_sig => sum_layer4_128238816_128238928_128239096,
    carry_sig => carry_layer4_128238816_128238928_128239096
);

FA_128316808_128316752: FA 
PORT MAP (
    bit_a => carry_layer3_128264008_128264232_128264400,
    bit_b => carry_layer3_128264568_128264736_128264848,
    bit_c => carry_layer3_128265016_128265184,
    sum_sig => sum_layer4_128238760_128238984_128239152,
    carry_sig => carry_layer4_128238760_128238984_128239152
);

FA_128316920_128316976: FA 
PORT MAP (
    bit_a => sum_layer3_128264680_128264904_128265072,
    bit_b => sum_layer3_128265240_128265408_128265520,
    bit_c => sum_layer3_128265688_128265856,
    sum_sig => sum_layer4_128239320_128239432_128239600,
    carry_sig => carry_layer4_128239320_128239432_128239600
);

FA_128317144_128317088: FA 
PORT MAP (
    bit_a => carry_layer3_128264680_128264904_128265072,
    bit_b => carry_layer3_128265240_128265408_128265520,
    bit_c => carry_layer3_128265688_128265856,
    sum_sig => sum_layer4_128239264_128239488_128239656,
    carry_sig => carry_layer4_128239264_128239488_128239656
);

FA_128317256_128317312: FA 
PORT MAP (
    bit_a => sum_layer3_128227312_128265352_128265576,
    bit_b => sum_layer3_128265744_128265912_128266080,
    bit_c => sum_layer3_128266192_128204984,
    sum_sig => sum_layer4_128239824_128239936_128240104,
    carry_sig => carry_layer4_128239824_128239936_128240104
);

FA_128317480_128317424: FA 
PORT MAP (
    bit_a => sum_layer2_128227816_128227984_128228152,
    bit_b => carry_layer3_128227312_128265352_128265576,
    bit_c => carry_layer3_128265744_128265912_128266080,
    sum_sig => sum_layer4_128205488_128239768_128239992,
    carry_sig => carry_layer4_128205488_128239768_128239992
);

FA_128317592_128317648: FA 
PORT MAP (
    bit_a => carry_layer3_128266192_128204984,
    bit_b => sum_layer3_128228320_128266024_128204872,
    bit_c => sum_layer3_128205040_128205208_128205320,
    sum_sig => sum_layer4_128240160_128240328_128240440,
    carry_sig => carry_layer4_128240160_128240328_128240440
);

FA_128317816_128317760: FA 
PORT MAP (
    bit_a => sum_layer2_128228544_128228656_128228880,
    bit_b => carry_layer3_128228320_128266024_128204872,
    bit_c => carry_layer3_128205040_128205208_128205320,
    sum_sig => sum_layer4_128205992_128240272_128240496,
    carry_sig => carry_layer4_128205992_128240272_128240496
);

HA_128317928_128317984: HA 
PORT MAP (
    bit_a => sum_layer3_128228824_128205152_128205376,
    bit_b => sum_layer3_128205544_128205712_128205824,
    sum_sig => sum_layer4_128240664_128240776,
    carry_sig => carry_layer4_128240664_128240776
);

FA_128318208_128318152: FA 
PORT MAP (
    bit_a => carry_layer3_128228824_128205152_128205376,
    bit_b => carry_layer3_128205544_128205712_128205824,
    bit_c => sum_layer3_128205656_128205880_128206048,
    sum_sig => sum_layer4_128240608_128240832_128241000,
    carry_sig => carry_layer4_128240608_128240832_128241000
);

FA_128318376_128318320: FA 
PORT MAP (
    bit_a => carry_layer3_128205656_128205880_128206048,
    bit_b => carry_layer3_128206216_128206328_128206496,
    bit_c => sum_layer3_128206160_128206384_128206552,
    sum_sig => sum_layer4_128240944_128241168_128241336,
    carry_sig => carry_layer4_128240944_128241168_128241336
);

FA_128318544_128318488: FA 
PORT MAP (
    bit_a => carry_layer3_128206160_128206384_128206552,
    bit_b => carry_layer3_128206720_128206832_128207000,
    bit_c => sum_layer3_128206664_128206888_128207056,
    sum_sig => sum_layer4_128241280_128241504_128241616,
    carry_sig => carry_layer4_128241280_128241504_128241616
);

FA_128318712_128318656: FA 
PORT MAP (
    bit_a => carry_layer3_128206664_128206888_128207056,
    bit_b => carry_layer3_128207224_128207336_128207504,
    bit_c => sum_layer3_128207168_128207392_128207560,
    sum_sig => sum_layer4_128217160_128217328_128217496,
    carry_sig => carry_layer4_128217160_128217328_128217496
);

FA_128318880_128318824: FA 
PORT MAP (
    bit_a => sum_layer2_128256208_128256320_128256488,
    bit_b => carry_layer3_128207168_128207392_128207560,
    bit_c => carry_layer3_128207728_128207840,
    sum_sig => sum_layer4_128208176_128217440_128217664,
    carry_sig => carry_layer4_128208176_128217440_128217664
);

FA_128318992_128318936: FA 
PORT MAP (
    bit_a => sum_layer2_128256544_128256712_128256824,
    bit_b => carry_layer3_128207672_128207896_128208064,
    bit_c => sum_layer3_128208008_128208232_128208400,
    sum_sig => sum_layer4_128208512_128217832_128218056,
    carry_sig => carry_layer4_128208512_128217832_128218056
);

FA_128319160_128319104: FA 
PORT MAP (
    bit_a => sum_layer2_128256656_128256880_128257048,
    bit_b => carry_layer3_128208008_128208232_128208400,
    bit_c => sum_layer3_128257160_128208344_128208568,
    sum_sig => sum_layer4_128208792_128218000_128218224,
    carry_sig => carry_layer4_128208792_128218000_128218224
);

HA_128319328_128319272: HA 
PORT MAP (
    bit_a => carry_layer3_128257160_128208344_128208568,
    bit_b => sum_layer3_128257496_128208736_128208848,
    sum_sig => sum_layer4_128218168_128218336,
    carry_sig => carry_layer4_128218168_128218336
);

HA_128319440_128331848: HA 
PORT MAP (
    bit_a => carry_layer3_128257496_128208736_128208848,
    bit_b => sum_layer3_128257776_128123008_128123176,
    sum_sig => sum_layer4_128218280_128218504,
    carry_sig => carry_layer4_128218280_128218504
);

HA_128332016_128331960: HA 
PORT MAP (
    bit_a => carry_layer3_128257776_128123008_128123176,
    bit_b => sum_layer3_128123120_128123288,
    sum_sig => sum_layer4_128218448_128218672,
    carry_sig => carry_layer4_128218448_128218672
);

HA_128332184_128332128: HA 
PORT MAP (
    bit_a => carry_layer3_128123120_128123288,
    bit_b => sum_layer3_128123232_128123456,
    sum_sig => sum_layer4_128218616_128218840,
    carry_sig => carry_layer4_128218616_128218840
);

HA_128332352_128332296: HA 
PORT MAP (
    bit_a => carry_layer3_128123232_128123456,
    bit_b => sum_layer3_128123400_128123624,
    sum_sig => sum_layer4_128218784_128219008,
    carry_sig => carry_layer4_128218784_128219008
);

HA_128332520_128332464: HA 
PORT MAP (
    bit_a => carry_layer2_127825904_128245832,
    bit_b => carry_layer3_128123400_128123624,
    sum_sig => sum_layer4_128123568_128218952,
    carry_sig => carry_layer4_128123568_128218952
);

HA_128332688_128332632: HA 
PORT MAP (
    bit_a => carry_layer4_128123792_128123960,
    bit_b => sum_layer4_128123904_128124128,
    sum_sig => sum_layer5_128219120_128219344,
    carry_sig => carry_layer5_128219120_128219344
);

HA_128332856_128332800: HA 
PORT MAP (
    bit_a => carry_layer4_128123904_128124128,
    bit_b => sum_layer4_128124072_128124296,
    sum_sig => sum_layer5_128219288_128219512,
    carry_sig => carry_layer5_128219288_128219512
);

HA_128333024_128332968: HA 
PORT MAP (
    bit_a => carry_layer4_128124072_128124296,
    bit_b => sum_layer4_128247120_128124240_128124520,
    sum_sig => sum_layer5_128219456_128219680,
    carry_sig => carry_layer5_128219456_128219680
);

HA_128333192_128333136: HA 
PORT MAP (
    bit_a => carry_layer4_128247120_128124240_128124520,
    bit_b => sum_layer4_128247456_128124464_128124688,
    sum_sig => sum_layer5_128219624_128219848,
    carry_sig => carry_layer5_128219624_128219848
);

HA_128333360_128333304: HA 
PORT MAP (
    bit_a => carry_layer4_128247456_128124464_128124688,
    bit_b => sum_layer4_128124632_128124800_128124912,
    sum_sig => sum_layer5_128219792_128220016,
    carry_sig => carry_layer5_128219792_128220016
);

FA_128333528_128333472: FA 
PORT MAP (
    bit_a => sum_layer3_128248016_128248128,
    bit_b => carry_layer4_128124632_128124800_128124912,
    bit_c => sum_layer4_128124744_128124968_128125136,
    sum_sig => sum_layer5_128125248_128219960_128220240,
    carry_sig => carry_layer5_128125248_128219960_128220240
);

FA_128333696_128333640: FA 
PORT MAP (
    bit_a => sum_layer3_128248464_128248632,
    bit_b => carry_layer4_128124744_128124968_128125136,
    bit_c => sum_layer4_128125080_128125304_128125472,
    sum_sig => sum_layer5_128125584_128220184_128220408,
    carry_sig => carry_layer5_128125584_128220184_128220408
);

FA_128333864_128333808: FA 
PORT MAP (
    bit_a => sum_layer3_128248856_128248968_128249136,
    bit_b => carry_layer4_128125080_128125304_128125472,
    bit_c => sum_layer4_128125416_128125640_128125808,
    sum_sig => sum_layer5_128125920_128220352_128220576,
    carry_sig => carry_layer5_128125920_128220352_128220576
);

FA_128334032_128333976: FA 
PORT MAP (
    bit_a => sum_layer3_128249360_128249472_128249640,
    bit_b => carry_layer4_128125416_128125640_128125808,
    bit_c => sum_layer4_128125752_128125976_128126144,
    sum_sig => sum_layer5_128126256_128220520_128220744,
    carry_sig => carry_layer5_128126256_128220520_128220744
);

FA_128334200_128334144: FA 
PORT MAP (
    bit_a => carry_layer4_128125752_128125976_128126144,
    bit_b => sum_layer4_128262496_128126088_128126312,
    bit_c => sum_layer4_128126480_128126592,
    sum_sig => sum_layer5_128220688_128220856_128220968,
    carry_sig => carry_layer5_128220688_128220856_128220968
);

FA_128334424_128334368: FA 
PORT MAP (
    bit_a => carry_layer4_128262496_128126088_128126312,
    bit_b => carry_layer4_128126480_128126592,
    bit_c => sum_layer4_128263168_128126424_128126648,
    sum_sig => sum_layer5_128220800_128221024_128221136,
    carry_sig => carry_layer5_128220800_128221024_128221136
);

FA_128334592_128334536: FA 
PORT MAP (
    bit_a => carry_layer4_128263168_128126424_128126648,
    bit_b => carry_layer4_128126816_128126928,
    bit_c => sum_layer4_128126760_128237640_128237808,
    sum_sig => sum_layer5_128315464_128315632_128315800,
    carry_sig => carry_layer5_128315464_128315632_128315800
);

FA_128334760_128334704: FA 
PORT MAP (
    bit_a => carry_layer4_128126760_128237640_128237808,
    bit_b => carry_layer4_128237920_128238088,
    bit_c => sum_layer4_128237752_128237976_128238144,
    sum_sig => sum_layer5_128315744_128315968_128316136,
    carry_sig => carry_layer5_128315744_128315968_128316136
);

FA_128334928_128334872: FA 
PORT MAP (
    bit_a => carry_layer4_128237752_128237976_128238144,
    bit_b => carry_layer4_128238312_128238424_128238592,
    bit_c => sum_layer4_128238256_128238480_128238648,
    sum_sig => sum_layer5_128316080_128316304_128316472,
    carry_sig => carry_layer5_128316080_128316304_128316472
);

FA_128335096_128335040: FA 
PORT MAP (
    bit_a => carry_layer4_128238256_128238480_128238648,
    bit_b => carry_layer4_128238816_128238928_128239096,
    bit_c => sum_layer4_128238760_128238984_128239152,
    sum_sig => sum_layer5_128316416_128316640_128316808,
    carry_sig => carry_layer5_128316416_128316640_128316808
);

FA_128335264_128335208: FA 
PORT MAP (
    bit_a => carry_layer4_128238760_128238984_128239152,
    bit_b => carry_layer4_128239320_128239432_128239600,
    bit_c => sum_layer4_128239264_128239488_128239656,
    sum_sig => sum_layer5_128316752_128316976_128317144,
    carry_sig => carry_layer5_128316752_128316976_128317144
);

FA_128335432_128335376: FA 
PORT MAP (
    bit_a => carry_layer4_128239264_128239488_128239656,
    bit_b => carry_layer4_128239824_128239936_128240104,
    bit_c => sum_layer4_128205488_128239768_128239992,
    sum_sig => sum_layer5_128317088_128317312_128317480,
    carry_sig => carry_layer5_128317088_128317312_128317480
);

FA_128335600_128335544: FA 
PORT MAP (
    bit_a => carry_layer4_128205488_128239768_128239992,
    bit_b => carry_layer4_128240160_128240328_128240440,
    bit_c => sum_layer4_128205992_128240272_128240496,
    sum_sig => sum_layer5_128317424_128317648_128317816,
    carry_sig => carry_layer5_128317424_128317648_128317816
);

FA_128335768_128335712: FA 
PORT MAP (
    bit_a => sum_layer3_128206216_128206328_128206496,
    bit_b => carry_layer4_128205992_128240272_128240496,
    bit_c => carry_layer4_128240664_128240776,
    sum_sig => sum_layer5_128241112_128317760_128317984,
    carry_sig => carry_layer5_128241112_128317760_128317984
);

FA_128335824_128344136: FA 
PORT MAP (
    bit_a => sum_layer3_128206720_128206832_128207000,
    bit_b => carry_layer4_128240608_128240832_128241000,
    bit_c => sum_layer4_128240944_128241168_128241336,
    sum_sig => sum_layer5_128241448_128318152_128318376,
    carry_sig => carry_layer5_128241448_128318152_128318376
);

FA_128344304_128344248: FA 
PORT MAP (
    bit_a => sum_layer3_128207224_128207336_128207504,
    bit_b => carry_layer4_128240944_128241168_128241336,
    bit_c => sum_layer4_128241280_128241504_128241616,
    sum_sig => sum_layer5_128217272_128318320_128318544,
    carry_sig => carry_layer5_128217272_128318320_128318544
);

FA_128344472_128344416: FA 
PORT MAP (
    bit_a => sum_layer3_128207728_128207840,
    bit_b => carry_layer4_128241280_128241504_128241616,
    bit_c => sum_layer4_128217160_128217328_128217496,
    sum_sig => sum_layer5_128217608_128318488_128318712,
    carry_sig => carry_layer5_128217608_128318488_128318712
);

FA_128344640_128344584: FA 
PORT MAP (
    bit_a => sum_layer3_128207672_128207896_128208064,
    bit_b => carry_layer4_128217160_128217328_128217496,
    bit_c => sum_layer4_128208176_128217440_128217664,
    sum_sig => sum_layer5_128217888_128318656_128318880,
    carry_sig => carry_layer5_128217888_128318656_128318880
);

HA_128344808_128344752: HA 
PORT MAP (
    bit_a => carry_layer4_128208176_128217440_128217664,
    bit_b => sum_layer4_128208512_128217832_128218056,
    sum_sig => sum_layer5_128318824_128318992,
    carry_sig => carry_layer5_128318824_128318992
);

HA_128344976_128344920: HA 
PORT MAP (
    bit_a => carry_layer4_128208512_128217832_128218056,
    bit_b => sum_layer4_128208792_128218000_128218224,
    sum_sig => sum_layer5_128318936_128319160,
    carry_sig => carry_layer5_128318936_128319160
);

HA_128345144_128345088: HA 
PORT MAP (
    bit_a => carry_layer4_128208792_128218000_128218224,
    bit_b => sum_layer4_128218168_128218336,
    sum_sig => sum_layer5_128319104_128319328,
    carry_sig => carry_layer5_128319104_128319328
);

HA_128345312_128345256: HA 
PORT MAP (
    bit_a => carry_layer4_128218168_128218336,
    bit_b => sum_layer4_128218280_128218504,
    sum_sig => sum_layer5_128319272_128319440,
    carry_sig => carry_layer5_128319272_128319440
);

HA_128345480_128345424: HA 
PORT MAP (
    bit_a => carry_layer4_128218280_128218504,
    bit_b => sum_layer4_128218448_128218672,
    sum_sig => sum_layer5_128331848_128332016,
    carry_sig => carry_layer5_128331848_128332016
);

HA_128345648_128345592: HA 
PORT MAP (
    bit_a => carry_layer4_128218448_128218672,
    bit_b => sum_layer4_128218616_128218840,
    sum_sig => sum_layer5_128331960_128332184,
    carry_sig => carry_layer5_128331960_128332184
);

HA_128345816_128345760: HA 
PORT MAP (
    bit_a => carry_layer4_128218616_128218840,
    bit_b => sum_layer4_128218784_128219008,
    sum_sig => sum_layer5_128332128_128332352,
    carry_sig => carry_layer5_128332128_128332352
);

HA_128345984_128345928: HA 
PORT MAP (
    bit_a => carry_layer4_128218784_128219008,
    bit_b => sum_layer4_128123568_128218952,
    sum_sig => sum_layer5_128332296_128332520,
    carry_sig => carry_layer5_128332296_128332520
);

HA_128346096_128346152: HA 
PORT MAP (
    bit_a => carry_layer5_128219120_128219344,
    bit_b => sum_layer5_128219288_128219512,
    sum_sig => sum_layer6_128332632_128332856,
    carry_sig => carry_layer6_128332632_128332856
);

HA_128346320_128346264: HA 
PORT MAP (
    bit_a => carry_layer5_128219288_128219512,
    bit_b => sum_layer5_128219456_128219680,
    sum_sig => sum_layer6_128332800_128333024,
    carry_sig => carry_layer6_128332800_128333024
);

HA_128346488_128346432: HA 
PORT MAP (
    bit_a => carry_layer5_128219456_128219680,
    bit_b => sum_layer5_128219624_128219848,
    sum_sig => sum_layer6_128332968_128333192,
    carry_sig => carry_layer6_128332968_128333192
);

HA_128346656_128346600: HA 
PORT MAP (
    bit_a => carry_layer5_128219624_128219848,
    bit_b => sum_layer5_128219792_128220016,
    sum_sig => sum_layer6_128333136_128333360,
    carry_sig => carry_layer6_128333136_128333360
);

HA_128346824_128346768: HA 
PORT MAP (
    bit_a => carry_layer5_128219792_128220016,
    bit_b => sum_layer5_128125248_128219960_128220240,
    sum_sig => sum_layer6_128333304_128333528,
    carry_sig => carry_layer6_128333304_128333528
);

HA_128346992_128346936: HA 
PORT MAP (
    bit_a => carry_layer5_128125248_128219960_128220240,
    bit_b => sum_layer5_128125584_128220184_128220408,
    sum_sig => sum_layer6_128333472_128333696,
    carry_sig => carry_layer6_128333472_128333696
);

HA_128347160_128347104: HA 
PORT MAP (
    bit_a => carry_layer5_128125584_128220184_128220408,
    bit_b => sum_layer5_128125920_128220352_128220576,
    sum_sig => sum_layer6_128333640_128333864,
    carry_sig => carry_layer6_128333640_128333864
);

HA_128347328_128347272: HA 
PORT MAP (
    bit_a => carry_layer5_128125920_128220352_128220576,
    bit_b => sum_layer5_128126256_128220520_128220744,
    sum_sig => sum_layer6_128333808_128334032,
    carry_sig => carry_layer6_128333808_128334032
);

HA_128347496_128347440: HA 
PORT MAP (
    bit_a => carry_layer5_128126256_128220520_128220744,
    bit_b => sum_layer5_128220688_128220856_128220968,
    sum_sig => sum_layer6_128333976_128334200,
    carry_sig => carry_layer6_128333976_128334200
);

FA_128347664_128347608: FA 
PORT MAP (
    bit_a => sum_layer4_128126816_128126928,
    bit_b => carry_layer5_128220688_128220856_128220968,
    bit_c => sum_layer5_128220800_128221024_128221136,
    sum_sig => sum_layer6_128315576_128334144_128334424,
    carry_sig => carry_layer6_128315576_128334144_128334424
);

FA_128347832_128347776: FA 
PORT MAP (
    bit_a => sum_layer4_128237920_128238088,
    bit_b => carry_layer5_128220800_128221024_128221136,
    bit_c => sum_layer5_128315464_128315632_128315800,
    sum_sig => sum_layer6_128315912_128334368_128334592,
    carry_sig => carry_layer6_128315912_128334368_128334592
);

FA_128348000_128347944: FA 
PORT MAP (
    bit_a => sum_layer4_128238312_128238424_128238592,
    bit_b => carry_layer5_128315464_128315632_128315800,
    bit_c => sum_layer5_128315744_128315968_128316136,
    sum_sig => sum_layer6_128316248_128334536_128334760,
    carry_sig => carry_layer6_128316248_128334536_128334760
);

FA_128348112_128372808: FA 
PORT MAP (
    bit_a => sum_layer4_128238816_128238928_128239096,
    bit_b => carry_layer5_128315744_128315968_128316136,
    bit_c => sum_layer5_128316080_128316304_128316472,
    sum_sig => sum_layer6_128316584_128334704_128334928,
    carry_sig => carry_layer6_128316584_128334704_128334928
);

FA_128372976_128372920: FA 
PORT MAP (
    bit_a => sum_layer4_128239320_128239432_128239600,
    bit_b => carry_layer5_128316080_128316304_128316472,
    bit_c => sum_layer5_128316416_128316640_128316808,
    sum_sig => sum_layer6_128316920_128334872_128335096,
    carry_sig => carry_layer6_128316920_128334872_128335096
);

FA_128373144_128373088: FA 
PORT MAP (
    bit_a => sum_layer4_128239824_128239936_128240104,
    bit_b => carry_layer5_128316416_128316640_128316808,
    bit_c => sum_layer5_128316752_128316976_128317144,
    sum_sig => sum_layer6_128317256_128335040_128335264,
    carry_sig => carry_layer6_128317256_128335040_128335264
);

FA_128373312_128373256: FA 
PORT MAP (
    bit_a => sum_layer4_128240160_128240328_128240440,
    bit_b => carry_layer5_128316752_128316976_128317144,
    bit_c => sum_layer5_128317088_128317312_128317480,
    sum_sig => sum_layer6_128317592_128335208_128335432,
    carry_sig => carry_layer6_128317592_128335208_128335432
);

FA_128373480_128373424: FA 
PORT MAP (
    bit_a => sum_layer4_128240664_128240776,
    bit_b => carry_layer5_128317088_128317312_128317480,
    bit_c => sum_layer5_128317424_128317648_128317816,
    sum_sig => sum_layer6_128317928_128335376_128335600,
    carry_sig => carry_layer6_128317928_128335376_128335600
);

FA_128373648_128373592: FA 
PORT MAP (
    bit_a => sum_layer4_128240608_128240832_128241000,
    bit_b => carry_layer5_128317424_128317648_128317816,
    bit_c => sum_layer5_128241112_128317760_128317984,
    sum_sig => sum_layer6_128318208_128335544_128335768,
    carry_sig => carry_layer6_128318208_128335544_128335768
);

HA_128373816_128373760: HA 
PORT MAP (
    bit_a => carry_layer5_128241112_128317760_128317984,
    bit_b => sum_layer5_128241448_128318152_128318376,
    sum_sig => sum_layer6_128335712_128335824,
    carry_sig => carry_layer6_128335712_128335824
);

HA_128373984_128373928: HA 
PORT MAP (
    bit_a => carry_layer5_128241448_128318152_128318376,
    bit_b => sum_layer5_128217272_128318320_128318544,
    sum_sig => sum_layer6_128344136_128344304,
    carry_sig => carry_layer6_128344136_128344304
);

HA_128374152_128374096: HA 
PORT MAP (
    bit_a => carry_layer5_128217272_128318320_128318544,
    bit_b => sum_layer5_128217608_128318488_128318712,
    sum_sig => sum_layer6_128344248_128344472,
    carry_sig => carry_layer6_128344248_128344472
);

HA_128374320_128374264: HA 
PORT MAP (
    bit_a => carry_layer5_128217608_128318488_128318712,
    bit_b => sum_layer5_128217888_128318656_128318880,
    sum_sig => sum_layer6_128344416_128344640,
    carry_sig => carry_layer6_128344416_128344640
);

HA_128374488_128374432: HA 
PORT MAP (
    bit_a => carry_layer5_128217888_128318656_128318880,
    bit_b => sum_layer5_128318824_128318992,
    sum_sig => sum_layer6_128344584_128344808,
    carry_sig => carry_layer6_128344584_128344808
);

HA_128374656_128374600: HA 
PORT MAP (
    bit_a => carry_layer5_128318824_128318992,
    bit_b => sum_layer5_128318936_128319160,
    sum_sig => sum_layer6_128344752_128344976,
    carry_sig => carry_layer6_128344752_128344976
);

HA_128374824_128374768: HA 
PORT MAP (
    bit_a => carry_layer5_128318936_128319160,
    bit_b => sum_layer5_128319104_128319328,
    sum_sig => sum_layer6_128344920_128345144,
    carry_sig => carry_layer6_128344920_128345144
);

HA_128374992_128374936: HA 
PORT MAP (
    bit_a => carry_layer5_128319104_128319328,
    bit_b => sum_layer5_128319272_128319440,
    sum_sig => sum_layer6_128345088_128345312,
    carry_sig => carry_layer6_128345088_128345312
);

HA_128375160_128375104: HA 
PORT MAP (
    bit_a => carry_layer5_128319272_128319440,
    bit_b => sum_layer5_128331848_128332016,
    sum_sig => sum_layer6_128345256_128345480,
    carry_sig => carry_layer6_128345256_128345480
);

HA_128375328_128375272: HA 
PORT MAP (
    bit_a => carry_layer5_128331848_128332016,
    bit_b => sum_layer5_128331960_128332184,
    sum_sig => sum_layer6_128345424_128345648,
    carry_sig => carry_layer6_128345424_128345648
);

HA_128375496_128375440: HA 
PORT MAP (
    bit_a => carry_layer5_128331960_128332184,
    bit_b => sum_layer5_128332128_128332352,
    sum_sig => sum_layer6_128345592_128345816,
    carry_sig => carry_layer6_128345592_128345816
);

HA_128375664_128375608: HA 
PORT MAP (
    bit_a => carry_layer5_128332128_128332352,
    bit_b => sum_layer5_128332296_128332520,
    sum_sig => sum_layer6_128345760_128345984,
    carry_sig => carry_layer6_128345760_128345984
);

HA_128375832_128375776: HA 
PORT MAP (
    bit_a => carry_layer4_128123568_128218952,
    bit_b => carry_layer5_128332296_128332520,
    sum_sig => sum_layer6_128332464_128345928,
    carry_sig => carry_layer6_128332464_128345928
);

Adder_final: signed_adder 
GENERIC MAP (
    SIGNAL_LENGTH => 324
)
PORT MAP (
    input_A => first_vector,
    input_B => second_vector,
    clk     => clk,
    reset   => reset,
    en      => en,
    output  => output_vector
);

a0_and_b0 <= input_a(0) and input_b(0);
a0_and_b1 <= input_a(0) and input_b(1);
a0_and_b2 <= input_a(0) and input_b(2);
a0_and_b3 <= input_a(0) and input_b(3);
a0_and_b4 <= input_a(0) and input_b(4);
a0_and_b5 <= input_a(0) and input_b(5);
a0_and_b6 <= input_a(0) and input_b(6);
a0_and_b7 <= input_a(0) and input_b(7);
a0_and_b8 <= input_a(0) and input_b(8);
a0_and_b9 <= input_a(0) and input_b(9);
a0_and_b10 <= input_a(0) and input_b(10);
a0_and_b11 <= input_a(0) and input_b(11);
a0_and_b12 <= input_a(0) and input_b(12);
a0_and_b13 <= input_a(0) and input_b(13);
a0_and_b14 <= input_a(0) and input_b(14);
a0_and_b15 <= input_a(0) and input_b(15);
a0_and_b16 <= input_a(0) and input_b(16);
a0_and_b17 <= input_a(0) and input_b(17);
a1_and_b0 <= input_a(1) and input_b(0);
a1_and_b1 <= input_a(1) and input_b(1);
a1_and_b2 <= input_a(1) and input_b(2);
a1_and_b3 <= input_a(1) and input_b(3);
a1_and_b4 <= input_a(1) and input_b(4);
a1_and_b5 <= input_a(1) and input_b(5);
a1_and_b6 <= input_a(1) and input_b(6);
a1_and_b7 <= input_a(1) and input_b(7);
a1_and_b8 <= input_a(1) and input_b(8);
a1_and_b9 <= input_a(1) and input_b(9);
a1_and_b10 <= input_a(1) and input_b(10);
a1_and_b11 <= input_a(1) and input_b(11);
a1_and_b12 <= input_a(1) and input_b(12);
a1_and_b13 <= input_a(1) and input_b(13);
a1_and_b14 <= input_a(1) and input_b(14);
a1_and_b15 <= input_a(1) and input_b(15);
a1_and_b16 <= input_a(1) and input_b(16);
a1_and_b17 <= input_a(1) and input_b(17);
a2_and_b0 <= input_a(2) and input_b(0);
a2_and_b1 <= input_a(2) and input_b(1);
a2_and_b2 <= input_a(2) and input_b(2);
a2_and_b3 <= input_a(2) and input_b(3);
a2_and_b4 <= input_a(2) and input_b(4);
a2_and_b5 <= input_a(2) and input_b(5);
a2_and_b6 <= input_a(2) and input_b(6);
a2_and_b7 <= input_a(2) and input_b(7);
a2_and_b8 <= input_a(2) and input_b(8);
a2_and_b9 <= input_a(2) and input_b(9);
a2_and_b10 <= input_a(2) and input_b(10);
a2_and_b11 <= input_a(2) and input_b(11);
a2_and_b12 <= input_a(2) and input_b(12);
a2_and_b13 <= input_a(2) and input_b(13);
a2_and_b14 <= input_a(2) and input_b(14);
a2_and_b15 <= input_a(2) and input_b(15);
a2_and_b16 <= input_a(2) and input_b(16);
a2_and_b17 <= input_a(2) and input_b(17);
a3_and_b0 <= input_a(3) and input_b(0);
a3_and_b1 <= input_a(3) and input_b(1);
a3_and_b2 <= input_a(3) and input_b(2);
a3_and_b3 <= input_a(3) and input_b(3);
a3_and_b4 <= input_a(3) and input_b(4);
a3_and_b5 <= input_a(3) and input_b(5);
a3_and_b6 <= input_a(3) and input_b(6);
a3_and_b7 <= input_a(3) and input_b(7);
a3_and_b8 <= input_a(3) and input_b(8);
a3_and_b9 <= input_a(3) and input_b(9);
a3_and_b10 <= input_a(3) and input_b(10);
a3_and_b11 <= input_a(3) and input_b(11);
a3_and_b12 <= input_a(3) and input_b(12);
a3_and_b13 <= input_a(3) and input_b(13);
a3_and_b14 <= input_a(3) and input_b(14);
a3_and_b15 <= input_a(3) and input_b(15);
a3_and_b16 <= input_a(3) and input_b(16);
a3_and_b17 <= input_a(3) and input_b(17);
a4_and_b0 <= input_a(4) and input_b(0);
a4_and_b1 <= input_a(4) and input_b(1);
a4_and_b2 <= input_a(4) and input_b(2);
a4_and_b3 <= input_a(4) and input_b(3);
a4_and_b4 <= input_a(4) and input_b(4);
a4_and_b5 <= input_a(4) and input_b(5);
a4_and_b6 <= input_a(4) and input_b(6);
a4_and_b7 <= input_a(4) and input_b(7);
a4_and_b8 <= input_a(4) and input_b(8);
a4_and_b9 <= input_a(4) and input_b(9);
a4_and_b10 <= input_a(4) and input_b(10);
a4_and_b11 <= input_a(4) and input_b(11);
a4_and_b12 <= input_a(4) and input_b(12);
a4_and_b13 <= input_a(4) and input_b(13);
a4_and_b14 <= input_a(4) and input_b(14);
a4_and_b15 <= input_a(4) and input_b(15);
a4_and_b16 <= input_a(4) and input_b(16);
a4_and_b17 <= input_a(4) and input_b(17);
a5_and_b0 <= input_a(5) and input_b(0);
a5_and_b1 <= input_a(5) and input_b(1);
a5_and_b2 <= input_a(5) and input_b(2);
a5_and_b3 <= input_a(5) and input_b(3);
a5_and_b4 <= input_a(5) and input_b(4);
a5_and_b5 <= input_a(5) and input_b(5);
a5_and_b6 <= input_a(5) and input_b(6);
a5_and_b7 <= input_a(5) and input_b(7);
a5_and_b8 <= input_a(5) and input_b(8);
a5_and_b9 <= input_a(5) and input_b(9);
a5_and_b10 <= input_a(5) and input_b(10);
a5_and_b11 <= input_a(5) and input_b(11);
a5_and_b12 <= input_a(5) and input_b(12);
a5_and_b13 <= input_a(5) and input_b(13);
a5_and_b14 <= input_a(5) and input_b(14);
a5_and_b15 <= input_a(5) and input_b(15);
a5_and_b16 <= input_a(5) and input_b(16);
a5_and_b17 <= input_a(5) and input_b(17);
a6_and_b0 <= input_a(6) and input_b(0);
a6_and_b1 <= input_a(6) and input_b(1);
a6_and_b2 <= input_a(6) and input_b(2);
a6_and_b3 <= input_a(6) and input_b(3);
a6_and_b4 <= input_a(6) and input_b(4);
a6_and_b5 <= input_a(6) and input_b(5);
a6_and_b6 <= input_a(6) and input_b(6);
a6_and_b7 <= input_a(6) and input_b(7);
a6_and_b8 <= input_a(6) and input_b(8);
a6_and_b9 <= input_a(6) and input_b(9);
a6_and_b10 <= input_a(6) and input_b(10);
a6_and_b11 <= input_a(6) and input_b(11);
a6_and_b12 <= input_a(6) and input_b(12);
a6_and_b13 <= input_a(6) and input_b(13);
a6_and_b14 <= input_a(6) and input_b(14);
a6_and_b15 <= input_a(6) and input_b(15);
a6_and_b16 <= input_a(6) and input_b(16);
a6_and_b17 <= input_a(6) and input_b(17);
a7_and_b0 <= input_a(7) and input_b(0);
a7_and_b1 <= input_a(7) and input_b(1);
a7_and_b2 <= input_a(7) and input_b(2);
a7_and_b3 <= input_a(7) and input_b(3);
a7_and_b4 <= input_a(7) and input_b(4);
a7_and_b5 <= input_a(7) and input_b(5);
a7_and_b6 <= input_a(7) and input_b(6);
a7_and_b7 <= input_a(7) and input_b(7);
a7_and_b8 <= input_a(7) and input_b(8);
a7_and_b9 <= input_a(7) and input_b(9);
a7_and_b10 <= input_a(7) and input_b(10);
a7_and_b11 <= input_a(7) and input_b(11);
a7_and_b12 <= input_a(7) and input_b(12);
a7_and_b13 <= input_a(7) and input_b(13);
a7_and_b14 <= input_a(7) and input_b(14);
a7_and_b15 <= input_a(7) and input_b(15);
a7_and_b16 <= input_a(7) and input_b(16);
a7_and_b17 <= input_a(7) and input_b(17);
a8_and_b0 <= input_a(8) and input_b(0);
a8_and_b1 <= input_a(8) and input_b(1);
a8_and_b2 <= input_a(8) and input_b(2);
a8_and_b3 <= input_a(8) and input_b(3);
a8_and_b4 <= input_a(8) and input_b(4);
a8_and_b5 <= input_a(8) and input_b(5);
a8_and_b6 <= input_a(8) and input_b(6);
a8_and_b7 <= input_a(8) and input_b(7);
a8_and_b8 <= input_a(8) and input_b(8);
a8_and_b9 <= input_a(8) and input_b(9);
a8_and_b10 <= input_a(8) and input_b(10);
a8_and_b11 <= input_a(8) and input_b(11);
a8_and_b12 <= input_a(8) and input_b(12);
a8_and_b13 <= input_a(8) and input_b(13);
a8_and_b14 <= input_a(8) and input_b(14);
a8_and_b15 <= input_a(8) and input_b(15);
a8_and_b16 <= input_a(8) and input_b(16);
a8_and_b17 <= input_a(8) and input_b(17);
a9_and_b0 <= input_a(9) and input_b(0);
a9_and_b1 <= input_a(9) and input_b(1);
a9_and_b2 <= input_a(9) and input_b(2);
a9_and_b3 <= input_a(9) and input_b(3);
a9_and_b4 <= input_a(9) and input_b(4);
a9_and_b5 <= input_a(9) and input_b(5);
a9_and_b6 <= input_a(9) and input_b(6);
a9_and_b7 <= input_a(9) and input_b(7);
a9_and_b8 <= input_a(9) and input_b(8);
a9_and_b9 <= input_a(9) and input_b(9);
a9_and_b10 <= input_a(9) and input_b(10);
a9_and_b11 <= input_a(9) and input_b(11);
a9_and_b12 <= input_a(9) and input_b(12);
a9_and_b13 <= input_a(9) and input_b(13);
a9_and_b14 <= input_a(9) and input_b(14);
a9_and_b15 <= input_a(9) and input_b(15);
a9_and_b16 <= input_a(9) and input_b(16);
a9_and_b17 <= input_a(9) and input_b(17);
a10_and_b0 <= input_a(10) and input_b(0);
a10_and_b1 <= input_a(10) and input_b(1);
a10_and_b2 <= input_a(10) and input_b(2);
a10_and_b3 <= input_a(10) and input_b(3);
a10_and_b4 <= input_a(10) and input_b(4);
a10_and_b5 <= input_a(10) and input_b(5);
a10_and_b6 <= input_a(10) and input_b(6);
a10_and_b7 <= input_a(10) and input_b(7);
a10_and_b8 <= input_a(10) and input_b(8);
a10_and_b9 <= input_a(10) and input_b(9);
a10_and_b10 <= input_a(10) and input_b(10);
a10_and_b11 <= input_a(10) and input_b(11);
a10_and_b12 <= input_a(10) and input_b(12);
a10_and_b13 <= input_a(10) and input_b(13);
a10_and_b14 <= input_a(10) and input_b(14);
a10_and_b15 <= input_a(10) and input_b(15);
a10_and_b16 <= input_a(10) and input_b(16);
a10_and_b17 <= input_a(10) and input_b(17);
a11_and_b0 <= input_a(11) and input_b(0);
a11_and_b1 <= input_a(11) and input_b(1);
a11_and_b2 <= input_a(11) and input_b(2);
a11_and_b3 <= input_a(11) and input_b(3);
a11_and_b4 <= input_a(11) and input_b(4);
a11_and_b5 <= input_a(11) and input_b(5);
a11_and_b6 <= input_a(11) and input_b(6);
a11_and_b7 <= input_a(11) and input_b(7);
a11_and_b8 <= input_a(11) and input_b(8);
a11_and_b9 <= input_a(11) and input_b(9);
a11_and_b10 <= input_a(11) and input_b(10);
a11_and_b11 <= input_a(11) and input_b(11);
a11_and_b12 <= input_a(11) and input_b(12);
a11_and_b13 <= input_a(11) and input_b(13);
a11_and_b14 <= input_a(11) and input_b(14);
a11_and_b15 <= input_a(11) and input_b(15);
a11_and_b16 <= input_a(11) and input_b(16);
a11_and_b17 <= input_a(11) and input_b(17);
a12_and_b0 <= input_a(12) and input_b(0);
a12_and_b1 <= input_a(12) and input_b(1);
a12_and_b2 <= input_a(12) and input_b(2);
a12_and_b3 <= input_a(12) and input_b(3);
a12_and_b4 <= input_a(12) and input_b(4);
a12_and_b5 <= input_a(12) and input_b(5);
a12_and_b6 <= input_a(12) and input_b(6);
a12_and_b7 <= input_a(12) and input_b(7);
a12_and_b8 <= input_a(12) and input_b(8);
a12_and_b9 <= input_a(12) and input_b(9);
a12_and_b10 <= input_a(12) and input_b(10);
a12_and_b11 <= input_a(12) and input_b(11);
a12_and_b12 <= input_a(12) and input_b(12);
a12_and_b13 <= input_a(12) and input_b(13);
a12_and_b14 <= input_a(12) and input_b(14);
a12_and_b15 <= input_a(12) and input_b(15);
a12_and_b16 <= input_a(12) and input_b(16);
a12_and_b17 <= input_a(12) and input_b(17);
a13_and_b0 <= input_a(13) and input_b(0);
a13_and_b1 <= input_a(13) and input_b(1);
a13_and_b2 <= input_a(13) and input_b(2);
a13_and_b3 <= input_a(13) and input_b(3);
a13_and_b4 <= input_a(13) and input_b(4);
a13_and_b5 <= input_a(13) and input_b(5);
a13_and_b6 <= input_a(13) and input_b(6);
a13_and_b7 <= input_a(13) and input_b(7);
a13_and_b8 <= input_a(13) and input_b(8);
a13_and_b9 <= input_a(13) and input_b(9);
a13_and_b10 <= input_a(13) and input_b(10);
a13_and_b11 <= input_a(13) and input_b(11);
a13_and_b12 <= input_a(13) and input_b(12);
a13_and_b13 <= input_a(13) and input_b(13);
a13_and_b14 <= input_a(13) and input_b(14);
a13_and_b15 <= input_a(13) and input_b(15);
a13_and_b16 <= input_a(13) and input_b(16);
a13_and_b17 <= input_a(13) and input_b(17);
a14_and_b0 <= input_a(14) and input_b(0);
a14_and_b1 <= input_a(14) and input_b(1);
a14_and_b2 <= input_a(14) and input_b(2);
a14_and_b3 <= input_a(14) and input_b(3);
a14_and_b4 <= input_a(14) and input_b(4);
a14_and_b5 <= input_a(14) and input_b(5);
a14_and_b6 <= input_a(14) and input_b(6);
a14_and_b7 <= input_a(14) and input_b(7);
a14_and_b8 <= input_a(14) and input_b(8);
a14_and_b9 <= input_a(14) and input_b(9);
a14_and_b10 <= input_a(14) and input_b(10);
a14_and_b11 <= input_a(14) and input_b(11);
a14_and_b12 <= input_a(14) and input_b(12);
a14_and_b13 <= input_a(14) and input_b(13);
a14_and_b14 <= input_a(14) and input_b(14);
a14_and_b15 <= input_a(14) and input_b(15);
a14_and_b16 <= input_a(14) and input_b(16);
a14_and_b17 <= input_a(14) and input_b(17);
a15_and_b0 <= input_a(15) and input_b(0);
a15_and_b1 <= input_a(15) and input_b(1);
a15_and_b2 <= input_a(15) and input_b(2);
a15_and_b3 <= input_a(15) and input_b(3);
a15_and_b4 <= input_a(15) and input_b(4);
a15_and_b5 <= input_a(15) and input_b(5);
a15_and_b6 <= input_a(15) and input_b(6);
a15_and_b7 <= input_a(15) and input_b(7);
a15_and_b8 <= input_a(15) and input_b(8);
a15_and_b9 <= input_a(15) and input_b(9);
a15_and_b10 <= input_a(15) and input_b(10);
a15_and_b11 <= input_a(15) and input_b(11);
a15_and_b12 <= input_a(15) and input_b(12);
a15_and_b13 <= input_a(15) and input_b(13);
a15_and_b14 <= input_a(15) and input_b(14);
a15_and_b15 <= input_a(15) and input_b(15);
a15_and_b16 <= input_a(15) and input_b(16);
a15_and_b17 <= input_a(15) and input_b(17);
a16_and_b0 <= input_a(16) and input_b(0);
a16_and_b1 <= input_a(16) and input_b(1);
a16_and_b2 <= input_a(16) and input_b(2);
a16_and_b3 <= input_a(16) and input_b(3);
a16_and_b4 <= input_a(16) and input_b(4);
a16_and_b5 <= input_a(16) and input_b(5);
a16_and_b6 <= input_a(16) and input_b(6);
a16_and_b7 <= input_a(16) and input_b(7);
a16_and_b8 <= input_a(16) and input_b(8);
a16_and_b9 <= input_a(16) and input_b(9);
a16_and_b10 <= input_a(16) and input_b(10);
a16_and_b11 <= input_a(16) and input_b(11);
a16_and_b12 <= input_a(16) and input_b(12);
a16_and_b13 <= input_a(16) and input_b(13);
a16_and_b14 <= input_a(16) and input_b(14);
a16_and_b15 <= input_a(16) and input_b(15);
a16_and_b16 <= input_a(16) and input_b(16);
a16_and_b17 <= input_a(16) and input_b(17);
a17_and_b0 <= input_a(17) and input_b(0);
a17_and_b1 <= input_a(17) and input_b(1);
a17_and_b2 <= input_a(17) and input_b(2);
a17_and_b3 <= input_a(17) and input_b(3);
a17_and_b4 <= input_a(17) and input_b(4);
a17_and_b5 <= input_a(17) and input_b(5);
a17_and_b6 <= input_a(17) and input_b(6);
a17_and_b7 <= input_a(17) and input_b(7);
a17_and_b8 <= input_a(17) and input_b(8);
a17_and_b9 <= input_a(17) and input_b(9);
a17_and_b10 <= input_a(17) and input_b(10);
a17_and_b11 <= input_a(17) and input_b(11);
a17_and_b12 <= input_a(17) and input_b(12);
a17_and_b13 <= input_a(17) and input_b(13);
a17_and_b14 <= input_a(17) and input_b(14);
a17_and_b15 <= input_a(17) and input_b(15);
a17_and_b16 <= input_a(17) and input_b(16);
a17_and_b17 <= input_a(17) and input_b(17);
first_vector <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & carry_layer6_128345760_128345984 & carry_layer6_128345592_128345816 & carry_layer6_128345424_128345648 & carry_layer6_128345256_128345480 & carry_layer6_128345088_128345312 & carry_layer6_128344920_128345144 & carry_layer6_128344752_128344976 & carry_layer6_128344584_128344808 & carry_layer6_128344416_128344640 & carry_layer6_128344248_128344472 & carry_layer6_128344136_128344304 & carry_layer6_128335712_128335824 & carry_layer6_128318208_128335544_128335768 & carry_layer6_128317928_128335376_128335600 & carry_layer6_128317592_128335208_128335432 & carry_layer6_128317256_128335040_128335264 & carry_layer6_128316920_128334872_128335096 & carry_layer6_128316584_128334704_128334928 & carry_layer6_128316248_128334536_128334760 & carry_layer6_128315912_128334368_128334592 & carry_layer6_128315576_128334144_128334424 & carry_layer6_128333976_128334200 & carry_layer6_128333808_128334032 & carry_layer6_128333640_128333864 & carry_layer6_128333472_128333696 & carry_layer6_128333304_128333528 & carry_layer6_128333136_128333360 & carry_layer6_128332968_128333192 & carry_layer6_128332800_128333024 & carry_layer6_128332632_128332856 & sum_layer6_128332632_128332856 & sum_layer5_128219120_128219344 & sum_layer4_128123792_128123960 & sum_layer3_128246000_128246168 & sum_layer2_127826128_127826296 & sum_layer1_127830168_127844480 & a0_and_b0 ;
second_vector <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & sum_layer6_128332464_128345928 & sum_layer6_128345760_128345984 & sum_layer6_128345592_128345816 & sum_layer6_128345424_128345648 & sum_layer6_128345256_128345480 & sum_layer6_128345088_128345312 & sum_layer6_128344920_128345144 & sum_layer6_128344752_128344976 & sum_layer6_128344584_128344808 & sum_layer6_128344416_128344640 & sum_layer6_128344248_128344472 & sum_layer6_128344136_128344304 & sum_layer6_128335712_128335824 & sum_layer6_128318208_128335544_128335768 & sum_layer6_128317928_128335376_128335600 & sum_layer6_128317592_128335208_128335432 & sum_layer6_128317256_128335040_128335264 & sum_layer6_128316920_128334872_128335096 & sum_layer6_128316584_128334704_128334928 & sum_layer6_128316248_128334536_128334760 & sum_layer6_128315912_128334368_128334592 & sum_layer6_128315576_128334144_128334424 & sum_layer6_128333976_128334200 & sum_layer6_128333808_128334032 & sum_layer6_128333640_128333864 & sum_layer6_128333472_128333696 & sum_layer6_128333304_128333528 & sum_layer6_128333136_128333360 & sum_layer6_128332968_128333192 & sum_layer6_128332800_128333024 & '0' & '0' & '0' & '0' & '0' & '0' & '0' ;
output <= output_vector(18-1 downto 0);

end wallace_tree;