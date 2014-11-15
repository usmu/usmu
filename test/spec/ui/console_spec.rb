require 'usmu/ui/console'

Usmu.disable_stdout_logging

RSpec.describe Usmu::Ui::Console do
  it 'supports --quiet' do
    expect(Usmu).to receive(:quiet_logging)
    ui = Usmu::Ui::Console.new(%w{--quiet --config test/site/usmu.yml})
  end

  it 'supports --log' do
    expect(Usmu).to receive(:add_file_logger).with('test.log')
    ui = Usmu::Ui::Console.new(%w{--log test.log --config test/site/usmu.yml})
  end

  it 'supports --verbose' do
    expect(Usmu).to receive(:verbose_logging)
    ui = Usmu::Ui::Console.new(%w{--verbose --config test/site/usmu.yml})
  end

  it 'supports --trace' do
    expect(Usmu).to_not receive(:disable_stdout_logging)
    ui = Usmu::Ui::Console.new(%w{--trace --config test/site/usmu.yml})
    error_message = 'Raising an error to test trace'
    allow(ui.site_generator).to receive(:generate).and_raise(error_message)
    expect {ui.execute}.to raise_error(error_message)
  end
end
