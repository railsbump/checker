# frozen_string_literal: true

require "json"
require_relative "../../lib/rails_bump/checker"

module CliTestStubs
  module_function

  def success?
    ENV.fetch("CHECKER_TEST_SUCCESS", "true") == "true"
  end

  def result
    RailsBump::Checker::Result.new(
      rails_version: "7.1.0",
      dependencies: {"sidekiq" => ">= 6"},
      compat_id: "123",
      success: success?,
      strategy: "CliTestStubs",
      output: "stubbed output"
    )
  end
end

module RailsBump
  module Checker
    class BundleLocallyCheck
      def check
        CliTestStubs.result
      end
    end

    class RailsReleaseCheck
      def check
        CliTestStubs.result
      end
    end

    module SentryNotifier
      module_function

      def capture_check_failure(check_name:, result:)
        path = ENV.fetch("CHECKER_TEST_SENTRY_LOG", nil)
        return unless path

        payload = {
          check_name: check_name,
          success: result.success?,
          rails_version: result.rails_version,
          compat_id: result.compat_id
        }

        File.write(path, JSON.dump(payload))
      end
    end
  end
end
