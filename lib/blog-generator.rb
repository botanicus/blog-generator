require 'blog-generator/post'
require 'blog-generator/post_list'

module BlogGenerator
  class Generator
    def self.parse(site, posts_dir, drafts_dir = false)
      posts = Dir.glob("#{posts_dir}/*.{html,md}").reduce(Array.new) do |posts, path|
        posts.push(Post.new(site, path))
      end

      if drafts_dir
        Dir.glob("#{drafts_dir}/*.{html,md}").each do |path|
          draft = Post.new(site, path)
          draft.metadata[:draft] = true
          draft.metadata[:published_at] = Time.not.utc # Let's emulate it so we get expected attributes in development.
          posts.push(draft)
        end
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
