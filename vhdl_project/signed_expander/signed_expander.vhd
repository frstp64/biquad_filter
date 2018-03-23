----------------------------------------------------------------------------------
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

