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
    forecast_data = get_extended_forecast(point_data[:forecast_url])

    # Using the gathered metadata, fetch:
    # 1. Current weather
    # 2. Today's forecast
    # 3. Extended (5-day) forecast
    new_data =  {
        city: point_data[:city],
        state: point_data[:state],
        current: get_current_observation(point_data[:observation_station]),
        today: extract_today_forecast(forecast_data),
        extended: extract_five_day_forecast(forecast_data),
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
    temperature = to_fahrenheit(obs_data.dig("properties", "temperature", "value"))

    {
      temperature: temperature ? "#{temperature}°F" : "-",
      description: obs_data.dig("properties", "textDescription")
    }
  end

  def get_extended_forecast(forecast_url)
    self.class.get(forecast_url)
  end

  def extract_today_forecast(forecast_data)
    today = forecast_data["properties"]["periods"].first(2)

    # Check if the first period is "Tonight", meaning that there is only one period for today.
    # In this case, set the high temperature to "-" and the low temperature to the first period's temperature.
    # Otherwise, set the high temperature to the first period's temperature and the low temperature to the second period's temperature.
    if (today[0]["name"].downcase.match?(/tonight/))
      {
        high: "-",
        low: today[0]["temperature"]
      }
    else
      {
        high: today[0]["temperature"],
        low: today[1]["temperature"]
      }
    end
  end

  def extract_five_day_forecast(forecast_data)
    forecast_data["properties"]["periods"].map do |period|
      # Filter out periods related to the current day.
      next if period["name"].downcase.match?(/morning|afternoon|today|tonight/)

      {
        name: period["name"],
        temperature: period["temperature"],
        temperature_unit: period["temperatureUnit"],
        short_forecast: period["shortForecast"],
        detailed_forecast: period["detailedForecast"]
      }
    end.compact.take(10)
  end

  def to_fahrenheit(celsius)
    return nil if celsius.nil?

    (celsius * 9.0 / 5.0 + 32).round(1)
  end
end
