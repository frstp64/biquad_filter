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

