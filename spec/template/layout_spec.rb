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
    configuration = Usmu::Configuration.from_file('test-site/usmu.yml')
    layout = Usmu::Template::Layout.new(configuration, 'html.slim')
  end

  it 'should add a default load_path for sass templates' do
    configuration = Usmu::Configuration.from_hash({'source' => 'src'}, 'test/usmu.yml')
    layout = Usmu::Template::Layout.new(configuration, 'css/app.scss', 'scss', "body{color: #000;}", {})
    defaults = layout.send :add_template_defaults, {}, 'sass'
    expect(defaults[:load_paths]).to eq(['test/src/css'])
  end

  it 'should merge load_path\'s for sass templates' do
    configuration = Usmu::Configuration.from_hash({'source' => 'src'}, 'test/usmu.yml')
    layout = Usmu::Template::Layout.new(configuration, 'css/app.scss', 'scss', "body{color: #000;}", {})
    defaults = layout.send :add_template_defaults, {load_paths: ['test/src/assets/scss']}, 'sass'
    expect(defaults[:load_paths].sort).to eq(['test/src/assets/scss', 'test/src/css'])
  end
end
