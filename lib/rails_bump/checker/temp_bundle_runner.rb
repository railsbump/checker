require "fileutils"
require "stringio"
require "tmpdir"

module RailsBump
  module Checker
    module TempBundleRunner
      private

      def run_bundle_install(gemfile_content:, installer_options: {})
        with_tmp_dir do |tmp_dir|
          gemfile_path = File.join(tmp_dir, "Gemfile")
          gemfile_lock_path = File.join(tmp_dir, "Gemfile.lock")

          File.write(gemfile_path, gemfile_content)

          puts "Checking with temporary Gemfile: \n\n#{gemfile_content}\n\n"

          definition = Bundler::Definition.build(gemfile_path, gemfile_lock_path, nil)

          capture_stdout do
            Bundler::Installer.install(gemfile_path, definition, **installer_options)
          end
        end
      end

      def with_tmp_dir
        FileUtils.mkdir_p("tmp")
        Dir.mktmpdir("checker-", "tmp") do |tmp_dir|
          yield tmp_dir
        end
      end

      def capture_stdout
        original_stdout = $stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = original_stdout
      end
    end
  end
end
