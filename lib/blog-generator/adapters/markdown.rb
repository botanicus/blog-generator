def convert_markdown(markup)
  require 'redcarpet'

  renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true)
  markdown = Redcarpet::Markdown.new(renderer, extensions = {})
  markdown.render(markup)
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

  # Maybe rename body -> raw_body and to_html -> body.
  # This is being rewritten from initialize!
  def body(format = @format)
    require 'pry'; binding.pry ###
    case format
    when :md
      @body ||= convert_markdown(self.body(:html)) # I don't think this would work with ||= (which we're using so we can rewrite @body = in initialize.)
    when :html
      @body ||= File.read(@path).match(/\n---\n(.+)$/m)[1].strip
    else
      raise TypeError.new("Format #{@format} isn't supported.")
    end
  end
