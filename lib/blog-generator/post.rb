require 'redcarpet'
require 'nokogiri'
require 'yaml'

module BlogGenerator
  class Post
    attr_reader :slug
    def initialize(slug, markdown_with_header)
      @slug, @markdown_with_header = slug, markdown_with_header
    end

    def title
      self.document.css('h1').inner_text
    end

    def excerpt
      self.document.css('p:first').inner_text
    end

    def header
      if @markdown_with_header.match(/\n---\s*\n/)
        YAML.load(@markdown_with_header).reduce(Hash.new) do |buffer, (key, value)|
          buffer.merge(key.to_sym => value)
        end
      else
        Hash.new
      end
    end

    def markdown_text
      if @markdown_with_header.match(/\n---\s*\n/)
        lines = @markdown_with_header.split("\n")
        index = lines.index('---')
        lines[(index + 1)..-1].join("\n")
      else
        @markdown_with_header
      end
    end

    def body
      self.markdown_text.split("\n").
        reject { |line| line.match(/# #{self.title}|#{self.excerpt}/) }.
        join("\n").sub(/^\s*(.+)\s*$/, '\1').gsub(/^#(#*) /, '\1 ')
    end

    def html_text
      @html_text ||= begin
        parser = Redcarpet::Markdown.new(Redcarpet::Render::HTML, footnotes: true)
        parser.render(self.markdown_text)
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

    def validate
      unless self.document.css('h1').length == 1
        raise ValidationError, "There was supposed to be exactly 1 <h1> element"
      end

      unless self.excerpt
        raise ValidationError, "Excerpt hasn't been found"
      end
    end
  end
end
