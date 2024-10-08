# frozen_string_literal: true

require File.expand_path("lib/rails_bump/checker/version", __dir__)

Gem::Specification.new do |spec|
  spec.name = "rails_bump-checker"
  spec.version = RailsBump::Checker::VERSION
  spec.authors = ["Ernesto Tagwerker"]
  spec.email = ["ernesto+github@ombulabs.com"]

  spec.summary = "It helps railsbump.org check for compatibility."
  spec.description = "It uses GitHub Actions to test for compatibility using different strategies."
  spec.homepage = "https://github.com/railsbump/checker"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 1.9.3"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/railsbump/checker"
  spec.metadata["changelog_uri"] = "https://github.com/railsbump/checker"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
