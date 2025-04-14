class GeocodingZipCodeError < StandardError
  def initialize(address)
    @address = address
    super()
  end

  def message
    "A valid US zip code was not found for address: #{@address}"
  end
end
