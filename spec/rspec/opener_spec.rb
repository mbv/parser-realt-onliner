require 'spec_helper'
require 'opener'

RSpec.describe UrlGenerator do
  describe '#url_with_page' do
    let(:params) do
      { price:      { min: 10,
                      max: 40 },
        rent_type:  ['4_rooms'],
        only_owner: true,
        bounds:     { lb: { lat: 53.72752332178119,
                            long: 27.413028708853112 },
                      rt: { lat: 54.076181123270445,
                            long: 27.711908525658554 } },
        currency:   'usd', metro: ['blue_line'] }
    end
    let(:expected_url) { 'https://ak.api.onliner.by/search/apartments?bounds%5Blb%5D%5Blat%5D=53.72752332178119&bounds%5Blb%5D%5Blong%5D=27.413028708853112&bounds%5Brt%5D%5Blat%5D=54.076181123270445&bounds%5Brt%5D%5Blong%5D=27.711908525658554&currency=usd&metro%5B%5D=blue_line&only_owner=true&page=3&price%5Bmax%5D=40&price%5Bmin%5D=10&rent_type%5B%5D=4_rooms' }
    let(:page) { 3 }
    subject(:url_generator) { described_class.new(params) }

    it 'url should be like this' do
      expect(url_generator.url_with_page page).to eq(expected_url)
    end
  end
end