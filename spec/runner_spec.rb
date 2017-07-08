require 'spec_helper'

RSpec.describe LogParse::Runner do
  let(:logfile){ StringIO.new "line one\nline two\n line three" }
  let(:count)  { :foo }
  let(:filter) { { bar: 'baz' } }

  subject{ described_class.new(logfile, count, filter) }

  context '#add_to_results' do
    it 'creates a field in results' do
      subject.add_to_results :foo
      expect(subject.results).to eq(foo: 1)
    end

    it 'increments a field in results' do
      subject.add_to_results :foo
      subject.add_to_results :foo
      subject.add_to_results :foo
      expect(subject.results).to eq(foo: 3)
    end
  end

  context '#invoke' do
    let(:parser)  { double }
    let(:error)   { {} }
    let(:matching){ { foo: 'qix', bar: 'baz' } }
    let(:missing) { { foo: 'qix', bar: 'missing' } }

    before do
      allow(subject).to receive(:parser){ parser }
    end

    it 'adds errors to results' do
      expect(parser).to receive(:extract){ error }
      expect(parser).to receive(:extract){ error }
      expect(parser).to receive(:extract){ error }
      subject.invoke
      expect(subject.results).to eq(errors: 3)
    end

    it 'adds filters to results' do
      expect(parser).to receive(:extract){ missing }
      expect(parser).to receive(:extract){ missing }
      expect(parser).to receive(:extract){ missing }
      subject.invoke
      expect(subject.results).to eq(filtered: 3)
    end

    it 'increments extracted fields' do
      expect(parser).to receive(:extract){ matching }
      expect(parser).to receive(:extract){ matching }
      expect(parser).to receive(:extract){ matching }
      subject.invoke
      expect(subject.results).to eq('qix' => 3)
    end
  end
end
