class WebCrawlerService
  def call(url)
    crawl_pages(url: url,
                path: '/',
                pages_map: initialize_pages_map,
                recursion_limit: 30)
  end

  private

  def crawl_pages(url:, path:, pages_map:, recursion_limit:)
    return {} if recursion_limit.zero? ||
                 different_domain?(url, path) ||
                 !path?(path)

    puts "in crawl_pages: #{path}. depth: #{recursion_limit}" if Rails.env.development?
    response = client(url).get(path)

    return {} if !response.success? || !html_content?(response)

    html = Nokogiri::HTML(response.body)

    pages_map[path] += collect_assets(html)

    new_pages_map = collect_links(html).reduce(pages_map) do |pages, link|
      next pages if page_visited?(pages, link)
      pages.merge! crawl_pages(url: url,
                               path: link,
                               pages_map: pages_map,
                               recursion_limit: recursion_limit - 1)
    end

    new_pages_map.to_h
  end

  def collect_links(html)
    html.css('a').map do |l|
      l["href"]
    end.compact
  end

  def html_content?(response)
    content_type = response.headers['Content-Type']
    content_type && content_type.include?('text/html')
  end

  def collect_assets(html)
    html.css('[src]').map do |a|
      a['src']
    end
  end

  def path?(path)
    URI.parse(path).path.present?
  end

  def page_visited?(pages_map, page)
    pages_map.keys.include? page
  end

  def different_domain?(url, path)
    URI.parse(path).host != URI.parse(url).host
  rescue URI::InvalidURIError
    true
  end

  def initialize_pages_map
    Hash.new { |k, v| k[v] = Array.new }
  end

  def client(url)
    Faraday.new(url: URI::HTTPS.build(host: url).to_s) do |f|
      f.headers['Connection'] = 'Keep-Alive'
      f.adapter Faraday.default_adapter
    end
  end
end
