require 'json'
require 'date'
require 'yaml'
require 'nokogiri'

module BlogGenerator
  class Post
    REGEXP = /^((\d{4}-\d{2}-\d{2})-)?(.+)\.(html|md)$/

    [:slug, :tags, :published_at, :updated_at].each do |attribute|
      define_method(attribute) do
        @metadata[attribute]
      end
    end

    attr_reader :site, :metadata, :format
    def initialize(site, path)
      # TODO: metadata so we can construct url (base_url + relative) AND merge author
      @site, @path = site, File.expand_path(path)

      # TODO: Bring back .md from adapters/markdown.rb
      published_on, slug, format = parse_path(path)

      @metadata = self.load_metadata
      @metadata.merge!(slug: slug)
      @metadata.merge!(excerpt: excerpt)
      @metadata.merge!(path: "/posts/#{slug}") ### TODO: some routing config.
      @metadata.merge!(links: self.links)

      @metadata[:tags].map! do |tag|
        slug = generate_slug(tag)
        {title: tag, slug: slug, path: "/tags/#{slug}"}
      end
    end

    def raw_metadata
      @raw_metadata ||= begin
        YAML.load_file(@path) || raise("Metadata in #{@path} are not valid YAML.")
      end
    end

    def load_metadata
      self.raw_metadata.reduce(Hash.new) do |buffer, (slug, value)|
        buffer.merge(slug.to_sym => value.dup)
      end
    end

    def author
      self.metadata[:author] || site.author
    end

    def email
      self.metadata[:email] || site.email
    end

    def generate_slug(name) # for tags, should go to utils or something.
      name.downcase.tr(' /', '-').delete('!?')
    end

    def relative_url
      "/posts/#{slug}"
    end

    def absolute_url
      [site.base_url, self.relative_url].join('')
    end

    def raw_body
      File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    end

    def body
      @body ||= begin
        document = nokogiri_raw_document.dup
        document.css('#excerpt').remove
        document.css('body').inner_html.strip
      end
    end

    def excerpt
      @excerpt ||= begin
        document = nokogiri_raw_document.dup
        document.css('#excerpt').inner_html.sub(/\s*(.+)\s*/, '\1')
      end
    end

    def as_json
      @metadata.merge(body: body)
    end

    def to_json(*args)
      self.as_json.to_json(*args)
    end

    def save(extra_metadata = Hash.new)
      extra_metadata = extra_metadata.reduce(Hash.new) do |buffer, (key, value)|
        buffer.merge(key.to_s => value)
      end

      metadata = self.raw_metadata.merge(extra_metadata)
      <<-EOF
#{metadata.map { |key, value| "#{key}: #{value}"}.join("\n")}
---

<p id="excerpt">
  #{self.excerpt}
</p>

#{self.body}
      EOF
    end

    def links
      nokogiri_raw_document.css('a').map do |anchor|
        anchor.attribute('href').value
      end.uniq
    end

    private
    def nokogiri_raw_document
      @nokogiri_raw_document ||= Nokogiri::HTML(self.raw_body)
    end

    def parse_path(path)
      match = File.basename(path).match(REGEXP)
      published_on = match[1] ? Date.parse(match[1]).to_time.utc : nil
      [published_on, match[3], match[4].to_sym]
    end
  end
end
