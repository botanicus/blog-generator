require 'json'
require 'date'
require 'yaml'
require 'nokogiri'
require 'cgi'

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
        buffer.merge(slug.to_sym => try_to_dup(value))
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
        process_body(nokogiri_raw_document.dup)
      end
    end

    def process_body(document)
      document.css('#excerpt').remove
      document.css('img[src^="/assets/"]').each do |img|
        absolute_url = img.attribute('src').value
        asset_path   = "..#{absolute_url}" # This is extremely shakey, it depends on us being in api.botanicus.me.
        if File.exists?(asset_path)
          img['src'] = image_binary_data(asset_path)
        else
          raise "Asset #{asset_path} doesn't exist."
        end
      end

      document.css('body').inner_html.strip
    end

    def post_processed_body
      @post_processed_body ||= post_process_body(self.body.to_s)
    end

    # This is a terrible hack to make unescaped code possible.
    def post_process_body(text)
      regexp = /<code lang="(\w+)">\n?(.*?)<\/code>/m
      original_body_matches = self.raw_body.scan(regexp)

      text.gsub(regexp).with_index do |pre, index|
        language, code = original_body_matches[index]
        "<pre><code class=\"#{language}\">#{CGI.escapeHTML(code)}</code></pre>"
      end
    end

    def image_binary_data(asset_path)
      require 'base64'

      extension    = File.extname(asset_path)[1..-1]
      binary_data  = File.read(asset_path)
      encoded_data = Base64.encode64(binary_data)

      "data:image/#{extension};base64,#{encoded_data}"
    end

    def excerpt
      @excerpt ||= begin
        document = nokogiri_raw_document.dup
        document.css('#excerpt').inner_html.sub(/^\s*(.*)\s*$/, '\1').chomp
      end
    end

    def as_json
      @metadata.merge(body: self.post_processed_body).tap do |metadata|
        metadata[:published_at] && metadata[:published_at] = DateTime.parse(metadata[:published_at])
        metadata[:updated_at]   && metadata[:updated_at]   = DateTime.parse(metadata[:updated_at])
      end
    end

    def to_json(*args)
      self.as_json.to_json(*args)
    end

    def save(extra_metadata = Hash.new)
      extra_metadata = extra_metadata.reduce(Hash.new) do |buffer, (key, value)|
        buffer.merge(key.to_s => value)
      end

      excerpt = self.excerpt.empty? ? %Q{<p id="excerpt">\n</p>} : %Q{<p id="excerpt">\n  #{self.excerpt}\n</p>}
      metadata = self.raw_metadata.merge(extra_metadata)
      <<-EOF
#{metadata.map { |key, value| "#{key}: #{value}"}.join("\n")}
---

#{excerpt}

#{self.post_processed_body}
      EOF
    end

    def links
      nokogiri_raw_document.css('a[href^="/posts/"]').map do |anchor|
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

    # true and some others cannot be cloned.
    def try_to_dup(value)
      value.dup
    rescue TypeError
      value
    end
  end
end
