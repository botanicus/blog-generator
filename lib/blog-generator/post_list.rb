require 'forwardable'

module BlogGenerator
  class PostList
    extend Forwardable

    attr_reader :posts
    def initialize
      @posts = Array.new
    end

    def_delegators :@posts, :reduce, :each

    def to_json(*)
      self.posts.reduce(Array.new) do |data, post|
        data << {title: post.title, slug: post.slug}
      end.to_json
    end


    [:push, :<<].each do |method|
      define_method(method) do |*args, &block|
        @posts.send(method, *args, &block)
        self # Important!
      end
    end
  end
end
