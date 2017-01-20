require 'json'
require 'forwardable'

module BlogGenerator
  class PostList
    extend Forwardable

    attr_reader :site, :posts
    def initialize(site, posts = Array.new)
      @site, @posts = site, posts
    end

    def_delegators :@posts, :reduce, :each, :sort, :first, :last, :[], :empty?, :any?, :select # It might be about time to use some metaprogramming.

    def as_json
      self.posts.map do |post|
        post.as_json.tap do |metadata|
          metadata.delete(:body)
        end
      end
    end

    def to_json(*args)
      self.as_json.to_json(*args)
    end

    [:push, :<<].each do |method|
      define_method(method) do |*args, &block|
        @posts.send(method, *args, &block)
        self # Important!
      end
    end
  end
end
