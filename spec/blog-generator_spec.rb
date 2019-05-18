require 'blog-generator'

describe BlogGenerator::ContentDirectoryValidator do
  context "valid content directory" do
    subject { described_class.new('spec/data/content-valid') }

    it "returns true" do
      expect(subject.validate).to be(true)
    end
  end
end
