require "spec_helper"

RSpec.describe RailsBump::Checker::RailsReleaseCheck do
  describe "#with_tmp_dir" do
    it "creates a checker-scoped temporary directory under tmp" do
      checker = described_class.new(rails_version: "7.1.0")

      allow(FileUtils).to receive(:mkdir_p)
      expect(Dir).to receive(:mktmpdir).with("checker-", "tmp").and_yield("tmp/release-scope-test")

      yielded = nil
      checker.send(:with_tmp_dir) { |tmp_dir| yielded = tmp_dir }

      expect(yielded).to eq("tmp/release-scope-test")
    end
  end

  describe "#check" do
    let(:version) { "6.1.0" }

    before do
      @checker = RailsBump::Checker::RailsReleaseCheck.new(
        rails_version: version
      )
    end

    context "when version of Rails does not exist" do
      let(:version) { "999.9.9" }

      it "returns success => false" do
        result = @checker.check

        expect(result.success?).to be_falsey
      end

      it "returns output with useful details" do
        msg = "Could not find gem 'rails (= 999.9.9)' in rubygems"

        result = @checker.check

        expect(result.output).to include(msg)
      end
    end

    context "when version of Rails exists and it is compatible" do
      it "installs dependencies without errors" do
        result = @checker.check

        expect(result.success?).to be_truthy
      end
    end

    it "uses Dir.mktmpdir scoped under tmp" do
      checker = described_class.new(rails_version: "7.1.0")
      scoped_tmp_dir = "tmp/release-scope-test"

      allow(checker).to receive(:try_bundle_install).with(scoped_tmp_dir).and_return("ok")
      allow(Bundler).to receive(:with_unbundled_env).and_yield
      allow(FileUtils).to receive(:mkdir_p)
      expect(Dir).to receive(:mktmpdir).with("checker-", "tmp").and_yield(scoped_tmp_dir)

      checker.check
    end
  end
end
