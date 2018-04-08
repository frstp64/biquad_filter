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

