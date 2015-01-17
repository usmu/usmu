require 'usmu/deployment/directory_diff'
require 'usmu/mock_remote_files'
require 'ostruct'
require 'digest'

RSpec.describe Usmu::Deployment::DirectoryDiff do
  let (:configuration) { Usmu::Configuration.from_hash({}) }

  context '#initialize' do
    it 'initializes variables' do
      remote_files = OpenStruct.new {}
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.send :configuration).to eq(configuration)
      expect(diff.send :remote_files).to eq(remote_files)
    end
  end

  context '#get_diffs' do
    it 'returns file changes' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {}, 'articles.html' => {}, 'remote.html' => {} })
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html site/articles.html site/local.html))
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:filter_files).with('articles.html').and_return(false)
      expect(diff).to receive(:filter_files).with('index.html').and_return(true)

      expect(diff.get_diffs).to eq({
                                       local: %w{local.html},
                                       remote: %w{remote.html},
                                       updated: %w{index.html},
                                   })
    end
  end

  context '#filter_files' do
    let (:now) { Time.now }
    let (:file) { 'Hello world!' }

    before do
      expect(File).to receive(:stat).with('site/index.html').and_return(OpenStruct.new mtime: now)
      expect(File).to receive(:read).with('site/index.html').and_return(file)
    end

    it 'rejects identical files' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {mtime: now} })
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:check_hash).with(file, {mtime: now}).and_return(true)

      expect(diff.send :filter_files, 'index.html').to eq(false)
    end

    it 'rejects files newer on remote' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {mtime: now + 200} })
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:check_hash).with(file, {mtime: now + 200}).and_return(true)

      expect(diff.send :filter_files, 'index.html').to eq(false)
    end

    it 'allows files newer on local' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {mtime: now - 200} })
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:check_hash).with(file, {mtime: now - 200}).and_return(true)

      expect(diff.send :filter_files, 'index.html').to eq(true)
    end

    it 'allows files with different hashes' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {mtime: now} })
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:check_hash).with(file, {mtime: now}).and_return(false)

      expect(diff.send :filter_files, 'index.html').to eq(true)
    end

    it 'allows files with different hashes and newer remote file' do
      remote_files = Usmu::MockRemoteFiles.new({ 'index.html' => {mtime: now + 200} })
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)
      expect(diff).to receive(:check_hash).with(file, {mtime: now + 200}).and_return(false)

      expect(diff.send :filter_files, 'index.html').to eq(true)
    end
  end

  context '#check_hash' do
    let (:contents) { 'Hello world!' }
    let (:diff) { Usmu::Deployment::DirectoryDiff.new(configuration, nil) }

    it 'can validate an MD5 hash' do
      expect(diff.send :check_hash, contents, {md5: '86fb269d190d2c85f6e0468ceca42a20'}).to eq(true)
      expect(diff.send :check_hash, contents, {md5: '02a24acec8640e6f58c2d091d962bf68'}).to eq(false)
    end

    it 'can validate a SHA1 hash' do
      expect(diff.send :check_hash, contents, {sha1: 'd3486ae9136e7856bc42212385ea797094475802'}).to eq(true)
      expect(diff.send :check_hash, contents, {sha1: '208574490797ae58321224cb6587e6319ea6843d'}).to eq(false)
    end

    it 'can validate a remote file with no hash' do
      expect(diff.send :check_hash, contents, {}).to eq(true)
    end
  end

  context '#local_files_list' do
    it 'returns a list of files in the local output directory' do
      expect(Dir).to receive(:[]).with('site/**/{*,.??*}').and_return(%w{site/index.html})
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, nil)

      expect(diff.send :local_files_list).to eq(%w{index.html})
    end
  end
end
