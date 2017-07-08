require 'optparse'

module LogParse
  # Runner class handles parsing options and output
  class Runner
    class << self
      def debug(msg)
        $stderr.puts msg if options[:debug]
      end

      def options
        @defaults ||= {
          count:  :source_address,
          filter: { protocol: 'TLSv1' },
          debug:  false,
        }
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def optparse
        @optparse ||= OptionParser.new do |opts|
          opts.version = LogParse::VERSION
          opts.banner = 'Usage: log_parse [options] FILE'

          count_desc = "Count occurrences of FIELD. Default #{options[:count]}"
          opts.on('-c', '--count FIELD', LogParse::Parser.new.fields, count_desc) do |field|
            options[:count] = field.to_sym
          end

          filter_desc = "Filter by VALUE in FIELD. Default #{options[:filter].to_a.join('=')}"
          opts.on('-f', '--filter FIELD=VALUE', filter_desc) do |filter|
            field, value = filter.split('=')
            abort 'Filter must be specified as FIELD=VALUE' if [field, value].any?(&:nil?)
            abort 'Filter FIELD invalid' unless LogParse::Parser.new.fields.include?(field)
            options[:filter] = { field.to_sym => value }
          end

          debug_desc = "Run in debug mode. Default #{options[:debug]}"
          opts.on('-d', '--debug', debug_desc) do
            options[:debug] = true
          end
        end
      end

      def invoke!
        args = optparse.parse!
        debug "Invoked with options #{options}"
        abort 'Must specify a log FILE to parse' if args.empty?
        logfile = File.open(args.first, 'r')
        runner = new(logfile, options[:count], options[:filter])
        runner.invoke
        display runner.results
      end

      def display(results)
        debug "Log parsing errors: #{results.delete(:errors)}"
        debug "Log lines filtered: #{results.delete(:filtered)}"
        results.sort_by{ |_, val| - val }.each{ |key, val| puts "#{key}: #{val}" }
      end
    end

    attr_reader :logfile, :count_field, :filter_field, :filter_value, :parser, :results

    def initialize(logfile, count, filter)
      @logfile = logfile
      @count_field = count
      @filter_field = filter.keys.first
      @filter_value = filter.values.first
      @parser = LogParse::Parser.new
      @results = Hash.new(0)
    end

    def add_to_results(field)
      results[field] += 1
    end

    def invoke
      logfile.each do |line|
        extracted = parser.extract(line.strip)
        if extracted.empty?
          self.class.debug "Error parsing #{line}"
          add_to_results :errors
          next
        end
        if extracted[filter_field] != filter_value
          add_to_results :filtered
          next
        end
        add_to_results extracted[count_field]
      end
    end
  end
end
