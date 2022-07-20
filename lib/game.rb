class Pos
  def initialize(size, x,y,value)
    @id = size * x + y
    @x = x
    @y = y
    @value = value
  end

  def inspect
    return "<Pos @id=#{@id} @x=#{@x} @y=#{@y} @value=#{@value}>"
  end
end


class Game
  attr :elements
  def initialize(size=4)
    @size = size
    @elements = []
    @init_level = 2
  end

  def create_init_value
    total_count = @size ** 2
    init_value_count = total_count * @init_level / 10
    zero_value_count = total_count - init_value_count

    values = []

    for i in (0..init_value_count-1)
      values.push(rand(1..4)*2)
    end
    
    for i in (0..zero_value_count-1)
      values.push(0)
    end

    values.shuffle
  end

  def create_elements
    pos_values = create_init_value

    max_nums = @size - 1
    for i in (0..max_nums)
      row = []
      for j in (0..max_nums)
        row.push(Pos.new(@size, i,j,pos_values[i*@size+j]))
      end
      @elements.push(row)
    end
  end

  def pick(x,y)
    @elements[x][y]
  end

  def 

end

# Game.new.create_init_value
g = Game.new
g.create_elements
p g.pick(0,1)