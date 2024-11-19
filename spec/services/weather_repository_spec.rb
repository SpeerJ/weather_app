require "rails_helper"

RSpec.describe WeatherRepository do
  let(:name) { "Hollywood" }
  describe "#search" do
    subject(:search) { described_class.search(name) }
    context "When the locations are found" do
      it "Returns locations" do
        VCR.use_cassette("locations_search") do
          result = search

          expect(result).to be_a(Array)
          expect(result.first).to be_a(FoundLocation)
          expect(result.first.name).to eq(name)
        end
      end
    end
  end

  describe "#get_weather" do
    let(:latitude) { 46.2 }
    let(:longitude) { -74.1 }
    subject(:get_weather) { described_class.get_weather(latitude, longitude) }
    context "When the forecast is retrieved" do
      it "Returns a forecast summary" do
        result = get_weather
        expect(result).to be_a(ForecastSummary)
        expect(result.daily_forecast).to be_a(Forecast)
        expect(result.hourly_forecast.temperature).to be_between(-100, 200)
      end
    end
  end
end
