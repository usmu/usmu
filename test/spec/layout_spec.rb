require 'support/shared_layout'

RSpec.describe Usmu::Layout do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_hash({}) }

  it 'uses the \'layouts\' folder' do
    layout = Usmu::Layout.new(configuration, 'html.slim', 'slim', "head\nbody", {})
    expect(layout.send :content_path).to eq('layouts')
  end

  it 'has an input path' do
    layout = Usmu::Layout.new(configuration, 'html.slim', 'slim', "head\nbody", {})
    expect(layout.respond_to? :input_path).to eq(true)
    expect(layout.input_path).to eq('layouts/html.slim')
  end
end
