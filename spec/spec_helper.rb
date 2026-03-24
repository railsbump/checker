# frozen_string_literal: true

if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    track_files "lib/**/*.rb"
  end
end

require "rails_bump/checker"

def with_env(overrides)
  originals = overrides.each_key.to_h { |key| [key, ENV[key]] }
  overrides.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  yield
ensure
  originals.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
