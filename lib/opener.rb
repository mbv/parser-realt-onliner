require 'active_support/core_ext/hash'
require 'net/http'
require 'json'
require 'dry-container'
require 'dry-monads'
require 'dry-transaction'
require_relative 'parser'
require_relative 'getter_pages'

class ParserHelper

  JSON_NAME_APARTMENTS = 'apartments'.freeze
  JSON_NAME_URL        = 'url'.freeze

  def self.parse_apartments(content)
    content[JSON_NAME_APARTMENTS].map do |apartment|
      apartment[JSON_NAME_URL]
    end
  end

  def self.fetch_apartments(urls)
    threads = []
    urls.each do |url|
      threads << Thread.new { Thread.current[:result] = Parser.new.parse(url) }
      sleep(0.1)
    end
    threads.map do |t|
      t.join
      t[:result]
    end
  end
end

class ParserContainer
  extend Dry::Container::Mixin

  JSON_NAME_PAGE   = 'page'.freeze
  JSON_NAME_LAST   = 'last'.freeze
  JSON_NAME_ERRORS = 'errors'.freeze

  register :first_page, (->(input) do
    url  = input[:url_generator].url_with_page(1)
    page = input[:getter_pages].get_json(url)
    if page.key? JSON_NAME_ERRORS
      Dry::Monads.Left(error: 'Bad params', errors: page[JSON_NAME_ERRORS])
    else
      Dry::Monads.Right(page: page, **input)
    end
  end)
  register :all_json_pages, (->(input) do
    pages           = [input[:page]]
    all_count_pages = input[:page][JSON_NAME_PAGE][JSON_NAME_LAST]
    (2..all_count_pages).each do |page_number|
      url = input[:url_generator].url_with_page(page_number)
      pages << input[:getter_pages].get_json(url)
    end
    Dry::Monads.Right(pages: pages)
  end)

  register :get_apartment_urls, (->(input) do
    urls = []
    input[:pages].each do |page|
      urls.concat ParserHelper.parse_apartments(page)
    end
    Dry::Monads.Right(urls: urls)
  end)

  register :fetch_apartments, (->(input) do
    apartments = ParserHelper.fetch_apartments(input[:urls])
    Dry::Monads.Right(apartments: apartments)
  end)
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
  def initialize(params, getter_pages = GetterPages.new)
    @url_generator = UrlGenerator.new(params)
    @getter_pages  = getter_pages
    @parser        = Dry.Transaction(container: ParserContainer) do
      step :first_page
      step :all_json_pages
      step :get_apartment_urls
      step :fetch_apartments
    end
  end

  def start
    @parser.call(url_generator: @url_generator,
                 getter_pages:  @getter_pages)
  end
end
