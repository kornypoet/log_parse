require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'log_parse', type: :aruba do
  let(:usage) do
    <<-USAGE.gsub(/^ {6}/, '').chomp
      Usage: log_parse [options] FILE
          -c, --count FIELD                Count occurrences of FIELD. Default source_address
          -f, --filter FIELD=VALUE         Filter by VALUE in FIELD. Default protocol=TLSv1
          -d, --debug                      Run in debug mode. Default false
    USAGE
  end

  let(:logfile){ File.expand_path('../fixtures/example.log', __FILE__) }

  context 'log_parse --help' do
    it 'displays the usage' do
      run_simple 'log_parse --help'
      expect(last_command_started).to have_output(usage)
    end
  end

  context 'log_parse --version' do
    it 'displays the version' do
      run_simple 'log_parse --version'
      expect(last_command_started).to have_output("log_parse #{LogParse::VERSION}")
    end
  end

  context 'log_parse spec/fixtures/example.log' do
    it 'outputs the results' do
      run_simple "log_parse #{logfile}"
      expect(last_command_started).to have_output_on_stdout('52.34.86.123: 1')
    end

    it 'errors if not given a file' do
      run 'log_parse'
      expect(last_command_started).to have_output_on_stderr('Must specify a log FILE to parse')
    end

    it 'errors if the file is unreadable' do
      run 'log_parse unreadable.log'
      expect(last_command_started).to have_output_on_stderr(/No such file or directory/)
    end
  end

  context 'log_parse spec/fixtures/example.log -c dest_address' do
    it 'outputs the results with a different field count' do
      run_simple "log_parse #{logfile} -c dest_address"
      expect(last_command_started).to have_output_on_stdout('10.0.12.108: 1')
    end

    it 'errors if given an invalid field' do
      run "log_parse #{logfile} -c invalid"
      expect(last_command_started).to have_output_on_stderr(/invalid argument: -c invalid/)
    end
  end

  context 'log_parse spec/fixtures/example.log -f response_status=200' do
    it 'outputs the results with a different filter' do
      run_simple "log_parse #{logfile} -f response_status=200"
      expect(last_command_started).to have_output_on_stdout("204.18.135.54: 1\n52.34.86.123: 1")
    end

    it 'errors unless given a string formatted FIELD=VALUE' do
      run "log_parse #{logfile} -f invalid"
      expect(last_command_started).to have_output_on_stderr('Filter must be specified as FIELD=VALUE')
    end

    it 'errors if given an invalid field' do
      run "log_parse #{logfile} -f invalid=200"
      expect(last_command_started).to have_output_on_stderr('Filter FIELD invalid')
    end
  end

  context 'log_parse spec/fixtures/example.log --debug' do
    it 'outputs the results with additional debug information' do
      run_simple "log_parse #{logfile} --debug"
      expect(last_command_started).to have_output_on_stdout('52.34.86.123: 1')
      expect(last_command_started).to have_output_on_stderr <<-STDERR.gsub(/^ {8}/, '').chomp
        Invoked with options {:count=>:source_address, :filter=>{:protocol=>"TLSv1"}, :debug=>true}
        Error parsing # these are a few randomly generated log lines to aid in testing
        Log parsing errors: 1
        Log lines filtered: 1
      STDERR
    end
  end
end
