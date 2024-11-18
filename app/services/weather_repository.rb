require 'open_meteo'

module WeatherRepository
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
    location = OpenMeteo::Entities::Location.new(latitude:, longitude:)
    OpenMeteo::Forecast.new.get(location:, variables:)
  end
end