require 'active_support/core_ext/hash'
require 'net/http'
require 'json'
require_relative 'parser'

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

  def initialize(params)
    @url_generator = UrlGenerator.new(params)
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
    urls.each do |url|
      threads << Thread.new { Thread.current[:apartments] = Parser.new.parse(url) }
      sleep(0.1)
    end
    apartments = []
    threads.each do |t|
      t.join
      apartments << t[:apartments]
    end
    apartments
  end

end
