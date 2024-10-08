require 'fileutils'
require 'stringio'

module RailsBump
  module Checker
    class RailsReleaseCheck
      def initialize(opts = {})
        @rails_version = opts[:rails_version] || "9.1.0"
        @captured_output = ""
        @result = nil
      end

      # This method checks a compat by actually attempting to install the compat's dependencies with the compat's Rails version locally. If the installation fails, the compat is marked as incompatible. If it succeeds, it is marked as compatible. If any of the dependencies have native extensions that cannot be built, the compat is marked as inconclusive.
      # def check_with_bundler_locally
      def check
        puts "Checking compatibility:"
        puts "Rails version #{@rails_version}"

        begin
          # Ensure the tmp directory exists
          FileUtils.mkdir_p('tmp')

          # Set up the environment and definition
          Bundler.with_unbundled_env do
            @captured_output = try_bundle_install

            puts "✅ Compatible dependencies"
            @result = Result.new(
              rails_version: @rails_version,
              success: true,
              strategy: self.class.name,
              output: @captured_output
            )
          end
        rescue => err
          puts "💔 Incompatible dependencies"
          @result = Result.new(
            rails_version: @rails_version,
            success: false,
            strategy: self.class.name,
            output: "#{@captured_output}\n\nBundler error: #{err.message}\n\n#{err.backtrace}"
          )
        ensure
          puts "Cleaning up temporary files..."
          FileUtils.rm_rf('tmp')
        end

        @result
      end

      private

      # Create a temporary Gemfile with the specified dependencies
      def gemfile_content
        result = <<~GEMFILE
          source 'https://rubygems.org'
          gem 'rails', '#{@rails_version}'
        GEMFILE

        result
      end

      def try_bundle_install
        File.write('tmp/Gemfile', gemfile_content)

        puts "Checking with temporary Gemfile: \n\n#{gemfile_content}\n\n"

        # Build the definition from the temporary Gemfile
        definition = Bundler::Definition.build('tmp/Gemfile', 'tmp/Gemfile.lock', nil)

        original_stdout = $stdout
        $stdout = StringIO.new
        begin
          Bundler::Installer.install(Bundler.root, definition)
        ensure
          @captured_output = $stdout.string
          $stdout = original_stdout
        end

        @captured_output
      end
    end
  end
end
