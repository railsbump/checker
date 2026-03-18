require "fileutils"
require "stringio"
require "tmpdir"

module RailsBump
  module Checker
    class BundleLocallyCheck
      def initialize(opts = {})
        @rails_version = opts[:rails_version] || "9.1.0"
        @dependencies = opts[:dependencies] || []
        @compat_id = opts[:compat_id]
        @captured_output = ""
        @result = nil
      end

      # This method checks a compat by actually attempting to install the compat's dependencies with the compat's Rails version locally. If the installation fails, the compat is marked as incompatible. If it succeeds, it is marked as compatible. If any of the dependencies have native extensions that cannot be built, the compat is marked as inconclusive.
      # def check_with_bundler_locally
      def check
        puts "Checking compatibility:"
        puts "Rails version #{@rails_version}"
        puts "Dependencies: #{@dependencies}\n\n"

        if @dependencies.empty?
          puts "No dependencies to check"
          puts "✅ Compatible dependencies"
          return Result.new(
            rails_version: @rails_version,
            dependencies: @dependencies,
            compat_id: @compat_id,
            success: true,
            strategy: self.class.name,
            output: "No dependencies to check"
          )
        end

        begin
          # Set up the environment and definition
          Bundler.with_unbundled_env do
            with_tmp_dir do |tmp_dir|
              @captured_output = try_bundle_install(tmp_dir)
            end

            puts "✅ Compatible dependencies"
            @result = Result.new(
              rails_version: @rails_version,
              dependencies: @dependencies,
              compat_id: @compat_id,
              success: true,
              strategy: self.class.name,
              output: @captured_output
            )
          end
        rescue => err
          puts "💔 Incompatible dependencies"
          @result = Result.new(
            rails_version: @rails_version,
            dependencies: @dependencies,
            compat_id: @compat_id,
            success: false,
            strategy: self.class.name,
            output: "#{@captured_output}\n\nBundler error: #{err.message}\n\n#{err.backtrace}"
          )
        end

        @result
      end

      private

      def with_tmp_dir
        FileUtils.mkdir_p("tmp")
        Dir.mktmpdir("checker-", "tmp") do |tmp_dir|
          yield tmp_dir
        end
      end

      # Create a temporary Gemfile with the specified dependencies
      def gemfile_content
        result = <<~GEMFILE
          source 'https://rubygems.org'
          gem 'rails', '#{@rails_version}'
        GEMFILE

        @dependencies.each do |gem_name, gem_version|
          next if gem_name == "rails"
          versions = gem_version.split(",").map { |v| "'#{v.strip}'" }.join(", ")
          result += "gem '#{gem_name}', #{versions}\n"
        end

        result
      end

      def try_bundle_install(tmp_dir)

        # Clean Bundler cache
        `bundle clean --force`

        File.write(File.join(tmp_dir, "Gemfile"), gemfile_content)

        puts "Checking with temporary Gemfile: \n\n#{gemfile_content}\n\n"

        # Build the definition from the temporary Gemfile
        definition = Bundler::Definition.build(File.join(tmp_dir, "Gemfile"), File.join(tmp_dir, "Gemfile.lock"), nil)

        original_stdout = $stdout
        $stdout = StringIO.new
        begin
          Bundler::Installer.install(File.join(tmp_dir, "Gemfile"), definition, force: true, jobs: 4)
        ensure
          @captured_output = $stdout.string
          $stdout = original_stdout
        end

        @captured_output
      end
    end
  end
end
