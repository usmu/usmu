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
    it 'should list layouts' do
      expect(meta_mock).to receive(:metadata).at_least(1).times.with('embedded.slim').and_return({})
      expect(meta_mock).to receive(:metadata).at_least(1).times.with('html.slim').and_return({})
      expect(meta_mock).to receive(:metadata).at_least(1).times.with('post.slim').and_return({})
      expect(generator.layouts.map {|l| l.name}.sort).to eq(%w{embedded.slim html.slim post.slim})
    end
  end

  context '#renderables' do
    before do
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', '.dotfiletest.txt').and_return(false)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'assets/external.scss').and_return(true)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'css/app.scss').and_return(true)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'index.md').and_return(true)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'posts/second-post.md').and_return(true)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'posts/test-post.md').and_return(true)
      allow(Usmu::Template::Layout).to receive(:is_valid_file?).with('source', 'robots.txt').and_return(false)
    end

    it 'should create static files as StaticFile and honour the "static" metadata attribute' do
      expect(generator.renderables.select {|r| r.class == Usmu::Template::StaticFile }.map {|r| r.name}.sort).to eq(%w{.dotfiletest.txt assets/external.scss robots.txt})
    end

    it 'should create static files as StaticFile and honour the "static" metadata attribute' do
      expect(generator.renderables.select {|r| r.class == Usmu::Template::Page }.map {|r| r.name}.sort).to eq(%w{css/app.scss index.md posts/second-post.md posts/test-post.md})
    end

    it 'should not list directories' do
      expect(generator.renderables.select {|f| f.name == 'posts'}.length).to eq(0)
    end
  end

  context '#generate' do
    it 'should call #generate_page for each renderable' do
      expect(generator).to receive(:renderables).and_return([{test: 'success'}])
      expect(generator).to receive(:generate_page).with({test: 'success'})
      expect(generator.generate).to eq(nil)
      expect(@log_output.readline).to eq("   INFO  Usmu::SiteGenerator : Source: src\n")
      expect(@log_output.readline).to eq("   INFO  Usmu::SiteGenerator : Destination: site\n")
      expect(@log_output.readline).to eq("   INFO  Usmu::SiteGenerator : \n")
    end
  end

  context '#collections' do
    it 'should return a Collections interface' do
      expect(Usmu::Collections).to receive(:new).with(generator).and_return({test: 'success'})
      expect(generator.collections).to eq({test: 'success'})
    end
  end

  context '#refresh' do
    it 'refresh collections' do
      expect(generator.collections).to receive(:refresh).and_return(true)
      expect(generator.refresh).to eq(nil)
    end
  end

  context '#generate_page' do
    before do
      allow(File).to receive(:directory?).with('site').and_return(true)
      allow(File).to receive(:directory?).with('site/subdir').and_return(false)
    end

    it 'should write a file and update mtime to match source files' do
      page = OpenStruct.new name: 'test.slim', input_path: 'src/test.slim', output_filename: 'test.html', render: '<!DOCTYPE html><h1>It works!</h1>', mtime: 100
      expect(File).to receive(:write).with('site/test.html', '<!DOCTYPE html><h1>It works!</h1>')
      expect(FileUtils).to receive(:touch).with('site/test.html', mtime: 100).and_return(true)
      expect(FileUtils).to_not receive(:mkdir_p)

      expect(generator.send :generate_page, page).to eq(nil)

      expect(@log_output.readline).to eq("SUCCESS  Usmu::SiteGenerator : creating test.html...\n")
      expect(@log_output.readline).to eq("  DEBUG  Usmu::SiteGenerator : Rendering test.html from test.slim\n")
    end

    it 'should create directories as necessary' do
      page = OpenStruct.new name: 'test.slim', input_path: 'src/subdir/test.slim', output_filename: 'subdir/test.html', render: '<!DOCTYPE html><h1>It works!</h1>', mtime: 100
      expect(File).to receive(:write).with('site/subdir/test.html', '<!DOCTYPE html><h1>It works!</h1>')
      expect(FileUtils).to receive(:touch).with('site/subdir/test.html', mtime: 100).and_return(true)
      expect(FileUtils).to receive(:mkdir_p).with('site/subdir')

      expect(generator.send :generate_page, page).to eq(nil)
    end
  end
end
