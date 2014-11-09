require 'rspec'
require 'usmu/configuration'

RSpec.describe Usmu::Configuration do
  context 'should prepend configuration folder' do
    before do
      hash = {
          'source' => 'source',
          'destination' => 'destination',
          'layouts' => 'templates',
      }
      @configuration = Usmu::Configuration.from_hash(hash, 'test/usmu.yaml')
    end

    it 'to source' do
      expect(@configuration.source_path).to eq('test/source')
    end

    it 'to destination' do
      expect(@configuration.destination_path).to eq('test/destination')
    end

    it 'to layouts' do
      expect(@configuration.layouts_path).to eq('test/templates')
    end
  end

  context 'should have a default path' do
    before do
      hash = {}
      @configuration = Usmu::Configuration.from_hash(hash)
    end

    it 'for source' do
      expect(@configuration.source_path).to eq('src')
    end

    it 'for destination' do
      expect(@configuration.destination_path).to eq('site')
    end

    it 'for layouts' do
      expect(@configuration.layouts_path).to eq('layouts')
    end
  end

  it 'should remember arbitrary configuration' do
    configuration = Usmu::Configuration.from_hash({:test => 'foo'})
    expect(configuration[:test]).to eq('foo')
  end
end
