require 'erb'
require 'ostruct'
require 'digest'
require 'forwardable'

module BlogGenerator
  class Feed
    extend Forwardable
    def_delegators :@feed, :base_url, :title, :subtitle, :author, :email

    attr_reader :feed, :posts
    def initialize(feed, posts, relative_url)
      @feed, @posts = OpenStruct.new(feed), posts
      @relative_url = relative_url
    end

    def feed_url
      [@feed.base_url, @relative_url].join('/')
    end

    def id
      digest = Digest::MD5.hexdigest(posts.each.map(&:title).join(","))
      "urn:uuid:#{digest}"
    end

    def updated_at
      self.posts.first.published_on.iso8601
    end

    def template
      # @template ||= DATA.read # Why can't I use DATA?
      @template ||= File.read(__FILE__).sub(/\A.*\n__END__\n/m, '')
    end

    def render
      ERB.new(self.template).result(binding)
    end
  end
end

__END__
<?xml version="1.0" encoding="utf-8"?>

<feed xmlns="http://www.w3.org/2005/Atom">
  <title><%= self.title %></title>
  <subtitle><%= self.subtitle %></subtitle>
  <link href="<%= self.feed_url %>" rel="self" />
  <link href="<%= self.base_url %>" />
  <id><%= self.id %></id>
  <updated><%= self.updated_at %></updated>

  <% posts.each do |post| %>
  <entry>
    <title><%= post.title %></title>
    <link href="<%= post.url %>" />
    <link rel="alternate" type="text/html" href="<%= post.url %>"/>
    <id><%= post.id %></id>
    <updated><%= post.updated_at %></updated>
    <summary><%= post.excerpt %></summary>
    <content type="xhtml">
      <%= post.content %>
    </content>
    <author>
      <name><%= post.author %></name>
      <email><%= post.email %></email>
    </author>
  </entry>
  <% end %>
</feed>
