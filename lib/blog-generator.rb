require 'json'

require 'blog-generator/post'
require 'blog-generator/post_list'

require 'blog-generator/feed'

module BlogGenerator
  class Generator
    # created_at = when compiled, UTC date time. Do not update if was created before.
    # updated_at = UTC date time if MD5 of body was updated
    # slug cannot be updated
    # delete if was deleted
    # => It has to be in Git now.
    def self.parse(site, posts_dir, old_posts)
      posts = Dir.glob("#{posts_dir}/*.{html,md}").reduce(Array.new) do |posts, path|
        posts.push(Post.new(site, path))
      end

      published_posts = posts.select { |post| ! post.metadata[:draft] }

      published_posts.sort! do |a, b|
        b.published_at <=> a.published_at
      end

      self.new(site, PostList.new(site, published_posts))
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
