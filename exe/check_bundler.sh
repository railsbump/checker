#!/usr/bin/env ruby

require 'json'
require 'optparse'
require_relative '../lib/rails_bump/checker'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: check_bundle [options]"

  opts.on("-id", "--compat_id COMPAT_ID", "Specify the RailsBump compat id") do |compat_id|
    options[:compat_id] = compat_id
  end


  opts.on("-r", "--rails_version VERSION", "Specify the Rails version") do |v|
    options[:rails_version] = v
  end

  opts.on("-d", '--dependencies DEPENDENCIES", "Specify dependencies in JSON format \'{"cronex":"<= 0.13.0","fugit":"~> 1.8","globalid":"<= 1.0.1","sidekiq":"<= 6"}\'') do |d|
    begin
      puts "Parsing JSON: #{d}"
      options[:dependencies] = JSON.parse(d)
    rescue JSON::ParserError => e
      puts "Invalid JSON format for dependencies: #{e.message} -- Parsing #{d}"
      exit 1
    end
  end
end

begin
  option_parser.parse!
  unless options.size >= 2 && options.size <= 3
    puts option_parser
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts option_parser
  exit 1
end

checker = RailsBump::Checker::BundleLocallyCheck.new(
  rails_version: options[:rails_version],
  dependencies: options[:dependencies],
  compat_id: options[:compat_id]
)

result = checker.check

puts "Reporting..."
reporter = RailsBump::Checker::ResultReporter.new(result)
reporter.report
puts "Done reporting"

puts result.output
puts ""
puts "Success: #{result.success?}"

exit(result.success ? 0 : 1)
