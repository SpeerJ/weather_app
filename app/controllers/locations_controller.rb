class LocationsController < ApplicationController
  rescue_from WeatherRepository::WeatherApiError, with: :handle_api_error
  # GET /locations
  def index
    name = search_params[:name]
    return @locations = [] if name.nil? || name.empty?

    @locations = WeatherRepository.search(name)
  end

  # GET /locations/(Name to Display)?Latitude=$&Longitude=
  def show
    @location = weather_params[:id]
    @forecast = WeatherRepository.get_weather_cached(weather_params[:latitude], weather_params[:longitude])
    flash.now[:notice] = "Using cached data" if @forecast.cached
  end

  private

  def handle_api_error(exception)
     redirect_to root_path, flash: { alert: exception.message }
  end

    # Only allow a list of trusted parameters through.
    def search_params
      params.permit(:name, :commit)
    end

   def weather_params
     params.permit(:name, :latitude, :longitude, :id)
   end
end
