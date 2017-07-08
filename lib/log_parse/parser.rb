module LogParse
  # Parser class handles the log file pattern matching
  class Parser
    PATTERN = Regexp.compile(
      /
        ^
        (?<timestamp>[^\s]+)
        \s
        (?<source_address>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
        :
        (?<source_port>\d{1,5})
        \s
        (?<dest_address>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})
        :
        (?<dest_port>\d{1,5})
        \s
        (?<response_status>\d{3})
        \s
        (?<http_request>"[^"]*")
        \s
        (?<user_agent>"[^"]*")
        \s
        (?<cipher>[\w-]*)
        \s
        (?<protocol>TLSv[\d.]+)
        $
      /x
    )

    def fields
      PATTERN.names
    end

    def extract(str)
      match = PATTERN.match str
      return {} if match.nil?
      Hash[match.names.map(&:to_sym).zip(match.captures)]
    end
  end
end
