require "spec_helper"

RSpec.describe RailsBump::Checker::RailsReleaseCheck do
  describe "#gemfile_content" do
    subject(:content) { checker.send(:gemfile_content) }

    context "with an exact rails version" do
      let(:checker) { described_class.new(rails_version: "7.1.0") }

      it "includes the rails gem with that version" do
        expect(content).to include("gem 'rails', '7.1.0'")
      end
    end

    context "with a pessimistic version constraint" do
      let(:checker) { described_class.new(rails_version: "~> 7.1.0") }

      it "includes the rails gem with that constraint" do
        expect(content).to include("gem 'rails', '~> 7.1.0'")
      end
    end

    context "with a multi-constraint rails version" do
      let(:checker) { described_class.new(rails_version: ">= 7.0, < 8.0") }

      it "formats each constraint as a separate argument" do
        expect(content).to include("gem 'rails', '>= 7.0', '< 8.0'")
      end
    end
  end

  describe "#tmp_dir" do
    it "is unique per instance so concurrent runs do not collide" do
      checker_a = described_class.new(rails_version: "7.1.0")
      checker_b = described_class.new(rails_version: "7.2.0")

      expect(checker_a.send(:tmp_dir)).not_to eq(checker_b.send(:tmp_dir))
    end

    it "is stable within the same instance" do
      checker = described_class.new(rails_version: "7.1.0")

      expect(checker.send(:tmp_dir)).to eq(checker.send(:tmp_dir))
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
  end
end
