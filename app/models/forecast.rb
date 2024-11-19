class Forecast
  attr_reader :weather_code, :temperature

  def initialize(weather_code:, temperature:)
    @weather_code = weather_code
    @temperature = temperature
  end
end