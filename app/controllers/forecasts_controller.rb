class ForecastsController < ApplicationController
  def index
  end

  def search
    return unless params[:address].present?

    begin
      Rails.logger.debug "Fetching location data for address: #{params[:address]}"
      location = GeocodingService.location_data_from_address(params[:address])

      Rails.logger.debug "Location data fetched: #{location.inspect}"

      @forecast = WeatherService.new(
        lat: location[:lat],
        lon: location[:lon],
        zip: location[:zip]
      ).fetch_forecast

      Rails.logger.debug "Forecast data fetched: #{@forecast.inspect}"

      respond_to do |format|
        format.turbo_stream do
          Rails.logger.debug "Rendering Turbo Stream response."

          render turbo_stream: turbo_stream.replace(
            "forecast_results",
            partial: "forecasts/weather_report",
            locals: { forecast: @forecast }
          )
        end
      end
    rescue GeocodingAddressError, GeocodingZipCodeError => e
      flash[:alert] = e.message
    rescue => e
      flash[:alert] = "An error occurred while fetching the forecast: #{e.message}."
    end
  end
end
