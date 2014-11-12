
RSpec.shared_examples 'a renderable file' do
  let(:empty_configuration) { Usmu::Configuration.from_hash({}) }

  it 'and has a name' do
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', '', {})
    expect(layout.respond_to? :name).to eq(true)
    expect(layout.name).to eq('body.slim')
  end

  it 'and can be rendered' do
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', '', {})
    expect(layout.respond_to? :render).to eq(true)
    expect(layout.method(:render).arity).to eq(-1)
    expect(layout.method(:render).parameters.length).to eq(1)
  end
end

RSpec.shared_examples 'a layout' do
  include_examples 'a renderable file'

  let(:title_configuration) { Usmu::Configuration.from_hash({'default meta' => {'title' => 'title'}}) }
  let(:meta_with_title) { {'title' => 'title'} }
  let(:content) { "title \#{title}\nbody\n  #container\n    | \#{{content}}" }

  it 'and has a type' do
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, meta_with_title)
    expect(layout.respond_to? :type).to eq(true)
    expect(layout.type).to eq('slim')
  end

  it 'and it renders a template' do
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, {})
    expect(layout.render({'title' => 'title', 'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end
end

RSpec.shared_examples 'a layout with metadata' do
  include_examples 'a layout'

  it 'and has metadata' do
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, meta_with_title)
    expect(layout.respond_to? :metadata).to eq(true)
    expect(layout.metadata).to eq(meta_with_title)
  end

  it 'and respects default meta from configuration' do
    layout = described_class.new(title_configuration, 'body.slim', 'slim', content, {})
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end

  context 'and prioritises' do
    it 'variables over metadata' do
      layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, meta_with_title)
      expect(layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq(<<-EOF)
<title>overridden title</title><body><div id="container">test</div></body>
      EOF
    end

    it 'variables over default metadata' do
      layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, {})
      expect(layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq(<<-EOF)
<title>overridden title</title><body><div id="container">test</div></body>
      EOF
    end
  end

  it 'and it has a html output filename' do
    layout = described_class.new(empty_configuration, 'index.md', 'md', content, {})
    expect(layout.output_filename).to eq('index.html')
  end
end

RSpec.shared_examples 'an embeddable layout' do
  include_examples 'a layout with metadata'

  let(:wrapper) { "html\n  | \#{{content}}"}

  it 'and respects parent templates' do
    parent = described_class.new(empty_configuration, 'html.slim', 'slim', wrapper, {})
    layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, {'layout' => parent, 'title' => 'test title'})
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>test title</title><body><div id="container">test</div></body>
</html>
    EOF
  end

  it 'and respects templates from default metadata' do
    parent = described_class.new(empty_configuration, 'html.slim', 'slim', wrapper, {})
    default_layout_configuration = Usmu::Configuration.from_hash({'default meta' => {'layout' => parent}})
    layout = described_class.new(default_layout_configuration, 'body.slim', 'slim', content, {'title' => 'test title'})
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>test title</title><body><div id="container">test</div></body>
</html>
    EOF
  end

  it 'and uses a template of "none" to explicitly disable the parent template' do
    default_layout_configuration = Usmu::Configuration.from_hash({'default meta' => {'layout' => 'html'}})
    layout = described_class.new(default_layout_configuration, 'body.slim', 'slim', content, {'layout' => 'none', 'title' => 'test title'})
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>test title</title><body><div id="container">test</div></body>
    EOF
  end

  context 'and prioritises' do
    it 'metadata over parent metadata' do
      parent = described_class.new(empty_configuration, 'html.slim', 'slim', wrapper, {'title' => 'title'})
      layout = described_class.new(empty_configuration, 'body.slim', 'slim', content, {'layout' => parent, 'title' => 'overridden title'})
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end

    it 'parent metadata over default metadata' do
      parent = described_class.new(title_configuration, 'html.slim', 'slim', wrapper, {'title' => 'overridden title'})
      layout = described_class.new(title_configuration, 'body.slim', 'slim', content, {'layout' => parent})
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end
  end
end
