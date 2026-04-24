require "net/http"
require "uri"
require "json"

module RailsBump
  module Checker
    class ResultReporter
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

        endpoint = result_endpoint

        http = Net::HTTP.new(endpoint.host, endpoint.port)
        http.use_ssl = true if endpoint.scheme == "https"

        request = Net::HTTP::Post.new(endpoint.path, {"Content-Type" => "application/json"})
        request["RAILS-BUMP-API-KEY"] = @api_key

        request.body = {
          compat_id: @compat_id,
          rails_version: @rails_version,
          dependencies: @dependencies,
          success: @result.success?,
          strategy: @result.strategy,
          github_action_url: ENV["GITHUB_ACTION_URL"]
        }.to_json

        response = http.request(request)
        puts "Response: #{response.body} (Status: #{response.code})"
      end

      private

      def result_endpoint
        host = ENV["RAILS_BUMP_API_HOST"] || "http://localhost:3000"
        URI.parse("#{host}/results")
      end
    end
  end
end
