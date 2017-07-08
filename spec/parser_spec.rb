require 'spec_helper'

# rubocop:disable Metrics/LineLength, Metrics/BlockLength
RSpec.describe LogParse::Parser do
  let(:example_one) do
    '2017-03-19T05:01:27.173Z 204.18.135.54:42860 10.31.0.5:8080 200 "GET https://api.chargeio.com:443/v1/events HTTP/1.1" "-" ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2'
  end

  let(:example_two) do
    '2017-03-19T05:02:02.554Z 52.34.86.123:41649 10.0.12.108:8080 200 "GET https://api.chargeio.com:443/v1/transactions?start_date=2017-03-17T05%3A02%3A01.77Z&end_date=2017-03-19T05%3A02%3A01.77Z HTTP/1.1" "ChargeIO PHP Client v1.0.0" AES256-SHA TLSv1'
  end

  context '#fields' do
    it 'returns the field names' do
      expect(subject.fields).to eq(%w[timestamp source_address source_port dest_address
                                      dest_port response_status http_request user_agent cipher protocol])
    end
  end

  context '#extract' do
    it 'returns an empty hash when there is no match' do
      expect(subject.extract('foobar')).to eq({})
    end

    it 'extracts the fields from example_one correctly' do
      expect(subject.extract(example_one)).to eq(timestamp:       '2017-03-19T05:01:27.173Z',
                                                 source_address:  '204.18.135.54',
                                                 source_port:     '42860',
                                                 dest_address:    '10.31.0.5',
                                                 dest_port:       '8080',
                                                 response_status: '200',
                                                 http_request:    '"GET https://api.chargeio.com:443/v1/events HTTP/1.1"',
                                                 user_agent:      '"-"',
                                                 cipher:          'ECDHE-RSA-AES128-GCM-SHA256',
                                                 protocol:        'TLSv1.2')
    end

    it 'extracts the fields from example_two correctly' do
      expect(subject.extract(example_two)).to eq(timestamp:       '2017-03-19T05:02:02.554Z',
                                                 source_address:  '52.34.86.123',
                                                 source_port:     '41649',
                                                 dest_address:    '10.0.12.108',
                                                 dest_port:       '8080',
                                                 response_status: '200',
                                                 http_request:    '"GET https://api.chargeio.com:443/v1/transactions?start_date=2017-03-17T05%3A02%3A01.77Z&end_date=2017-03-19T05%3A02%3A01.77Z HTTP/1.1"',
                                                 user_agent:      '"ChargeIO PHP Client v1.0.0"',
                                                 cipher:          'AES256-SHA',
                                                 protocol:        'TLSv1')
    end
  end
end
