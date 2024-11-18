json.extract! location, :id, :latitude, :longitude, :elevation, :population, :country_code, :created_at, :updated_at
json.url location_url(location, format: :json)
