require 'json'

require 'blog-generator/post'
require 'blog-generator/post_list'

module BlogGenerator
  class Generator
    def self.parse(site, posts_dir, old_posts)
      posts = Dir.glob("#{posts_dir}/*.{html,md}").reduce(Array.new) do |posts, path|
        posts.push(Post.new(site, path))
      end

      published_posts = posts.select { |post| ! post.metadata[:draft] }

      published_posts.sort! do |a, b|
        b.published_at <=> a.published_at
      end

      published_posts.each do |post|
        if old_post = old_posts[post.slug]
          post.update_post_with_previous_values(OpenStruct.new(old_post))
          p [post.published_at, post.published_on]
          if post.published_at && post.published_on.to_date != post.published_at.to_date
            abort "~ Published_at doesn't match published_on from the date part of #{post.slug} filename: #{[post.published_on.to_date, post.published_at.to_date].inspect}"
          end

        else
          puts "~ New post: #{post.slug}"
        end
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
