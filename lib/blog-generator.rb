require 'digest'
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
          draft.metadata[:published_at] = Time.now.utc.strftime('%d/%m/%Y %H:%M') # Let's emulate it so we get expected attributes in development.
          posts.push(draft)
        end
      end

      posts.sort! do |a, b|
        DateTime.parse(b.published_at) <=> DateTime.parse(a.published_at)
      end

      self.new(site, PostList.new(site, posts))
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

    def validate!
      self.validate_digest!
      self.validate_linked_posts!
    end

    def validate_digest!
      @posts.each do |post|
        next if post.metadata[:draft]

        # copied from cli/update.rb
        body_digest = Digest::MD5.hexdigest(post.raw_body) # Raw body, so it's with the excerpt as well.

        if body_digest != post.metadata[:digest]
          warn "WARNING: The MD5 digest of the body of #{post.slug} changed. You should either acknowledge so by running the update command or dismiss it by running the ignore_update command."
        end
      end
    end

    def validate_linked_posts!
      @posts.each do |post|
        post.links.each do |link|
          unless @posts.any? { |post| post.metadata[:path] == link }
            raise "Post #{post.slug} links #{link}, but there is no such post."
          end
        end
      end
    end
  end
end
