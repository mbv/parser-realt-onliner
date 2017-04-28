require 'json'
require 'csv'

class AbstractSaver
  def save(_)
    throw NotImplementedError
  end
end

class JsonSaver < AbstractSaver
  def save(apartments)
    File.open('temp.json', 'w') do |f|
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


  COLUMNS = (['Address', 'Price'] + COLUMNS_OPTIONS).freeze


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
    row << apartment[:price]
    COLUMNS_OPTIONS.each do |option_name|
      row << (contains_in_apartment?(apartment, option_name) ? '+' : '-')
    end
    row
  end

  def save(apartments)
    CSV.open('myfile.csv', "w") do |csv|
      csv << COLUMNS
      apartments.each do |apartment|
        csv << format_apartment(apartment)
      end
    end
  end
end