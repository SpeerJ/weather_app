require_relative '../services/weather_repository'

class LocationsController < ApplicationController

  # GET /locations or /locations.json
  def index
    @locations = search_params[:name].nil? ? [] : WeatherRepository.search(search_params[:name])
  end

  # GET /locations/1 or /locations/1.json
  def show
    @location = WeatherRepository.get_weather(weather_params[:latitude], weather_params[:longitude])
  end

  private

    # Only allow a list of trusted parameters through.
    def search_params
      params.permit(:name, :commit)
    end

   def weather_params
     params.permit(:name, :latitude, :longitude, :id)
   end
end
