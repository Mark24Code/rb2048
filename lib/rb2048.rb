# frozen_string_literal: true

require_relative "rb2048/version"

module Rb2048
  class Error < StandardError; end

  class InvalidValue < StandardError;end
  # Your code goes here...
end

module Rb2048
  class Pos
    attr :id,:x,:y,:value
    def initialize(size, x,y,value)
      @id = size * x + y
      @x = (x <= size -1 && x >= 0) ? x : rise_error('Pos: x out of bounds ( 0 <= x <= size - 1)')
      @y = (y <= size -1 && y >= 0) ? y : rise_error('Pos: y out of bounds ( 0 <= y <= size - 1)')
      @value = value % 2 == 0 ? value : rise_error('Pos: need `even number`')
    end

    def rise_error(msg)
      throw ::Rb2048::InvalidValue, msg
    end

    def inspect
      return "<Pos @id=#{@id} @x=#{@x} @y=#{@y} @value=#{@value}>"
    end
  end


  class GameBoard
    attr :elements
    def initialize(size=4, level = 2)
      @size = size
      @elements = []
      @level = level
    end

    def create_init_value
      total_count = @size ** 2
      init_value_count = total_count * @level / 10
      zero_value_count = total_count - init_value_count

      values = []

      for i in (0..init_value_count-1)
        values.push(2 ** rand(1..4))
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
          # row.push(Pos.new(@size, i,j,pos_values[i*@size+j]))
          row.push(pos_values[i*@size+j])
        end
        @elements.push(row)
      end

      @elements
    end

    def pick(x,y)
      @elements[x][y]
    end

    def bigger_then_zero(arr)
      arr.filter { |e| e > 0}
    end

    def left_merge
      for row_index in (0..@size-1)
        row = @elements[row_index]
        update_row = update_line(row)
        @elements[row_index] = update_row
      end
      @elements
    end

    def right_merge
      for row_index in (0..@size-1)
        row = @elements[row_index]
        update_row = update_line(row.reverse)
        @elements[row_index] = update_row.reverse
      end
      @elements
    end

    
    def up_merge
      
      for col_index in (0..@size-1)
        col = []
        for row_index in (0..@size-1)
          col.push(@elements[row_index][col_index])
        end
        update_col = update_line(col)

        for row_index in (0..@size-1)
          @elements[row_index][col_index] = update_col[row_index]
        end
      end
      @elements
    end

    def down_merge
      for col_index in (0..@size-1)
        col = []
        for row_index in (0..@size-1)
          col.push(@elements[row_index][col_index])
        end

        update_col = update_line(col.reverse).reverse
        # update
        for row_index in (0..@size-1)
          @elements[row_index][col_index] = update_col[row_index]
        end
      end
    end

    def merge_once(arr)

      if arr.length == 1
        return arr
      end

      data = arr.clone
      result = []
      first = nil
      next_ = nil

      while !data.empty?
        if first == nil
          first = data.shift
        end

        if next_ == nil
          next_ = data.shift
        end

        if first != next_
          result.push(first)
          if next_
            data.unshift(next_)
          end
          first = nil
          next_ = nil
        else
          result.push(first + next_)

          first = nil
          next_ = nil
        end
      end

      return result
    end


    def merge(arr)

      result = arr.clone
      while result.length != result.uniq.length
        result = merge_once(result)
      end

      return result
    end

    def zero_array(len)
      Array.new(len,0)
    end

    def update_line(arr)
      size = arr.length
      compact = merge(bigger_then_zero(arr))
      compact.concat(zero_array(size - compact.length))      
    end

    def draw
      puts '-'*(@elements.length*4+10)
      for i in (0..@elements.length-1)
        for j in (0..@elements.length-1)
          printf "#{@elements[i][j]} \t"
        end
        printf "\n"
      end
    end
  end

  class Game

    def initialize
      @g = ::Rb2048::GameBoard.new
      @g.create_elements
    end
    def run
      @g.draw
      while true
         command = gets.chomp
         dispatch(command)
      end
    end

    def dispatch(command)
      case command
      when 'w'
        action('up')
      when 'a'
        action('left')
      when 'd'
        action('right')
      when 's'
        action('down')
      when 'q'
        system('clear')
        puts 'exit'
        exit 0
      else

      end
    end

    def action(direction)
      @g.__send__("#{direction}_merge")
      @g.draw
    end
  end
end


# p g.left_merge
# p g.right_merge
# p g.up_merge

game = ::Rb2048::Game.new

game.run
# # game.action("left")
# # game.action("right")
# # game.action("up")
# game.action("down")