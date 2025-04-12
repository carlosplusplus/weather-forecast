class GeocodingService
  # This method takes an address as input and returns lat, long, and zip code.
  #   If a zip code is not found, raise a GeocodingZipCodeError.
  #   If latitude and longitude coordinates are not found, raise a GeocodingAddressError.
  def self.location_data_from_address(address)
    result = Geocoder.search(address, params: { countrycodes: "us" }).first

    raise GeocodingAddressError.new(address) unless result&.coordinates.present?
    raise GeocodingZipCodeError.new(address) unless result&.postal_code.present?

    {
      lat: result.coordinates[0],
      lon: result.coordinates[1],
      zip: result.postal_code
    }
  end
end
