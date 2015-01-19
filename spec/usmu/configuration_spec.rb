require 'usmu/configuration'

RSpec.describe Usmu::Configuration do
  let (:configuration_hash) {
    {
        'source' => 'source',
        'destination' => 'destination',
        'layouts' => 'templates',
        'includes' => 'inc',
    }
  }
  let (:configuration) { Usmu::Configuration.from_hash(configuration_hash, 'test/usmu.yaml') }
  let (:empty_configuration) { Usmu::Configuration.from_hash({}) }

  context '#initialize' do
    it 'should set class variables correctly' do
      expect(configuration.config_dir).to eq('test')
      expect(configuration.config_file).to eq('test/usmu.yaml')
      expect(configuration.send :config).to eq(configuration_hash)
      expect(configuration.send(:log).class).to eq(Logging::Logger)
      expect(configuration.send(:log).name).to eq(described_class.name)
    end

    it 'should set config_path to the current directory for a bare filename' do
      configuration = Usmu::Configuration.from_hash(configuration_hash, 'usmu.yaml')
      expect(configuration.config_dir).to eq('.')
    end

    it 'should set config_dir to nil if no config_path is set' do
      configuration = Usmu::Configuration.from_hash(configuration_hash)
      expect(configuration.config_dir).to eq(nil)
    end
  end

  context '.from_file' do
    it 'should raise an error if no filename is specified' do
      expect { Usmu::Configuration.from_file(nil) }.to raise_error(ArgumentError, 'File not found: ')
    end

    it 'should raise an error if file does not exist' do
      expect { Usmu::Configuration.from_file('nonexistent.yml') }.to raise_error(ArgumentError, 'File not found: nonexistent.yml')
    end

    it 'should pass through the contents of the named file to constructor' do
      allow(YAML).to receive(:load_file).with('usmu.yml').and_return(configuration_hash)
      allow(File).to receive(:exist?).with('usmu.yml').and_return(true)
      expect(Usmu::Configuration).to receive(:new).with(configuration_hash, 'usmu.yml')
      Usmu::Configuration.from_file('usmu.yml')
      expect(@log_output.readline).to eq("  DEBUG  Usmu::Configuration : Loading configuration from usmu.yml\n")
    end
  end

  context '.from_hash' do
    it 'should pass through it\'s arguments through to constructor' do
      expect(Usmu::Configuration).to receive(:new).with(configuration_hash, 'usmu.yml')
      Usmu::Configuration.from_hash(configuration_hash, 'usmu.yml')
    end

    it 'should have a default of nil for the configuration name' do
      expect(Usmu::Configuration).to receive(:new).with(configuration_hash, nil)
      Usmu::Configuration.from_hash(configuration_hash)
    end
  end

  context '#source_path' do
    it 'should prepend configuration folder' do
      expect(configuration.source_path).to eq('test/source')
    end

    it 'should have a default path' do
      expect(empty_configuration.source_path).to eq('src')
    end
  end

  context '#destination_path' do
    it 'should prepend configuration folder' do
      expect(configuration.destination_path).to eq('test/destination')
    end

    it 'should have a default path' do
      expect(empty_configuration.destination_path).to eq('site')
    end
  end

  context '#layouts_path' do
    it 'should prepend configuration folder' do
      expect(configuration.layouts_path).to eq('test/templates')
    end

    it 'should have a default path' do
      expect(empty_configuration.layouts_path).to eq('layouts')
    end
  end

  context '#includes_path' do
    it 'should prepend configuration folder' do
      expect(configuration.includes_path).to eq('test/inc')
    end

    it 'should have a default path' do
      expect(empty_configuration.includes_path).to eq('includes')
    end
  end

  context '#source_files' do
    it 'should return a list of source files' do
      allow(Dir).to receive(:'[]').with('src/**/{*,.??*}').and_return(%w(src/index.md src/test.md))
      expect(empty_configuration.source_files).to eq(%w(index.md test.md))
    end
  end

  context '#layouts_files' do
    it 'should have a list of layouts files' do
      allow(Dir).to receive(:'[]').with('layouts/**/{*,.??*}').and_return(%w(layouts/html.slim layouts/page.slim))
      expect(empty_configuration.layouts_files).to eq(%w(html.slim page.slim))
    end

    it 'should ignore metadata files in the layouts folder' do
      allow(Dir).to receive(:'[]').with('layouts/**/{*,.??*}').and_return(%w(layouts/html.slim layouts/html.meta.yml layouts/page.slim))
      expect(empty_configuration.layouts_files).to eq(%w(html.slim page.slim))
    end
  end

  context '#includes_files' do
    it 'should have a list of includes files' do
      allow(Dir).to receive(:'[]').with('includes/**/{*,.??*}').and_return(%w(includes/footer.slim))
      expect(empty_configuration.includes_files).to eq(%w(footer.slim))
    end

    it 'should ignore metadata files in the includes folder' do
      allow(Dir).to receive(:'[]').with('includes/**/{*,.??*}').and_return(%w(includes/footer.slim includes/footer.meta.yml))
      expect(empty_configuration.includes_files).to eq(%w(footer.slim))
    end
  end

  context '#source_metadata' do
    it 'should return a new metadata service for the source folder' do
      ms = {fake: 'success'}
      expect(Usmu::MetadataService).to receive(:new).with(empty_configuration.source_path).and_return(ms)
      expect(empty_configuration.source_metadata).to eq(ms)
    end
  end

  context '#layouts_metadata' do
    it 'should return a new metadata service for the layouts folder' do
      ms = {fake: 'success'}
      expect(Usmu::MetadataService).to receive(:new).with(empty_configuration.layouts_path).and_return(ms)
      expect(empty_configuration.layouts_metadata).to eq(ms)
    end
  end

  context '#includes_metadata' do
    it 'should return a new metadata service for the layouts folder' do
      ms = {fake: 'success'}
      expect(Usmu::MetadataService).to receive(:new).with(empty_configuration.includes_path).and_return(ms)
      expect(empty_configuration.includes_metadata).to eq(ms)
    end
  end

  context '#exclude' do
    it 'returns the exclude option in the configuration array' do
      expect(Usmu::Configuration.from_hash({'exclude' => ['test.md']}).exclude).to eq(['test.md'])
    end

    it 'has a default value of an empty array' do
      expect(empty_configuration.exclude).to eq([])
    end
  end

  context '#[]' do
    it 'should remember arbitrary configuration' do
      configuration = Usmu::Configuration.from_hash({:test => 'foo'})
      expect(configuration[:test]).to eq('foo')
    end

    it 'should allow indexing the configuration file' do
      configuration = Usmu::Configuration.from_hash({test: 'foo'})
      expect(configuration[:test]).to eq('foo')
    end

    it 'should allow indexing the configuration file with a default value' do
      configuration = Usmu::Configuration.from_hash({test: 'foo'})
      expect(configuration[:bar, default: 'baz']).to eq('baz')
    end

    it 'should allow indexing the configuration file using a path of indices' do
      configuration = Usmu::Configuration.from_hash({test: {bar: 'foo'}})
      expect(configuration[:test, :bar]).to eq('foo')
    end

    it 'should return nil if the element does not exist' do
      expect(empty_configuration[:test]).to eq(nil)
    end
  end

  context '#get_path' do
    it 'should return input if config_dir is nil' do
      expect(empty_configuration.send :get_path, 'source').to eq('source')
    end

    it 'should prepend input with config_dir if it is not nil' do
      expect(configuration.send :get_path, 'source').to eq('test/source')
    end
  end

  context '#get_files' do
    it 'should ignore metadata files' do
      allow(Dir).to receive(:'[]').with('src/**/{*,.??*}').and_return(%w(src/index.md src/index.meta.yml src/test.md))
      expect(empty_configuration.send :get_files, 'src').to eq(%w(index.md test.md))
    end

    it 'should not return folders' do
      allow(File).to receive(:directory?).and_return(false)
      allow(File).to receive(:directory?).with('src/test').and_return(true)
      allow(Dir).to receive(:'[]').with('src/**/{*,.??*}').and_return(%w(src/index.md src/index.meta.yml src/test src/test/test.md))
      expect(empty_configuration.send :get_files, 'src').to eq(%w(index.md test/test.md))
    end

    it 'should exclude files' do
      allow(Dir).to receive(:'[]').with('src/**/{*,.??*}').and_return(%w(src/foo.md))
      allow(configuration).to receive(:excluded?).with('foo.md').and_return(true)
      expect(configuration.send :get_files, 'src').to eq([])
    end
  end

  context '#excluded?' do
    it 'should ignore files in folders if a trailing "/" is used' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['test/']})
      expect(configuration.send :excluded?, 'test/foo/test.md').to eq(true)
    end

    it 'should honor *' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['*/foo.md']})
      expect(configuration.send :excluded?, 'test/foo.md').to eq(true)
    end

    it 'should ignore folders specified with * without a trailing /' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['*']})
      expect(configuration.send :excluded?, 'test/foo.md').to eq(false)
    end

    it 'should ignore files inside folders specified via globs with trailing "/"' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['test/*/']})
      expect(configuration.send :excluded?, 'test/foot/foo.md').to eq(true)
    end

    it 'should honor **' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['**/foo.md']})
      expect(configuration.send :excluded?, 'test/foo/foo.md').to eq(true)
    end

    it 'should honor []' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['[ab].md']})
      expect(configuration.send :excluded?, 'a.md').to eq(true)
      expect(configuration.send :excluded?, 'b.md').to eq(true)
      expect(configuration.send :excluded?, 'index.md').to eq(false)
    end

    # FNM_EXTGLOB is supported from MRI 2.0 onwards. We also support the 1.9.3 ABI for JRuby and Rubinius sake. Only
    # run this test if it's possible for it to pass.
    if defined?(File::FNM_EXTGLOB)
      it 'should honor {a,b}' do
        configuration = Usmu::Configuration.from_hash({'exclude' => ['{a,b}.md']})
        expect(configuration.send :excluded?, 'a.md').to eq(true)
        expect(configuration.send :excluded?, 'b.md').to eq(true)
        expect(configuration.send :excluded?, 'index.md').to eq(false)
      end
    end

    it 'should honor \\ as an escape' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['\*.md']})
      expect(configuration.send :excluded?, '*.md').to eq(true)
      expect(configuration.send :excluded?, 'index.md').to eq(false)
    end

    it 'should honor ?' do
      configuration = Usmu::Configuration.from_hash({'exclude' => ['?.md']})
      expect(configuration.send :excluded?, 'a.md').to eq(true)
    end
  end
end
