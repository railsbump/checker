# frozen_string_literal: true

module RailsBump
  module Checker
    module SentryNotifier
      module_function

      def capture_check_failure(check_name:, result:)
        return unless sentry_enabled?

        init_sentry

        Sentry.with_scope do |scope|
          scope.set_tags(component: "cli", check: check_name)
          scope.set_context("check_result", {
            success: result.success?,
            rails_version: result.rails_version,
            compat_id: result.compat_id,
            dependencies: result.dependencies
          })
          scope.set_extras(output: result.output.to_s)

          Sentry.capture_message("#{check_name} failed", level: :error)
        end
      rescue LoadError => e
        warn "Sentry reporting skipped (sentry-ruby not available): #{e.message}"
      rescue => e
        warn "Sentry reporting failed: #{e.class}: #{e.message}"
      end

      def sentry_enabled?
        !ENV.fetch("SENTRY_DSN", "").strip.empty?
      end

      def init_sentry
        return if defined?(@sentry_initialized) && @sentry_initialized

        require "sentry-ruby"

        Sentry.init do |config|
          config.dsn = ENV.fetch("SENTRY_DSN", nil)
          config.environment = ENV.fetch("SENTRY_ENVIRONMENT", ENV.fetch("RACK_ENV", "development"))
          config.release = sentry_release
        end

        @sentry_initialized = true
      end

      def sentry_release
        release = ENV.fetch("SENTRY_RELEASE", "").strip
        release = ENV.fetch("HEROKU_RELEASE_VERSION", "").strip if release.empty?
        release.empty? ? nil : release
      end
    end
  end
end
