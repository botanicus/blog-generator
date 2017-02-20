require 'json'
require 'integration/spec_helper'

describe '/posts.json' do
  let(:posts) do
    JSON.parse(File.read('spec/data/output/posts.json'))
  end

  it "is a JSON array of posts" do
    expect(posts).to be_an(Array)
  end

  describe 'single post' do
    subject { posts.last }
    it_behaves_like 'a post listing'
  end
end
