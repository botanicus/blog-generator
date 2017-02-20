require 'json'
require 'integration/spec_helper'

describe '/post/second-post.json' do
  subject do
    JSON.parse(File.read('spec/data/output/posts/second-post.json'))
  end

  it_behaves_like 'a post listing'

  it 'has a body' do
    pending 'Markdown broken.'
    expect(subject['body']).to match('<h1>Hello world!</h1>')
  end
end
