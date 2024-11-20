class DailyForecast
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
