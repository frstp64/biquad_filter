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

signal division_ring: std_logic_vector(division_factor*2-1 downto 0);

begin

	process (clk_in, reset)
	begin
		if reset='1' then
			division_ring <= (1 => '1', others => '0');
			clk_out <= '0';
		elsif rising_edge(clk_in) then
			if en='1' then
				division_ring <= division_ring(division_factor*2-2 downto 0) & division_ring(division_factor*2-1);
				clk_out <= division_ring(division_factor*2-1);
			end if;
		end if;
	end process;

end Behavioral;

