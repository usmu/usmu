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

  it 'should have a list of source files' do
    @configuration = Usmu::Configuration.from_hash({})
    allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test.md))
    expect(@configuration.source_files).to eq(%w(index.md test.md))
  end

  it 'should ignore metadata files in the source folder' do
    @configuration = Usmu::Configuration.from_hash({})
    allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/index.meta.yml src/test.md))
    expect(@configuration.source_files).to eq(%w(index.md test.md))
  end

  it 'should have a list of layouts files' do
    @configuration = Usmu::Configuration.from_hash({})
    allow(Dir).to receive(:'[]').with('layouts/**/*').and_return(%w(layouts/html.slim layouts/page.slim))
    expect(@configuration.layouts_files).to eq(%w(html.slim page.slim))
  end

  it 'should ignore metadata files in the layouts folder' do
    @configuration = Usmu::Configuration.from_hash({})
    allow(Dir).to receive(:'[]').with('layouts/**/*').and_return(%w(layouts/html.slim layouts/html.meta.yml layouts/page.slim))
    expect(@configuration.layouts_files).to eq(%w(html.slim page.slim))
  end

  it 'should remember arbitrary configuration' do
    configuration = Usmu::Configuration.from_hash({:test => 'foo'})
    expect(configuration[:test]).to eq('foo')
  end

  context 'should exclude files from source' do
    it 'as specified' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['foo.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/foo.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'in ignored folders if trailing "/" is used' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['test/']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test/foo/test.md src/test/foo.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and honor *' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['*/foo.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test/foo/foo.md src/test/foo.md))
      expect(@configuration.source_files).to eq(%w(index.md test/foo/foo.md))
    end

    it 'and * ignores folders without a trailing /' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['*']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test/foo.md src/test.md))
      expect(@configuration.source_files).to eq(%w(test/foo.md))
    end

    it 'and honor **' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['**/foo.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test/foo/foo.md src/test/foo.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and honor []' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['[ab].md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/a.md src/b.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and honor {a,b}' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['{a,b}.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/a.md src/b.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and honor \\ as an escape' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['\*.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/*.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and honor ?' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['?.md']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/a.md src/b.md))
      expect(@configuration.source_files).to eq(%w(index.md))
    end

    it 'and ignore files inside folders specified via globs with trailing "/"' do
      @configuration = Usmu::Configuration.from_hash({'exclude' => ['test/*/']})
      allow(Dir).to receive(:'[]').with('src/**/*').and_return(%w(src/index.md src/test/foo/foo.md src/test/foo.md))
      expect(@configuration.source_files).to eq(%w(index.md test/foo.md))
    end
  end
end
