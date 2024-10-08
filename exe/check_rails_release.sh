#!/usr/bin/env ruby

require 'json'
require 'optparse'
require_relative '../lib/rails_bump/checker'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: check_rails_release [options]"

  opts.on("-r", "--rails_version VERSION", "Specify the Rails version") do |v|
    options[:rails_version] = v
  end
end

begin
  option_parser.parse!
  if options.size != 1
    puts option_parser
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts option_parser
  exit 1
end

checker = RailsBump::Checker::RailsReleaseCheck.new(
  rails_version: options[:rails_version]
)

result = checker.check

# puts "Reporting..."
# reporter = RailsBump::Checker::ResultReporter.new(result)
# reporter.report
# puts "Done reporting"

puts result.output
puts ""
puts "Success: #{result.success?}"

exit(0)
