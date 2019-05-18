require 'blog-generator/post'

describe BlogGenerator::Post do
  context 'with header' do
    subject do
      described_class.new <<~EOF
        tags: ["Ruby", "testing"]
        ---
        # Hello world
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam viverra ac leo at laoreet. Vivamus tristique pulvinar sem, in euismod odio. Curabitur ullamcorper ligula felis. Suspendisse at accumsan ante. Pellentesque convallis lorem eget metus fringilla, sit amet porttitor neque posuere. Praesent scelerisque est in lorem egestas ornare. Pellentesque ullamcorper ipsum id ante finibus gravida. Sed eget finibus tortor. Proin aliquam scelerisque rhoncus. Quisque in diam purus. Donec et tincidunt ante, sed finibus nisi.
      EOF
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
  end
end
