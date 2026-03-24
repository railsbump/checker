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

        original_host = ENV["RAILS_BUMP_API_HOST"]
        original_key = ENV["RAILS_BUMP_API_KEY"]
        begin
          ENV["RAILS_BUMP_API_HOST"] = "http://custom-host.test"
          ENV["RAILS_BUMP_API_KEY"] = "test-key"
          described_class.new(result).report
        ensure
          ENV["RAILS_BUMP_API_HOST"] = original_host
          ENV["RAILS_BUMP_API_KEY"] = original_key
        end

        assert_requested(:post, "http://custom-host.test/results")
      end
    end

    context "when RAILS_BUMP_API_HOST is not set" do
      it "defaults to localhost" do
        stub_request(:post, "http://localhost:3000/results").to_return(status: 200, body: "ok")

        original_host = ENV["RAILS_BUMP_API_HOST"]
        original_key = ENV["RAILS_BUMP_API_KEY"]
        begin
          ENV.delete("RAILS_BUMP_API_HOST")
          ENV["RAILS_BUMP_API_KEY"] = "test-key"
          described_class.new(result).report
        ensure
          ENV["RAILS_BUMP_API_HOST"] = original_host
          ENV["RAILS_BUMP_API_KEY"] = original_key
        end

        assert_requested(:post, "http://localhost:3000/results")
      end
    end
  end
end
