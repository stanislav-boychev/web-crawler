require 'rails_helper'

describe 'Domains::AssetsController', type: :request do
  describe 'index' do
    let(:faraday) {
      Faraday.new { |builder|
        builder.adapter :test, Faraday::Adapter::Test::Stubs.new { |stub|
          stub.get('/') { |env| [200, { 'Content-Type' => 'text/html' }, body] }
        }
      }
    }

    let(:body) {
      Nokogiri::HTML::Builder.new do |doc|
        doc.html {
          doc.body {
            doc.img(src: '/asset-1')
          }
        }
      end.to_html
    }

    before {
      allow(Faraday).to receive(:new).and_return(faraday)
    }

    let(:domain) { 'abc.com' }
    let(:html) { Nokogiri::HTML.parse(response.body) }

    before {
      get domain_assets_path(domain)
    }

    it 'returns 200 status code' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns html with asset-1' do
      expect(html.text).to match '/asset-1'
    end
  end
end
