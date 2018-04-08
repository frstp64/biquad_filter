----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:00:53 04/07/2018 
-- Design Name: 
-- Module Name:    HA - Behavioral 
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

entity HA is
Port (
    bit_a : in  STD_LOGIC;
    bit_b : in STD_LOGIC;
    sum_sig : out  STD_LOGIC;
    carry_sig: out STD_LOGIC
);
END HA;

architecture Behavioral of HA is

begin
sum_sig <= bit_a xor bit_b;
carry_sig <= bit_a and bit_b;

end Behavioral;

