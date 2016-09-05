class Domains::AssetsController < ApplicationController
  def index
    @assets_per_page = WebCrawlerService.new.call(params[:domain_id])
  end
end
