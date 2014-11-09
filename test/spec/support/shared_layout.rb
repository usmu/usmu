
RSpec.shared_examples 'a layout' do
  let(:empty_configuration) { Usmu::Configuration.from_hash({}) }
  let(:title_configuration) { Usmu::Configuration.from_hash({'default meta' => {'title' => 'title'}}) }
  let(:empty_hash) { {} }
  let(:meta_with_title) { {'title' => 'title'} }
  let(:content) { "title \#{title}\nbody\n  #container\n    | \#{{content}}" }

  it 'and has a name' do
    layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, meta_with_title)
    expect(layout.respond_to? :name).to eq(true)
    expect(layout.name).to eq('body')
  end

  it 'and has a type' do
    layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, meta_with_title)
    expect(layout.respond_to? :type).to eq(true)
    expect(layout.type).to eq('slim')
  end

  it 'and has metadata' do
    layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, meta_with_title)
    expect(layout.respond_to? :metadata).to eq(true)
    expect(layout.metadata).to eq(meta_with_title)
  end

  it 'and can be rendered' do
    layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, meta_with_title)
    expect(layout.respond_to? :render).to eq(true)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end

  it 'and respects default meta from configuration' do
    layout = Usmu::Layout.new(title_configuration, 'body', 'slim', content, empty_hash)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end

  context 'and prioritises' do
    it 'variables over metadata' do
      layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, meta_with_title)
      expect(layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq(<<-EOF)
<title>overridden title</title><body><div id="container">test</div></body>
    EOF
    end

    it 'variables over default metadata' do
      layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, empty_hash)
      expect(layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq(<<-EOF)
<title>overridden title</title><body><div id="container">test</div></body>
      EOF
    end
  end

end

RSpec.shared_examples 'an embeddable layout' do
  include_examples 'a layout'

  let(:wrapper) { "html\n  | \#{{content}}"}

  it 'and respects parent templates' do
    parent = Usmu::Layout.new(empty_configuration, 'html', 'slim', wrapper, empty_hash)
    layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, {'layout' => parent, 'title' => 'test title'})
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>test title</title><body><div id="container">test</div></body>
</html>
    EOF
  end

  context 'and prioritises' do
    it 'metadata over parent metadata' do
      parent = Usmu::Layout.new(empty_configuration, 'html', 'slim', wrapper, {'title' => 'title'})
      layout = Usmu::Layout.new(empty_configuration, 'body', 'slim', content, {'layout' => parent, 'title' => 'overridden title'})
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end

    it 'parent metadata over default metadata' do
      parent = Usmu::Layout.new(title_configuration, 'html', 'slim', wrapper, {'title' => 'overridden title'})
      layout = Usmu::Layout.new(title_configuration, 'body', 'slim', content, {'layout' => parent})
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end
  end
end
