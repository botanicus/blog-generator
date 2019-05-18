require 'redcarpet'
require 'nokogiri'

module BlogGenerator
  class Post
    def initialize(markdown_with_header)
      @document = document
    end

    def title
      @document.find('h1').inner_text
    end

    def excerpt
      @document.find('p:first').inner_text
    end

    def header
      if @markdown_with_header.match(/\n---\s*\n/)
        YAML.parse(@markdown_with_header)
      else
        Hash.new
      end
    end

    def markdown_text
    end

    def html_text
      @html_text ||= begin
        parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML, footnotes: true)
        parser.render(File.read(self.markdown_text))
      end
    end

    def document
      @document ||= Nokogiri::HTML(self.html_text)
    end

    def image_paths
      self.document.css('img').map do |element|
        element.attr('src').to_s
      end
    end

    def as_json
      {title: self.title, excerpt: self.excerpt, body: self.body}
    end

    protected
    def parse
    end
  end
end
