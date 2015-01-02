require 'support/shared_layout'
require 'usmu/template/layout'

RSpec.describe Usmu::Template::Layout do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_hash({}) }

  it 'uses the \'layouts\' folder' do
    layout = Usmu::Template::Layout.new(configuration, 'html.slim', 'slim', "head\nbody", {})
    expect(layout.send :content_path).to eq('layouts')
  end

  it 'has an input path' do
    layout = Usmu::Template::Layout.new(configuration, 'html.slim', 'slim', "head\nbody", {})
    expect(layout.respond_to? :input_path).to eq(true)
    expect(layout.input_path).to eq('layouts/html.slim')
  end

  it 'should not allow circular references with #find_layout' do
    # This will also get tested during the acceptance tests, though we test here explicitly to help aid narrow where
    # the bug actually is.
    configuration = Usmu::Configuration.from_file('test/site/usmu.yml')
    layout = Usmu::Template::Layout.new(configuration, 'html.slim')
  end
end
