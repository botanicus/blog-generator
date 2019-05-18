class Post
  def initialize(document)
    @document = document
  end

  def title
    @document.find('h1').inner_text
  end

  def excerpt
    @document.find('p:first').inner_text
  end

  protected
  def parse
  end
end
