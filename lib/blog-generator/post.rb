require 'json'
require 'date'
require 'yaml'
require 'nokogiri'

module BlogGenerator
  class Post
    REGEXP = /^(\d{4}-\d{2}-\d{2})-(.+)\.(html|md)$/

    attr_reader :site, :metadata, :format, :published_on, :updated_at
    def initialize(site, path)
      # TODO: metadata so we can construct url (base_url + relative) AND merge author
      @site, @path = site, File.expand_path(path)

      @metadata = YAML.load_file(path).reduce(Hash.new) do |buffer, (slug, value)|
        buffer.merge(slug.to_sym => value)
      end

      @published_on, slug, format = parse_path(path)

      @format = format # So we can access it from excerpt without having to pass it as an argument and break everything.

      @body = convert_markdown(self.body) if format == :md
      self.body # cache if it wasn't called yet

      @metadata.merge!(slug: slug, published_at: self.published_at)
      @metadata.merge!(excerpt: excerpt)
      @metadata.merge!(path: "/posts/#{slug}") ### TODO: some routing config.

      @metadata[:tags].map! do |tag|
        slug = generate_slug(tag)
        feed = "#{site.base_url}/#{slug}.atom"
        {title: tag, slug: slug, path: "/tags/#{slug}", feed: feed}
      end

      tag_feeds = @metadata[:tags].map do |tag|
        tag[:feed]
      end

      # @metadata.merge!(feeds: atom.feeds + tag_feeds) ### TODO: some routing config.

      document = Nokogiri::HTML(self.body)
      document.css('#excerpt').remove
      @body = document.css('body').inner_html.strip
    end

    # slug cannot be updated
    # => It has to be in Git now.
    def update_post_with_previous_values(old_post)
      @published_at = DateTime.parse(old_post.published_at).to_time.utc
      @updated_at = DateTime.parse(old_post.updated_at).to_time.utc if old_post.updated_at
      @metadata.merge!(published_at: self.published_at)
      @metadata.merge!(updated_at: self.updated_at) if @updated_at
      if old_post.body != self.body # TODO: some more intelligent analysis, if more than 10% changed.
        puts "~ Post #{self.slug} has been updated."
        self.update!
      end
    end

    # TODO: get rid off the variable and proxy it to metadata[:published_at].
    def published_at
      # When it was actually generated. It is then sourced from the last generated file, so it doesn't keep updating.
      @published_at ||= Time.now.utc
    end

    def update!
      @updated_at = Time.now.utc
    end

    def author
      self.metadata[:author] || site.author
    end

    def email
      self.metadata[:email] || site.email
    end

    def generate_slug(name)
      name.downcase.tr(' /', '-').delete('!?')
    end

    def relative_url
      "/posts/#{slug}"
    end

    def absolute_url
      [site.base_url, self.relative_url].join('')
    end

    def id
      digest = Digest::MD5.hexdigest(self.metadata[:slug])
      "urn:uuid:#{digest}"
    end

    # Maybe rename body -> raw_body and to_html -> body.
    def body
      @body ||= File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    end

    def excerpt
      if self.format == :html
        @excerpt ||= Nokogiri::HTML(Nokogiri::HTML(self.body).css('#excerpt').inner_html.strip).css('p').inner_html
      elsif self.format == :md
        # We're converting it to MD, apparently it's necessary even though we
        # converted the whole text initially, but it seems like MD ignores whatever
        # is in <div id="excerpt">...</div>.
        @excerpt ||= Nokogiri::HTML(convert_markdown(Nokogiri::HTML(self.body).css('#excerpt').inner_html.strip)).css('p').inner_html
      end
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
      [Date.parse(match[1]).to_time.utc, match[2], match[3].to_sym]
    end

    def convert_markdown(markup)
      require 'redcarpet'

      renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
      markdown = Redcarpet::Markdown.new(renderer, extensions = {})
      markdown.render(markup)
    end
  end
end
