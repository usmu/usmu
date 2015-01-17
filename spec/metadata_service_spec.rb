require 'usmu/metadata_service'

RSpec.describe Usmu::MetadataService do
  let (:service) { Usmu::MetadataService.new('test') }

  context '#initialize' do
    it 'stores a base directory for checks' do
      expect(service.send :base).to eq('test')
    end
  end

  context '#metadata' do
    it 'returns an empty hash if no metadata available' do
      expect(File).to receive(:exist?).with('test/test.meta.yml').and_return(false)
      allow(File).to receive(:directory?).and_return(false)
      expect(service.metadata('test.md')).to eq({})
    end

    it 'returns metadata for files in the root folder' do
      expect(File).to receive(:exist?).with('test/a.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/a.meta.yml').and_return({test: 'success'})
      allow(File).to receive(:directory?).and_return(false)
      expect(service.metadata('a.md')).to eq({test: 'success'})
    end

    it 'looks for dotfile metadata using the entire filename' do
      expect(File).to receive(:exist?).with('test/.dotfile.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/.dotfile.meta.yml').and_return({test: 'success'})
      allow(File).to receive(:directory?).and_return(false)
      expect(service.metadata('.dotfile')).to eq({test: 'success'})
    end

    it 'looks for metadata using the entire filename if file has no extension' do
      expect(File).to receive(:exist?).with('test/dotfile.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/dotfile.meta.yml').and_return({test: 'success'})
      allow(File).to receive(:directory?).and_return(false)
      expect(service.metadata('dotfile')).to eq({test: 'success'})
    end

    it 'merges metadata from parent folders' do
      expect(File).to receive(:exist?).with('test/foo/test.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/foo/test.meta.yml').and_return({test: 'success'})
      expect(File).to receive(:exist?).with('test/foo/meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/foo/meta.yml').and_return({dir: 'success'})

      expect(File).to receive(:directory?).with('test/foo').and_return(true)
      allow(File).to receive(:directory?).and_return(false)

      expect(service.metadata('foo/test.md')).to eq({dir: 'success', test: 'success'})
    end

    it 'only searches for a file extension in the filename' do
      expect(File).to receive(:exist?).with('test/te.st/meta.yml').and_return(false)
      expect(File).to receive(:exist?).with('test/te.st/dotfile.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/te.st/dotfile.meta.yml').and_return({test: 'success'})

      expect(File).to receive(:directory?).with('test/te.st').and_return(true)
      allow(File).to receive(:directory?).and_return(false)

      expect(service.metadata('te.st/dotfile')).to eq({test: 'success'})
    end

    it 'favours metadata from objects to metadata from parent objects' do
      expect(File).to receive(:exist?).with('test/foo/test.meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/foo/test.meta.yml').and_return({test: 'success'})
      expect(File).to receive(:exist?).with('test/foo/meta.yml').and_return(true)
      expect(YAML).to receive(:load_file).with('test/foo/meta.yml').and_return({test: 'directory'})

      expect(File).to receive(:directory?).with('test/foo').and_return(true)
      allow(File).to receive(:directory?).and_return(false)

      expect(service.metadata('foo/test.md')).to eq({test: 'success'})
    end
  end
end
