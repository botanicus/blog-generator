require 'blog-generator'

describe BlogGenerator::ContentDirectoryValidator do
  context "valid content directory with post only" do
    subject { described_class.new('spec/data/basic-content-valid') }

    it "returns true" do
      expect(subject.validate).to be(true)
    end
  end

  context "valid content directory with post and images" do
    subject { described_class.new('spec/data/content-valid') }

    it "returns true" do
      expect(subject.validate).to be(true)
    end
  end

  context "invalid content directory with post but not images" do
    subject { described_class.new('spec/data/content-invalid-missing-images') }

    it "returns true" do
      expect { subject.validate }.to raise_error(BlogGenerator::ValidationError)
    end
  end
end

describe BlogGenerator::Generator do
  context "valid content directory with post only" do
    subject { described_class.new('spec/data/basic-content-valid', 'spec/data/tmp') }

    let(:actions) { subject.generate.to_a }

    it "returns true" do
      expect(actions[0]).to be_kind_of(BlogGenerator::CreateDirectoryAction)
      expect(actions[0].target_directory_path).to eql("spec/data/tmp/#{Time.now.strftime('%Y-%m-%d')}-hello-world/")

      expect(actions[1]).to be_kind_of(BlogGenerator::FileWriteAction)
      expect(actions[1].target_file_path).to eql("spec/data/tmp/#{Time.now.strftime('%Y-%m-%d')}-hello-world/hello-world.json")
      expect { JSON.parse(actions[1].content) }.not_to raise_error
      content = JSON.parse(actions[1].content)
      expect(content.keys).to eql(['title', 'excerpt', 'body', 'publishedAt'])
      expect(content['title']).to eql('Hello world')
      expect(content['excerpt']).to match(/^Lorem.+nisi.$/)

      body = content['body'].split("\n")
      expect(body.length).to eql(5)
      expect(body[0]).to eql('# Heading I')
      expect(body[1]).to match(/^Curabitur.+venenatis.$/)
      expect(body[2]).to eql('')
      expect(body[3]).to eql('# Heading II')
      expect(body[4]).to match(/^Vestibulum.+metus.$/)
      expect(content['publishedAt']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$/)

      expect(actions[2]).to be_kind_of(BlogGenerator::FileWriteAction)
      # TODO

      expect(actions[3]).to be_kind_of(BlogGenerator::FileWriteAction)
      # TODO

      expect(actions.length).to be(5)
    end
  end

  context "valid content directory with post and images" do
    subject { described_class.new('spec/data/content-valid', 'spec/data/tmp') }

    let(:actions) { subject.generate.to_a }

    it "returns true" do
      expect(actions[0]).to be_kind_of(BlogGenerator::CreateDirectoryAction)
      expect(actions[0].target_directory_path).to eql("spec/data/tmp/#{Time.now.strftime('%Y-%m-%d')}-hello-world/")

      expect(actions[1]).to be_kind_of(BlogGenerator::MoveFileAction)
      expect(actions[1].source_file).to eql('spec/data/content-valid/pic_II.png')
      expect(actions[1].target_directory).to eql('spec/data/tmp/2019-05-19-hello-world/')

      expect(actions[2]).to be_kind_of(BlogGenerator::MoveFileAction)
      expect(actions[2].source_file).to eql('spec/data/content-valid/pic_I.png')
      expect(actions[2].target_directory).to eql('spec/data/tmp/2019-05-19-hello-world/')

      expect(actions[3]).to be_kind_of(BlogGenerator::FileWriteAction)
      expect(actions[3].target_file_path).to eql("spec/data/tmp/#{Time.now.strftime('%Y-%m-%d')}-hello-world/hello-world.json")
      expect { JSON.parse(actions[3].content) }.not_to raise_error
      content = JSON.parse(actions[3].content)
      expect(content.keys).to eql(['title', 'excerpt', 'body', 'publishedAt'])
      expect(content['title']).to eql('Post title')
      expect(content['excerpt']).to match(/^Lorem.+nisi.$/)

      body = content['body'].split("\n")
      expect(body.length).to eql(8)
      expect(body[0]).to eql('![pic_I](pic_I.png)')
      expect(body[1]).to eql('# Heading I')
      expect(body[2]).to match(/^Curabitur.+venenatis.$/)
      expect(body[3]).to eql('')
      expect(body[4]).to eql('![pic_II](pic_II.png)')
      expect(body[5]).to eql('')
      expect(body[6]).to eql('# Heading II')
      expect(body[7]).to match(/^Vestibulum.+metus.$/)
      expect(content['publishedAt']).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}$/)

      expect(actions[4]).to be_kind_of(BlogGenerator::FileWriteAction)
      # TODO

      expect(actions[5]).to be_kind_of(BlogGenerator::FileWriteAction)
      # TODO

      expect(actions[6]).to be_kind_of(BlogGenerator::FileWriteAction)
      # TODO

      expect(actions.length).to be(7)
    end
  end

  # We are not testing invalid content, as that one doesn't pass through validation.
end
