require 'rspec'
require 'usmu/configuration'

RSpec.describe 'Usmu::Configuration' do

  context 'should prepend configuration folder' do
    before do
      hash = {
          'source' => 'source',
          'destination' => 'destination',
      }
      @configuration = Usmu::Configuration.from_hash(hash, 'test/usmu.yaml')
    end

    it 'to source' do
      expect(@configuration.source).to eq('test/source')
    end

    it 'to destination' do
      expect(@configuration.destination).to eq('test/destination')
    end
  end

  it 'should remember arbitrary configuration' do
    configuration = Usmu::Configuration.from_hash({:test => 'foo'})
    expect(configuration[:test]).to eq('foo')
  end
end
