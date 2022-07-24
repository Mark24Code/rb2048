# frozen_string_literal: true

require "test_helper"

class TestRb2048 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rb2048::VERSION
  end
end

class GameBoard < Minitest::Test

  def setup
    @size = 4
    @level = 2
    @g = ::Rb2048::GameBoard.new(4)
  end

  def test_merge_once
    r1 = @g.merge_once([8,2,2,8])

    assert_equal r1, [8,4,8]
  end

  def test_merge
    m = lambda { |arr| @g.merge(arr)}

    r1 = m.call([0,0,0,0])
    assert_equal r1, [0]

    r2 = m.call([2,2,2,2])
    assert_equal r2, [8]

    r3 = m.call([2,16,16,2])

    assert_equal r3, [2,32,2]
  end

  def test_check_game_status
    data = [
      16, 8, 32, 4,
      8, 2, 4, 32,
      2, 64, 16, 4,
      16, 2, 8, 2]

    g = ::Rb2048::GameBoard.new
    g.create_elements(data)

    g.check_game_status
    status = g.status
    assert_equal -1, status
    
  end
end
