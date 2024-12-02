##
# Takes the weather code returned from an api and converts it into an emoji and description
# emoji: an emoji representation of this kind of weather
# code: a number 0-99 representing the kind of weather outside at this location(sunny, rainy, etc) look at WeatherRepository::WeatherCodes for details
WeatherCode = Struct.new(:emoji, :code, :description)

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
