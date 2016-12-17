library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.board_pkg.all;

entity board is
generic(initial_cell_state : board_matrix);
port(reset : in std_logic;
	enable : in std_logic;
	user_override : in board_matrix;
	board_clk : in std_logic;
	board_tracker : inout board_matrix);
	
end entity board;

architecture behavior of board is
signal j, k : integer := 0;
signal internal_cell_clock : std_logic;
signal board_tracker_int : board_matrix;


component cell is
generic(initial_state : std_logic);
port(reset : in std_logic;
	en : in std_logic;
	cell_clk : in std_logic;
	cell_left, cell_right : in std_logic;
    upper_left, upper, upper_right: std_logic;
    lower_left, lower, lower_right : in std_logic;
	 override : in std_logic;
	 alive : inout std_logic);

end component cell;

begin

	
	internal_cell_clock <= board_clk;
	
	
	board_tracker <= board_tracker_int;

	
	
	outer_grid: for j in 0 to N generate
			inner_grid: for k in 0 to N generate
			
			-- j refers to horizontal direction and increases from left to right.
			-- k refers to vertical direction and increases from top to bottom.
			-- (column, row)
			--(0,0) is top left, (16, 0) is top right.
			
				upper_left: if (j = 0 AND k = 0) generate
					cell : entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(N)(0),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(N)(N),
						upper => board_tracker_int(0)(N),
						upper_right => board_tracker_int(j+1)(N),
						lower_left => board_tracker_int(N)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(j+1)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate upper_left;
			
				upper: if (j > 0 AND j < N AND k = 0) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(j-1)(N),
						upper => board_tracker_int(j+1)(N),
						upper_right => board_tracker_int(j+1)(N),
						lower_left => board_tracker_int(j-1)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(j+1)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate upper;
				
				upper_right: if (j = N AND k = 0) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(0)(0),
						upper_left => board_tracker_int(j-1)(N),
						upper => board_tracker_int(N)(N),
						upper_right => board_tracker_int(0)(N),
						lower_left => board_tracker_int(j-1)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(0)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate upper_right;
				
				cell_left: if (j = 0 AND k > 0 AND k < N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(N)(k),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(N)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(j+1)(k-1),
						lower_left => board_tracker_int(N)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(j+1)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate cell_left;
				
				middle: if (j > 0 AND j < N AND k > 0 AND k < N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(j-1)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(j+1)(k-1),
						lower_left => board_tracker_int(j-1)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(j+1)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate middle;
				
				cell_right: if (j = N AND k > 0 AND k < N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(0)(k),
						upper_left => board_tracker_int(j-1)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(0)(k-1),
						lower_left => board_tracker_int(j-1)(k+1),
						lower => board_tracker_int(j)(k+1),
						lower_right => board_tracker_int(0)(k+1),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate cell_right;
				
				lower_left: if (j = 0 AND k = N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(N)(k),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(N)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(j+1)(k-1),
						lower_left => board_tracker_int(N)(0),
						lower => board_tracker_int(j)(0),
						lower_right => board_tracker_int(j+1)(0),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate lower_left;
				
				lower: if (j > 0 AND j < N AND k = N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(j+1)(k),
						upper_left => board_tracker_int(j-1)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(j+1)(k-1),
						lower_left => board_tracker_int(j-1)(0),
						lower => board_tracker_int(j)(0),
						lower_right => board_tracker_int(j+1)(0),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate lower;
				
				lower_right: if (j = N AND k = N) generate 
					cell: entity work.cell(behavior)
						generic map(initial_state => initial_cell_state(j)(k))
						port map(reset => reset,
						en => enable,
						cell_clk => internal_cell_clock,
						cell_left => board_tracker_int(j-1)(k),
						cell_right => board_tracker_int(0)(k),
						upper_left => board_tracker_int(j-1)(k-1),
						upper => board_tracker_int(j)(k-1),
						upper_right => board_tracker_int(0)(k-1),
						lower_left => board_tracker_int(j-1)(0),
						lower => board_tracker_int(j)(0),
						lower_right => board_tracker_int(0)(0),
						override => user_override(j)(k),
						alive => board_tracker_int(j)(k));
				end generate lower_right;
					
			end generate inner_grid;
		
	end generate outer_grid;

	
end architecture behavior;
					
					
					
					
					
					