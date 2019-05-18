require 'blog-generator/post'

describe BlogGenerator::Post do
  context 'with header' do
    subject do
      described_class.new 'hello-world', <<~EOF
        tags: ["Ruby", "testing"]
        ---
        # Hello world
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam viverra ac leo at laoreet. Vivamus tristique pulvinar sem, in euismod odio. Curabitur ullamcorper ligula felis. Suspendisse at accumsan ante. Pellentesque convallis lorem eget metus fringilla, sit amet porttitor neque posuere. Praesent scelerisque est in lorem egestas ornare. Pellentesque ullamcorper ipsum id ante finibus gravida. Sed eget finibus tortor. Proin aliquam scelerisque rhoncus. Quisque in diam purus. Donec et tincidunt ante, sed finibus nisi.

        ## Subtitle
        Curabitur at lectus at nibh sagittis cursus. Etiam ligula elit, tincidunt id augue rhoncus, tincidunt feugiat urna. Vivamus placerat nunc nec ligula imperdiet auctor. Vestibulum facilisis, metus vitae suscipit vestibulum, ex lectus placerat tellus, id volutpat odio enim non mauris. Sed venenatis vulputate urna, eu rutrum eros mattis non. Morbi lobortis tempor lorem, non efficitur metus congue quis. Proin sagittis nec mi vitae pellentesque. Ut porta magna id finibus lobortis. Proin tempor auctor lectus sit amet venenatis.
      EOF
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
      expect(lines.length).to be(5)
      expect(lines[0]).to eql("# #{subject.title}")
      expect(lines[1]).to match(/^Lorem.+nisi.$/)
      expect(lines[2]).to eql('')
      expect(lines[3]).to eql('## Subtitle')
      expect(lines[4]).to match(/^Curabitur.+venenatis.$/)
    end

    it 'parses out the #body' do
      lines = subject.body.split("\n")
      expect(lines.length).to be(2)
      expect(lines[0]).to eql('## Subtitle')
      expect(lines[1]).to match(/^Curabitur.+venenatis.$/)
    end
  end
end
