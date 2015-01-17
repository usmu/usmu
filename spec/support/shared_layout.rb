
RSpec.shared_examples 'a renderable file' do
  let(:empty_configuration) { Usmu::Configuration.from_hash({}) }

  it 'and has a name' do
    layout = described_class.new(empty_configuration, 'body.slim', {}, 'slim', '')
    expect(layout.respond_to? :name).to eq(true)
    expect(layout.name).to eq('body.slim')
  end

  it 'and can be rendered' do
    layout = described_class.new(empty_configuration, 'body.slim', {}, 'slim', '')
    expect(layout.respond_to? :render).to eq(true)
    expect(layout.method(:render).arity).to eq(-1)
    expect(layout.method(:render).parameters.length).to eq(1)
  end
end

RSpec.shared_examples 'a layout' do
  include_examples 'a renderable file'

  let(:title_configuration) { Usmu::Configuration.from_hash({'default meta' => {'title' => 'title'}}) }
  let(:meta_with_title) { {'title' => 'meta title'} }
  let(:content) { "title \#{title}\nbody\n  #container\n    | \#{{content}}" }

  it 'and has a type' do
    layout = described_class.new(empty_configuration, 'body.slim', meta_with_title, 'slim', content)
    expect(layout.respond_to? :type).to eq(true)
    expect(layout.type).to eq('slim')
  end

  it 'and it renders a template' do
    layout = described_class.new(empty_configuration, 'body.slim', {}, 'slim', content)
    expect(layout.render({'title' => 'title', 'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end

  context 'and when it\'s type' do
    it 'is invalid' do
      expect {described_class.new(empty_configuration, 'body.foo', {}, nil, '')}.to raise_error()
    end

    it 'is erb then it\'s output type should be taken from it\'s filename' do
      layout = described_class.new(empty_configuration, 'body.txt.erb', {}, 'erb', '')
      expect(layout.output_filename).to eq('body.txt')
    end

    it 'is rhtml then it\'s output type should be taken from it\'s filename' do
      layout = described_class.new(empty_configuration, 'body.txt.rhtml', {}, 'rhtml', '')
      expect(layout.output_filename).to eq('body.txt')
    end

    it 'is erubis then it\'s output type should be taken from it\'s filename' do
      layout = described_class.new(empty_configuration, 'body.txt.erubis', {}, 'erubis', '')
      expect(layout.output_filename).to eq('body.txt')
    end

    it 'is markdown then it\'s output type should be html' do
      layout = described_class.new(empty_configuration, 'body.markdown', {}, 'markdown', '')
      expect(layout.output_filename).to eq('body.html')
    end

    it 'is mkd then it\'s output type should be html' do
      layout = described_class.new(empty_configuration, 'body.mkd', {}, 'mkd', '')
      expect(layout.output_filename).to eq('body.html')
    end

    it 'is md then it\'s output type should be html' do
      layout = described_class.new(empty_configuration, 'body.md', {}, 'md', '')
      expect(layout.output_filename).to eq('body.html')
    end

    it 'is coffee then it\'s output type should be js' do
      layout = described_class.new(empty_configuration, 'body.coffee', {}, 'coffee', '')
      expect(layout.output_filename).to eq('body.js')
    end

    it 'is less then it\'s output type should be css' do
      layout = described_class.new(empty_configuration, 'body.less', {}, 'less', '')
      expect(layout.output_filename).to eq('body.css')
    end

    it 'is liquid then it\'s output type should be taken from it\'s filename' do
      layout = described_class.new(empty_configuration, 'body.txt.liquid', {}, 'liquid', '')
      expect(layout.output_filename).to eq('body.txt')
    end

    it 'is sass then it\'s output type should be scss' do
      layout = described_class.new(empty_configuration, 'body.sass', {}, 'sass', '')
      expect(layout.output_filename).to eq('body.css')
    end

    it 'is scss then it\'s output type should be css' do
      layout = described_class.new(empty_configuration, 'body.scss', {}, 'scss', '')
      expect(layout.output_filename).to eq('body.css')
    end

    it 'is slim then it\'s output type should be html' do
      layout = described_class.new(empty_configuration, 'body.slim', {}, 'slim', '')
      expect(layout.output_filename).to eq('body.html')
    end
  end
end

RSpec.shared_examples 'a layout with metadata' do
  include_examples 'a layout'

  it 'and has metadata' do
    layout = described_class.new(empty_configuration, 'body.slim', meta_with_title, 'slim', content)
    expect(layout.respond_to? :metadata).to eq(true)
    expect(layout.metadata).to eq(meta_with_title)
  end

  it 'and respects default meta from configuration' do
    layout = described_class.new(title_configuration, 'body.slim', {}, 'slim', content)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>title</title><body><div id="container">test</div></body>
    EOF
  end

  context 'and prioritises' do
    it 'variables over metadata' do
      layout = described_class.new(empty_configuration, 'body.slim', meta_with_title, 'slim', content)
      expect(layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq(<<-EOF)
<title>overridden title</title><body><div id="container">test</div></body>
      EOF
    end

    it 'metadata over default metadata' do
      layout = described_class.new(title_configuration, 'body.slim', meta_with_title, 'slim', content)
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>meta title</title><body><div id="container">test</div></body>
      EOF
    end
  end

  it 'and it has a html output filename' do
    layout = described_class.new(empty_configuration, 'index.md', {}, 'md', content)
    expect(layout.output_filename).to eq('index.html')
  end
end

RSpec.shared_examples 'an embeddable layout' do
  include_examples 'a layout with metadata'

  let(:wrapper) { "html\n  | \#{{content}}"}

  it 'and respects parent templates' do
    parent = described_class.new(empty_configuration, 'html.slim', {}, 'slim', wrapper)
    layout = described_class.new(empty_configuration, 'body.slim', {'layout' => parent, 'title' => 'test title'}, 'slim', content)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>test title</title><body><div id="container">test</div></body>
</html>
    EOF
  end

  it 'and respects templates from default metadata' do
    parent = described_class.new(empty_configuration, 'html.slim', {}, 'slim', wrapper)
    default_layout_configuration = Usmu::Configuration.from_hash({'default meta' => {'layout' => parent}})
    layout = described_class.new(default_layout_configuration, 'body.slim', {'title' => 'test title'}, 'slim', content)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>test title</title><body><div id="container">test</div></body>
</html>
    EOF
  end

  it 'and uses a template of "none" to explicitly disable the parent template' do
    default_layout_configuration = Usmu::Configuration.from_hash({'default meta' => {'layout' => 'html'}})
    layout = described_class.new(default_layout_configuration, 'body.slim', {'layout' => 'none', 'title' => 'test title'}, 'slim', content)
    expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<title>test title</title><body><div id="container">test</div></body>
    EOF
  end

  it 'only uses a wrapper layout if the output types match' do
    parent = described_class.new(empty_configuration, 'html.slim', {}, 'slim', wrapper)
    layout = described_class.new(empty_configuration, 'app.scss', {'layout' => parent}, 'scss', 'body { color: #000; }')
    expect(layout.render({'content' => ''})).to eq(<<-EOF)
body {
  color: #000; }
    EOF
  end

  context 'and prioritises' do
    it 'metadata over parent metadata' do
      parent = described_class.new(empty_configuration, 'html.slim', {'title' => 'title'}, 'slim', wrapper)
      layout = described_class.new(empty_configuration, 'body.slim', {'layout' => parent, 'title' => 'overridden title'}, 'slim', content)
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end

    it 'parent metadata over default metadata' do
      parent = described_class.new(title_configuration, 'html.slim', {'title' => 'overridden title'}, 'slim', wrapper)
      layout = described_class.new(title_configuration, 'body.slim', {'layout' => parent}, 'slim', content)
      expect(layout.render({'content' => 'test'})).to eq(<<-EOF)
<html><title>overridden title</title><body><div id="container">test</div></body>
</html>
      EOF
    end
  end
end
