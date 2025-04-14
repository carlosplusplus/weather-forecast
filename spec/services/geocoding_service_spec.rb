require "rails_helper"

RSpec.describe GeocodingService do
  describe ".location_data_from_address" do
    let(:address) { "20 W 34th St, New York, NY 10001" }

    context "when the address is valid and returns coordinates and postal code" do
      before do
        # Mock the Geocoder.search response
        mock_result = double(
          Geocoder::Result::Base,
          coordinates: [40.7128, -74.0060],
          postal_code: "10001"
        )
        allow(Geocoder).to receive(:search).with(address, params: { countrycodes: "us" }).and_return([mock_result])
      end

      it "returns the latitude, longitude, and zip code" do
        result = described_class.location_data_from_address(address)

        expect(result).to eq({
          lat: 40.7128,
          lon: -74.0060,
          zip: "10001"
        })
      end
    end

    context "when the address does not return coordinates" do
      before do
        # Mock the Geocoder.search response with no coordinates
        mock_result = double(
          Geocoder::Result::Base,
          coordinates: nil,
          postal_code: "10001"
        )
        allow(Geocoder).to receive(:search).with(address, params: { countrycodes: "us" }).and_return([mock_result])
      end

      it "raises a GeocodingAddressError" do
        expect {
          described_class.location_data_from_address(address)
        }.to raise_error(GeocodingAddressError, /#{address}/)
      end
    end

    context "when the address does not return a postal code" do
      before do
        # Mock the Geocoder.search response with no postal code
        mock_result = double(
          Geocoder::Result::Base,
          coordinates: [40.7128, -74.0060],
          postal_code: nil
        )
        allow(Geocoder).to receive(:search).with(address, params: { countrycodes: "us" }).and_return([mock_result])
      end

      it "raises a GeocodingZipCodeError" do
        expect {
          described_class.location_data_from_address(address)
        }.to raise_error(GeocodingZipCodeError, /#{address}/)
      end
    end

    context "when the Geocoder returns no results" do
      before do
        # Mock the Geocoder.search response with an empty array
        allow(Geocoder).to receive(:search).with(address, params: { countrycodes: "us" }).and_return([])
      end

      it "raises a GeocodingAddressError" do
        expect {
          described_class.location_data_from_address(address)
        }.to raise_error(GeocodingAddressError, /#{address}/)
      end
    end
  end
end
