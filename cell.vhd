library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity cell is
generic(initial_state : std_logic);
port(reset : in std_logic;
	en : in std_logic;
	cell_clk : in std_logic;
	cell_left, cell_right : in std_logic;
    upper_left, upper, upper_right: in std_logic;
    lower_left, lower, lower_right : in std_logic;
	 override : in std_logic;
	alive : inout std_logic);

end entity cell;

architecture behavior of cell is

function check_neighbor(neighbor : std_logic) return boolean is
variable result : boolean;
begin
	if neighbor = '1' then
		result := TRUE;
	else
		result := FALSE;
   end if;

   return result;

end function check_neighbor;

begin

	game_of_life : process(cell_clk, reset, override)
	variable ul_var : integer range 0 to 1 := 0;
	variable u_var : integer range 0 to 1 := 0;
	variable ur_var : integer range 0 to 1:= 0;
	variable cl_var : integer range 0 to 1:= 0;
	variable cr_var : integer range 0 to 1 := 0;
	variable ll_var : integer range 0 to 1 := 0;
	variable l_var : integer range 0 to 1 := 0;
	variable lr_var : integer range 0 to 1 := 0;
	variable alive_var : integer range 0 to 1 := 0;
	variable neighbors : integer range 0 to 8 := 0;	-- 'neighbors' holds the count of live cell neighbors for the particular cell

	
   begin		
		
		if(reset = '1') then
			alive <= initial_state;
			neighbors := 0;
			ul_var := 0;
			u_var := 0;
			ur_var := 0;
			cl_var := 0;
			cr_var := 0;
			ll_var := 0;
			l_var := 0;
			lr_var := 0;
			
			if (initial_state = '0') then
				alive_var := 0;
			else
				alive_var := 1;
			end if;
		
		elsif(override = '1') then
			alive <= '1';
			
		elsif(en = '1') then
						
			if(rising_edge(cell_clk)) then
			
			
				if(check_neighbor(upper_left) = TRUE) then
					ul_var := 1;
				else
					ul_var := 0;
				end if;
			
				if(check_neighbor(upper) = TRUE) then
					u_var := 1;
				else
					u_var := 0;
				end if;
			
				if(check_neighbor(upper_right) = TRUE) then
					ur_var := 1;
				else
					ur_var := 0;
				end if;
			
				if(check_neighbor(cell_left) = TRUE) then
					cl_var := 1;
				else
					cl_var := 0;
				end if;
				
				if(check_neighbor(cell_right) = TRUE) then
					cr_var := 1;
				else
					cr_var := 0;					
				end if;
				
				if(check_neighbor(lower_left) = TRUE) then
					ll_var := 1;
				else
					ll_var := 0;
				end if;
				
				if(check_neighbor(lower) = TRUE) then
					l_var := 1;
				else
					l_var := 0;
				end if;
				
				if(check_neighbor(lower_right) = TRUE) then
					lr_var := 1;
				else
					lr_var := 0;
				end if;
				
				neighbors := ul_var + u_var + ur_var + cl_var + cr_var + ll_var + l_var + lr_var;


				if((alive_var = 0 AND neighbors = 3) OR (alive_var = 1 AND (neighbors = 2 OR neighbors = 3))) then	-- if particular cell is dead but has three live neighbors, or if cell is alive and has two or three live neighbors, turn cell on
					alive <= '1';
					alive_var := 1;
				else
					alive <= '0';
					alive_var := 0;
				end if;
				
			end if;
			
		end if;
		
	
    end process game_of_life;
	 

end architecture behavior;