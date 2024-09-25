require 'spec_helper'

RSpec.describe RailsBump::Checker::BundleLocallyCheck do
  describe '#check' do
    let(:deps) do
      {"cronex"=>">= 0.13.0", "fugit"=>"~> 1.8", "globalid"=>">= 1.0.1", "sidekiq"=>">= 6"}
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

        expect(result.output).to include(msg)
      end
    end

    context "when version of Rails exists and it is compatible" do
      it 'installs dependencies without errors' do
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
        {"rails"=>">= 4.2.0"}
      end
      
      it "returns success => false" do 
        result = @checker.check

        expect(result.success?).to be_falsey
      end

      it "returns output with useful details" do 
        msg = "You cannot specify the same gem twice"

        result = @checker.check

        expect(result.output).to include(msg)
      end
    end
  end
end