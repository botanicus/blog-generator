require 'json'

require 'blog-generator/post'
require 'blog-generator/post_list'

require 'blog-generator/feed'

module BlogGenerator
  class Generator
    def self.parse(site, posts_dir)
      posts = Dir.glob("#{posts_dir}/*.{html,md}").reduce(PostList.new(site)) do |posts, path|
        posts.push(Post.new(site, path))
      end

      posts = posts.sort do |a, b|
        b.published_on <=> a.published_on
      end

      self.new(site, posts)
    end

    attr_reader :site, :posts
    def initialize(site, posts)
      @posts = posts
    end

    def tags
      @posts.reduce(Hash.new) do |buffer, post|
        post.tags.each do |tag|
          buffer[tag] ||= PostList.new(site)
          buffer[tag] << post
        end

        buffer
      end
    end
  end
end
