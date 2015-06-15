require 'json'
require 'date'
require 'yaml'
require 'nokogiri'

module BlogGenerator
  class Post
    REGEXP = /^(\d{4}-\d{2}-\d{2})-(.+)\.(html|md)$/

    attr_reader :site, :metadata
    def initialize(site, path)
      # TODO: metadata so we can construct url (base_url + relative) AND merge author
      @site, @path = site, path

      @metadata = YAML.load_file(path).reduce(Hash.new) do |buffer, (key, value)|
        buffer.merge(key.to_sym => value)
      end

      published_on, slug, format = parse_path(path)

      @body = convert_markdown(self.body) if format == :md
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
      name.downcase.tr(' /', '-').delete('!?')
    end

    # Maybe rename body -> raw_body and to_html -> body.
    def body
      @body ||= File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    end

    # We're converting it to MD, apparently it's necessary even though we converted the whole text initially, but it seems like MD ignores whatever is in <div id="excerpt">...</div>.
    def excerpt
      @excerpt ||= Nokogiri::HTML(convert_markdown(Nokogiri::HTML(self.body).css('#excerpt').inner_html.strip)).css('p').inner_html
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

    def convert_markdown(markup)
      require 'redcarpet'

      renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      markdown.render(markup)
    end
  end
end
