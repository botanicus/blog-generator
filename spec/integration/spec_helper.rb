puts("$ rm -rf spec/data/output")
system("rm -rf spec/data/output")
puts("$ cd spec/data && bundle exec ../bin/blog-generator.rb generate output")
puts
system("cd spec/data && bundle exec ../bin/blog-generator.rb generate output")
puts

shared_examples 'a post listing' do
  it 'has a title' do
    expect(subject['title']).to eq('Second post')
  end

  it 'has a slug' do
    expect(subject['slug']).to eq('second-post')
  end

  it 'has a published_at date' do
    expect(subject['published_at']).to eq('2017-01-24T23:14:00+00:00')
  end

  it 'has an excerpt' do
    pending 'Markdown broken.'
    expect(subject['excerpt']).to eq('This is the <em>excerpt</em>.')
  end

  it 'has tags' do
    expect(subject['tags']).to eq([{'title' => 'Test some/thing', 'slug' => 'test-some-thing', 'path' => '/tags/test-some-thing'}])
  end
end
