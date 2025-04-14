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

      flash.discard(:alert) # Clear the flash message after a successful request

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(
              "forecast_results",
              partial: "forecasts/weather_report",
              locals: { forecast: @forecast }
            ),
            turbo_stream.update("flash", "") # Clear the flash Turbo frame
          ]
        end
      end
    rescue GeocodingAddressError, GeocodingZipCodeError => e
      handle_error(e, "flash", :unprocessable_entity)
    rescue StandardError => e
      handle_error(e, "flash", :internal_server_error, "An error occurred while fetching the forecast")
    end
  end

  private

  def handle_error(exception, turbo_frame_id, status, default_message = nil)
    Rails.logger.error "#{exception.class}: #{exception.message}"
    flash[:alert] = default_message || exception.message

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          turbo_frame_id,
          partial: "shared/flash"
        )
      end
    end
  end
end
