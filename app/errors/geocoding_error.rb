class GeocodingError < StandardError
  def initialize(address)
    super("Geocoding failed for address: #{address}")
  end
end
