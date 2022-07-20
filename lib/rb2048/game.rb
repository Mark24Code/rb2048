require_relative './game_board'

module Rb2048
  class Game
    def initialize(init_elements = nil)
      @g = ::Rb2048::GameBoard.new
      @g.create_elements(init_elements)
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
        redraw
      end
    end

    def action(direction)
      @g.__send__("#{direction}_merge")
      redraw
    end



    def redraw
      # system('clear')
      resp = @g.tun_result
      data = resp[:data]
      size = resp[:size]
      
      puts '-'*(size*4+10)
      puts "score:#{resp[:score]}"
      puts "status:#{resp[:status]}"
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
