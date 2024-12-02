# Weather APP
This is a code challenge.
A Ruby on Rails 8 and OpenMeteo based weather app.

Enter your city, choose from the list of possible matches and get your weather.

https://github.com/user-attachments/assets/3c35a9ef-4a67-4809-83c5-fe257dc6f791

## Technical Details and Design considerations

This app uses the OpenMeteo API through the open-meteo gem. weather_repository.rb is responsible for calling the API and handling any errors. WeatherRepository is a module. I chose a module over a singleton because, due to the API gem's design, no state needs to be persisted between calls. It also could have been a simple object instantiated on need. The advantage of that approach is that the decoupling provided made testing easier. However, using VCR for integration tests allows for rapid integration tests. Ultimately, I determined that a module was perfectly adequate.

The OpenMeteoDeserializable Mixin provides the code for deserialization in a way that is accessible to tests. It also checks on include for the class's "TRANSLATION" constant. This constant maps API versions of names to the names in the object. In order to decouple the API from internal models, it might have made sense to wrap these objects in some way or put the Translation constants elsewhere. However, to keep things simple and lines of code down, I elected to keep these constants in the model. It's subjective, and if I had worked with an existing code base, I might have done it differently depending on its style.

This app has a simple GitHub workflow for CI and utilizes RSpec for integration, system, and unit testing. It provides near-total coverage of the Views, Models, Controllers, the WeatherRepository class, and the OpenMeteoDeserializable mixin.
