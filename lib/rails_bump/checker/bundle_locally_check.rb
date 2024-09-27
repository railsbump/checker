require 'fileutils'
require 'stringio'

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

        begin
          # Ensure the tmp directory exists
          FileUtils.mkdir_p('tmp')

          # Set up the environment and definition
          Bundler.with_unbundled_env do
            @captured_output = try_bundle_install

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
        rescue Bundler::BundlerError => e
          puts "💔 Incompatible dependencies"
          @result = Result.new(
            rails_version: @rails_version,
            dependencies: @dependencies,
            compat_id: @compat_id,
            success: false,
            strategy: self.class.name,
            output: "#{@captured_output}\n\nBundler error: #{e.message}\n\n#{e.backtrace}"
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

        @dependencies.each do |gem_name, gem_version|
          result += "gem '#{gem_name}', '#{gem_version}'\n"
        end

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
          @captured_output = $stdout.string
        ensure
          $stdout = original_stdout
        end

        @captured_output
      end
    end
  end
end
