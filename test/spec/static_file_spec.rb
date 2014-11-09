require 'rspec'
require 'support/shared_layout'
require 'usmu/static_file'

RSpec.describe Usmu::StaticFile do
  it_behaves_like 'a renderable file'

  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }

  it 'uses the \'source\' folder' do
    file = Usmu::StaticFile.new(configuration, 'robots.txt')
    rendered = file.render
    expect(rendered).to eq(File.read('test/expected-site/robots.txt'))
  end
end
