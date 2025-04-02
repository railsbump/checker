require "net/http"
require "uri"
require "json"

module RailsBump
  module Checker
    class ResultReporter
      RAILS_BUMP_HOST = ENV["RAILS_BUMP_API_HOST"] || "http://localhost:3000"
      RESULT_ENDPOINT = URI.parse("#{RAILS_BUMP_HOST}/results")

      def initialize(result)
        @result = result
        @compat_id = result.compat_id.to_i
        @dependencies = result.dependencies
        @rails_version = result.rails_version
        @api_key = ENV["RAILS_BUMP_API_KEY"].to_s
      end

      def report
        return puts "Skipping report because compat_id was not provided" if @compat_id.zero?
        return puts "Skipping report because RAILS_BUMP_API_KEY was not provided" if @api_key.empty?

        http = Net::HTTP.new(RESULT_ENDPOINT.host, RESULT_ENDPOINT.port)
        http.use_ssl = true if RESULT_ENDPOINT.scheme == "https"

        request = Net::HTTP::Post.new(RESULT_ENDPOINT.path, {"Content-Type" => "application/json"})
        request["RAILS-BUMP-API-KEY"] = @api_key

        request.body = {
          compat_id: @compat_id,
          rails_version: @rails_version,
          dependencies: @dependencies,
          success: @result.success?,
          output: @result.output,
          strategy: @result.strategy,
          github_action_url: ENV["GITHUB_ACTION_URL"]
        }.to_json

        response = http.request(request)
        puts "Response: #{response.body} (Status: #{response.code})"
      end
    end
  end
end
