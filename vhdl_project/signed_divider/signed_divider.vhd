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

