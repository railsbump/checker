require "spec_helper"

RSpec.describe RailsBump::Checker::BundleLocallyCheck do
  describe "#gemfile_content" do
    subject(:content) { checker.send(:gemfile_content) }

    let(:checker) { described_class.new(rails_version: "7.1.0", dependencies: deps) }

    context "with a single version constraint" do
      let(:deps) { {"sidekiq" => ">= 6"} }

      it "formats the gem line with a single version argument" do
        expect(content).to include("gem 'sidekiq', '>= 6'")
      end
    end

    context "with multiple version constraints separated by a comma" do
      let(:deps) { {"some_gem" => ">= 1.0, < 2.0"} }

      it "formats the gem line with each constraint as a separate argument" do
        expect(content).to include("gem 'some_gem', '>= 1.0', '< 2.0'")
      end
    end

    context "when a dependency is rails" do
      let(:deps) { {"rails" => "6.0.0"} }

      it "skips the rails dependency (rails version comes from the checker)" do
        # Only the rails line from the header should appear, not a duplicate
        expect(content.scan("gem 'rails'").count).to eq(1)
        expect(content).to include("gem 'rails', '7.1.0'")
      end
    end
  end

  describe "#check" do
    let(:deps) do
      {"cronex" => ">= 0.13.0", "fugit" => "~> 1.8", "globalid" => ">= 1.0.1", "sidekiq" => ">= 6"}
    end
    let(:version) { "6.1.0" }

    before do
      @checker = RailsBump::Checker::BundleLocallyCheck.new(
        rails_version: version,
        dependencies: deps
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

        expect(result.output.downcase).to include(msg.downcase)
      end
    end

    context "when version of Rails exists and it is compatible" do
      it "installs dependencies without errors" do
        result = @checker.check

        expect(result.success?).to be_truthy
      end
    end

    context "when dependencies are empty" do
      let(:deps) { [] }

      it "installs dependencies without errors" do
        result = @checker.check

        expect(result.success?).to be_truthy
      end
    end

    context "when dependencies are clearly incompatible" do
      let(:deps) do
        {"administrate" => "0.1.0"}
      end

      it "returns success => false" do
        result = @checker.check

        expect(result.success?).to be_falsey
      end

      it "returns output with useful details" do
        msg = "Could not find compatible versions"

        result = @checker.check

        expect(result.output.downcase).to include(msg.downcase)
      end
    end
  end
end
