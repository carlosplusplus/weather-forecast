class GeocodingService
  # This method is used to get the ZIP code from an address.
  # It raises an error if the ZIP code cannot be found.
  def self.zip_from_address(address)
    result = Geocoder.search(address).first
    result&.postal_code || (raise GeocodingError, "ZIP code not found for address: #{address}")
  end
end
