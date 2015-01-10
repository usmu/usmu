require 'support/shared_layout'
require 'usmu/template/static_file'

RSpec.describe Usmu::Template::StaticFile do
  it_behaves_like 'a renderable file'

  let(:configuration) { Usmu::Configuration.from_file('test-site/usmu.yml') }

  it 'uses the \'source\' folder' do
    file = Usmu::Template::StaticFile.new(configuration, 'robots.txt')
    rendered = file.render
    expect(rendered).to eq(File.read('test-site/expected-site/robots.txt'))
  end

  it 'has an input path' do
    configuration = Usmu::Configuration.from_hash({})
    page = Usmu::Template::StaticFile.new(configuration, 'robots.txt', 'txt', '', {})
    expect(page.respond_to? :input_path).to eq(true)
    expect(page.input_path).to eq('src/robots.txt')
  end

  it 'has an output filename that matches input' do
    file = Usmu::Template::StaticFile.new(configuration, 'robots.txt')
    expect(file.output_filename).to eq('robots.txt')
  end
end
