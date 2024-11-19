class Forecast
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