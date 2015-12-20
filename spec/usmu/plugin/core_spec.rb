require 'usmu/plugin/core'
require 'usmu/configuration'
require 'usmu/mock_commander'
require 'ostruct'
require 'rack'
require 'usmu/ui/rack_server'

RSpec.describe Usmu::Plugin::Core do
  let (:plugin) { described_class.new }
  let (:configuration) { Usmu::Configuration.from_hash({}) }
  let (:ui) { OpenStruct.new configuration: configuration }
  let (:commander) { Usmu::MockCommander.new }
  let (:options) { Commander::Command::Options.new }

  context '#commands' do
    it 'stores a the UI given to it' do
      plugin.commands(ui, commander)

      expect(plugin.send :ui).to eq(ui)
      expect(@log_output.readline).to eq("  DEBUG  Usmu::Plugin::Core : Adding core console commands...\n")
    end

    it 'defines a "generate" command' do
      plugin.commands(ui, commander)

      command = commander.get_command :generate
      expect(command[:syntax]).to eq('usmu generate')
      expect(command[:description]).to eq('Generates your website using the configuration specified.')
      expect(command[:action]).to be_a(Proc)
    end

    it 'defines a "init" command' do
      plugin.commands(ui, commander)

      command = commander.get_command :init
      expect(command[:syntax]).to eq('usmu init [path]')
      expect(command[:description]).to eq('Initialise a new website in the given path, or the current directory if none given.')
      expect(command[:action]).to be_a(Proc)
    end

    it 'defines a "serve" command' do
      plugin.commands(ui, commander)

      command = commander.get_command :serve
      expect(command[:syntax]).to eq('usmu serve')
      expect(command[:description]).to eq('Serve files processed files directly. This won\'t update files on disk, but you will be able to view your website as rendered.')
      expect(command[:action]).to be_a(Proc)
    end
  end

  context '#command_generate' do
    it 'raises an error when arguments are specified' do
      expect { plugin.command_generate(['foo'], options) }.to raise_error('This command does not take arguments')
    end

    it 'raises an error when invalid options are specified' do
      expect { plugin.command_generate([], []) }.to raise_error('Invalid options')
    end

    it 'should generate a site' do
      expect(configuration.generator).to receive(:generate)

      plugin.send :ui=, ui
      plugin.command_generate [], options
    end
  end

  context '#command_init' do
    it 'should do something'
  end

  context '#command_serve' do
    let (:empty_configuration) { Usmu::Configuration.from_hash({}) }
    let (:configuration) {
      Usmu::Configuration.from_hash(
          {
              'serve' => {
                  'host' => '0.0.0.0',
                  'port' => 8008,
              }
          }
      )
    }
    let (:rs) { OpenStruct.new }

    before do
      allow(Usmu::Ui::RackServer).to receive(:new).with(empty_configuration).and_return(rs)
      allow(Usmu::Ui::RackServer).to receive(:new).with(configuration).and_return(rs)
    end

    it 'raises an error when arguments are specified' do
      expect { plugin.command_serve(['foo'], options) }.to raise_error('This command does not take arguments')
    end

    it 'raises an error when invalid options are specified' do
      expect { plugin.command_serve([], []) }.to raise_error('Invalid options')
    end

    it 'should start a WEBrick Rack handler with a new RackServer UI' do
      plugin.send :ui=, OpenStruct.new(configuration: empty_configuration)
      expect(Rack::Handler::WEBrick).to receive(:run).with(rs, Host: 'localhost', Port: 8080)
      plugin.command_serve [], options
      expect(@log_output.readline).to eq("   INFO  Usmu::Plugin::Core : Starting webserver...\n")
    end

    it 'should take hostname and ports from the configuration file' do
      plugin.send :ui=, OpenStruct.new(configuration: configuration)
      expect(Rack::Handler::WEBrick).to receive(:run).with(rs, Host: '0.0.0.0', Port: 8008)
      plugin.command_serve [], options
    end
  end

  context '#init_copy_file' do
    it 'should do something'
  end
end
