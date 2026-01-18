# This sets up the Geocoder with a default timeout and lookup service.

# Timeout is set to 5 seconds, raising an error if the geocoding service does not respond within this time.
# Lookup service is set to :nominatim, which is a free geocoding service that does not require an API key.
# The units are set to miles (mi), which means that distances will be calculated in miles.

Geocoder.configure(
  timeout: 10,
  lookup: :nominatim,
  units: :mi,
  use_https: true,
  http_headers: {
    "User-Agent" => ENV.fetch(
      "GEOCODER_USER_AGENT",
      "WeatherForecast Rails App (local development)"
    )
  }
)
