require 'support/shared_layout'

RSpec.describe Usmu::Page do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }

  it 'uses the \'source\' folder' do
    page = Usmu::Page.new(configuration, 'index.md')
    rendered = page.render({})
    expect(rendered).to eq(File.read('test/expected-site/index.html'))
  end

  it 'has an input path' do
    configuration = Usmu::Configuration.from_hash({})
    page = Usmu::Page.new(configuration, 'index.md', 'md', '# test', {})
    expect(page.respond_to? :input_path).to eq(true)
    expect(page.input_path).to eq('src/index.md')
  end
end
