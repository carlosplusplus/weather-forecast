class ForecastsController < ApplicationController
  def index
  end

  def search
    return unless params[:address].present?

    begin
      location = GeocodingService.location_data_from_address(params[:address])

      @forecast = WeatherService.new(
        lat: location[:lat],
        lon: location[:lon],
        zip: location[:zip]
      ).fetch_forecast

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "forecast_results",
            partial: "forecasts/weather_report",
            locals: { forecast: @forecast }
          )
        end
      end
    rescue GeocodingAddressError, GeocodingZipCodeError => e
      Rails.logger.error "Geocoding error: #{e.message}"
      flash[:alert] = e.message
      head :unprocessable_entity
    rescue => e
      Rails.logger.error "Unexpected error: #{e.message}"
      flash[:alert] = "An error occurred while fetching the forecast: #{e.message}."
      head :internal_server_error
    end
  end
end
