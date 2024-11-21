##
# Takes the weather code returned from an api and converts it into an emoji and description
# emoji: an emoji representation of this kind of weather
# code: a number 0-99 representing the kind of weather outside at this location(sunny, rainy, etc) look at WeatherRepository::WeatherCodes for details
WeatherCode = Struct.new(:emoji, :code, :description)
