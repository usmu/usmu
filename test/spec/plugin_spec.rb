require 'usmu/plugin'
require 'ostruct'

RSpec.describe Usmu::Plugin do
  before(:each) do
    # noinspection RubyStringKeysInHashInspection
    allow(Gem::Specification).to receive(:find_all).and_return([OpenStruct.new({'name' => 'usmu-mock_plugin'})])
  end

  let(:plugins) { Usmu::Plugin.new }

  it 'should load the core plugin' do
    plugins.load_plugins
    expect(plugins.plugins.select {|p| p.class.name == 'Usmu::Plugin::Core'}.length).to eq(1)
  end

  it 'should load plugins from gems' do
    plugins.load_plugins
    expect(plugins.plugins.select {|p| p.class.name == 'Usmu::MockPlugin'}.length).to eq(1)
  end

  it 'should avoid loading plugins more than once' do
    # noinspection RubyStringKeysInHashInspection
    allow(Gem::Specification).to receive(:find_all).and_return([
                                                                   OpenStruct.new({'name' => 'usmu-mock_plugin'}),
                                                                   OpenStruct.new({'name' => 'usmu-mock_plugin'}),
                                                               ])
    plugins.load_plugins
    expect(plugins.plugins.select {|p| p.class.name == 'Usmu::MockPlugin'}.length).to eq(1)
  end

  it 'should call methods by name when using #invoke' do
    plugins.load_plugins
    plugins.plugins.select {|p| p.class.name == 'Usmu::MockPlugin' }.each do |p|
      allow(p).to receive(:test).with('Hello world!')
    end

    plugins.invoke :test, 'Hello world!'
  end

  it 'should aggregate information from plugins when using #invoke' do
    plugins.load_plugins
    plugins.plugins.select {|p| p.class.name == 'Usmu::MockPlugin' }.each do |p|
      allow(p).to receive(:test).and_return(['Goodbye world!'])
    end

    expect(plugins.invoke :test).to eq([['Goodbye world!']])
  end
end
