----------------------------------------------------------------------------------
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


process (clk, reset)
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

