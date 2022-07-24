require_relative './logger'

module Rb2048
  class GameBoard
    attr :elements
    def initialize(size=4, level = 2,win_standard=2048)
      @size = size
      @elements = []

      @level = level
      @score = 0
      @start_timestamp = nil
      @end_timestamp = nil
      @status = 0 # -1 lost, 0 init/running, 1 win
      @win_standard = win_standard

      @logger = LoggerMan
    end

    def create_init_value
      total_count = @size ** 2
      init_value_count = total_count * @level / 10
      zero_value_count = total_count - init_value_count

      values = []
      for i in (0..init_value_count-1)
        values.push(rand_init)
      end

      for i in (0..zero_value_count-1)
        values.push(0)
      end

      values.shuffle
    end

    def create_elements(init_elements = nil)
      pos_values = init_elements || create_init_value

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
      @logger.log("Left", @elements)
      for row_index in (0..@size-1)
        row = @elements[row_index]
        update_row = update_line(row)
        @elements[row_index] = update_row
      end
      @elements
    end

    def right_merge
      @logger.log("Right", @elements)
      for row_index in (0..@size-1)
        row = @elements[row_index]
        update_row = update_line(row.reverse)
        @elements[row_index] = update_row.reverse
      end
      @elements
    end


    def up_merge
      @logger.log("UP", @elements)
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
      @logger.log("Down", @elements)
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

      if arr.length <= 1
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

    def collect_max_score(result)
      max_ = result.max
      if max_
        @score = @score > result.max ? @score : result.max
      end
    end

    def merge(arr)
      if arr.length <= 0
         return arr
      end
      result = arr.clone

      while true
        before = result.clone
        result = merge_once(result)
        break if before == result
      end

      collect_max_score(result)

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

    def start_timer
      @start_timestamp = Time.now.to_i
    end

    def close_tiemr
      @end_timestamp = Time.now.to_i
    end

    def check_game_status
      if @score >= @win_standard
        return @status = 1
      else
        # check  x、y direction，lengt == uniq.length
        # check x
        dead_road = @size * 2

        for row_index in (0..@size-1)
          row = @elements[row_index]
          compact = bigger_then_zero(row)
          if compact.length == compact.uniq.length
            dead_road -= 1
          end
        end

        for col_index in (0..@size-1)
          col = []
          for row_index in (0..@size-1)
            col.push(@elements[col_index][row_index])
          end

          compact = bigger_then_zero(col)
          if compact.length > 0 && compact.length == compact.uniq.length
            dead_road -= 1
          end
        end

        if dead_road == 0
          @status = -1
        end
      end
    end

    def rand_init
      2 ** rand(1..4)
    end

    def create_new_number
      zeros = all_zero_pos
      if zeros.length > 0
        x,y = zeros.sample
        new_number = rand_init
        @elements[x][y] = new_number
        {pos:[x,y], value: new_number}
      end

      return nil
    end

    def all_zero_pos
      zeros = []
      for i in (0..@size-1)
        for j in (0..@size-1)
          e = @elements[i][j]
          if e == 0
            zeros.push([i,j])
          end
        end
      end

      zeros
    end

    def tun_result
      tun_new_value = create_new_number

      check_game_status

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
        level: @level,
        score: @score,
        start_timestamp: @start_timestamp,
        end_timestamp: @end_timestamp,
        status: @status,
        tun_new_value: tun_new_value
      }
    end
  end
end
