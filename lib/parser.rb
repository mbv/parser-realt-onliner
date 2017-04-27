require 'nokogiri'
require 'open-uri'

class Parser

  def parse(url)
    page = Nokogiri::HTML(open(url))

    middle_block = page.css('div.g-middle')

    apartment_bar = middle_block.css('div.apartment-bar')
    apartment_info = middle_block.css('div.apartment-info')
    price = apartment_bar.css('span[class="apartment-bar__price-value apartment-bar__price-value_primary"]').text.strip

    address = apartment_info.css('div[class="apartment-info__sub-line apartment-info__sub-line_large"]').text.strip




    puts price
    puts address
    puts parse_apartment_options apartment_info
  end

  def parse_apartment_options(apartment_info)
    result_options = []
    options = apartment_info.css('div.apartment-options div.apartment-options__item')

    options.each do |option|
      result_options << {
          name: option.text.strip,
          contains: !(option['class'].include? 'apartment-options__item_lack'),
      }
    end
    result_options
  end

end


Parser.new.parse('https://r.onliner.by/ak/apartments/222486')
