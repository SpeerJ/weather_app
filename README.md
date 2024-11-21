# Weather APP
This is a code challenge.
A Ruby on Rails 8 and OpenMeteo based weather app.

Enter your city, choose from the list of possible matches and get your weather.

https://github.com/user-attachments/assets/3c35a9ef-4a67-4809-83c5-fe257dc6f791

## Technical Details

This App makes use of the OpenMeteo api through the open-meteo gem. weather_repository.rb is responsible for deserializing the results of the geolocation and forecast calls into PORO models. WeatherRepository is a module, I chose a module over a singleton because, due to the design of the api gem, there is no state that needs to be persisted in between calls.

The app has a setup CI system that runs rspec integration and system tests that should cover all significant methods.
