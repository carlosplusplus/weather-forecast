class ForecastsController < ApplicationController
  def index
    return unless params[:address].present?

    begin
      location = GeocodingService.location_data_from_address(params[:address])
      forecast = WeatherService.new(
        lat: location[:lat],
        lon: location[:lon],
        zip: location[:zip]
      ).fetch_forecast

      @address = params[:address]
      @forecast = forecast
    rescue GeocodingAddressError, GeocodingZipCodeError => e
      flash[:alert] = e.message
    rescue => e
      flash[:alert] = "An error occurred while fetching the forecast: #{e.message}."
    end
  end
end
