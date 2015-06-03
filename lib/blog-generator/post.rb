require 'date'
require 'json'
require 'yaml'
require 'nokogiri'
# require 'ostruct'

module BlogGenerator
  class Post
    REGEXP = /^(\d{4}-\d{2}-\d{2})-(.+)\.(html|md)$/

    attr_reader :metadata
    def initialize(path)
      @path = path

      @metadata = YAML.load_file(path).reduce(Hash.new) do |buffer, (key, value)|
        buffer.merge(key.to_sym => value)
      end

      published_on, slug, format = parse_path(path)

      @body = convert_markdown if format == :md
      self.body # cache if it wasn't called yet

      @metadata.merge!(slug: slug, published_on: published_on)
      @metadata.merge!(excerpt: excerpt)

      @metadata[:tags].map! do |tag|
        {title: tag, slug: generate_slug(tag)}
      end

      document = Nokogiri::HTML(self.body)
      document.css('#excerpt').remove
      @body = document.css('body').inner_html.strip
    end

    def generate_slug(name)
      name.downcase.tr(' ', '-').delete('!?')
    end

    # Maybe rename body -> raw_body and to_html -> body.
    def body
      @body ||= File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    end

    def excerpt
      @excerpt ||= Nokogiri::HTML(self.body).css('#excerpt').inner_html.strip
    end

    def as_json
      @metadata.merge(body: body)
    end

    def to_json(*args)
      self.as_json.to_json(*args)
    end

    private
    def method_missing(method, *args, &block)
      return super if (! args.empty?) || block
      @metadata[method]
    end

    def parse_path(path)
      match = File.basename(path).match(REGEXP)
      [Date.parse(match[1]), match[2], match[3].to_sym]
    end

    def convert_markdown
      require 'redcarpet'

      renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      markdown.render(self.body)
    end
  end
end
