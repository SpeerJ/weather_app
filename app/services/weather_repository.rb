require "open_meteo"
require "open_meteo/client"

##
# Handles the communication with the OpenMeteo gem and converting it's formats into useful models for our app
module WeatherRepository
  # Create custom errors so our front-end is not coupled to the OpenMeteo gem
  class WeatherRepositoryError < StandardError; end

  class WeatherApiError < WeatherRepositoryError; end

  class BadInputError < WeatherRepositoryError; end
  extend self

  ##
  # This method searches in OpenMeteo for locations
  # It puts the results into Foundlocation, especially the critical latitude, and longitude
  def search(name, variables: {})
    begin
      with_custom_exceptions do
        search = OpenMeteo::Search.new.get(name: name, variables:)

        return [] if search.nil?
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
      rescue NoMethodError => e
        return [] if e.message.include?("undefined method `map' for nil") # API client bug in cases of non-sensical searches
        raise e
      end
    end
  end

  ##
  # This method takes a location(lat, long) and returns it's forecast using non-expired cached results or new results
  def get_weather_cached(latitude, longitude)
    key = "weather_#{latitude}_#{longitude}"
    already_cached = Rails.cache.exist?(key)

    weather_results = Rails.cache.fetch(key, expires_in: 30.minutes) do
      get_weather(latitude, longitude)
    end
    weather_results.cached = already_cached

    weather_results
  end

  private
  def with_custom_exceptions
    begin
      yield
    rescue OpenMeteo::Client::ConnectionFailed
      raise WeatherApiError, "Something went wrong with the connection"
    rescue OpenMeteo::Client::Timeout
      raise WeatherApiError, "The request to Open Meteo timed out"
    end
  end

  ##
  # This method takes a location(lat, long) and returns it's forecast
  def get_weather(latitude, longitude, variables: {})
    begin
      with_custom_exceptions do
        location = OpenMeteo::Entities::Location.new(latitude: latitude.to_d, longitude: longitude.to_d)
        # We use variables to specify what kind of forecast we want.
        raw_forecast = OpenMeteo::Forecast.new.get(location:, variables: {
          **variables,
          daily: DailyForecast::TRANSLATION.keys - [ :time ], # The keys are used for both input and output. Time is returned but is not expected in requested variables.
          current: Forecast::TRANSLATION.keys - [ :time ],
          hourly: Forecast::TRANSLATION.keys - [ :time ]
        })
        ForecastSummary.new(
          current_forecast: Forecast.deserialize(raw_forecast.current.item),
          daily_forecasts: DailyForecast.deserialize_all(raw_forecast.daily),
          hourly_forecasts: Forecast.deserialize_all(raw_forecast.hourly),
          cached: false
        )
      end
    rescue OpenMeteo::Entities::Contracts::ApplicationContract::ValidationError
      raise BadInputError, "The provided latitude or longitude is invalid, not between -90 and 90."
    end
  end
end
