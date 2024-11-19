require 'open_meteo'

module WeatherRepository
  TRANSLATIONS = {
    DailyForecast => {
      temperature_2m_max: :high,
      temperature_2m_min: :low,
      weather_code: :weather_code
    },
    Forecast => {
      weather_code: :weather_code,
      temperature_2m: :temperature
    }
  }

  def self.search(name, variables: {})
    search = OpenMeteo::Search.new.get(name: name, variables:)
    search.results.map do |result|
      FoundLocation.new(
        name: result.name,
        state: result.admin1,
        latitude: result.latitude,
        longitude: result.longitude,
        elevation: result.elevation,
        population: result.population,
        country_code: result.country_code)
    end
  end

  def self.get_weather(latitude, longitude, variables: {})
    location = OpenMeteo::Entities::Location.new(latitude: latitude.to_d, longitude: longitude.to_d)
    raw_forecast = OpenMeteo::Forecast.new.get(location:, variables: {
      **variables,
      daily: TRANSLATIONS[DailyForecast].keys,
      current: TRANSLATIONS[Forecast].keys,
      hourly: TRANSLATIONS[Forecast].keys
    })
    ForecastSummary.new(
      current_forecast: deserialize_flat(Forecast, raw_forecast.current.item),
      daily_forecasts: deserialize_array(DailyForecast, raw_forecast.daily),
      hourly_forecasts: deserialize_array(Forecast, raw_forecast.hourly))
  end

  private

  def self.deserialize_array(type, results)
    results.items.map do |item|
      deserialize_flat(type, item)
    end
  end

  def self.deserialize_flat(type, results, options = {})
    type.new(**options, **TRANSLATIONS[type].map do |key, value|
      [value, results.send(key)]
    end.to_h)
  end
end