class WeatherService
  include HTTParty

  # National Weather Service API base URL
  base_uri "https://api.weather.gov"
  headers "User-Agent" => "WeatherForecast Rails 8 Application"
  format :json

  attr_reader :lat, :lon, :zip

  def initialize(lat:, lon:, zip:)
    @lat = lat
    @lon = lon
    @zip = zip
  end

  def fetch_forecast
    # Check if the forecast data is already cached.
    # If cached, return the cached data with a flag indicating it's from the cache.
    cached = Rails.cache.read("forecast-#{zip}")
    return cached.merge(from_cache: true) if cached

    # If not cached, fetch the data from the API and store it in the cache.
    # with an expiration time of 30 minutes.
    point_data = get_points_metadata

    new_data =  {
        city: point_data[:city],
        state: point_data[:state],
        current: get_current_observation(point_data[:observation_station]),
        today: extract_today_forecast(point_data[:forecast_url]),
        extended: get_extended_forecast(point_data[:forecast_url]),
        from_cache: false
    }

    Rails.cache.write("forecast-#{zip}", new_data, expires_in: 30.minutes)
    new_data
  end

  private

  def get_points_metadata
    res = self.class.get("/points/#{lat},#{lon}")

    {
      city: res.dig("properties", "relativeLocation", "properties", "city"),
      state: res.dig("properties", "relativeLocation", "properties", "state"),
      forecast_url: res.dig("properties", "forecast"),
      observation_station: res.dig("properties", "observationStations"),
      zip_code: zip
    }
  end

  def get_current_observation(stations_url)
    station_list = self.class.get(stations_url)
    first_station_id = station_list["features"][0]["id"].split("/").last

    obs_data = self.class.get("/stations/#{first_station_id}/observations/latest")

    {
      temperature: to_fahrenheit(obs_data.dig("properties", "temperature", "value")),
      description: obs_data.dig("properties", "textDescription")
    }
  end

  def get_extended_forecast(forecast_url)
    @extended_forecast ||= begin
      forecast = self.class.get(forecast_url)

      forecast["properties"]["periods"].map do |period|
        # Filter out periods related to the current day.
        next if period["name"].downcase.match?(/morning|afternoon|today|tonight/)

        {
          name: period["name"],
          temperature: period["temperature"],
          temperature_unit: period["temperatureUnit"],
          short_forecast: period["shortForecast"],
          detailed_forecast: period["detailedForecast"]
        }
      end.compact.take(10) # Limit to 10 period (5 days, day/night pairs)
    end
  end

  def extract_today_forecast(forecast_url)
    today = get_extended_forecast(forecast_url).first(2) # Today and tonight

    # TODO: fix high/low temperature output

    {
      high: today.find { |p| p[:name].downcase.include?("day") }&.dig(:temperature),
      low: today.find { |p| p[:name].downcase.include?("night") }&.dig(:temperature)
    }
  end

  def to_fahrenheit(celsius)
    return nil if celsius.nil?

    (celsius * 9.0 / 5.0 + 32).round(1)
  end
end
