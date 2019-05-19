require 'time'
require 'blog-generator/models'

describe BlogGenerator::Post do
  subject do
    described_class.new(data)
  end

  let(:data) {{
    title: 'Hello world',
    slug: 'hello-world',
    excerpt: 'Lorem ipsum.',
    publishedAt: Time.now.iso8601
  }}

  it 'extends data with path' do
    expect(subject.as_json).to eql(data.merge(path: '/posts/hello-world'))
  end
end

describe BlogGenerator::Tag do
  subject do
    described_class.new('Ruby on Rails', [post_I, post_II, post_III])
  end

  let(:post_I) do
    BlogGenerator::Post.new(
      title: 'Hello world',
      slug: 'hello-world',
      excerpt: 'Lorem ipsum.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:post_II) do
    BlogGenerator::Post.new(
      title: 'Ruby on Rails post I',
      slug: 'ruby-on-rails-post-I',
      excerpt: 'Sed eu est ipsum.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:post_III) do
    BlogGenerator::Post.new(
      title: 'React.js post I',
      slug: 'reactjs-post-I',
      excerpt: 'In sed tortor nulla.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:data) { subject.as_json }

  it 'formats tag and posts data' do
    expect(data.keys).to eql([:tag, :posts])
    expect(data[:tag]).to eql({name: 'Ruby on Rails', slug: 'ruby-on-rails', path: '/tags/ruby-on-rails'})
    expect(data[:posts].length).to be(3)
    expect(data[:posts].map { |post| post[:slug] }).to eql(['hello-world', 'ruby-on-rails-post-I', 'reactjs-post-I'])
  end
end
