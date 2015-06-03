require 'json'

require 'blog-generator/post'
require 'blog-generator/post_list'

module BlogGenerator
  class Generator
    def self.parse(posts_dir)
      posts = Dir.glob("#{posts_dir}/*.{html,md}").reduce(PostList.new) do |posts, path|
        post = Post.new(path)
        puts "~ Parsing #{post.inspect}"
        posts.push(post)
      end

      self.new(posts)
    end

    attr_reader :posts
    def initialize(posts)
      @posts = posts
    end

    def tags
      @posts.reduce(Hash.new) do |buffer, post|
        puts; puts
        p post
        puts; puts
        post.tags.each do |tag|
          buffer[tag] ||= PostList.new
          buffer[tag] << post
        end

        buffer
      end
    end
  end
end
