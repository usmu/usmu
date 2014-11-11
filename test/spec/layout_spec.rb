require 'support/shared_layout'

RSpec.describe Usmu::Layout do
  it_behaves_like 'an embeddable layout'

  let(:configuration) { Usmu::Configuration.from_file('test/site/usmu.yml') }

  it 'uses the \'layouts\' folder' do
    layout = Usmu::Layout.new(configuration, 'html.slim')
    rendered = layout.render({'content' => 'test'})
    expect(rendered).to eq(<<-EOF)
<!DOCTYPE html>
<html>
  <head>
    <title>Default Title | Testing website</title>
  </head>
  <body>
    <div id="content">
      test
    </div>
  </body>
</html>
    EOF
  end
end
