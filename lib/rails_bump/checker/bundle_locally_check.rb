require 'fileutils'
require 'stringio' 

module RailsBump
  module Checker
    class BundleLocallyCheck
      def initialize(opts = {})
        @rails_version = opts[:rails_version] || "9.1.0"
        @dependencies = opts[:dependencies] || []
      end

      # This method checks a compat by actually attempting to install the compat's dependencies with the compat's Rails version locally. If the installation fails, the compat is marked as incompatible. If it succeeds, it is marked as compatible. If any of the dependencies have native extensions that cannot be built, the compat is marked as inconclusive.
      # def check_with_bundler_locally
      def check
        captured_output = ""

        puts "Checking compatibility:"
        puts "Rails version #{@rails_version}"
        puts "Dependencies: #{@dependencies}\n\n"  

        begin
          # Ensure the tmp directory exists
          FileUtils.mkdir_p('tmp')

          # Set up the environment and definition
          Bundler.with_unbundled_env do
            # Create a temporary Gemfile with the specified dependencies
            gemfile_content = <<~GEMFILE
              source 'https://rubygems.org'
              gem 'rails', '#{@rails_version}'
            GEMFILE

            @dependencies.each do |gem_name, gem_version|
              gemfile_content += "gem '#{gem_name}', '#{gem_version}'\n"
            end

            File.write('tmp/Gemfile', gemfile_content)

            puts "Checking with temporary Gemfile: \n\n#{gemfile_content}\n\n"

            # Build the definition from the temporary Gemfile
            definition = Bundler::Definition.build('tmp/Gemfile', 'tmp/Gemfile.lock', nil)
            
            original_stdout = $stdout
            $stdout = StringIO.new
            begin
              Bundler::Installer.install(Bundler.root, definition)
              captured_output = $stdout.string
            ensure
              $stdout = original_stdout
            end

            puts "✅ Compatible dependencies"
            Result.new(success: true, output: captured_output)
          end
        rescue Bundler::BundlerError => e
          puts "💔 Incompatible dependencies"
          Result.new(success: false, output: "#{captured_output}\n\nBundler error: #{e.message}\n\n#{e.backtrace}")
        ensure
          puts "Cleaning up temporary files..."
          FileUtils.rm_rf('tmp')
        end
      end
    end
  end
end
