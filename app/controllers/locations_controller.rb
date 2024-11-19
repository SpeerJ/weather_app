class LocationsController < ApplicationController

  # GET /locations
  def index
    @locations = search_params[:name].nil? ? [] : WeatherRepository.search(search_params[:name])
  end

  # GET /locations/(Name to Display)?Latitude=$&Longitude=
  def show
    @location = weather_params[:id]
    @forecast = WeatherRepository.get_weather_cached(weather_params[:latitude], weather_params[:longitude])
    flash.now[:notice] = "Using cached data" if @forecast.cached
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
