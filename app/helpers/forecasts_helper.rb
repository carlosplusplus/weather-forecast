module ForecastsHelper
  # This method generates an HTML image tag for a weather icon based on the short forecast description.
  # It uses a case statement to match various weather conditions and returns the corresponding icon file name.
  def weather_icon(short_forecast, size = 14)
    icon_file = case short_forecast.downcase
    when /rain/i # Matches "Rain", "Light Rain", "Heavy Rain", etc.
                  "rain.png"
    when /snow/i # Matches "Snow", "Light Snow", "Heavy Snow", etc.
                  "snow.png"
    when "partly sunny"
                  "partly_sunny.png"
    when "partly cloudy"
                  "partly_cloudy.png"
    when /thunderstorm/ # Matches "Thunderstorm", "Severe Thunderstorm", etc.
                  "thunderstorm.png"
    when /cloudy|fog/
                  "cloudy.png"
    else
                  "sunny.png" # Matches everything else! ☀️
    end

    image_tag("weather_icons/#{icon_file}", alt: short_forecast, class: "w-#{size} h-#{size} mx-auto")
  end

  def abbreviate_day(day)
    day[0..2].upcase
  end
end
