require 'support/shared_layout'
require 'usmu/page'

RSpec.describe Usmu::Page do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_hash({}) }

  it 'uses the \'source\' folder' do
    page = Usmu::Page.new(configuration, 'index.md', 'md', '# test', {})
    expect(page.send :content_path).to eq('src')
  end

  it 'has an input path' do
    page = Usmu::Page.new(configuration, 'index.md', 'md', '# test', {})
    expect(page.respond_to? :input_path).to eq(true)
    expect(page.input_path).to eq('src/index.md')
  end
end
