require "curses"
require_relative './game_board'
require "thread"
require_relative './logger'


trap("INT") { ::Rb2048::Game.quit_game; exit 0 }

module Rb2048
  class Game

    def self.quit_game
      Curses.close_screen
      printf "Goodbye :P \n"
    end

    def initialize(init_elements = nil)
      @backend = ::Rb2048::GameBoard.new
      @backend.create_elements(init_elements)

      @render = ::Rb2048::GameRender.new
      @window = @render.window

      @frame_data_channel = Queue.new
      @refresh_rate = 60
      @frame_delta = 1.0 / @refresh_rate

      @io_data_channel = Queue.new

      @logger = LoggerMan
    end

    def run
      init_game
      main_loop
    end

    def init_game
      @logger.log("INIT", "start")
      @frame_data_channel << @backend.tun_result
    end

    def main_loop
      key_listener_thr = Thread.new { self.key_listener }
      action_thr = Thread.new { self.action }
      render_thr = Thread.new { self.render }

      [key_listener_thr,action_thr, render_thr].map(&:join)
    end

    def action
      while (command = @io_data_channel.shift)
        if command == :QUIT
          self.class.quit_game
          exit 0
        else
          @backend.__send__("#{command.to_s.downcase}_merge")
          frame_data = @backend.tun_result
          @frame_data_channel << frame_data
        end
      end

    end

    def key_listener()
      while true
        command = nil

        k = @window.getch
        if k ==  Curses::KEY_UP || k ==  "w"
          command =  :UP
        elsif k ==  Curses::KEY_DOWN || k ==  "s"
          command =  :DOWN
        elsif k ==  Curses::KEY_LEFT || k ==  "a"
          command =  :LEFT
        elsif k ==  Curses::KEY_RIGHT || k ==  "d"
          command =  :RIGHT
        elsif k ==  "q"
          command = :QUIT
        else
        end

        @io_data_channel << command if command
        sleep 0.08
      end
    end

    def render
      while (frame_data = @frame_data_channel.shift)
        break if frame_data == :done
        @render.draw(frame_data) if frame_data
        sleep 0.16
      end
    end
  end

  class GameRender
    attr :window
    def initialize
      @window = nil
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

      @window = Curses::Window.new(@window_height, @window_width, 0, 0)
      @window.refresh
    end

    def draw(payload)
      data = payload[:data]
      size = payload[:size]

      level = payload[:level]
      score = payload[:score]
      last_action = payload[:last_action]
      status = payload[:status]

      start_timestamp = payload[:start_timestamp]
      end_timestamp = payload[:end_timestamp]

      tun_new_value = payload[:tun_new_value]

      @window.clear

      # display board content buffer
      buffer = []
      number_width = score.to_s.length * 2
      for row_index in (0..size-1)
        row_text = "|"
        for col_index in (0..size-1)

          n = data[row_index][col_index]
          n_text = " "*(number_width - n.to_s.length) + n.to_s
          row_text +=" "*2+"#{n_text}"+" "*2+"|"
        end
        buffer.push(row_text)
      end

      # x,y offset counter
      row,col = [0,1]

      # title
      content_width = buffer.first.length
      title = "-- Ruby 2048 --"
      left_offset = (content_width - title.length) / 2
      row = row + 1
      @window.setpos(row, left_offset)
      @window.addstr("-- Ruby 2048 --")

      # board
      row = row + 2
      start_row, start_col = [row,1]
      @window.setpos(start_row, start_col)
      @window.addstr("-"*buffer.first.length)
      buffer.each_with_index do |line,index|
        @window.setpos(start_row+index*2 + 2, start_col)
        @window.addstr("-" * line.length)
        @window.setpos(start_row+index*2 + 1, start_col)
        @window.addstr(line)
      end

      # score
      row = row + buffer.length * 2 + 2
      @window.setpos(row, col)
      @window.addstr("Score:\t#{score}\t\t#{"You:"+last_action.to_s if last_action}")

      # status

      row = row + 1
      @window.setpos(row, col)
      result_text = nil
      if status == 1
        result_text = "Congratulation! You have got 2048!!! :D"
      elsif status == -1
        result_text = "YOU LOST :("
      end
      @window.addstr(result_text)

      # control
      row = row + 2
      @window.setpos(row, col)
      @window.addstr("Control: W(↑) A(←) S(↓) D(→) Q(quit) R(Restart)")
      @window.refresh
    end
  end
end
