class ForecastSummary
  attr_reader :current_forecast, :hourly_forecast, :daily_forecast

  def initialize(current_forecast:, hourly_forecast:, daily_forecast:)
    @current_forecast = current_forecast
    @hourly_forecast = hourly_forecast
    @daily_forecast = daily_forecast
  end

  def to_partial_path
    "forecast"
  end
end