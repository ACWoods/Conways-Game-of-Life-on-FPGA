library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package board_pkg is

constant N : integer := 16;
type board_matrix is array(0 to N) of std_logic_vector(0 to N);	-- matrix of alive states

end package board_pkg;