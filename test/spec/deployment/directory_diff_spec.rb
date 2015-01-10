require 'usmu/deployment/directory_diff'
require 'usmu/mock_remote_files'
require 'ostruct'
require 'digest'

RSpec.describe Usmu::Deployment::DirectoryDiff do
  context '#get_diffs' do
    let (:configuration) { Usmu::Configuration.from_hash({}) }
    let (:file) { 'Hello world!' }
    let (:now) { Time.at(1420875742) }

    before do
      allow(File).to receive(:stat).with('site/index.html').and_return(OpenStruct.new({mtime: now}))
      allow(File).to receive(:read).with('site/index.html').and_return(file)
    end

    it 'returns remote only files' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w())
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now + 100,
                  :md5 => Digest::MD5.hexdigest(file),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({remote: ['index.html'], local: [], updated: []})
    end

    it 'returns local only files' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new({})
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: ['index.html'], remote: [], updated: []})
    end

    it 'hides identical files' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now,
                  :md5 => Digest::MD5.hexdigest(file),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: [], remote: [], updated: []})
    end

    it 'hides files newer on remote' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now + 100,
                  :md5 => Digest::MD5.hexdigest(file),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: [], remote: [], updated: []})
    end

    it 'returns files newer on local' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now - 100,
                  :md5 => Digest::MD5.hexdigest(file),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: [], remote: [], updated: ['index.html']})
    end

    it 'returns files with different hashes' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now,
                  :md5 => Digest::MD5.hexdigest(file + 'foo'),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: [], remote: [], updated: ['index.html']})
    end

    it 'returns files with different hashes and newer remote file' do
      allow(Dir).to receive(:'[]').with('site/**/{*,.??*}').and_return(%w(site/index.html))
      remote_files = Usmu::MockRemoteFiles.new(
          {
              'index.html' => {
                  :mtime => now + 100,
                  :md5 => Digest::MD5.hexdigest(file + 'foo'),
              },
          }
      )
      diff = Usmu::Deployment::DirectoryDiff.new(configuration, remote_files)

      expect(diff.get_diffs).to eq({local: [], remote: [], updated: ['index.html']})
    end
  end
end
