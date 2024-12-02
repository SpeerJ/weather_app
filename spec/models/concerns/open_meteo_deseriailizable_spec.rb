require "rails_helper"

class Empty
end

class WithTranslation
  TRANSLATION = {}
end

RSpec.describe OpenMeteoDeserializable do
  describe "#include" do
    it "raises a NoTranslationForClass exception" do
      expect { Empty.include(described_class) }.to raise_error NoTranslationForClass
    end

    it "doesn't raise a NoTranslationForClass exception when included" do
      WithTranslation.include(described_class)
    end
  end

  describe "#deserialize on Forecast" do
    TestForecast = Struct.new(:weather_code, :temperature_2m, :time, keyword_init: true)
    subject(:deserialize) { Forecast.deserialize(TestForecast.new(weather_code:, temperature_2m:, time:)) }

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
    subject(:deserialize) { DailyForecast.deserialize(TestDailyForecast.new(weather_code:, temperature_2m_min:, temperature_2m_max:, time:)) }

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
