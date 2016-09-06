class Domains::AssetsController < ApplicationController
  def index
    @pages_map = WebCrawlerService.new.call(params[:domain_id])
  end
end
