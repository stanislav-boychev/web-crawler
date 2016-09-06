require 'rails_helper'

describe Domains::AssetsController, :type => :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(:get => '/domains/abc.com/assets').to route_to('domains/assets#index', domain_id: 'abc.com')
    end
  end
end
