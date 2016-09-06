require 'rails_helper'

describe 'domains/assets/index' do
  let(:pages_map) { { 'pages-a' => ['asset-1', 'asset-2'] } }

  before {
    assign(:pages_map, pages_map)
    render
  }

  subject { Nokogiri::HTML.parse(rendered) }

  it 'has table header with pages-a' do
    header_text = subject.css('th').text
    expect(header_text).to match 'pages-a'
  end

  it 'has table columns with asset-1' do
    header_text = subject.css('td')[0].text
    expect(header_text).to match 'asset-1'
  end

  it 'has table columns with asset-1' do
    header_text = subject.css('td')[1].text
    expect(header_text).to match 'asset-2'
  end
end
