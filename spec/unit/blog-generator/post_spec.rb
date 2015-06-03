require 'blog-generator/post'

describe BlogGenerator::Post do
  subject do
    described_class.new('spec/data/posts/2015-06-01-hello-world.html')
  end

  describe '#metadata' do
    it 'extracts metadata from the YAML header' do
      expect(subject.metadata.title).to eq('Hello world!')
      expect(subject.metadata.tags).to eq(['Hello world', 'Test'])
    end

    it 'extracts slug and published_on from the file name' do
      expect(subject.metadata.slug).to eq('hello-world')
      expect(subject.metadata.published_on.iso8601).to eq('2015-06-01')
    end

    it 'extracts the excerpt' do
      expect(subject.metadata.excerpt).to eq('This is the <em>excerpt</em>.')
    end
  end

  shared_examples 'HTML body' do
    describe '#body' do
      it 'returns the HTML' do
        expect(subject.body).to match('<div id="excerpt">')
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
    it 'serialises metadata to JSON' do
      expect(subject.to_json).to eq({
        'title' => 'Hello world!',
        'tags'  => ['Hello world', 'Test'],
        'slug'  => 'hello-world',
        'published_on' => '2015-06-01',
        'excerpt' => 'This is the <em>excerpt</em>.'}.to_json)
    end
  end
end