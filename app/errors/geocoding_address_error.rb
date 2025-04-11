class GeocodingAddressError < StandardError
  def initialize(address)
    super("Latitude / Longitude coordinates could not be returned for address: #{address}")
  end
end
