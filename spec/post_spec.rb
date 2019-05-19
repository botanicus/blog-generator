require 'blog-generator/post'

describe BlogGenerator::Post do
  context 'with header' do
    subject do
      described_class.new('hello-world', File.read('spec/data/basic-content-valid/hello-world.md'))
    end

    it 'has #slug' do
      expect(subject.slug).to eql('hello-world')
    end

    it 'parses out the #title' do
      expect(subject.title).to eql('Hello world')
    end

    it 'parses out the #excerpt' do
      expect(subject.excerpt).to match(/^Lorem.+nisi.$/)
    end

    it 'parses out the #header' do
      expect(subject.header).to eql(tags: ['Ruby', 'testing'])
    end

    it 'parses out the #markdown_text' do
      lines = subject.markdown_text.split("\n")
      expect(lines.length).to be(9)
      expect(lines[0]).to eql('')
      expect(lines[1]).to eql("# #{subject.title}")
      expect(lines[2]).to match(/^Lorem.+nisi.$/)
      expect(lines[3]).to eql('')
      expect(lines[4]).to eql('## Heading I')
      expect(lines[5]).to match(/^Curabitur.+venenatis.$/)
      expect(lines[6]).to eql('')
      expect(lines[7]).to eql('## Heading II')
      expect(lines[8]).to match(/^Vestibulum.+metus.$/)
    end

    # It converts h2 to h1 etc, because h1 is the article title.
    it 'parses out the #body' do
      lines = subject.body.split("\n")
      expect(lines.length).to be(5)
      expect(lines[0]).to eql('# Heading I')
      expect(lines[1]).to match(/^Curabitur.+venenatis.$/)
      expect(lines[2]).to eql('')
      expect(lines[3]).to eql('# Heading II')
      expect(lines[4]).to match(/^Vestibulum.+metus.$/)
    end
  end
end
