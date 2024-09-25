# frozen_string_literal: true

require "bundler"
require_relative "checker/version"
require_relative "checker/result"
require_relative "checker/bundle_locally_check"

module RailsBump
  module Checker
    class Error < StandardError; end
    # Your code goes here...
  end
end
