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
end arch_nbitregister;