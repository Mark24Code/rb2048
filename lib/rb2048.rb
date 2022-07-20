# frozen_string_literal: true

require_relative "rb2048/version"

module Rb2048
  class Error < StandardError; end

  class InvalidValue < StandardError;end
  # Your code goes here...
end

module Rb2048

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
          row.push(pos_values[i*@size+j])
        end
        @elements.push(row)
      end
      @elements
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

    def create_zero_array(len)
      Array.new(len,0)
    end

    def update_line(arr)
      size = arr.length
      compact = merge(bigger_then_zero(arr))
      compact.concat(create_zero_array(size - compact.length))      
    end

    def render
      data = []

      for i in (0..@elements.length-1)
        row = []
        for j in (0..@elements.length-1)
          row.push(@elements[i][j])
        end
        data.push(row)
      end

      return {
        data: data,
        size: @size,
        level: @level
      }
    end
  end

  class Game

    def initialize
      @g = ::Rb2048::GameBoard.new
      @g.create_elements
    end

    def run
      redraw
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
      redraw
    end

    def redraw
      system('clear')
      resp = @g.render
      data = resp[:data]
      size = resp[:size]

      puts '-'*(size*4+10)
      for i in (0..size-1)
        for j in (0..size-1)
          printf "#{data[i][j]} \t"
        end
        printf "\n"
      end
    end
  end
end


game = ::Rb2048::Game.new
game.run