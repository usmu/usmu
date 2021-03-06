require 'usmu/ui/console'

Usmu.disable_stdout_logging

RSpec.describe Usmu::Ui::Console do
  it 'supports --quiet' do
    expect(Usmu).to receive(:quiet_logging)
    Usmu::Ui::Console.new(%w{--quiet --config test-site/usmu.yml})
  end

  it 'supports --log' do
    expect(Usmu).to receive(:add_file_logger).with('test.log')
    Usmu::Ui::Console.new(%w{--log test.log --config test-site/usmu.yml})
  end

  it 'supports --verbose' do
    expect(Usmu).to receive(:verbose_logging)
    Usmu::Ui::Console.new(%w{--verbose --config test-site/usmu.yml})
  end

  it '#load_configuration returns a configuration' do
    config = Usmu::Ui::Console.new(%w{--config test-site/usmu.yml}).load_configuration('test-site/usmu.yml')
    expect(config.class.name).to eq('Usmu::Configuration')
  end
end
