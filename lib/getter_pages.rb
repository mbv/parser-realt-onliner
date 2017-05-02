class GetterPages
  def initialize(client = Net::HTTP)
    @client = client
  end

  def get_page(url)
    uri = URI(url)
    Net::HTTP.get(uri)
  end

  def get_json(url)
    JSON.parse(get_page(url))
  end
end