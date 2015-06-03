require 'json'
require 'integration/spec_helper'

describe '/tags.json' do
  let(:tagged_posts) do
    JSON.parse(File.read('spec/output/tags/test-some-thing.json'))
  end

  it "is a JSON array of posts with given tag" do
    expect(tagged_posts).to be_an(Array)
  end

  describe 'single post' do
    subject { tagged_posts.last }
    it_behaves_like 'a post listing'
  end
end
