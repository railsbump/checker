# frozen_string_literal: true

require "json"
require "open3"
require "rbconfig"
require "tmpdir"
require "spec_helper"

RSpec.describe "CLI scripts" do
  let(:ruby) { RbConfig.ruby }
  let(:stubs_file) { File.expand_path("support/cli_test_stubs.rb", __dir__) }
  let(:bundler_script) { File.expand_path("../exe/check_bundler.sh", __dir__) }
  let(:rails_release_script) { File.expand_path("../exe/check_rails_release.sh", __dir__) }

  def run_script(script_path, args:, success:, sentry_log: nil, sentry_dsn: nil)
    env = {
      "CHECKER_TEST_SUCCESS" => success.to_s
    }
    env["CHECKER_TEST_SENTRY_LOG"] = sentry_log if sentry_log
    env["SENTRY_DSN"] = sentry_dsn if sentry_dsn

    Open3.capture3(
      env,
      ruby,
      "-r",
      stubs_file,
      script_path,
      *args
    )
  end

  describe "check_bundler.sh" do
    let(:valid_args) do
      [
        "--rails_version",
        "7.1.0",
        "--dependencies",
        "{\"sidekiq\":\"~> 7.0\"}"
      ]
    end

    it "returns exit code 0 when the check succeeds" do
      _out, _err, status = run_script(bundler_script, args: valid_args, success: true)

      expect(status.exitstatus).to eq(0)
    end

    it "returns non-zero and reports to Sentry when the check fails" do
      Dir.mktmpdir do |dir|
        sentry_log = File.join(dir, "sentry.json")
        _out, _err, status = run_script(
          bundler_script,
          args: valid_args,
          success: false,
          sentry_log: sentry_log,
          sentry_dsn: "https://examplePublicKey@o0.ingest.sentry.io/0"
        )

        expect(status.exitstatus).to eq(1)
        expect(File.exist?(sentry_log)).to be(true)
        payload = JSON.parse(File.read(sentry_log))
        expect(payload.fetch("check_name")).to eq("check_bundler")
      end
    end

    it "returns non-zero for invalid arguments" do
      _out, _err, status = run_script(bundler_script, args: [], success: true)

      expect(status.exitstatus).to eq(1)
    end
  end

  describe "check_rails_release.sh" do
    let(:valid_args) { ["--rails_version", "7.1.0"] }

    it "returns exit code 0 when the check succeeds" do
      _out, _err, status = run_script(rails_release_script, args: valid_args, success: true)

      expect(status.exitstatus).to eq(0)
    end

    it "returns non-zero and reports to Sentry when the check fails" do
      Dir.mktmpdir do |dir|
        sentry_log = File.join(dir, "sentry.json")
        _out, _err, status = run_script(
          rails_release_script,
          args: valid_args,
          success: false,
          sentry_log: sentry_log,
          sentry_dsn: "https://examplePublicKey@o0.ingest.sentry.io/0"
        )

        expect(status.exitstatus).to eq(1)
        expect(File.exist?(sentry_log)).to be(true)
        payload = JSON.parse(File.read(sentry_log))
        expect(payload.fetch("check_name")).to eq("check_rails_release")
      end
    end

    it "returns non-zero for invalid arguments" do
      _out, _err, status = run_script(rails_release_script, args: [], success: true)

      expect(status.exitstatus).to eq(1)
    end
  end
end
