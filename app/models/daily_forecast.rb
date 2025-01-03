##
# A forecast similar to Forecast but with high and low temperatures
# high, low: the predicted temperature range for the day
# country_code: a number 0-99 representing the kind of weather outside at this location(sunny, rainy, etc) look at WeatherRepository::WeatherCodes for details
class DailyForecast
  ##
  # Contains the OpenMeteo name for attributes and our local name for attributes
  TRANSLATION = {
    time: :date,
    temperature_2m_max: :high,
    temperature_2m_min: :low,
    weather_code: :weather_code
  }

  include OpenMeteoDeserializable
  attr_reader :weather_code, :high, :low, :date

  def initialize(weather_code:, high:, low:, date:)
    @weather_code = weather_code
    @date = date
    @high = high
    @low = low
  end

  def to_partial_path
    "daily_forecasts/daily_forecast"
  end
end
