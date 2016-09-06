require 'rails_helper'

RSpec.describe Domains::AssetsController, :type => :controller do
  describe 'GET domains/:domain/assets' do
    let(:service_factory) { WebCrawlerService }
    let(:service) { instance_double(service_factory) }
    let(:pages_map) { { 'page-a' => ['asset-1', 'asset-2'] } }

    before {
      allow(service_factory).to receive(:new).and_return(service)
      allow(service).to receive(:call).and_return(pages_map)
      get :index, domain_id: 'abc.com'
    }

    it 'response with OK' do
      expect(response).to have_http_status(:ok)
    end

    it 'assigns @page_map' do
      expect(assigns(:pages_map)).to eq pages_map
    end

    it 'renders domains/assets/index template' do
      expect(response).to render_template('domains/assets/index')
    end
  end
end
