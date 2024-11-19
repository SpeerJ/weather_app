class DailyForecast
  attr_reader :weather_code, :high, :low

  def initialize(weather_code:, high:, low:)
    @weather_code = weather_code
    @high = high
    @low = low
  end
end