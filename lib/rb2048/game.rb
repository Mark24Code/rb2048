require "curses"
require_relative './game_board'


module Rb2048
  class Game
    def initialize(init_elements = nil)
      @backend = ::Rb2048::GameBoard.new
      @backend.create_elements(init_elements)

      @frontend = ::Rb2048::GameRender.new
    end

    def run
      main_loop
    end

    def main_loop
      # user event
      # data model
      # ui render
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
      @backend.__send__("#{direction}_merge")
      @frontend.render(@backend.tun_result)
    end
  end

  class GameRender
    def initialize
      @window_height = nil
      @window_width = nil

      init_screen
    end

    def init_screen
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.curs_set(0)  # Invisible cursor
      Curses.stdscr.keypad = true

      @window_height = Curses.lines
      @window_width = Curses.cols

      @win = Curses::Window.new(@window_height, @window_width, 0, 0)
      @win.box(0,0) # border
      title = " 2048 "
      @win.setpos(0, @window_width / 2 - title.length / 2)
      @win.addstr(title)
      @win.refresh
    end

    def main_loop
      loop do
        sleep 0.1
      end
    end

    def render(payload)
      data = payload[:data]
      size = payload[:size]
      
      level = payload[:level]
      score = payload[:score]
      status = payload[:status]

      start_timestamp = payload[:start_timestamp]
      end_timestamp = payload[:end_timestamp]

      tun_new_value = payload[:tun_new_value]

      @win.clear
      @win.box(0,0)
      # puts '-'*(size*4+10)
      # puts "score:#{resp[:score]}"
      # puts "status:#{resp[:status]}"
      # puts '-'*(size*4+10)
      
      buffer = []
      for row_index in (0..size-1)
        row_text = "|"
        for col_index in (0..size-1)
          row_text +=" "*2+"#{data[row_index][col_index]}"+" "*2+"|"
        end
        buffer.push(row_text)
      end

      start_row, start_col = [3,2]
      @win.setpos(start_row, start_col)
      @win.addstr("-"*buffer.first.length)
      buffer.each_with_index do |line,index|
        @win.setpos(start_row+index*2 + 2, start_col)
        @win.addstr("-" * line.length)
        @win.setpos(start_row+index*2 + 1, start_col)
        @win.addstr(line)
      end

      @win.refresh

      # TODO delete
      main_loop
      
    end

  end
end

::Rb2048::GameRender.new.render({data:[[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4]],size: 4})