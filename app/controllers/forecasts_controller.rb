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
      :city => "Prosper",
      :state => "TX",
      :current    => {
        :temperature => 42.1,
        :description => "Mostly Cloudy"
      },
      :today      => {
        :high => 47,
        :low  => 39
      },
      :extended   => [
        {
          :name              => "Friday",
          :temperature       => 47,
          :temperature_unit  => "F",
          :short_forecast    => "Light Rain Likely",
          :detailed_forecast => "Rain likely. Cloudy, with a high near 47. East wind 5 to 10 mph. Chance of precipitation is 70%. New rainfall amounts between a quarter and half of an inch possible."
        },
        {
          :name              => "Friday Night",
          :temperature       => 37,
          :temperature_unit  => "F",
          :short_forecast    => "Rain",
          :detailed_forecast => "Rain. Cloudy, with a low around 37. Northeast wind around 10 mph, with gusts as high as 25 mph. Chance of precipitation is 90%. New rainfall amounts between three quarters and one inch possible."
        },
        {
          :name              => "Saturday",
          :temperature       => 43,
          :temperature_unit  => "F",
          :short_forecast    => "Snow",
          :detailed_forecast => "Rain. Cloudy, with a high near 43. Northeast wind 10 to 15 mph. Chance of precipitation is 90%. New rainfall amounts between a half and three quarters of an inch possible."
        },
        {
          :name              => "Saturday Night",
          :temperature       => 38,
          :temperature_unit  => "F",
          :short_forecast    => "Light Rain Likely",
          :detailed_forecast => "Rain likely. Mostly cloudy, with a low around 38. North wind around 10 mph. Chance of precipitation is 60%. New rainfall amounts less than a tenth of an inch possible."
        },
        {
          :name              => "Sunday",
          :temperature       => 57,
          :temperature_unit  => "F",
          :short_forecast    => "Sunny",
          :detailed_forecast => "A chance of rain. Partly sunny, with a high near 57. Chance of precipitation is 30%. New rainfall amounts less than a tenth of an inch possible."
        },
        {
          :name              => "Sunday Night",
          :temperature       => 40,
          :temperature_unit  => "F",
          :short_forecast    => "Slight Chance Light Rain then Partly Cloudy",
          :detailed_forecast => "A slight chance of rain before 8pm. Partly cloudy, with a low around 40."
        },
        {
          :name              => "Monday",
          :temperature       => 66,
          :temperature_unit  => "F",
          :short_forecast    => "Mostly Sunny",
          :detailed_forecast => "Mostly sunny, with a high near 66."
        },
        {
          :name              => "Monday Night",
          :temperature       => 49,
          :temperature_unit  => "F",
          :short_forecast    => "Chance Rain Showers",
          :detailed_forecast => "A chance of rain showers after 8pm. Mostly cloudy, with a low around 49. Chance of precipitation is 40%."
        },
        {
          :name              => "Tuesday",
          :temperature       => 64,
          :temperature_unit  => "F",
          :short_forecast    => "Thunderstorms Likely",
          :detailed_forecast => "A slight chance of rain showers before 8am. Partly sunny, with a high near 64."
        },
        {
          :name              => "Tuesday Night",
          :temperature       => 40,
          :temperature_unit  => "F",
          :short_forecast    => "Partly Cloudy",
          :detailed_forecast => "Partly cloudy, with a low around 40."
        }
      ],
      :from_cache => true
    }

    @address = address

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("forecast_results", partial: "forecasts/weather_report", locals: { forecast: @forecast, address: @address })
      end
    end
  end
end
