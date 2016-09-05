class WebCrawlerService
  def call(url)
    visited_pages = Hash.new { |k, v| k[v] = Array.new }
    get_pages(url, '/', visited_pages, 30)
  end

  private

  def get_pages(url, path, visited_pages, depth_count)
    return {} if depth_count == 0
    return {} if visited_pages.keys.include? path
    return {} if URI.parse(path).host != URI.parse(url).host
    # return {} if URI.parse(path).scheme.in? %w(tel mailto)

    puts "in get_pages: #{path}. depth: #{depth_count}" if Rails.env.development?
    response = client(url).get(path)

    return {} unless response.success?

    content_type = response.headers['Content-Type']
    if !content_type || content_type.exclude?('text/html')
      return {}
    end

    html = Nokogiri::HTML(response.body)
    static_assets = html.css('[src]').map do |a|
      a['src']
    end

    visited_pages[path] += static_assets
    paths = html.css('a').map do |l|
      l["href"]
    end.compact

    unvisited_paths = paths.select do |l|
      visited_pages.keys.exclude? l
    end

    unvisited_paths.reduce(visited_pages) do |pages, next_path|
      pages.merge get_pages(url, next_path, visited_pages, depth_count - 1)
    end.to_h
  end

  def client(url)
    Faraday.new(url: "https://#{url}")
  end
end
