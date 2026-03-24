require "rails_bump/checker/result_reporter"
require "rails_bump/checker/result"
require "webmock"

RSpec.describe RailsBump::Checker::ResultReporter do
  include WebMock::API

  before { WebMock.enable! }
  after do
    WebMock.reset!
    WebMock.disable!
  end

  let(:result) do
    instance_double(
      RailsBump::Checker::Result,
      compat_id: 123,
      dependencies: "[]",
      rails_version: "7.0.0",
      success?: true,
      output: "ok",
      strategy: "bundler"
    )
  end

  describe "#report" do
    context "when RAILS_BUMP_API_HOST changes at runtime" do
      it "uses the current ENV value" do
        stub_request(:post, "http://custom-host.test/results").to_return(status: 200, body: "ok")

        with_env("RAILS_BUMP_API_HOST" => "http://custom-host.test", "RAILS_BUMP_API_KEY" => "test-key") do
          described_class.new(result).report
        end

        assert_requested(:post, "http://custom-host.test/results")
      end
    end

    context "when RAILS_BUMP_API_HOST is not set" do
      it "defaults to localhost" do
        stub_request(:post, "http://localhost:3000/results").to_return(status: 200, body: "ok")

        with_env("RAILS_BUMP_API_HOST" => nil, "RAILS_BUMP_API_KEY" => "test-key") do
          described_class.new(result).report
        end

        assert_requested(:post, "http://localhost:3000/results")
      end
    end
  end
end
