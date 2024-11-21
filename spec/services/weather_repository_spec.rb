require "rails_helper"

RSpec.describe WeatherRepository do
  let(:name) { "Hollywood" }
  describe "#search" do
    subject(:search) { described_class.search(name) }
    context "When a real location name is given" do
      it "Returns locations" do
        VCR.use_cassette("locations_search") do
          result = search

          expect(result).to be_a(Array)
          expect(result.first).to be_a(FoundLocation)
          expect(result.first.name).to eq(name)
        end
      end
    end
    context "When a nonsense location name is given" do
      let(:name) { "asdfasdfasdf" }

      it "Returns no locations" do
        VCR.use_cassette("locations_nonsense_search") do
          result = search

          expect(result).to be_a(Array)
          expect(result.empty?).to be(true)
        end
      end
    end
  end

  describe "#get_weather" do
    let(:latitude) { 46.2 }
    let(:longitude) { -74.1 }
    subject(:get_weather) { described_class.get_weather(latitude, longitude) }
    context "When appropriate latitude and longitude are provided" do
      it "Returns a forecast summary" do
        VCR.use_cassette("get_weather_forecast_bad_lat_long") do
          result = get_weather
          expect(result).to be_a(ForecastSummary)
          expect(result.daily_forecast).to be_a(Array)
          expect(result.daily_forecast.first.weather_code).to be_a(WeatherCode)
          expect(result.hourly_forecast.first.temperature).to be_between(-100, 200)
        end
      end
    end

    context "When faulty latitude and longitude are provided" do
      let(:latitude) { 91 }
      let(:longitude) { -91 }

      it "Returns a forecast summary" do
        expect { get_weather }.to raise_error(WeatherRepository::BadInputError)
      end
    end
  end

  describe "#deserialize on Forecast" do
    TestForecast = Struct.new(:weather_code, :temperature_2m, :time, keyword_init: true)
    subject(:deserialize) { WeatherRepository.deserialize(Forecast, TestForecast.new(weather_code:, temperature_2m:, time:)) }

    context "When the data is valid" do
      let(:weather_code) { 1 }
      let(:temperature_2m) { 10 }
      let(:time) { '2024-11-21T00:00' }

      it "Deserializes a forecast" do
        result = deserialize
        expect(result).to be_a(Forecast)
        expect(result.weather_code.code).to eq(weather_code)
        expect(result.time).to eq(time)
        expect(result.temperature).to eq(temperature_2m)
      end
    end
  end

  describe "#deserialize on DailyForecast" do
    TestDailyForecast = Struct.new(:weather_code, :temperature_2m_min, :temperature_2m_max, :time, keyword_init: true)
    subject(:deserialize) { WeatherRepository.deserialize(DailyForecast, TestDailyForecast.new(weather_code:, temperature_2m_min:, temperature_2m_max:, time:)) }

    context "When the data is valid" do
      let(:weather_code) { 1 }
      let(:temperature_2m_max) { 10 }
      let(:temperature_2m_min) { 1 }
      let(:time) { '2024-11-21T00:00' }

      it "Deserializes a daily forecast" do
        result = deserialize
        expect(result).to be_a(DailyForecast)
        expect(result.weather_code.code).to eq(weather_code)
        expect(result.date).to eq(time)
        expect(result.high).to eq(temperature_2m_max)
        expect(result.low).to eq(temperature_2m_min)
      end
    end
  end
end
