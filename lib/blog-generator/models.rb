require 'time' # #iso8601

module BlogGenerator
  module Models
    class PostFromStoredPost
      def initialize(hash_data)
        @hash_data = hash_data.transform_keys(&:to_sym)
      end

      def as_json(*)
        {
          title: @hash_data.fetch(:title),
          slug: @hash_data.fetch(:slug),
          path: @hash_data.fetch(:path),
          tags: @hash_data.fetch(:tags),
          excerpt: @hash_data.fetch(:excerpt),
          publishedAt: @hash_data.fetch(:publishedAt)
        }
      end
    end

    class PostIndexFromPost
      def initialize(post)
        @post = post
      end

      def as_json(published_at)
        {
          title: @post.title,
          slug: @post.slug,
          path: "/posts/#{published_at.strftime('%Y-%m-%d')}-#{@post.slug}/#{@post.slug}.json",
          tags: @post.header[:tags],
          excerpt: @post.excerpt,
          publishedAt: published_at.iso8601
        }
      end
    end

    class FullPostFromPost < PostIndexFromPost
      def as_json(published_at)
        super(published_at).merge(body: @post.body)
      end
    end

    class Tag
      def initialize(tag_name, posts)
        @tag_name, @posts = tag_name, posts

        unless posts.all? { |post| post.respond_to?(:as_json) }
          raise ArgumentError, 'Posts must have #as_json method'
        end
      end

      def as_json(published_at)
        {tag: self.tag_data, posts: @posts.map { |post| post.as_json(published_at) }}
      end

      def tag_data
        {
          name: @tag_name,
          slug: self.slug,
          path: "/tags/#{self.slug}"
        }
      end

      def slug
        @tag_name.downcase.tr(' ', '-').delete('.,?!')
      end
    end
  end
end
