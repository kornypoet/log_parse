require 'optparse'

module LogParse
  class Runner
    class << self
      def default_options
        @default_options ||= {
          count: 'source_address',
          filter: { protocol: 'TLSv1' },
        }
      end

      def optparse
        @optparse ||= OptionParser.new do |opts|
          opts.version = LogParse::VERSION
          opts.banner = 'Usage: log_parse [options] FILE'

          count_desc = "Count occurrences of FIELD. Default #{default_options[:count]}"
          opts.on('-c', '--count FIELD', LogParse::Parser.new.fields, count_desc) do |field|
            default_options[:count] = field
          end

          filter_desc = "Filter by VALUE in FIELD. Default #{default_options[:filter].to_a.join('=')}"
          opts.on('-f', '--filter FIELD=VALUE', filter_desc) do |filter|
            field, value = filter.split('=')
            raise 'Filter must be specified as FIELD=VALUE' if [field, value].any?(&:nil?)
            default_options[:filter] = { field.to_sym => value }
          end
        end
      end

      def invoke!
        args = optparse.parse!
        raise 'Must specify a log FILE to parse' if args.empty?
        logfile = File.open(args.first, 'r')
        runner = self.new(logfile, default_options[:count], default_options[:filter])
        runner.invoke
        runner.results
      end
    end

    def initialize(logfile, count, filter)
      @logfile = logfile
      @count = count
      @filter = filter
      @parser = LogParse::Parser.new
    end

    def invoke
      @logfile.each do |line|
      end
    end

    def results
    end
  end
end
