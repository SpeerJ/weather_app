class ForecastSummary
  attr_reader :current_forecast, :hourly_forecast, :daily_forecast

  def initialize(current_forecast:, hourly_forecasts:, daily_forecasts:)
    @current_forecast = current_forecast
    @hourly_forecast = hourly_forecasts
    @daily_forecast = daily_forecasts
  end

  def to_partial_path
    "forecast"
  end
end