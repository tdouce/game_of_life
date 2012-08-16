require_relative 'game_of_life'
require 'ruby-debug'

describe Cell do

  let(:alive_cells){
    {
      '2,2'   => true,
      '2,3'   => true,
      '2,4'   => true,
    }
  }

  let(:neighbor_math) { 
    [[0 , 1 ],
     [1 , 1 ],
     [1 , 0 ],
     [1 , -1],
     [0 , -1],
     [-1, -1],
     [-1, 0 ],
     [-1, 1 ]]
  }
 
  let(:coordinate) {'2,3'}
  let(:x) { 2 }
  let(:y) { 3 }
  let(:cell) { described_class.new(coordinate, alive_cells) }

  it "should be intializable and should except a coordinate as a string (i.e. '3,2') and alive_cells" do
    c = Cell.new(coordinate, alive_cells)
    expect(c).to be_true
  end

  it 'x and y coordinates must be an integer' do
    x_to_s = '2'
    y_to_s = '3'
    expect(x_to_s).to_not eq(x)
    expect(y_to_s).to_not eq(y)
  end

  it 'cell x coordinate should be readable' do
    expect(cell.x_coord).to eq(x)
  end

  it 'cell y coordinate should be readable' do
    expect(cell.y_coord).to eq(y)
  end

  it 'knows if it alive' do
    expect(cell.alive?).to eq(true)
  end

  it 'is dead when no neighbors' do
    alive_cells.delete('2,4')
    alive_cells.delete('2,2')
    cell.next
    expect(cell).to_not be_alive
  end

  it 'is dead when one neighbor' do
    alive_cells.delete('4,3')
    alive_cells.delete('4,4')
    alive_cells.delete('3,4')
    alive_cells.delete('2,2')
    cell.next
    expect(cell).to_not be_alive
  end
 
  it 'is alive with two neighbors' do
    cell.next
    expect(cell).to be_alive
  end

  it 'is alive with three neighbors' do
    alive_cells['3,3'] = true
    cell.next
    expect(cell).to be_alive
  end

  it 'dies when has more than three neighbors' do
    alive_cells['3,3'] = true
    alive_cells['1,3'] = true
    cell.next
    expect(cell).to_not be_alive
  end

  it "should be able to count neighbors" do
    expect(cell.alive_neighbors_count).to eq(2) 
  end

  it "should be able return an array of it's dead neighbors" do
    dead_neighbors_array = ['3,4', '3,3', '3,2', '1,2', '1,3', '1,4']
    cell.dead_neighbors_coords.should =~ dead_neighbors_array
  end

  it "should return an array of neighbors coords" do
    cell_neighbors = ['2,4', '2,2']
    cell.alive_neighbors_coords.should =~ cell_neighbors
  end

  it "should return cell's coordinates as a string" do
    expect(cell.coordinates_as_str).to eq('2,3')
  end

  it "should be able to calulate the position of adjacent cell" do
    math = neighbor_math[3]
    expect(cell.calculate_coordinate_of_neighbor(math)).to eq('3,2')
  end

  
end

describe Board do
  let(:alive_cells){
    {
      '2,2'   => true,
      '2,3'   => true,
      '2,4'   => true,
    }
  }

  let(:board) { described_class.new(alive_cells) }

  it "Should be intializable and accepts alive cells as parameter" do
    b = Board.new(alive_cells)
    expect(b).to be_true
  end

  it "should be able to determine which cells are alive in next frame" do
    board.next
    next_board_alive_cells = board.alive_cells
    expect(next_board_alive_cells.has_key? '1,3').to be_true 
    expect(next_board_alive_cells.has_key? '2,3').to be_true 
    expect(next_board_alive_cells.has_key? '3,3').to be_true 
    expect(next_board_alive_cells.has_key? '2,4').to_not be_true 
    expect(next_board_alive_cells.has_key? '2,2').to_not be_true 
  end

  it "should be able to determine which dead cells come alive by reproduction" do
    reproduction_cells = {'3,3'=>true, '1,3' => true}
    board.reproduction.should be_eql(reproduction_cells)
  end

  it "@next_frame_alive_cells should be reset to an empty hash has after self.next is invoked" do
    empty_hash = {}
    board.next
    board.next_frame_alive_cells.should be_eql(empty_hash)
  end

  it "@dead_neighbors_cells_with_3_alive_neighbors should be reset to an empty hash after self.next is invoked" do
    empty_set = Set.new 
    board.next
    board.dead_neighbors_cells_with_3_alive_neighbors.should be_eql(empty_set)
  end

  it "When self.next is called twice the alive_cells should equal the intial alive_cells" do
    board.next
    board.next
    board.alive_cells.should be_eql(alive_cells)
  end

  it "should convert a set of coordinates to a hash with default values of true" do
    pending
  end

  it "should prep next frame" do
    pending
  end

  it "should be able to print the current frame" do
    pending
  end
end

