require 'rails_helper'

RSpec.describe WebCrawlerService do
  subject { described_class.new.call(url) }

  let(:headers) { { 'Content-Type' => 'text/html' } }
  let(:url) { 'gocardless.com' }
  let(:code) { 200 }
  let(:root) { '/' }
  let(:link1) { '/link-a' }
  let(:link2) { '/link-b' }
  let(:html_builder) { Nokogiri::HTML::Builder }

  let(:faraday) {
    Faraday.new { |builder|
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new { |stub|
        stub.get(root) { |env| [code, headers, root_body] }
        stub.get(link1) { |env| [code, headers, link1_body] }
        stub.get(link2) { |env| [code, headers, link2_body] }
      }
    }
  }

  let(:link1_body) {
    html_builder.new do |doc|
      doc.html {
        doc.body {
          doc.div('Hello')
        }
      }
    end.to_html
  }

  let(:link2_body) {
    html_builder.new do |doc|
      doc.html {
        doc.body {
          doc.div('Hello')
        }
      }
    end.to_html
  }

  let(:root_body) {
    html_builder.new do |doc|
      doc.html {
        doc.body {
          doc.a(href: link1)
          doc.a(href: link2)
          doc.img(src: '/asset-1')
        }
      }
    end.to_html
  }

  before {
    allow(Faraday).to receive(:new).with(url: "https://#{url}").and_return(faraday)
  }

  it 'returns a Hash' do
    expect(subject).to be_a Hash
  end

  it 'returns assets per path' do
    expect(subject.size).to eq 3
    expect(subject).to include root => ['/asset-1']
    expect(subject).to include '/link-a' => []
    expect(subject).to include '/link-b' => []
  end

  context 'when status code is not 2xx' do
    let(:code) { 404 }

    it 'returns empty hash' do
      expect(subject).to be_a Hash
      expect(subject).to be_empty
    end
  end

  context 'when content type is not html' do
    let(:headers) { { 'Content-Type' => 'application/json' } }

    it 'returns empty hash' do
      expect(subject).to be_a Hash
      expect(subject).to be_empty
    end
  end

  context 'with nested pages' do
    it 'returns assets per path' do
      expect(subject).to include link1 => []
    end
  end

  context 'with cyclic paths' do
    let(:link1_body) {
      html_builder.new do |doc|
        doc.html {
          doc.body {
            doc.a(href: root)
            doc.img(src: '/asset-2')
          }
        }
      end.to_html
    }

    it 'returns assets per path' do
      expect(subject).to include root => ['/asset-1']
      expect(subject).to include link1 => ['/asset-2']
    end
  end

  context 'with two different pages linked to 3rd page' do
    let(:link1_body) {
      html_builder.new do |doc|
        doc.html {
          doc.body {
            doc.a(href: link2)
            doc.img(src: '/asset-2')
          }
        }
      end.to_html
    }

    let(:link2_body) {
      html_builder.new do |doc|
        doc.html {
          doc.body {
            doc.div('Hello')
          }
        }
      end.to_html
    }

    before {
      allow(faraday).to receive(:get).with(root).and_call_original
      allow(faraday).to receive(:get).with(link1).and_call_original
    }

    it 'returns assets per path' do
      expect(faraday).to receive(:get).with(link2).once.and_call_original
      expect(subject).to include root => ['/asset-1']
      expect(subject).to include link1 => ['/asset-2']
      expect(subject).to include link2 => []
    end
  end

  context 'with link to outside domain' do
    let(:link1) { 'https://bravenewworld.org/login' }

    before {
      allow(faraday).to receive(:get).and_call_original
    }
    it 'never visits it' do
      expect(faraday).not_to receive(:get).with(link1)
      expect(subject).not_to include link1
    end
  end

  # context 'with invalid schema' do
  #   let(:link1) { 'mailto:foo@mail.com' }
  #
  #   before {
  #     allow(faraday).to receive(:get).and_call_original
  #   }
  #   it 'never visits it' do
  #     expect(faraday).not_to receive(:get).with(link1)
  #     expect(subject).not_to include link1
  #   end
  # end
end
