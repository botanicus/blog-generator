module BlogGenerator
  class Post
    def initialize(hash_data)
      @hash_data = hash_data.transform_keys(&:to_sym)
    end

    def as_json
      {
        title: @hash_data.fetch(:title),
        slug: @hash_data.fetch(:slug),
        path: "/posts/#{@hash_data.fetch(:slug)}",
        excerpt: @hash_data.fetch(:excerpt),
        publishedAt: @hash_data.fetch(:publishedAt)
      }
    end
  end

  class Tag
    def initialize(tag_name, posts)
      @tag_name, @posts = tag_name, posts

      unless posts.all? { |post| post.respond_to?(:as_json) }
        raise ArgumentError, 'Posts must have #as_json method'
      end
    end

    def as_json
      {tag: self.tag_data, posts: @posts.map(&:as_json)}
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
