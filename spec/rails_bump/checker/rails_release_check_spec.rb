require "spec_helper"

RSpec.describe RailsBump::Checker::RailsReleaseCheck do
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

        puts result.output
        expect(result.success?).to be_truthy
      end
    end
  end
end
