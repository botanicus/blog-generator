puts("$ rm -rf spec/output")
system("rm -rf spec/output")
puts("$ bundle exec bin/blog-generator.rb spec/data/posts spec/output")
puts
system("bundle exec bin/blog-generator.rb spec/data/posts spec/output")
puts

shared_examples 'a post listing' do
  it 'has a title' do
    expect(subject['title']).to eq('Second post')
  end

  it 'has a key' do
    expect(subject['key']).to eq('second-post')
  end

  it 'has a published_on date' do
    expect(subject['published_on']).to eq('2015-06-02')
  end

  it 'has an excerpt' do
    expect(subject['excerpt']).to eq('This is the <em>excerpt</em>.')
  end

  it 'has tags' do
    expect(subject['tags']).to eq([{'title' => 'Test some/thing', 'key' => 'test-some-thing'}])
  end
end
