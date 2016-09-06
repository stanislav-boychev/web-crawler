require 'rails_helper'

RSpec.describe PagesMap do
  subject { described_class.new }

  it 'behaves like hash' do
    is_expected.to respond_to(:each)
    is_expected.to respond_to(:map)
    is_expected.to respond_to(:fetch)
    is_expected.to respond_to(:[])
    is_expected.to respond_to(:has_key?)
  end

  describe 'addition' do
    before {
      subject[:a] << 123
    }

    it 'accepts unknown keys and creates array' do
      is_expected.to eq a: [123]
    end
  end

  describe '#page_visited?' do
    context 'when visisted' do
      before {
        subject['page-1'] << 'something'
      }

      it 'returns true' do
        expect(subject.page_visited?('page-1')).to be_truthy
      end
    end

    context 'when unvisisted' do
      before {
        subject['page-2'] << 'something'
      }

      it 'returns false' do
        expect(subject.page_visited?('page-1')).to be_falsey
      end
    end
  end

  describe '#merge' do
    subject { pages_map.merge(other_hash) }

    let(:pages_map) { PagesMap.new }
    let(:other_hash) { { b: [432] } }

    it 'returns new PagesMap with merged hash' do
      is_expected.to eq b: [432]
    end
  end
end
