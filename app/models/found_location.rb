class FoundLocation
  attr_reader :name, :state, :latitude, :longitude, :elevation, :population, :country_code

  def initialize(name:, state:, latitude:, longitude:, elevation:, population:, country_code:)
    @name = name
    @state = state
    @latitude = latitude
    @longitude = longitude
    @elevation = elevation
    @population = population
    @country_code = country_code
  end

  ##
  # Add support to helper methods for this class
  def to_partial_path
    "location"
  end
end