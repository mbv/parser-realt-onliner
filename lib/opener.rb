require 'active_support'
require 'active_support/core_ext/hash'

class Opener
  BASE_URL = ''

  def set_prices raw_params
      { price: { min: raw_params['min_price'],
               max: raw_params['max_price']
      }}
  end

  def open
    params = {}
    params.merge! set_prices(
        min_price: 10,
        max_price: 20,
    )

    params = {

        currency: 'usd',
        only_owner: 'true',
        metro: [
            'blue_line'
        ],
        rent_type: [
            'room',
            '2_rooms'
        ],
        bounds: {
            lb: {
                lat: 53.72752332178119,
                long: 27.413028708853112,
            },
            rt: {
                lat: 54.076181123270445,
                long: 27.711908525658554,
            }
        },
        page: 1
    }

    url = params.to_query
    puts url
  end

  def start
    
  end

end


Opener.new.open
