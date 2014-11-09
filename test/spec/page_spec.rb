require 'rspec'
require 'support/shared_layout'
require 'usmu/page'

RSpec.describe Usmu::Page do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }

  it 'uses the \'source\' folder' do
    page = Usmu::Page.new(configuration, 'index.md')
    rendered = page.render({})
    expect(rendered).to eq(File.read('test/expected-site/index.html'))
  end
end
