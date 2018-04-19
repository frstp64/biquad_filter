
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY biquad_filter_v_tb IS
END biquad_filter_v_tb;
 
ARCHITECTURE behavior OF biquad_filter_v_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT biquad_filter
    PORT(
         clk : IN  std_logic;
         en : IN  std_logic;
         reset : IN  std_logic;
         parameter_A1_mul : IN  std_logic_vector(7 downto 0);
         parameter_A1_div : IN  std_logic_vector(7 downto 0);
         parameter_A2_mul : IN  std_logic_vector(7 downto 0);
         parameter_A2_div : IN  std_logic_vector(7 downto 0);
         parameter_B0_mul : IN  std_logic_vector(7 downto 0);
         parameter_B0_div : IN  std_logic_vector(7 downto 0);
         parameter_B1_mul : IN  std_logic_vector(7 downto 0);
         parameter_B1_div : IN  std_logic_vector(7 downto 0);
         parameter_B2_mul : IN  std_logic_vector(7 downto 0);
         parameter_B2_div : IN  std_logic_vector(7 downto 0);
         input_signal : IN  std_logic_vector(7 downto 0);
         output_signal : OUT  std_logic_vector(7 downto 0);
         change_input : OUT  std_logic;
         temporary_overflow : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal en : std_logic := '0';
   signal reset : std_logic := '0';
   signal parameter_A1_mul : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_A1_div : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_A2_mul : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_A2_div : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B0_mul : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B0_div : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B1_mul : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B1_div : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B2_mul : std_logic_vector(7 downto 0) := (others => '0');
   signal parameter_B2_div : std_logic_vector(7 downto 0) := (others => '0');
   signal input_signal : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal output_signal : std_logic_vector(7 downto 0);
   signal change_input : std_logic;
   signal temporary_overflow : std_logic;

   -- Clock period definitions
   constant clk_period : time := 100000 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: biquad_filter PORT MAP (
          clk => clk,
          en => en,
          reset => reset,
          parameter_A1_mul => parameter_A1_mul,
          parameter_A1_div => parameter_A1_div,
          parameter_A2_mul => parameter_A2_mul,
          parameter_A2_div => parameter_A2_div,
          parameter_B0_mul => parameter_B0_mul,
          parameter_B0_div => parameter_B0_div,
          parameter_B1_mul => parameter_B1_mul,
          parameter_B1_div => parameter_B1_div,
          parameter_B2_mul => parameter_B2_mul,
          parameter_B2_div => parameter_B2_div,
          input_signal => input_signal,
          output_signal => output_signal,
          change_input => change_input,
          temporary_overflow => temporary_overflow
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
		en<='0';
		reset<='1';
		wait for clk_period*100;
      en<='1';
		reset<='0';
		parameter_A1_mul<="00000111";
		parameter_A1_div<="00000111";
		parameter_A2_mul<="00000111";
		parameter_A2_div<="00000111";
		parameter_B0_mul<="00000111";
		parameter_B0_div<="00000001";
		parameter_B1_mul<="00000111";
		parameter_B1_div<="00000111";
		parameter_B2_mul<="00000111";
		parameter_B2_div<="00000111";
		input_signal<="00000001";
		wait for clk_period*1000;
		parameter_A1_mul<="00000111";
		parameter_A1_div<="00000111";
		parameter_A2_mul<="00000111";
		parameter_A2_div<="00000111";
		parameter_B0_mul<="00000111";
		parameter_B0_div<="00000001";
		parameter_B1_mul<="00000111";
		parameter_B1_div<="00000111";
		parameter_B2_mul<="00000111";
		parameter_B2_div<="00000111";
		input_signal<="00000001";
		wait for clk_period*100;
		parameter_A1_mul<="00000111";
		parameter_A1_div<="00000111";
		parameter_A2_mul<="00000111";
		parameter_A2_div<="00000111";
		parameter_B0_mul<="00000111";
		parameter_B0_div<="00000001";
		parameter_B1_mul<="00000111";
		parameter_B1_div<="00000111";
		parameter_B2_mul<="00000111";
		parameter_B2_div<="00000111";
		input_signal<="00000001";
		wait for clk_period*100;
		parameter_A1_mul<="00000111";
		parameter_A1_div<="00000111";
		parameter_A2_mul<="00000111";
		parameter_A2_div<="00000111";
		parameter_B0_mul<="00000111";
		parameter_B0_div<="00000001";
		parameter_B1_mul<="00000111";
		parameter_B1_div<="00000111";
		parameter_B2_mul<="00000111";
		parameter_B2_div<="00000111";
		input_signal<="00000001";
		wait for clk_period*100;
		parameter_A1_mul<="00000111";
		parameter_A1_div<="00000111";
		parameter_A2_mul<="00000111";
		parameter_A2_div<="00000111";
		parameter_B0_mul<="00000111";
		parameter_B0_div<="00000001";
		parameter_B1_mul<="00000111";
		parameter_B1_div<="00000111";
		parameter_B2_mul<="00000111";
		parameter_B2_div<="00000111";
		input_signal<="00000001";
		
		
		
		wait;
   end process;

END;
