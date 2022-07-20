# frozen_string_literal: true

require_relative "rb2048/version"

module Rb2048
  class Error < StandardError; end

  class InvalidValue < StandardError;end
  # Your code goes here...
end

require_relative "./rb2048/game"
