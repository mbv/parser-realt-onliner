class ParamFormatter
  attr_reader :params, :format, :path

  def initialize(raw_params)
    @raw_params = raw_params
    @format     = @raw_params.format
    @path       = @raw_params.path
  end

  def params
    @params ||= {}.merge(prices).merge(rent_type).merge(only_owner)
                  .merge(bounds).merge(currency).merge(metro)
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
