require 'usmu/site_generator'
require 'usmu/mock_metadata_configuration'
require 'ostruct'

RSpec.describe Usmu::SiteGenerator do
  let(:meta_mock) {
    Usmu::MockMetadataConfiguration.new(
        {
            'assets/external.scss' => { 'static' => true }
        }
    )
  }
  let(:configuration) { Usmu::Configuration.from_hash({}) }
  let(:generator) { Usmu::SiteGenerator.new(configuration) }

  before do
    allow(configuration).to receive(:layouts_metadata).and_return(meta_mock)
    allow(configuration).to receive(:source_metadata).and_return(meta_mock)

    allow(Dir).to receive(:[]).with('src/**/{*,.??*}').and_return(%w{src/.dotfiletest.txt src/assets src/assets/external.scss src/css src/css/app.scss src/index.md src/posts src/posts/second-post.md src/posts/test-post.md src/robots.txt})
    allow(Dir).to receive(:[]).with('layouts/**/{*,.??*}').and_return(%w{layouts/embedded.slim layouts/html.slim layouts/post.slim})

    allow(File).to receive(:directory?).and_return(false)
    %w{src/assets src/css src/posts}.each do |f|
      allow(File).to receive(:directory?).with(f).and_return(true)
    end

    allow(Usmu::Template::StaticFile).to receive(:new) {|config, filename, metadata| instance_double('Usmu::Template::StaticFile', class: Usmu::Template::StaticFile, name: filename) if config == configuration && metadata == meta_mock.metadata(filename) }
    allow(Usmu::Template::Page).to receive(:new) {|config, filename, metadata| instance_double('Usmu::Template::Page', class: Usmu::Template::Page, name: filename) if config == configuration && metadata == meta_mock.metadata(filename) }
    allow(Usmu::Template::Layout).to receive(:new) {|config, filename, metadata| instance_double('Usmu::Template::Layout', class: Usmu::Template::Layout, name: filename) if config == configuration && metadata == meta_mock.metadata(filename) }
  end

  context '#layouts' do
    it 'should have layouts' do
      expect(generator.layouts.map {|l| l.name}.sort).to eq(%w{embedded.slim html.slim post.slim})
    end
  end

  context '#renderables' do
    it 'should have a list of renderable items' do
      expect(generator.renderables.map {|r| r.name}.sort).to eq(%w{.dotfiletest.txt assets/external.scss css/app.scss index.md posts/second-post.md posts/test-post.md robots.txt})
    end
  end

  context '#pages' do
    it 'should have pages' do
      expect(generator.pages.map {|p| p.name}.sort).to eq(%w{css/app.scss index.md posts/second-post.md posts/test-post.md})
    end
  end

  context '#files' do
    it 'should have files' do
      expect(generator.files.map {|f| f.name}.sort).to eq(%w{.dotfiletest.txt assets/external.scss robots.txt})
    end

    it 'should not list directories' do
      expect(generator.files.select {|f| f.name == 'posts'}.length).to eq(0)
    end
  end

  context '#generate' do
    it 'should be able to generate a site' do
      expect(generator.respond_to? :generate).to eq(true)
    end
  end

  context '#collections' do
    it 'should do something'
  end

  context '#refresh' do
    it 'should do something'
  end

  context '#generate_page' do
    it 'should do something'
  end
end
