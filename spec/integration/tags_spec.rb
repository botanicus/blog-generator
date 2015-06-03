require 'json'
require 'integration/spec_helper'

describe '/tags.json' do
  let(:tags) do
    JSON.parse(File.read('spec/output/tags.json'))
  end

  it "is a JSON array of tags" do
    expect(tags).to be_an(Array)
  end

  describe 'single tagged post' do
    subject { tags.first }

    it 'has a title' do
      expect(subject['title']).to eq('Hello world')
    end

    it 'has a slug' do
      expect(subject['slug']).to eq('hello-world')
    end
  end
end
