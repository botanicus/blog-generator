require 'time'
require 'blog-generator/models'

describe BlogGenerator::Models::PostFromStoredPost do
  subject do
    described_class.new(data)
  end

  let(:data) {{
    title: 'Hello world',
    slug: 'hello-world',
    excerpt: 'Lorem ipsum.',
    publishedAt: Time.now.iso8601
  }}

  # This is true from PostFromPost, but not PostFromStoredPost.
  # it 'extends data with path' do
  #   expect(subject.as_json(Time.now)).to eql(data.merge(path: "/posts/#{Time.now.strftime('%Y-%m-%d')}-hello-world/hello-world.json"))
  # end
end

describe BlogGenerator::Models::Tag do
  subject do
    described_class.new('Ruby on Rails', [post_I, post_II, post_III])
  end

  let(:post_I) do
    BlogGenerator::Models::PostFromStoredPost.new(
      title: 'Hello world',
      slug: 'hello-world',
      path: '/posts/2019-05-18-hello-world/hello-world.json',
      tags: [],
      excerpt: 'Lorem ipsum.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:post_II) do
    BlogGenerator::Models::PostFromStoredPost.new(
      title: 'Ruby on Rails post I',
      slug: 'ruby-on-rails-post-I',
      path: '/posts/2019-05-18-ruby-on-rails-post-I/ruby-on-rails-post-I.json',
      tags: ['Ruby on Rails', 'Ruby'],
      excerpt: 'Sed eu est ipsum.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:post_III) do
    BlogGenerator::Models::PostFromStoredPost.new(
      title: 'React.js post I',
      slug: 'reactjs-post-I',
      path: '/posts/2019-05-18-reactjs-post-I/reactjs-post-I.json',
      tags: ['React.js', 'JavaScript'],
      excerpt: 'In sed tortor nulla.',
      publishedAt: Time.now.iso8601
    )
  end

  let(:data) { subject.as_json(Time.now) }

  it 'formats tag and posts data' do
    expect(data.keys).to eql([:tag, :posts])
    expect(data[:tag]).to eql({name: 'Ruby on Rails', slug: 'ruby-on-rails', path: '/tags/ruby-on-rails'})
    expect(data[:posts].length).to be(3)
    expect(data[:posts].map { |post| post[:slug] }).to eql(['hello-world', 'ruby-on-rails-post-I', 'reactjs-post-I'])
  end
end
