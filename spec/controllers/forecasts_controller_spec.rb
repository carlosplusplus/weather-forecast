require "rails_helper"

RSpec.describe ForecastsController, type: :controller do
  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #search" do
    let(:valid_address) { "411 Elm St, Dallas, TX 75202" }
    let(:location_data) { { lat: 32.7797, lon: -96.8084, zip: "75202" } }
    let(:forecast_data) { { city: "Dallas", state: "TX", current: {}, today: {}, extended: [] } }

    context "with a valid address" do
      before do
        allow(GeocodingService).to receive(:location_data_from_address).with(valid_address).and_return(location_data)
        allow(WeatherService).to receive(:new).with(lat: location_data[:lat], lon: location_data[:lon], zip: location_data[:zip]).and_return(double(fetch_forecast: forecast_data))
      end

      it "fetches the forecast and updates the turbo frames" do
        get :search, params: { address: valid_address }, format: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("turbo-stream")
        expect(response.body).to include("forecast_results")
      end
    end

    context "with an invalid address" do
      before do
        allow(GeocodingService).to receive(:location_data_from_address).and_raise(GeocodingAddressError, "Invalid address")
      end

      it "renders an error in the flash turbo frame" do
        get :search, params: { address: "Invalid address" }, format: :turbo_stream

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("Lat / Lon coordinates could not be returned for address: Invalid address")
      end
    end

    context "with a zip code error" do
      before do
        allow(GeocodingService).to receive(:location_data_from_address).and_raise(GeocodingZipCodeError, "Invalid zip code")
      end

      it "renders a zip code error in the flash turbo frame" do
        get :search, params: { address: "Invalid zip code" }, format: :turbo_stream

        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:alert]).to eq("A valid US zip code was not found for address: Invalid zip code")
      end
    end

    context "when an unexpected error occurs" do
      before do
        allow(GeocodingService).to receive(:location_data_from_address).and_raise(StandardError, "Something went wrong")
      end

      it "renders a generic error in the flash turbo frame" do
        get :search, params: { address: valid_address }, format: :turbo_stream

        expect(response).to have_http_status(:internal_server_error)
        expect(flash[:alert]).to eq("An error occurred while fetching the forecast")
      end
    end
  end
end
