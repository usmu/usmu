require 'usmu/site_generator'

RSpec.describe Usmu::SiteGenerator do
  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }
  let(:generator) { Usmu::SiteGenerator.new(configuration) }

  it 'should have layouts' do
    expect(generator.respond_to? :layouts).to eq(true)
    expect(generator.layouts.map {|l| l.name}.sort).to eq(%w{embedded.slim html.slim})
  end

  it 'should have a list of renderable items' do
    expect(generator.respond_to? :renderables).to eq(true)
    expect(generator.renderables.map {|r| r.name}.sort).to eq(%w{default.md embedded.md index.md robots.txt})
  end

  it 'should have pages' do
    expect(generator.respond_to? :pages).to eq(true)
    expect(generator.pages.map {|p| p.name}.sort).to eq(%w{default.md embedded.md index.md})
  end

  it 'should have files' do
    expect(generator.respond_to? :files).to eq(true)
    expect(generator.files.map {|f| f.name}.sort).to eq(%w{robots.txt})
  end

  it 'should be able to generate a site' do
    expect(generator.respond_to? :generate).to eq(true)
  end
end
