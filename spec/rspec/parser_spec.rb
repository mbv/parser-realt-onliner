require 'spec_helper'
require 'parser'

RSpec.describe Parser do
  describe '#parse_html' do
    let(:input_file) { File.expand_path('../fixtures/input', File.dirname(__FILE__)) }
    let(:expected_hash) do
      { price_primary:   '785,15 р.',
        price_secondary: '420 $',
        apartment_type:  '3-комнатная квартира',
        advert_type:     'Агент',
        description:     'Сдается трехкомнатная квартира студия возле метро. Квартира с хорошим ремонтом, есть вся мебель и бытовая техника, дом 2007 года постройки, 5 минут пешком до ст.м. Каменная Горка.',
        address:         'Минск, улица Лобанка, 14',
        phones:          '+375 44 534-75-44',
        options:         [{ name: 'Мебель', contains: true },
                          { name: 'Кухонная мебель', contains: true },
                          { name: 'Плита', contains: true },
                          { name: 'Холодильник', contains: true },
                          { name: 'Стиральная машина', contains: true },
                          { name: 'Телевизор', contains: true },
                          { name: 'Интернет', contains: true },
                          { name: 'Лоджия или балкон', contains: true },
                          { name: 'Кондиционер', contains: false }] }
    end
    subject(:parsed_hash) { described_class.new.parse(input_file) }

    it 'should parse html' do
      expect(parsed_hash).to include(expected_hash)
    end
  end
end