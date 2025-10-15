# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

namespace :spec do
  task :vcr_record_new do
    ENV["VCR_RECORD_NEW"] = "true"
    Rake::Task[:spec].invoke
  end
end
