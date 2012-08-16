# Game of Life: http://en.wikipedia.org/wiki/Conway's_Game_of_Life
# Rules:
#   Any live cell with fewer than two live neighbours dies, as if caused by under-population.
#   Any live cell with two or three live neighbours lives on to the next generation.
#   Any live cell with more than three live neighbours dies, as if by overcrowding.
#   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
#
# frame 1
#   5
#   4   0  
#   3   X 
#   2   0
#   1
#   0 1 2 3 4 5
#
#
# frame 2
#   5
#   4     
#   3 0 X 0
#   2   
#   1
#   0 1 2 3 4 5
#
#

require 'ruby-debug'
require 'set'
require 'pp'
require 'matrix'

# Pattern 1
alive_cells = { '2,2' => true, '2,3' => true, '2,4' => true }

# Pattern 2
#alive_cells = { '2,2' => true, 
#                '3,2' => true, 
#                '4,2' => true,
#                '3,3' => true,
#                '4,3' => true,
#                '5,3' => true }

# Pattern 3
#alive_cells = { '2,4' => true, 
#                '3,2' => true, 
#                '3,3' => true,
#                '4,3' => true,
#                '4,4' => true }
#

class Cell

  attr_reader :x_coord, :y_coord

  NEIGHBOR_MATH = [[0 , 1 ],
                   [1 , 1 ],
                   [1 , 0 ],
                   [1 , -1],
                   [0 , -1],
                   [-1, -1],
                   [-1, 0 ],
                   [-1, 1 ]]

  def initialize(coordinate, alive_cells)
    @x_coord = coordinate.split(',')[0].to_i
    @y_coord = coordinate.split(',')[1].to_i
    @alive   = true 
    @alive_cells = alive_cells
  end

  def alive?
    @alive 
  end

  def next
    @alive = (2..3) === self.alive_neighbors_count
  end

  def alive_neighbors_count
    self.alive_neighbors_coords.size
  end

  def alive_neighbors_coords
    self.neighbors_coords.select {|coord| @alive_cells.has_key? coord}
  end

  def dead_neighbors_coords
    self.neighbors_coords.select {|d| (@alive_cells.has_key? d) == false}
  end

  def coordinates_as_str
    [@x_coord.to_s, @y_coord.to_s].join(',')
  end

  def dead_neighbors_with_3_alive_neighbors
    self.dead_neighbors_coords.select{ |dead_cell| Cell.new(dead_cell, @alive_cells).alive_neighbors_count == 3 }
  end

  def calculate_coordinate_of_neighbor(number)
    [(@x_coord.to_i + number[0].to_i).to_s, (@y_coord.to_i + number[1].to_i).to_s].join(',')
  end

  def neighbors_coords
    NEIGHBOR_MATH.map {|m| self.calculate_coordinate_of_neighbor(m) }
  end
end


class Board

  attr_reader :next_frame_alive_cells, :alive_cells, :dead_neighbors_cells_with_3_alive_neighbors

  def initialize(alive_cells)
    @alive_cells            = alive_cells
    @next_frame_alive_cells = Hash.new {|hash, key| hash[key] = true}
    @dead_neighbors_cells_with_3_alive_neighbors = Set.new 
  end

  def reproduction 
    @alive_cells.keys.each do |alive_cell|
      cell = Cell.new(alive_cell, @alive_cells)
      @dead_neighbors_cells_with_3_alive_neighbors.add(cell.dead_neighbors_with_3_alive_neighbors)     
    end

    self.identify_reproduction_cells
  end

  def identify_reproduction_cells
    cells_for_reproduction = Hash.new {|hash, key| hash[key] = true}
    @dead_neighbors_cells_with_3_alive_neighbors.to_a.flatten.each {|cell| cells_for_reproduction[cell]}
    
    return cells_for_reproduction
  end

  def next
    @alive_cells.keys.each do |alive_cell|
      cell = Cell.new(alive_cell, @alive_cells)
      cell.next
      @next_frame_alive_cells[cell.coordinates_as_str] if cell.alive?
    end

    self.prep_for_next_frame
  end

  def prep_for_next_frame
    @alive_cells            = @next_frame_alive_cells.update(self.reproduction)
    @next_frame_alive_cells = Hash.new {|hash, key| hash[key] = true}
    @dead_neighbors_cells_with_3_alive_neighbors.clear
  end

  def print_frame(grid_area_squared)
    
    frame = Matrix.zero(grid_area_squared)
    @alive_cells.keys.each do |cell|
      x,y = cell.split(',')
      frame_copy = *frame
      frame_copy[x.to_i][y.to_i] = 1 
      frame = Matrix[*frame_copy]
    end
    frame.to_a.reverse.each {|r| puts r.to_s.gsub(/[\[\],]/,'') }
  end
end

b = Board.new(alive_cells)
grid_size = 10 

20.times {
  puts '*'*10
  puts 'alive cells:'
  puts b.alive_cells
  puts
  b.print_frame(grid_size)
  b.next
}

