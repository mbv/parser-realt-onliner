require 'nokogiri'
require 'open-uri'

class Parser
  CSS_MIDDLE_BLOCK           = 'div.g-middle'.freeze
  CSS_APARTMENT_BAR          = 'div.apartment-bar'.freeze
  CSS_APARTMENT_INFO         = 'div.apartment-info'.freeze
  CSS_PRICE                  = 'span[class="apartment-bar__price-value apartment-bar__price-value_primary"]'.freeze
  CSS_ADDRESS                = 'div[class="apartment-info__sub-line apartment-info__sub-line_large"]'.freeze
  CSS_OPTIONS                = 'div.apartment-options div.apartment-options__item'.freeze
  CSS_CLASS_OPTION_DISABLED = 'apartment-options__item_lack'.freeze

  HTML_TAG_ATTRIBUTE_CLASS = 'class'.freeze


  def parse(url)
    page = Nokogiri::HTML(open(url))

    middle_block = page.css(CSS_MIDDLE_BLOCK)

    apartment_bar  = middle_block.css(CSS_APARTMENT_BAR)
    apartment_info = middle_block.css(CSS_APARTMENT_INFO)
    price          = apartment_bar.css(CSS_PRICE).text.strip

    address = apartment_info.css(CSS_ADDRESS).text.strip
    options = parse_apartment_options apartment_info

    { price:   price,
      address: address,
      options: options }
  end

  def apartment_option_disabled?(option)
    !(option[HTML_TAG_ATTRIBUTE_CLASS].include? CSS_CLASS_OPTION_DISABLED)
  end

  def parse_apartment_options(apartment_info)
    result_options = []
    options        = apartment_info.css(CSS_OPTIONS)

    options.each do |option|
      result_options << { name:     option.text.strip,
                          contains: apartment_option_disabled?(option) }
    end
    result_options
  end

end
