----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:19:59 03/22/2018 
-- Design Name: 
-- Module Name:    signed_adder - combinational 
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

-- This module assumes no overflowASDasd

entity signed_adder is
    generic ( SIGNAL_LENGTH: positive);
    Port ( input_A : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           input_B : in  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0));
end signed_adder;

architecture combinational_ripple_carry of signed_adder is

signal a_xor_b: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal carry: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);

begin

carry(0) <= '0';

a_xor_b <= input_A xor input_b;

output <= a_xor_b xor carry;

carry(SIGNAL_LENGTH-1 downto 1) <= (input_A(SIGNAL_LENGTH-2 downto 0) and input_B(SIGNAL_LENGTH-2 downto 0) ) or ( (a_xor_b(SIGNAL_LENGTH-2 downto 0))  and carry(SIGNAL_LENGTH-2 downto 0));

end combinational_ripple_carry;



architecture combinational_carry_lookahead of signed_adder is


signal P: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal G: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
signal Cin: STD_LOGIC_VECTOR (SIGNAL_LENGTH-1 downto 0);
begin

P <= input_A xor input_B;
output <= P xor Cin;
G <= input_A and input_B;

Cin(0) <= '0';
Cin(SIGNAL_LENGTH-1 downto 1) <= G(SIGNAL_LENGTH-2 downto 0) or (P(SIGNAL_LENGTH-2 downto 0) and Cin(SIGNAL_LENGTH-2 downto 0));
end combinational_carry_lookahead;
