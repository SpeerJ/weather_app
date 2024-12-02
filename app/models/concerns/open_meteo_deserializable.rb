require_relative "../weather_code"
#
## Signifies that the class is not included in the TRANSLATIONS Hash, which tells the program what response attributes
# to expect and how to map them
class NoTranslationForClass < Exception
  def message
    "Cannot include Serializable without class being added to TRANSLATIONS hash"
  end
end

##
# Take an OpenMeteo::Entity and convert it to one of our local models
# type: Forecast or DailyForecast, it takes the entity attributes and puts them into this
# results: The received information from OpenMateo Api in OpenMateo::Entity format
# options: Anything else we would like to add to our new model instance
module OpenMeteoDeserializable
  def self.included(base)
    # The constant TRANSLATION must be defined in every deserializable class
    raise NoTranslationForClass unless defined? base::TRANSLATION
    base.extend(ClassMethods)
  end

  module ClassMethods
    ##
    # Convert results of OpenMeteo call into an instance of this class
    def deserialize(results, options = {})
      # Use TRANSLATIONS to change attribute name from OpenMeteo style to our app's style, decoupling interfaces
      model_instance_attributes = self::TRANSLATION.map do |meteo_name, attribute_name|
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

      self.new(**options, **model_instance_attributes)
    end

    def deserialize_all(results)
      results.items.map do |item|
        self.deserialize(item)
      end
    end
  end
end
