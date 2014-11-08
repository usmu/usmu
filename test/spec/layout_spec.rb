require 'rspec'
require 'usmu/layout'

RSpec.describe 'Usmu::Layout' do
  before do
    @configuration = Usmu::Configuration.from_hash({})
    @meta = {'title' => 'title'}
    @content = "title \#{title}\nbody\n  #container\n    | \#{{content}}"
    @layout = Usmu::Layout.new(@configuration, 'html', 'slim', @content, @meta)
  end

  it 'has metadata' do
    expect(@layout.respond_to? :metadata).to eq(true)
    expect(@layout.metadata).to eq(@meta)
  end

  it 'can be rendered' do
    expect(@layout.respond_to? :render).to eq(true)
    expect(@layout.render({'content' => 'test'})).to eq('<title>title</title><body><div id="container">test</div></body>')
  end

  it 'respects default meta from configuration' do
    configuration = Usmu::Configuration.from_hash({'default meta' => {'title' => 'default title'}})
    layout = Usmu::Layout.new(configuration, 'html', 'slim', @content, {})
    expect(layout.render({'content' => 'test'})).to eq('<title>default title</title><body><div id="container">test</div></body>')
  end

  it 'respects parent templates' do
    parent = Usmu::Layout.new(@configuration, 'html', 'slim', "html\n  | \#{{content}}", {})
    layout = Usmu::Layout.new(@configuration, 'body', 'slim', @content, {'layout' => parent, 'title' => 'test title'})
    expect(layout.render({'content' => 'test'})).to eq('<html><title>test title</title><body><div id="container">test</div></body></html>')
  end

  context "prioritises" do
    it 'variables over metadata' do
      expect(@layout.render({'content' => 'test', 'title' => 'overridden title'})).to eq('<title>overridden title</title><body><div id="container">test</div></body>')
    end

    it 'metadata over parent metadata' do
      parent = Usmu::Layout.new(@configuration, 'html', 'slim', "html\n  | \#{{content}}", {'title' => 'title'})
      layout = Usmu::Layout.new(@configuration, 'body', 'slim', @content, {'layout' => parent, 'title' => 'overridden title'})
      expect(layout.render content: 'test').to eq('<html><title>overridden title</title><body><div id="container">test</div></body></html>')
    end

    it 'parent metadata over default metadata' do
      configuration = Usmu::Configuration.from_hash({'default meta' => {'title' => 'title'}})
      parent = Usmu::Layout.new(configuration, 'html', 'slim', "html\n  | \#{{content}}", {'title' => 'overridden title'})
      layout = Usmu::Layout.new(configuration, 'body', 'slim', @content, {'layout' => parent})
      expect(layout.render content: 'test').to eq('<html><title>overridden title</title><body><div id="container">test</div></body></html>')
    end
  end
end
