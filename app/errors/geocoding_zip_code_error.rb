class GeocodingZipCodeError < StandardError
  def initialize(address)
    super("A valid US zip code must be provided for address: #{address}")
  end
end
