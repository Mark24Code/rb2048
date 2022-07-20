# frozen_string_literal: true

require "test_helper"

class TestRb2048 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rb2048::VERSION
  end
end

class Position < Minitest::Test
  def setup
    @p = ::Rb2048::Pos.new(4,0,1,2)
  end

  def test_new_position
    assert @p
  end

  def test_position_inspect
    position_text = @p.inspect
    assert position_text, "<Pos @id=1 @x=0 @y=1 @value=2>"
  end

end

class GameBoard < Minitest::Test

  def setup
    @size = 4
    @level = 2
    @g = ::Rb2048::GameBoard.new(4)
  end

  def test_create_elements
    assert @g.elements.length, @size ** 2
  end

  def test_zero_elements_count

    zero_value_count = @size ** 2 - @size ** 2 * @level / 10

    init_zero_count = 0
    @g.elements.each do |e|
      if e.value == 0
        init_value_count += 1
      end
    end

    assert init_zero_count, zero_value_count
  end

  def test_merge

    p @g.merge([2,2,2,2,2])

    assert true
  end

end