module RailsBump
  module Checker
    class Result
      attr_reader :success, :output

      def initialize(success: false, output: "")
        @success = success
        @output = output
      end

      def success?
        !!success
      end
    end
  end
end