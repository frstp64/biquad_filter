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

