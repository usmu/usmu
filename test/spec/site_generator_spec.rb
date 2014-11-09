require 'rspec'
require 'usmu/site_generator'

RSpec.describe Usmu::SiteGenerator do
  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }
  let(:generator) { Usmu::SiteGenerator.new(configuration) }

  it 'should have layouts' do
    expect(generator.respond_to? :layouts).to eq(true)
    expect(generator.layouts.map {|l| l.name}.sort).to eq(%w{embedded html})
  end

  it 'should have pages' do
    expect(generator.respond_to? :pages).to eq(true)
    expect(generator.pages.map {|p| p.name}.sort).to eq(%w{default embedded index})
  end

  it 'should have files' do
    expect(generator.respond_to? :files).to eq(true)
    expect(generator.files.map {|f| f.name}.sort).to eq(%w{})
  end
end
