class ForecastsController < ApplicationController
  def index
  end

  # def search
  #   return unless params[:address].present?

  #   begin
  #     location = GeocodingService.location_data_from_address(params[:address])
  #     forecast = WeatherService.new(
  #       lat: location[:lat],
  #       lon: location[:lon],
  #       zip: location[:zip]
  #     ).fetch_forecast

  #     @address = params[:address]
  #     @forecast = forecast

  #     respond_to do |format|
  #       format.turbo_stream do
  #         render turbo_stream: turbo_stream.replace("forecast_results", partial: "forecasts/weather_report", locals: { forecast: @forecast })
  #       end
  #     end
  #   rescue GeocodingAddressError, GeocodingZipCodeError => e
  #     flash[:alert] = e.message
  #   rescue => e
  #     flash[:alert] = "An error occurred while fetching the forecast: #{e.message}."
  #   end
  # end

  def search
    Rails.logger.debug "Request format: #{request.format}"
    address = params[:address]

    # Replace this with actual logic to fetch weather data
    @forecast = {
      current: { temperature: 72, description: "Sunny" },
      today: { high: 75, low: 65 },
      extended: [
        { name: "Monday", temperature: 70, temperature_unit: "F", short_forecast: "Partly Cloudy" },
        { name: "Tuesday", temperature: 68, temperature_unit: "F", short_forecast: "Rainy" }
      ],
      from_cache: false
    }
    @address = address

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("forecast_results", partial: "forecasts/weather_report", locals: { forecast: @forecast, address: @address })
      end
    end
  end
end
