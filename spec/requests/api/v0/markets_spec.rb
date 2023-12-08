require 'rails_helper'

RSpec.describe "API V0 Markets", type: :request do
  describe "GET /api/v0/markets" do
    it "returns a list of markets with vendor_count" do
      market1 = create(:market)
      7.times do
        vendor = create(:vendor)
        create(:market_vendor, market: market1, vendor: vendor)
      end

      get "/api/v0/markets", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].length).to eq(1)

      expect(json_response["data"][0]["id"]).to eq(market1.id.to_s)
      expect(json_response["data"][0]["attributes"]["name"]).to eq(market1.name)
      expect(json_response["data"][0]["attributes"]["vendor_count"]).to eq(7)
  
      markets = JSON.parse(response.body, symbolize_names: true)

      expect(markets[:data].count).to eq(1)
      markets[:data].each do |market|
      expect(market).to have_key(:id)
      expect(market[:id]).to be_an(String)

      expect(market).to have_key(:attributes)
      expect(market[:attributes]).to be_a(Hash)

      expect(market[:attributes]).to have_key(:name)
      expect(market[:attributes][:name]).to be_a(String)

      expect(market[:attributes]).to have_key(:street)
      expect(market[:attributes][:street]).to be_a(String)

      expect(market[:attributes]).to have_key(:city)
      expect(market[:attributes][:city]).to be_a(String)

      expect(market[:attributes]).to have_key(:county)
      expect(market[:attributes][:county]).to be_a(String)

      expect(market[:attributes]).to have_key(:state)
      expect(market[:attributes][:state]).to be_a(String)

      expect(market[:attributes]).to have_key(:zip)
      expect(market[:attributes][:zip]).to be_a(String)

      expect(market[:attributes]).to have_key(:lat)
      expect(market[:attributes][:lat]).to be_a(String)

      expect(market[:attributes]).to have_key(:lon)
      expect(market[:attributes][:lon]).to be_a(String)
      end
    end
  end
 

 describe "GET /api/v0/markets/:id" do
   it "returns a market with vendor_count for a valid id" do
    market1 = create(:market)
    7.times do
      vendor = create(:vendor)
      create(:market_vendor, market: market1, vendor: vendor)
    end

    get "/api/v0/markets/#{market1.id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

    expect(response).to have_http_status(:ok)


    json_response = JSON.parse(response.body)
    expect(json_response["data"]["id"]).to eq(market1.id.to_s) 
    expect(json_response["data"]["attributes"]["name"]).to eq(market1.name)
    expect(json_response["data"]["attributes"]["street"]).to eq(market1.street)
    expect(json_response["data"]["attributes"]["city"]).to eq(market1.city)
    expect(json_response["data"]["attributes"]["county"]).to eq(market1.county)
    expect(json_response["data"]["attributes"]["state"]).to eq(market1.state)
    expect(json_response["data"]["attributes"]["zip"]).to eq(market1.zip)
    expect(json_response["data"]["attributes"]["vendor_count"]).to eq(7)
  end
  

    it "returns a 404 status and error message for an invalid id" do
      get "/api/v0/markets/123123123123", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)

      if response.body.present?
        json_response = JSON.parse(response.body)
        if json_response["errors"].present?
          expect(json_response["errors"].first["detail"]).to eq("Couldn't find Market with 'id'=123123123123")
        else
          fail "Response body does not contain 'errors' key"
        end
      else
        fail "Response body is empty"
      end
    end
  end

   describe "GET /api/v0/markets/:id/vendors" do
    it "returns vendors for a valid market id" do
      market = create(:market)
      vendors = [] 
      7.times do
        vendor = create(:vendor)
        create(:market_vendor, market: market, vendor: vendor)
        vendors << vendor 
      end

      get "/api/v0/markets/#{market.id}/vendors", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response["data"]).to be_an(Array)
      expect(json_response["data"].length).to eq(7)

      expect(json_response["data"][0]["id"]).to eq(vendors[0].id.to_s)
      expect(json_response["data"][0]["attributes"]["name"]).to eq(vendors[0].name)

    end

    it "returns a 404 status and error message for an invalid market id" do
      get "/api/v0/markets/999/vendors", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body)
      expect(json_response["errors"][0]["detail"]).to eq("Couldn't find Market with 'id'=999")
    end
  end

  describe 'GET /api/v0/markets/search' do
    let!(:market) { create(:market, name: 'Nob Hill Growers Market', city: 'Albuquerque', state: 'New Mexico') }

    it 'returns a 200 status and the correct market data when valid parameters are sent' do
      get '/api/v0/markets/search', params: { city: 'Albuquerque', state: 'New Mexico', name: 'Nob Hill Growers Market' }, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response["data"][0]["name"]).to eq(market.name)  
    end


    it 'returns a 422 status and an error message when invalid parameters are sent' do
      get '/api/v0/markets/search', params: { city: 'Albuquerque' }, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:unprocessable_entity)

      json_response = JSON.parse(response.body)
      expect(json_response["errors"][0]["detail"]).to eq("Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.")
    end

    it 'returns a 200 status and an empty array when valid parameters are sent but no markets are found' do
      get '/api/v0/markets/search', params: { state: 'California' }, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]).to be_empty
    end
  end

  describe 'GET #nearest_atms' do
    let(:market) { create(:market) } 

    context 'when market exists' do
      before do
        stub_request(:get, "https://api.tomtom.com/search/2/categorySearch/ATM.json?lat=#{market.lat}&lon=#{market.lon}&categorySet=7397&view=Unified&relatedPois=child&key=IJY6QIxeLaV66xyJminIzUTp8AM3wHyA")
          .to_return(status: 200, body: { results: [] }.to_json)
      end

      it 'returns status code 200' do
        get "/api/v0/markets/#{market.id}/nearest_atms"
        expect(response).to have_http_status(200)
      end
    end

    context 'when market does not exist' do
      it 'returns status code 404' do
        get "/api/v0/markets/999/nearest_atms" 
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        get "/api/v0/markets/999/nearest_atms" 
        expect(response.body).to match(/Couldn't find Market/)
      end
    end
  end
end