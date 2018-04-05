LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY nbitregister_TB IS
END nbitregister_TB;
ARCHITECTURE behavior OF nbitregister_TB IS 
    COMPONENT nbitregister
    PORT(
         pre_op : IN  std_logic;
         clk : IN  std_logic;
         rst : IN  std_logic;
         op_a : IN  std_logic_vector(15 downto 0);
         q : OUT  std_logic_vector(15 downto 0);
         qb : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT; 
   --Inputs
   signal pre_op : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal op_a : std_logic_vector(15 downto 0) := (others => '0');
 	--Outputs
   signal q : std_logic_vector(15 downto 0);
   signal qb : std_logic_vector(15 downto 0);
   -- Clock period definitions
   constant clk_period : time := 10 ns;
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: nbitregister PORT MAP (
          pre_op => pre_op,
          clk => clk,
          rst => rst,
          op_a => op_a,
          q => q,
          qb => qb
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
			rst<='1';
		   wait for clk_period*10;
			rst<='0';
			pre_op<='1';
			op_a<="1111111111111111";
			wait for clk_period*10;
			pre_op<='0';
			wait for clk_period*10;
			op_a<="0111111111111111";
			wait for clk_period*10;
			pre_op<='1';
			wait for clk_period*10;
      wait;
   end process;
END;