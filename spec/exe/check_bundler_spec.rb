require "spec_helper"
require "open3"

RSpec.describe "exe/check_bundler.sh" do
  def run_script(*args)
    Open3.capture3(
      File.expand_path("../../exe/check_bundler.sh", __dir__),
      *args
    )
  end

  context "with no arguments" do
    it "prints usage and exits with 0" do
      stdout, _stderr, status = run_script

      expect(stdout).to include("Usage:")
      expect(status.exitstatus).to eq(0)
    end
  end

  context "with only one flag" do
    it "prints usage when only -r is given" do
      stdout, _stderr, status = run_script("-r", "7.2")

      expect(stdout).to include("Usage:")
      expect(status.exitstatus).to eq(0)
    end
  end

  context "with -i short flag" do
    it "accepts -i and passes compat_id through" do
      stdout, _stderr, status = run_script("-i", "123", "-r", "7.2")

      expect(stdout).to include("Success: true")
      expect(status.exitstatus).to eq(0)
    end
  end

  context "with --compat_id long flag" do
    it "accepts --compat_id and passes compat_id through" do
      stdout, _stderr, status = run_script("--compat_id", "123", "-r", "7.2")

      expect(stdout).to include("Success: true")
      expect(status.exitstatus).to eq(0)
    end
  end

  context "with an invalid flag" do
    it "prints usage and exits with 1" do
      stdout, _stderr, status = run_script("--bogus")

      expect(stdout).to include("Usage:")
      expect(status.exitstatus).to eq(1)
    end
  end

  context "with invalid JSON for -d" do
    it "prints an error and exits with 1" do
      stdout, _stderr, status = run_script("-r", "7.2", "-i", "1", "-d", "not-json")

      expect(stdout).to include("Invalid JSON format")
      expect(status.exitstatus).to eq(1)
    end
  end
end
