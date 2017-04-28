require 'nokogiri'
require 'open-uri'

class Parser
  CSS_MIDDLE_BLOCK          = 'div.g-middle'.freeze
  CSS_APARTMENT_BAR         = 'div.apartment-bar'.freeze
  CSS_APARTMENT_INFO        = 'div.apartment-info'.freeze
  CSS_BAR_LEFT_PART         = 'div[class="apartment-bar__part apartment-bar__part_66"]'.freeze
  CSS_BAR_RIGHT_PART        = 'div[class="apartment-bar__part apartment-bar__part_33 apartment-bar__part_right"]'.freeze
  CSS_PRICE_PRIMARY         = 'span[class="apartment-bar__price-value apartment-bar__price-value_primary"]'.freeze
  CSS_PRICE_SECONDARY       = 'span[class="apartment-bar__price apartment-bar__price_secondary"]'.freeze
  CSS_ADDRESS               = 'div[class="apartment-info__sub-line apartment-info__sub-line_large"]'.freeze
  CSS_DESCRIPTION           = 'div[class="apartment-info__sub-line apartment-info__sub-line_extended-bottom"]'.freeze
  CSS_APARTMENT_BAR_VALUE   = 'span.apartment-bar__value'.freeze
  CSS_OPTIONS               = 'div.apartment-options div.apartment-options__item'.freeze
  CSS_CLASS_OPTION_DISABLED = 'apartment-options__item_lack'.freeze
  CSS_CUSTOMER_INFO         = 'div[class="apartment-info__cell apartment-info__cell_33 apartment-info__cell_right"]'
  CSS_CUSTOMER_PHONE        = 'ul[class="apartment-info__list apartment-info__list_phones"] li.apartment-info__item a'

  HTML_TAG_ATTRIBUTE_CLASS = 'class'.freeze


  def parse(url)
    page = Nokogiri::HTML(open(url))

    middle_block = page.css(CSS_MIDDLE_BLOCK)

    apartment_bar  = middle_block.css(CSS_APARTMENT_BAR)
    apartment_info = middle_block.css(CSS_APARTMENT_INFO)
    bar_left_part  = apartment_bar.css(CSS_BAR_LEFT_PART)
    bar_right_part = apartment_bar.css(CSS_BAR_RIGHT_PART)

    customer_info = apartment_info.css(CSS_CUSTOMER_INFO)


    price_primary   = bar_left_part.css(CSS_PRICE_PRIMARY).text.strip
    price_secondary = bar_left_part.css(CSS_PRICE_SECONDARY).text.strip
    apartment_type  = bar_left_part.css(CSS_APARTMENT_BAR_VALUE).text.strip

    advert_type = bar_right_part.css(CSS_APARTMENT_BAR_VALUE).text.strip

    address     = apartment_info.css(CSS_ADDRESS).text.strip
    description = apartment_info.css(CSS_DESCRIPTION).text.strip
    options     = parse_apartment_options apartment_info

    phones = customer_info.css(CSS_CUSTOMER_PHONE).map { |phone| phone.text.strip}
                          .join(', ')

    { price_primary:   price_primary,
      price_secondary: price_secondary,
      apartment_type:  apartment_type,
      advert_type:     advert_type,
      description:     description,
      address:         address,
      phones:          phones,
      options:         options }
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
