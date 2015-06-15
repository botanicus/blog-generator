require 'blog-generator/post'

describe BlogGenerator::Post do
  subject do
    described_class.new('spec/data/posts/2015-06-01-hello-world.html')
  end

  describe '#metadata' do
    it 'extracts metadata from the YAML header' do
      expect(subject.metadata[:title]).to eq('Hello world!')
      hello = {title: 'Hello world', slug: 'hello-world'}
      test  = {title: 'Test some/thing', slug: 'test-some-thing'}
      expect(subject.metadata[:tags]).to eq([hello, test])
    end

    it 'extracts slug and published_on from the file name' do
      expect(subject.metadata[:slug]).to eq('hello-world')
      expect(subject.metadata[:published_on].iso8601).to eq('2015-06-01')
    end

    it 'extracts the excerpt' do
      expect(subject.metadata[:excerpt]).to eq('This is the <em>excerpt</em>.')
    end
  end

  shared_examples 'HTML body' do
    describe '#body' do
      it 'returns the HTML sans the excerpt' do
        expect(subject.body).not_to match('<div id="excerpt">')
        expect(subject.body).to match('<h1>Hello world!</h1>')
      end
    end

    describe '#excerpt' do
      it 'parses the excerpt from the body' do
        expect(subject.excerpt).to eq('This is the <em>excerpt</em>.')
      end
    end
  end

  context 'plain HTML' do
    it_behaves_like 'HTML body'
  end

  context 'markdown' do
    subject do
      described_class.new('spec/data/posts/2015-06-02-second-post.md')
    end

    it_behaves_like 'HTML body'
  end

  describe '#to_json' do
    it 'serialises metadata and the body to JSON' do
      expect(subject.to_json).to eq({
        'title' => 'Hello world!',
        'tags'  => [
          {title: 'Hello world', slug: 'hello-world'},
          {title: 'Test some/thing', slug: 'test-some-thing'}
        ],
        'slug'  => 'hello-world',
        'published_on' => '2015-06-01',
        'excerpt' => 'This is the <em>excerpt</em>.',
        'body' => "<h1>Hello world!</h1>\n<p>\n  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Soluta quibusdam necessitatibus tempore ullam incidunt amet omnis, veritatis dicta quisquam accusamus at provident vel facere corporis sed fugiat cumque. Consequuntur, necessitatibus!\n</p>"
      }.to_json)
    end
  end
end
