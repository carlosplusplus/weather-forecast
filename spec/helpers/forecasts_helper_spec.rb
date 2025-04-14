require "rails_helper"

RSpec.describe ForecastsHelper, type: :helper do
  describe "#weather_icon" do
    it "returns the correct icon for rain-related forecasts" do
      expect(helper.weather_icon("Rain")).to have_css("img[src*='weather_icons/rain']")
      expect(helper.weather_icon("Light Rain")).to have_css("img[src*='weather_icons/rain']")
      expect(helper.weather_icon("Heavy Rain")).to have_css("img[src*='weather_icons/rain']")
    end

    it "returns the correct icon for snow-related forecasts" do
      expect(helper.weather_icon("Snow")).to have_css("img[src*='weather_icons/snow']")
      expect(helper.weather_icon("Light Snow")).to have_css("img[src*='weather_icons/snow']")
      expect(helper.weather_icon("Heavy Snow")).to have_css("img[src*='weather_icons/snow']")
    end

    it "returns the correct icon for partly sunny forecasts" do
      expect(helper.weather_icon("Partly Sunny")).to have_css("img[src*='weather_icons/partly_sunny']")
    end

    it "returns the correct icon for partly cloudy forecasts" do
      expect(helper.weather_icon("Partly Cloudy")).to have_css("img[src*='weather_icons/partly_cloudy']")
    end

    it "returns the correct icon for thunderstorm-related forecasts" do
      expect(helper.weather_icon("Thunderstorm")).to have_css("img[src*='weather_icons/thunderstorm']")
      expect(helper.weather_icon("Severe Thunderstorm")).to have_css("img[src*='weather_icons/thunderstorm']")
    end

    it "returns the correct icon for cloudy or foggy forecasts" do
      expect(helper.weather_icon("Cloudy")).to have_css("img[src*='weather_icons/cloudy']")
      expect(helper.weather_icon("Fog")).to have_css("img[src*='weather_icons/cloudy']")
    end

    it "returns the sunny icon for unknown forecasts" do
      expect(helper.weather_icon("Sunny")).to have_css("img[src*='weather_icons/sunny']")
      expect(helper.weather_icon("Clear")).to have_css("img[src*='weather_icons/sunny']")
      expect(helper.weather_icon("Unknown")).to have_css("img[src*='weather_icons/sunny']")
    end

    it "includes the correct size in the image tag" do
      expect(helper.weather_icon("Sunny")).to have_css("img.w-14.h-14")
      expect(helper.weather_icon("Sunny", 20)).to have_css("img.w-20.h-20")
      expect(helper.weather_icon("Rain", 30)).to have_css("img.w-30.h-30")
    end
  end

  describe "#abbreviate_day" do
    it "abbreviates a full day name to the first three uppercase letters" do
      expect(helper.abbreviate_day("Monday")).to eq("MON")
      expect(helper.abbreviate_day("Tuesday")).to eq("TUE")
      expect(helper.abbreviate_day("Wednesday")).to eq("WED")
    end

    it "handles nil input gracefully" do
      expect(helper.abbreviate_day(nil)).to be_nil
    end

    it "handles empty strings gracefully" do
      expect(helper.abbreviate_day("")).to be_nil
    end
  end
end
