require "open_meteo"
require "open_meteo/client"

##
# Handles the communication with the OpenMeteo gem and converting it's formats into useful models for our app
module WeatherRepository
  # Create custom errors so our front-end is not coupled to the OpenMeteo gem
  class WeatherRepositoryError < StandardError; end

  class WeatherApiError < WeatherRepositoryError; end

  class BadInputError < WeatherRepositoryError; end

  ##
  # Contains the OpenMeteo name for attributes and our local name for attributes
  TRANSLATIONS = {
    DailyForecast => {
      time: :date,
      temperature_2m_max: :high,
      temperature_2m_min: :low,
      weather_code: :weather_code
    },
    Forecast => {
      weather_code: :weather_code,
      temperature_2m: :temperature,
      time: :time
    }
  }.freeze

  ##
  # Assigns emojis and descriptions from wmo_codes
  # credit: https://github.com/olivvein/wmo-emoji/tree/main
  WeatherCodes = [
    WeatherCode.new("☀️", 0, "Clear sky"),
    WeatherCode.new("🌤️", 1, "Mainly clear"),
    WeatherCode.new("⛅", 2, "Partly cloudy"),
    WeatherCode.new("☁️", 3, "Overcast"),
    WeatherCode.new("🌫️", 45, "Fog"),
    WeatherCode.new("🌫️", 48, "Depositing rime fog"),
    WeatherCode.new("🌧️", 51, "Drizzle: Light intensity"),
    WeatherCode.new("🌧️", 53, "Drizzle: Moderate intensity"),
    WeatherCode.new("🌧️", 55, "Drizzle: Dense intensity"),
    WeatherCode.new("🌧️", 56, "Freezing Drizzle: Light intensity"),
    WeatherCode.new("🌧️", 57, "Freezing Drizzle: Dense intensity"),
    WeatherCode.new("🌧️", 61, "Rain: Slight intensity"),
    WeatherCode.new("🌧️", 63, "Rain: Moderate intensity"),
    WeatherCode.new("🌧️", 65, "Rain: Heavy intensity"),
    WeatherCode.new("🌧️", 66, "Freezing Rain: Light intensity"),
    WeatherCode.new("🌧️", 67, "Freezing Rain: Heavy intensity"),
    WeatherCode.new("❄️", 71, "Snow fall: Slight intensity"),
    WeatherCode.new("❄️", 73, "Snow fall: Moderate intensity"),
    WeatherCode.new("❄️", 75, "Snow fall: Heavy intensity"),
    WeatherCode.new("❄️", 77, "Snow grains"),
    WeatherCode.new("🌧️", 80, "Rain showers: Slight intensity"),
    WeatherCode.new("🌧️", 81, "Rain showers: Moderate intensity"),
    WeatherCode.new("🌧️", 82, "Rain showers: Violent intensity"),
    WeatherCode.new("❄️", 85, "Snow showers: Slight intensity"),
    WeatherCode.new("❄️", 86, "Snow showers: Heavy intensity"),
    WeatherCode.new("⛈️", 95, "Thunderstorm: Slight or moderate"),
    WeatherCode.new("⛈️", 96, "Thunderstorm with slight hail"),
    WeatherCode.new("⛈️", 99, "Thunderstorm with heavy hail")
  ].freeze

  ##
  # This method searches in OpenMeteo for locations
  # It puts the results into Foundlocation, especially the critical latitude, and longitude
  def self.search(name, variables: {})
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
  # This method uses the previously acquired latitude and longitude and returns any non-expired cache
  def self.get_weather_cached(latitude, longitude)
    key = "weather_#{latitude}_#{longitude}"
    already_cached = Rails.cache.exist?(key)

    weather_results = Rails.cache.fetch(key, expires_in: 30.minutes) do
      get_weather(latitude, longitude)
    end
    weather_results.cached = already_cached

    weather_results
  end

  private # not actually private for the sake of testing
  def self.with_custom_exceptions
    begin
      yield
    rescue OpenMeteo::Client::ConnectionFailed
      raise WeatherApiError, "Something went wrong with the connection"
    rescue OpenMeteo::Client::Timeout
      raise WeatherApiError, "The request to Open Meteo timed out"
    end
  end

  ##
  # This method uses previously acquired latitude and Longitude to find the forecast
  def self.get_weather(latitude, longitude, variables: {})
    begin
      with_custom_exceptions do
        location = OpenMeteo::Entities::Location.new(latitude: latitude.to_d, longitude: longitude.to_d)
        # We use variables to specify what kind of forecast we want.
        raw_forecast = OpenMeteo::Forecast.new.get(location:, variables: {
          **variables,
          daily: TRANSLATIONS[DailyForecast].keys - [ :time ], # Remove time since this is already assumed and causes error
          current: TRANSLATIONS[Forecast].keys - [ :time ],
          hourly: TRANSLATIONS[Forecast].keys - [ :time ]
        })
        ForecastSummary.new(
          current_forecast: deserialize(Forecast, raw_forecast.current.item),
          daily_forecasts: deserialize_array(DailyForecast, raw_forecast.daily),
          hourly_forecasts: deserialize_array(Forecast, raw_forecast.hourly),
          cached: false
        )
      end
    rescue OpenMeteo::Entities::Contracts::ApplicationContract::ValidationError
      raise BadInputError, "The provided latitude or longitude is invalid, not between -90 and 90."
    end
  end

  def self.deserialize_array(type, results)
    results.items.map do |item|
      deserialize(type, item)
    end
  end

  ##
  # Take an OpenMeteo::Entity and convert it to one of our local models
  # type: Forecast or DailyForecast, it takes the entity attributes and puts them into this
  # results: The received information from OpenMateo Api in OpenMateo::Entity format
  # options: Anything else we would like to add to our new model instance
  def self.deserialize(type, results, options = {})
    # Use translations to change attribute name from OpenMeteo style to our app's style, decoupling interfaces
    model_instance_attributes = TRANSLATIONS[type].map do |meteo_name, attribute_name|
      value = results.send(meteo_name)

      # Deserialize the weather_code into our own custom WeatherCode
      if meteo_name == :weather_code
        weather_code = WeatherCodes.find { |x| x.code == value }
        next [ attribute_name, weather_code ]
      end

      # Deserialize the date into Date Time
      next [ attribute_name, DateTime.parse(value) ] if meteo_name == :time

      [ attribute_name, value ]
    end.to_h

    type.new(**options, **model_instance_attributes)
  end
end
