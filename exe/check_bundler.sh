#!/usr/bin/env ruby

require 'json'
require 'optparse'
require_relative '../lib/rails_bump/checker'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: check_bundle [options]"

  opts.on("-r", "--rails_version VERSION", "Specify the Rails version") do |v|
    options[:rails_version] = v
  end

  opts.on("-d", "--dependencies DEPENDENCIES", "Specify dependencies in the format 'gem1:version1,gem2:version2'") do |d|
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
  if options.size != 2
    puts option_parser
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts option_parser
  exit 1
end

checker = RailsBump::Checker::BundleLocallyCheck.new(
  rails_version: options[:rails_version],
  dependencies: options[:dependencies]
)

result = checker.check

puts result.output
puts ""
puts "Success: #{result.success?}"

exit(result.success ? 0 : 1)
