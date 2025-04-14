class GeocodingAddressError < StandardError
  def initialize(address)
    super("Lat / Lon coordinates could not be returned for address: #{address}")
  end
end
