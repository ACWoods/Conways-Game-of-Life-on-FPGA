library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.board_pkg.all;

entity img_generator is
port(reset : in std_logic;
	column, row: in unsigned(10 downto 0);
	pattern_signal : in std_logic;
	user_input : in std_logic;
	button : in std_logic_vector(3 downto 0);
	in_clk : in std_logic;
	button_clk : in std_logic;
	blank : in std_logic;
	red, green, blue : out std_logic);
	
constant pattern_1 : board_matrix := (	"00000000000000000",
													"00000100000100000",
													"00000100000100000",
													"00000110001100000",
													"00000000000000000",
													"01110011011001110",
													"00010101010101000",
													"00000110001100000",
													"00000000000000000",
													"00000110001100000",
													"00010101010101000",
													"01110011011001110",
													"00000000000000000",
													"00000110001100000",
													"00000100000100000",
													"00000100000100000",
													"00000000000000000");

constant pattern_2 : board_matrix := (	"00000000000000000",
													"00000000000000000",
													"00000000000000000",
													"00000000000000000",
													"00001101111110000",
													"00001101111110000",
													"00001100000000000",
													"00001100000110000",
													"00001100000110000",
													"00001100000110000",
													"00000000000110000",
													"00001111110110000",
													"00001111110110000",
													"00000000000000000",
													"00000000000000000",
													"00000000000000000",
													"00000000000000000");
													
constant test_pattern : board_matrix := (	"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111",
														"11111111111111111");
													
constant clear_pattern : board_matrix := ("00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000",
														"00000000000000000");

end img_generator;

architecture dataflow of img_generator is
constant column_grid_constant : unsigned := "00010000000";	-- 128
constant row_grid_constant : unsigned := "00000100001";	-- 33
signal board_gen_1 : board_matrix;
signal board_gen_2 : board_matrix;
signal board_gen_3 : board_matrix;
signal user_override_sig : board_matrix;
signal start_user_input : std_logic;
signal internal_clock : std_logic;


component board is
generic(initial_cell_state : board_matrix);
port(reset : in std_logic;
	enable : in std_logic;
	user_override : in board_matrix;
	board_clk : in std_logic;
	board_tracker : inout board_matrix);

end component board;

for all : board use entity work.board(behavior);


function game_of_life(board: board_matrix;	-- Reads the board matrix and determines live cells
							j : integer; 
							k : integer) return boolean is
variable result : boolean;
begin
	if board(j)(k) = '1' then
		result := TRUE;
	else
		result := FALSE;
   end if;

   return result;

end function game_of_life;


