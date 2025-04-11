class WeatherService
  include HTTParty

  # National Weather Service API base URL
  base_uri "https://api.weather.gov"
  headers "User-Agent" => "WeatherForecast Rails 8 Application"
  format :json

  attr_reader :lat, :lon

  def initialize(lat:, lon:)
    @lat = lat
    @lon = lon
  end

  def fetch_forecast
    point_data = get_points_metadata

    {
      current: get_current_observation(point_data[:observation_station]),
      today: extract_today_forecast(point_data[:forecast_url]),
      extended: get_extended_forecast(point_data[:forecast_url])
    }
  end

  private

  def get_points_metadata
    res = self.class.get("/points/#{lat},#{lon}")

    {
      forecast_url: res.dig("properties", "forecast"),
      observation_station: res.dig("properties", "observationStations")
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
        {
          name: period["name"],
          temperature: period["temperature"],
          temperature_unit: period["temperatureUnit"],
          short_forecast: period["shortForecast"],
          detailed_forecast: period["detailedForecast"]
        }
      end
    end
  end

  def extract_today_forecast(forecast_url)
    today = get_extended_forecast(forecast_url).first(2) # Today and tonight

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
