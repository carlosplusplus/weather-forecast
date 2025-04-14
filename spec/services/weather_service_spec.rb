require "rails_helper"

RSpec.describe WeatherService do
  let(:lat) { 32.7797 }
  let(:lon) { -96.8084 }
  let(:zip) { "75202" }
  let(:service) { described_class.new(lat: lat, lon: lon, zip: zip) }

  # Shared forecast_data for multiple tests
  let(:forecast_data) do
    {
      "properties" => {
        "periods" => [
          { "name" => "Today", "temperature" => 79, "temperatureUnit" => "F", "shortForecast" => "Showers Likely", "detailedForecast" => "Showers likely. High near 79." },
          { "name" => "Tonight", "temperature" => 64, "temperatureUnit" => "F", "shortForecast" => "Clear", "detailedForecast" => "Clear. Low around 64." },
          { "name" => "Monday", "temperature" => 87, "temperatureUnit" => "F", "shortForecast" => "Sunny", "detailedForecast" => "Sunny. High near 87." },
          { "name" => "Monday Night", "temperature" => 58, "temperatureUnit" => "F", "shortForecast" => "Mostly Cloudy", "detailedForecast" => "Mostly cloudy. Low around 58." },
          { "name" => "Tuesday", "temperature" => 77, "temperatureUnit" => "F", "shortForecast" => "Mostly Sunny", "detailedForecast" => "Mostly sunny, with a high near 77." },
          { "name" => "Tuesday Night", "temperature" => 55, "temperatureUnit" => "F", "shortForecast" => "Mostly Clear", "detailedForecast" => "Mostly clear, with a low around 55." },
          { "name" => "Wednesday", "temperature" => 82, "temperatureUnit" => "F", "shortForecast" => "Sunny", "detailedForecast" => "Sunny, with a high near 82." },
          { "name" => "Wednesday Night", "temperature" => 64, "temperatureUnit" => "F", "shortForecast" => "Partly Cloudy", "detailedForecast" => "Partly cloudy, with a low around 64." },
          { "name" => "Thursday", "temperature" => 88, "temperatureUnit" => "F", "shortForecast" => "Mostly Sunny", "detailedForecast" => "Mostly sunny, with a high near 88." },
          { "name" => "Thursday Night", "temperature" => 67, "temperatureUnit" => "F", "shortForecast" => "Mostly Cloudy", "detailedForecast" => "Mostly cloudy, with a low around 67." },
          { "name" => "Friday", "temperature" => 86, "temperatureUnit" => "F", "shortForecast" => "Mostly Cloudy", "detailedForecast" => "Mostly cloudy, with a high near 86." },
          { "name" => "Friday Night", "temperature" => 66, "temperatureUnit" => "F", "shortForecast" => "Slight Chance Showers", "detailedForecast" => "A slight chance of showers. Low around 66." },
          { "name" => "Saturday", "temperature" => 81, "temperatureUnit" => "F", "shortForecast" => "Chance Showers", "detailedForecast" => "A chance of showers. High near 81." },
          { "name" => "Saturday Night", "temperature" => 65, "temperatureUnit" => "F", "shortForecast" => "Chance Showers", "detailedForecast" => "A chance of showers. Low around 65." }
        ]
      }
    }
  end

  describe "#fetch_forecast" do
    context "when the forecast is cached" do
      before do
        cached_data = {
          city: "Dallas",
          state: "TX",
          current: { temperature: "72°F", description: "Clear" },
          today: { high: "75°F", low: "65°F" },
          extended: [],
          from_cache: true
        }
        allow(Rails.cache).to receive(:read).with("forecast-#{zip}").and_return(cached_data)
      end

      it "returns the cached forecast with from_cache set to true" do
        result = service.fetch_forecast

        expect(result[:city]).to eq("Dallas")
        expect(result[:state]).to eq("TX")
        expect(result[:from_cache]).to be true
        expect(Rails.cache).not_to receive(:write)
      end
    end

    context "when the forecast is not cached" do
      let(:point_data) do
        {
          city: "Dallas",
          state: "TX",
          forecast_url: "https://api.weather.gov/gridpoints/OKX/33,37/forecast",
          observation_station: "https://api.weather.gov/stations/KTXC/observations"
        }
      end

      let(:forecast_data) do
        {
          "properties" => {
            "periods" => [
              { "name" => "Today", "temperature" => 75, "temperatureUnit" => "F", "shortForecast" => "Sunny" },
              { "name" => "Tonight", "temperature" => 65, "temperatureUnit" => "F", "shortForecast" => "Clear" }
            ]
          }
        }
      end

      let(:current_observation) do
        { temperature: "72°F", description: "Clear" }
      end

      before do
        allow(Rails.cache).to receive(:read).with("forecast-#{zip}").and_return(nil)
        allow(service).to receive(:get_points_metadata).and_return(point_data)
        allow(service).to receive(:get_extended_forecast).with(point_data[:forecast_url]).and_return(forecast_data)
        allow(service).to receive(:get_current_observation).with(point_data[:observation_station]).and_return(current_observation)
        allow(service).to receive(:extract_today_forecast).with(forecast_data).and_return({ high: "75°F", low: "65°F" })
        allow(service).to receive(:extract_five_day_forecast).with(forecast_data).and_return([
          { name: "Monday", temperature: 75, temperature_unit: "F", short_forecast: "Sunny", detailed_forecast: "Clear skies." }
        ])
        allow(Rails.cache).to receive(:write)
      end

      it "fetches the forecast from the API and caches it" do
        result = service.fetch_forecast

        expect(result[:city]).to eq("Dallas")
        expect(result[:state]).to eq("TX")
        expect(result[:current]).to eq(current_observation)
        expect(result[:today]).to eq({ high: "75°F", low: "65°F" })
        expect(result[:extended].size).to eq(1)
        expect(result[:from_cache]).to be false

        expect(Rails.cache).to have_received(:write).with("forecast-#{zip}", result, expires_in: 30.minutes)
      end
    end
  end

  describe "#get_points_metadata" do
    let(:mock_response) do
      {
        "properties" => {
          "relativeLocation" => {
            "properties" => {
              "city" => "Dallas",
              "state" => "TX"
            }
          },
          "forecast" => "https://api.weather.gov/gridpoints/FWD/89,104/forecast",
          "observationStations" => "https://api.weather.gov/gridpoints/FWD/89,104/stations"
        }
      }
    end

    before do
      allow(service.class).to receive(:get).with("/points/#{lat},#{lon}").and_return(mock_response)
    end

    it "returns the correct metadata for the given coordinates" do
      result = service.send(:get_points_metadata)

      expect(result).to eq({
        city: "Dallas",
        state: "TX",
        forecast_url: "https://api.weather.gov/gridpoints/FWD/89,104/forecast",
        observation_station: "https://api.weather.gov/gridpoints/FWD/89,104/stations",
        zip_code: zip
      })
    end
  end

  describe "#get_current_observation" do
    let(:stations_url) { "https://api.weather.gov/gridpoints/FWD/89,104/stations" }

    let(:station_list_response) do
      {
        "features" => [
          { "id" => "https://api.weather.gov/stations/KDAL" }
        ]
      }
    end

    let(:observation_response) do
      {
        "properties" => {
          "temperature" => { "value" => 5.0 },
          "textDescription" => "Clear"
        }
      }
    end

    before do
      allow(service.class).to receive(:get).with(stations_url).and_return(station_list_response)
      allow(service.class).to receive(:get).with("/stations/KDAL/observations/latest").and_return(observation_response)
    end

    it "returns the current observation for the first station" do
      result = service.send(:get_current_observation, stations_url)

      expect(result).to eq({
        temperature: "41.0°F", # 5°C converted to Fahrenheit
        description: "Clear"
      })
    end

    context "when the temperature value is nil" do
      let(:observation_response) do
        {
          "properties" => {
            "temperature" => { "value" => nil },
            "textDescription" => "Clear"
          }
        }
      end

      it "returns '-' for the temperature" do
        result = service.send(:get_current_observation, stations_url)

        expect(result).to eq({
          temperature: "-",
          description: "Clear"
        })
      end
    end
  end

  describe "#extract_today_forecast" do
    context "when there is only one period for today" do
      let(:forecast_data) do
        {
          "properties" => {
            "periods" => [
              { "name" => "Tonight", "temperature" => 64, "temperatureUnit" => "F" }
            ]
          }
        }
      end

      it "returns high as '-' and low as the single period's temperature" do
        result = service.send(:extract_today_forecast, forecast_data)

        expect(result).to eq({ high: "-", low: 64 })
      end
    end

    context "when there are two periods for today" do
      it "returns high as the first period's temperature and low as the second period's temperature" do
        result = service.send(:extract_today_forecast, forecast_data)

        expect(result).to eq({ high: 79, low: 64 })
      end
    end
  end

  describe "#extract_five_day_forecast" do
    context "when there are more than 10 periods" do
      it "returns only the first 10 valid periods" do
        result = service.send(:extract_five_day_forecast, forecast_data)

        expect(result.size).to eq(10)
        expect(result.map { |p| p[:name] }).to eq([
          "Monday", "Monday Night", "Tuesday", "Tuesday Night", "Wednesday",
          "Wednesday Night", "Thursday", "Thursday Night", "Friday", "Friday Night"
        ])
      end

      it "ensures the first period's attributes are fully correct" do
        result = service.send(:extract_five_day_forecast, forecast_data)
        first_period = result.first

        expect(first_period).to eq({
          name: "Monday",
          temperature: 87,
          temperature_unit: "F",
          short_forecast: "Sunny",
          detailed_forecast: "Sunny. High near 87."
        })
      end
    end

    context "when there are irrelevant periods" do
      let(:forecast_data) do
        {
          "properties" => {
            "periods" => [
              { "name" => "Today", "temperature" => 87, "temperatureUnit" => "F" },
              { "name" => "Tonight", "temperature" => 64, "temperatureUnit" => "F" },
              { "name" => "Monday", "temperature" => 77, "temperatureUnit" => "F", "shortForecast" => "Sunny", "detailedForecast" => "Sunny." },
              { "name" => "Monday Night", "temperature" => 55, "temperatureUnit" => "F", "shortForecast" => "Clear", "detailedForecast" => "Clear." }
            ]
          }
        }
      end

      it "filters out irrelevant periods and returns only valid ones" do
        result = service.send(:extract_five_day_forecast, forecast_data)

        expect(result.size).to eq(2)
        expect(result.map { |p| p[:name] }).to eq([ "Monday", "Monday Night" ])
      end
    end
  end
end
