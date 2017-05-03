require 'spec_helper'
require 'opener'

RSpec.describe UrlGenerator do
  describe '#url_with_page' do
    let(:params) do
      { price:      { min: 10,
                      max: 40 },
        rent_type:  ['4_rooms'],
        only_owner: true,
        bounds:     { lb: { lat:  53.72752332178119,
                            long: 27.413028708853112 },
                      rt: { lat:  54.076181123270445,
                            long: 27.711908525658554 } },
        currency:   'usd', metro: ['blue_line'] }
    end
    let(:expected_url) { 'https://ak.api.onliner.by/search/apartments?bounds%5Blb%5D%5Blat%5D=53.72752332178119&bounds%5Blb%5D%5Blong%5D=27.413028708853112&bounds%5Brt%5D%5Blat%5D=54.076181123270445&bounds%5Brt%5D%5Blong%5D=27.711908525658554&currency=usd&metro%5B%5D=blue_line&only_owner=true&page=3&price%5Bmax%5D=40&price%5Bmin%5D=10&rent_type%5B%5D=4_rooms' }
    let(:page) { 3 }
    subject(:url_generator) { described_class.new(params) }

    it 'url should be like this' do
      expect(url_generator.url_with_page(page)).to eq(expected_url)
    end
  end
end

RSpec.describe ParserContainer do
  class BadGetterPages
    def get_json(_)
      { 'errors' => 'error' }
    end
  end
  class GoodGetterPages
    def get_json(_)
      {}
    end
  end
  class FakeUrlGenerator
    URL = 'fake_url'.freeze

    def url_with_page(_)
      URL
    end
  end

  before(:all) do
    @bad_getter_pages     = BadGetterPages.new
    @good_getter_pages    = GoodGetterPages.new
    @fake_url_generator   = FakeUrlGenerator.new
    @fake_page            = { 'page' => { 'last' => 1 } }
    @fake_page_with_2_all = { 'page' => { 'last' => 2 } }
    @good_page_for_return = @good_getter_pages.get_json nil
  end

  describe '#first_page' do
    let(:input_bad_params) do
      { getter_pages:  @bad_getter_pages,
        url_generator: @fake_url_generator }
    end
    let(:input_good_params) do
      { getter_pages:  @good_getter_pages,
        url_generator: @fake_url_generator }
    end
    let(:expected_bad_result) do
      { error:  'Bad params',
        errors: 'error' }
    end
    let(:expected_good_result) do
      { page:          @good_page_for_return,
        getter_pages:  @good_getter_pages,
        url_generator: @fake_url_generator }
    end
    first_page_step = ParserContainer.resolve(:first_page)

    it 'should return errors' do
      expect(first_page_step.call(input_bad_params).value).to eq(expected_bad_result)
    end

    it 'should return good value' do
      expect(first_page_step.call(input_good_params).value).to eq(expected_good_result)
    end

  end

  describe '#all_json_pages' do
    let(:input_one_page) do
      { page:          @fake_page,
        getter_pages:  @good_getter_pages,
        url_generator: @fake_url_generator }
    end
    let(:input_two_page) do
      { page:          @fake_page_with_2_all,
        getter_pages:  @good_getter_pages,
        url_generator: @fake_url_generator }
    end
    let(:exp_result_one_page) do
      { pages:            [@fake_page],
        parser_apartment: nil }
    end
    let(:exp_result_two_pages) do
      { pages:            [@fake_page_with_2_all, @good_page_for_return],
        parser_apartment: nil }
    end
    all_json_pages_step = ParserContainer.resolve(:all_json_pages)
    it 'should return one page' do
      expect(all_json_pages_step.call(input_one_page).value).to eq(exp_result_one_page)
    end
    it 'should return two pages' do
      expect(all_json_pages_step.call(input_two_page).value).to eq(exp_result_two_pages)
    end
  end
  describe '#get_apartment_urls' do
    good_page_with_apartments = { 'apartments' => [{ 'url' => 'url1' },
                                                   { 'url' => 'url2' }] }
    let(:input) do
      { pages: [good_page_with_apartments, good_page_with_apartments] }
    end

    let(:exp_urls) do
      { urls:             ['url1', 'url2', 'url1', 'url2'],
        parser_apartment: nil }
    end

    all_json_pages_step = ParserContainer.resolve(:get_apartment_urls)

    it 'should return urls from two pages' do
      expect(all_json_pages_step.call(input).value).to eq(exp_urls)
    end
  end
  describe '#fetch_apartments' do
    class FakeParser
      def parse(url)
        { url: url }
      end
    end
    let(:input) do
      { urls:             ['url1', 'url2'],
        parser_apartment: FakeParser.new }
    end
    let(:exp_result) do
      { apartments: [{ url: 'url1'},
                     { url: 'url2'}] }
    end

    fetch_apartments_step = ParserContainer.resolve(:fetch_apartments)

    it 'should return parsed pages' do
      expect(fetch_apartments_step.call(input).value).to eq(exp_result)
    end
  end

end
