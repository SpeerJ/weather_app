##
# A summary of all the forecast information
# current, hourly, daily forecast: objects of Forecast classes that contain weather and temperature info
# cached: Was this retrieved from cache?
class ForecastSummary
  attr_reader :current_forecast, :hourly_forecast, :daily_forecast
  attr_accessor :cached

  def initialize(current_forecast:, hourly_forecasts:, daily_forecasts:, cached:)
    @current_forecast = current_forecast
    @hourly_forecast = hourly_forecasts
    @daily_forecast = daily_forecasts
    @cached = cached
  end

  def to_partial_path
    "forecast_summaries/forecast_summary"
  end

  def future_hourly_forecast
    @hourly_forecast.select { |forecast| forecast.time.hour >= @current_forecast.time.hour }
  end
end
