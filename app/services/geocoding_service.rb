class GeocodingService
  # This method takes an address as input and returns a hash with latitude and longitude.
  # If the geocoding fails, it raises a GeocodingError with the address.
  def self.coords_from_address(address)
    result = Geocoder.search(address).first

    if result&.coordinates.present?
      { lat: result.coordinates[0], lon: result.coordinates[1] }
    else
      raise GeocodingError.new(address)
    end
  end
end
