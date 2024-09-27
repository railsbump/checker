module RailsBump
  module Checker
    class Result
      attr_reader :compat_id, :dependencies, :output, :rails_version, :strategy, :success

      def initialize(success: false, output: "", rails_version:, dependencies:, compat_id: nil, strategy:)
        @success = success
        @output = output
        @rails_version = rails_version
        @dependencies = dependencies
        @compat_id = compat_id
        @strategy = strategy
      end

      def success?
        !!success
      end
    end
  end
end