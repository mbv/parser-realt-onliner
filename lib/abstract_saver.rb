require 'json'
require 'csv'

class AbstractSaver

  def initialize(path)
    @path = path
  end

  def save(_)
    throw NotImplementedError
  end
end

class JsonSaver < AbstractSaver
  def save(apartments)
    File.open(@path, 'w') do |f|
      f.write(apartments.to_json)
    end
  end
end

class CsvSaver < AbstractSaver
  COLUMNS_OPTIONS = ['Furniture',
                     'Kitchen furniture',
                     'Plate',
                     'Fridge',
                     'Washer',
                     'TV',
                     'Internet',
                     'Loggia or balcony',
                     'Air conditioning'].freeze


  COLUMNS = (['Address',
              'Price Primary',
              'Price Secondary',
              'Apartment Type',
              'Advert Type',
              'Description',
              'Phones'] + COLUMNS_OPTIONS).freeze


  MAPPING = { 'Furniture'         => 'Мебель',
              'Kitchen furniture' => 'Кухонная мебель',
              'Plate'             => 'Плита',
              'Fridge'            => 'Холодильник',
              'Washer'            => 'Стиральная машина',
              'TV'                => 'Телевизор',
              'Internet'          => 'Интернет',
              'Loggia or balcony' => 'Лоджия или балкон',
              'Air conditioning'  => 'Кондиционер' }.freeze


  def contains_in_apartment?(apartment, option_name)
    option = apartment[:options].detect { |o| o[:name] == MAPPING[option_name] }
    option[:contains]
  end

  def format_apartment(apartment)
    row = []
    row << apartment[:address]
    row << apartment[:price_primary]
    row << apartment[:price_secondary]
    row << apartment[:apartment_type]
    row << apartment[:advert_type]
    row << apartment[:description]
    row << apartment[:phones]
    COLUMNS_OPTIONS.each do |option_name|
      row << (contains_in_apartment?(apartment, option_name) ? '+' : '-')
    end
    row
  end

  def save(apartments)
    CSV.open(@path, 'w') do |csv|
      csv << COLUMNS
      apartments.each do |apartment|
        csv << format_apartment(apartment)
      end
    end
  end
end