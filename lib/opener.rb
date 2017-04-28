require 'active_support/core_ext/hash'
require 'net/http'
require 'json'
require_relative 'parser'

class ParamFormatter
  attr_reader :params, :format

  def initialize(raw_params)
    @raw_params = raw_params
    @params     = {}.merge(prices).merge(rent_type).merge(only_owner)
                      .merge(bounds).merge(currency).merge(metro)
    puts params
    @format = @raw_params.format
  end

  def prices
    { price: { min: @raw_params.min_price,
               max: @raw_params.max_price } }
  end

  def rent_type
    { rent_type: @raw_params.rent_types }
  end

  def only_owner
    if @raw_params.only_owner
      { only_owner: @raw_params.only_owner }
    else
      {}
    end
  end

  def bounds
    { bounds: { lb: { lat:  53.72752332178119,
                      long: 27.413028708853112 },
                rt: { lat:  54.076181123270445,
                      long: 27.711908525658554 } } }
  end

  def currency
    { currency: @raw_params.currency }
  end

  def metro
    { metro: @raw_params.metro }
  end
end

class UrlGenerator
  BASE_URL = 'https://ak.api.onliner.by/search/apartments?'.freeze

  def initialize(params)
    @params = params
  end

  def page(page)
    { page: page }
  end

  def url_with_page(page)
    BASE_URL + @params.merge(page(page)).to_query
  end
end

class Opener

  JSON_NAME_PAGE       = 'page'.freeze
  JSON_NAME_LAST       = 'last'.freeze
  JSON_NAME_APARTMENTS = 'apartments'.freeze
  JSON_NAME_URL        = 'url'.freeze

  def initialize(raw_params)
    params_formatter = ParamFormatter.new(raw_params)
    @url_generator   = UrlGenerator.new(params_formatter.params)
    @format          = params_formatter.format
  end

  def get_json_by_url(url)
    uri      = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def parse_apartments(content)
    content[JSON_NAME_APARTMENTS].map do |apartment|
      apartment[JSON_NAME_URL]
    end
  end

  def start
    apartments_urls = []
    puts @url_generator.url_with_page 1
    first_page_content = get_json_by_url @url_generator.url_with_page 1
    #TODO fetch errors
    all_count_pages    = first_page_content[JSON_NAME_PAGE][JSON_NAME_LAST]
    (2..all_count_pages).each do |page|
      page_content = get_json_by_url @url_generator.url_with_page page
      apartments_urls.concat parse_apartments(page_content)
    end

    fetch_apartments apartments_urls
  end

  def fetch_apartments(urls)
    threads = []
    i       = 0
    urls.each do |url|
      threads[i] = Thread.new { Thread.current[:apartments] = Parser.new.parse(url); puts i }
      sleep(0.1)
      i += 1
    end
    apartments = []
    threads.each do |t|
      t.join
      apartments << t[:apartments]
    end
    apartments
  end

end