begin		

	internal_clock <= in_clk;

	
	I1: board generic map(initial_cell_state => pattern_1)
						port map(reset => reset,
							enable => NOT pattern_signal,
							board_clk => internal_clock,
							user_override => clear_pattern,
							board_tracker => board_gen_1);
	
	I2: board generic map(initial_cell_state => pattern_2)
						port map(reset => reset,
							enable => pattern_signal,
							board_clk => internal_clock,
							user_override => clear_pattern,
							board_tracker => board_gen_2);
						
	I3: board generic map(initial_cell_state => clear_pattern)
						port map(reset => reset,
							enable => NOT pattern_signal,
							board_clk => internal_clock,
							user_override => user_override_sig,
							board_tracker => board_gen_3);
	
	
						
		
	draw : process(row, column, blank, button_clk)	-- Display black screen
	variable j,k : integer := 0;
	variable a : integer := 0;
	variable b : integer := 16;
	variable clear : std_logic := '0';
	
	begin
		-- Blank screen if necessary
		if(blank = '1') then
			red <= '0';
			green <= '0';
			blue <= '0';
			
	
		else
			-- If screen not blank, draw image.  The image must be drawn in this order for the borders to overlap the grid.
			
			-- White spaces will have dimensions of 30 rows tall by 30 pixels (columns) wide. 30 * 17 = 510, green border should end at row/column (grid row range 33-576, column range 128-671)
			
			-- Grid
			if( row = row_grid_constant + 31   OR  	row = row_grid_constant + 63  OR  row = row_grid_constant + 95   OR	-- Uses one row/column for green grid line after every 30 rows/columns (adds 32)
				row = row_grid_constant + 127  OR	row = row_grid_constant + 159 OR  row = row_grid_constant + 191  OR
				row = row_grid_constant + 223  OR	row = row_grid_constant + 255 OR  row = row_grid_constant + 287  OR 
				row = row_grid_constant + 319  OR	row = row_grid_constant + 351 OR  row = row_grid_constant + 383  OR  
				row = row_grid_constant + 415  OR	row = row_grid_constant + 447 OR  row = row_grid_constant + 479  OR
				row = row_grid_constant + 511  OR   row = row_grid_constant + 543 OR
				
				column = column_grid_constant + 31   OR	column = column_grid_constant + 63  OR  column = column_grid_constant + 95   OR
				column = column_grid_constant + 127  OR	column = column_grid_constant + 159 OR  column = column_grid_constant + 191  OR
				column = column_grid_constant + 223  OR	column = column_grid_constant + 255 OR  column = column_grid_constant + 287  OR 
				column = column_grid_constant + 319  OR	column = column_grid_constant + 351 OR  column = column_grid_constant + 383  OR  
				column = column_grid_constant + 415  OR	column = column_grid_constant + 447 OR  column = column_grid_constant + 479  OR
				column = column_grid_constant + 511  OR	column = column_grid_constant + 543) then
				
				red <= '0';
				green <= '1';
				blue <= '0';
				
			else
				red <= '1'; -- White color
				green <= '1';
				blue <= '1';
				

		
			end if;
	
			-- Two methods used for drawing borders-pixel by pixel (green) and range (red).

			-- Green border
			if(row = "00000011110" OR row = "00000011111" OR row = "00000100000" OR	-- rows 30, 31, and 32
					row = "01001000000" OR row = "01001000001" OR row = "01001000010" OR	-- rows 576, 577, and 578
					column = "00001111110" OR column = "00001111111" OR column = "00010000000" OR	-- columns 126, 127, and 128
					column = "01010011111" OR column = "01010100000" OR column = "01010100001") then	-- columns 671, 672, and 673
			
				red <= '0';
				green <= '1';
				blue <= '0';
			
			end if;
			
			
			-- Red border
			if(row < 30) then
				if(row > 25) then
					red <= '1';
					green <= '0';
					blue <= '0';
				
				else
					red <= '0';	-- Blank screen
					green <= '0';
					blue <= '0';
				end if;
					
			elsif(row > 578) then
				if(row < 583) then
					red <= '1';
					green <= '0';
					blue <= '0';
			
				else
					red <= '0';	-- Blank screen
					green <= '0';
					blue <= '0';
				end if;
			
			end if;
			
			if(column < 126) then
				if(column > 121) then
					red <= '1';	
					green <= '0';
					blue <= '0';
						
				else
					red <= '0';	-- Blank screen
					green <= '0';
					blue <= '0';
				end if;
				
			elsif(column > 673) then
				if(column < 678) then
					red <= '1';
					green <= '0';
					blue <= '0';
			
				else
					red <= '0';	-- Blank screen
					green <= '0';
					blue <= '0';
				end if;	
				
			end if;
			
				
			if((row < 26 AND column > 121) OR (row > 582 AND column < 678)) then
					red <= '0';	-- Blank screen
					green <= '0';
					blue <= '0';
			end if;
	
		-- User live cell generation
			-- button(0): right
			-- button(1): down
			-- button(2): up
			-- button(3): left
			if(pattern_signal = '0') then
				if(rising_edge(button_clk)) then
					if(button(3) = '1') then
						if(a = N AND b = 0 AND start_user_input = '0') then	-- Initial button press by user to set cell alive						
							clear := '1';
							start_user_input <= '1';
						
						elsif(start_user_input = '1') then						
							if(b /= 0) then
								b := b - 1;
							else
								b := N;
							end if;
						end if;
					
					
					elsif(button(2) = '1') then
						if(start_user_input = '1') then
							if(a /= 0) then
								a := a - 1;
							else
								a := N;
							end if;
						end if;
							
					
					elsif(button(1) = '1') then
						if(start_user_input = '1') then		
							if(a /= N) then
								a := a + 1;
							else
								a := 0;
							end if;
						end if;
						
						
					elsif(button(0) = '1') then
						if(start_user_input = '1') then						
							if(b /= N) then
								b := b + 1;
							else
								a := 0;
							end if;
						end if;
					
					end if;
						
					if(clear = '1' OR reset = '1') then
						for j in 0 to N loop
							for k in 0 to N loop
								if(j = 16 AND k = 0) then
									user_override_sig(j)(k) <= '1';	--This is why it starts off with the one square
								else
									user_override_sig(j)(k) <= '0';
								end if;
							end loop;
						end loop;
						
						clear := '0';
					end if;
						
					if(user_input = '1') then
						user_override_sig(a)(b) <= '1';
					end if;
				
				end if;
						
			else
				a := N;
				b := 0;
				start_user_input <= '0';
			end if;
		
	
	
		-- Draw live cells
			for j in 0 to N loop
				for k in 0 to N loop
					
					if(pattern_signal = '0') then
						if(start_user_input = '1') then
							if(game_of_life(board_gen_3, j, k) = TRUE) then	-- Runs the user-generated board pattern through the game_of_life
								if(j = 0 AND k = 0) then
									if(row > row_grid_constant + (30 * j) AND row < row_grid_constant + (30 * (j + 1))
										AND column > column_grid_constant + (30 * k) AND column < column_grid_constant + (30 * (k + 1))) then
								
										red <= '0';	-- Black cell
										green <= '0';
										blue <= '0';
								
									end if;
								end if;
						
								if((j > 0 AND k > 0) OR (j = 0 AND k > 0) OR (j > 0 AND k = 0)) then		-- (2 * k) and (2 * k) are the offsets required to align the alive cells with the grid
									if(row > row_grid_constant + (30 * j) + (2 * j) AND row < row_grid_constant + ((30 * (j + 1)) + (2 * j))
										AND column > column_grid_constant + (30 * k) + (2 * k) AND column < column_grid_constant + ((30 * (k + 1)) + (2 * k))) then
								
										red <= '0';	-- Black cell
										green <= '0';
										blue <= '0';
								
									end if;
								end if;
							end if;
						
						else
							if(game_of_life(board_gen_1, j, k) = TRUE) then	-- Runs the first board pattern through the game_of_life
								if(j = 0 AND k = 0) then
									if(row > row_grid_constant + (30 * j) AND row < row_grid_constant + (30 * (j + 1))
										AND column > column_grid_constant + (30 * k) AND column < column_grid_constant + (30 * (k + 1))) then
								
										red <= '0';	-- Black cell
										green <= '0';
										blue <= '0';
								
									end if;
								end if;
						
								if((j > 0 AND k > 0) OR (j = 0 AND k > 0) OR (j > 0 AND k = 0)) then		-- (2 * k) and (2 * k) are the offsets required to align the alive cells with the grid
									if(row > row_grid_constant + (30 * j) + (2 * j) AND row < row_grid_constant + ((30 * (j + 1)) + (2 * j))
										AND column > column_grid_constant + (30 * k) + (2 * k) AND column < column_grid_constant + ((30 * (k + 1)) + (2 * k))) then
								
										red <= '0';	-- Black cell
										green <= '0';
										blue <= '0';
								
									end if;
								end if;
							end if;
						end if;
							
					else
						if(game_of_life(board_gen_2, j, k) = TRUE) then	-- Runs the second board pattern through the game_of_life
							if(j = 0 AND k = 0) then
								if(row > row_grid_constant + (30 * j) AND row < row_grid_constant + (30 * (j + 1))
									AND column > column_grid_constant + (30 * k) AND column < column_grid_constant + (30 * (k + 1))) then
							
									red <= '0';	-- Black cell
									green <= '0';
									blue <= '0';
							
								end if;
							end if;
					
							if((j > 0 AND k > 0) OR (j = 0 AND k > 0) OR (j > 0 AND k = 0)) then
								if(row > row_grid_constant + (30 * j) + (2 * j) AND row < row_grid_constant + ((30 * (j + 1)) + (2 * j))
									AND column > column_grid_constant + (30 * k) + (2 * k) AND column < column_grid_constant + ((30 * (k + 1)) + (2 * k))) then
							
									red <= '0';	-- Black cell
									green <= '0';
									blue <= '0';
							
								end if;
							end if;
						end if;
						
					end if;
			
				end loop;
			end loop;		
	
		end if;
		
	end process draw;

	
	
		
end architecture dataflow;