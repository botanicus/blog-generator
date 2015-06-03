require 'forwardable'

module BlogGenerator
  class PostList
    extend Forwardable

    attr_reader :posts
    def initialize
      @posts = Array.new
    end

    def_delegators :@posts, :reduce, :each

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
