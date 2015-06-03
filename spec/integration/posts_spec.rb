require 'json'

describe '/posts.json' do
  before(:all) do
    %x{rm -rf spec/output; bundle exec bin/blog-generator.rb spec/data/posts spec/output}
  end

  let(:posts) do
    JSON.parse(File.read('spec/output/posts.json'))
  end

  it "is a JSON array of posts" do
    expect(posts).to be_an(Array)
  end

  context 'single post' do
    subject { posts.last }

    it 'has a title' do
      expect(subject['title']).to eq('Second post')
    end

    it 'has a slug' do
      expect(subject['slug']).to eq('second-post')
    end

    it 'has a published_on date' do
      expect(subject['published_on']).to eq('2015-06-02')
    end

    it 'has an excerpt' do
      expect(subject['excerpt']).to eq('This is the <em>excerpt</em>.')
    end

    it 'has tags' do
      expect(subject['tags']).to eq([{'title' => 'Test', 'slug' => 'test'}])
    end
  end
end
