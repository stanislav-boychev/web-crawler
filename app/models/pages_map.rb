class PagesMap < SimpleDelegator
  attr_reader :data

  def initialize
    @data = Hash.new { |k, v| k[v] = Array.new }
    super(@data)
  end

  def page_visited?(page)
    @data.keys.include? page
  end

  def merge(other_hash)
    new_pages_map = self.class.new
    new_pages_map.merge! other_hash
    new_pages_map
  end
end
