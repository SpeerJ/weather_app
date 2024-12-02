##
# Forecast for a particular time
# time: date or hour of date for which this forecast applies
# country_code: a number 0-99 representing the kind of weather outside at this location(sunny, rainy, etc) look at WeatherRepository::WeatherCodes for details
class Forecast
  ##
  # Contains the OpenMeteo name for attributes and our local name for attributes
  TRANSLATION = {
    weather_code: :weather_code,
    temperature_2m: :temperature,
    time: :time
  }

  include OpenMeteoDeserializable
  attr_reader :weather_code, :temperature, :time

  def initialize(weather_code:, temperature:, time:)
    @weather_code = weather_code
    @temperature = temperature
    @time = time
  end

  def to_partial_path
    "forecasts/forecast"
  end
end
