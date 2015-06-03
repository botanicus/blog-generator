require 'date'
require 'json'
require 'yaml'
require 'nokogiri'
require 'ostruct'

module BlogGenerator
  class Post
    REGEXP = /^(\d{4}-\d{2}-\d{2})-(.+)\.(html|md)$/

    attr_reader :metadata
    def initialize(path)
      @path = path

      metadata = YAML.load_file(path)

      published_on, slug, format = parse_path(path)
      metadata.merge!(slug: slug, published_on: published_on)

      @metadata, @format = OpenStruct.new(metadata), format.to_sym
      body
    end

    # Maybe rename body -> raw_body and to_html -> body.
    def body
      @body ||= File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    end

    def excerpt
      document.css('#excerpt').inner_html.strip
    end

    def to_html
      return self.body if @format == :html
      convert_markdown if @format == :md
    end

    def to_json(*args)
      @metadata.instance_variable_get(:@table).to_json(*args)
    end

    private
    def method_missing(method, *args, &block)
      @metadata.send(method, *args, &block)
    end

    def document
      Nokogiri::HTML(self.to_html)
    end

    def parse_path(path)
      match = File.basename(path).match(REGEXP)
      [Date.parse(match[1]), match[2], match[3]]
    end

    def convert_markdown
      require 'redcarpet'

      renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      markdown.render(self.body)
    end
  end
end
