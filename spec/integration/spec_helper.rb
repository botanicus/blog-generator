%x{rm -rf spec/output}
%x{bundle exec bin/blog-generator.rb spec/data/posts spec/output}

shared_examples 'a post listing' do
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
    expect(subject['tags']).to eq([{'title' => 'Test some/thing', 'slug' => 'test-some-thing'}])
  end
end
