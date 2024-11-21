require 'rails_helper'

RSpec.describe 'Locations', type: :system do
  describe 'Location#index' do
    it "Loads a basic page" do
      visit 'locations/'

      expect(page) .to have_text('Locations')
    end

    it "Returns a list of locations" do
      VCR.use_cassette("get_locations_london") do
        visit 'locations/'

        fill_in "name", with: "London"
        click_button "search"

        expect(page) .to have_text('51.508') # Lat of London, UK, should be one of the first results
      end
    end

    it "Navigates to a location" do
      VCR.use_cassette("get_locations_london") do
        visit 'locations/'

        fill_in "name", with: "London"
        click_button "search"
      end

      VCR.use_cassette('get_weather_london') do
        first(".see-weather").click
      end
      expect(page) .to have_text('London')
    end

    it "Searches for an empty name without error" do
      VCR.use_cassette("get_locations_empty") do
        visit 'locations/'

        click_button "search"
      end
    end

    it "Searches for nonsense without an error" do
      VCR.use_cassette("get_locations_nonsense") do
        visit 'locations/'

        fill_in "name", with: "GGGGGGGG"
        click_button "search"
      end
    end
  end

  describe "Location#show" do
    it "Lacks correct latitude without an error" do
      VCR.use_cassette("get_forecast_without_latitude") do
        visit 'locations/london?longitude=51.508'
      end
    end

    it "Lacks correct longitude without an error" do
      VCR.use_cassette("get_forecast_without_longitude") do
        visit 'locations/london?latitude=51.508'
      end
    end

    it "Shows a page containing the name of the location" do
      VCR.use_cassette("get_forecast_without_lat_long") do
        visit 'locations/london'

        expect(page) .to have_text('london')
      end
    end
  end
end
