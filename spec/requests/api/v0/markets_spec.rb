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

      expect(json_response["data"][0]["attributes"]["id"]).to eq(market1.id)
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
    99.times do
      vendor = create(:vendor)
      create(:market_vendor, market: market1, vendor: vendor)
    end

    get "/api/v0/markets/#{market1.id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

    expect(response).to have_http_status(:ok)

    json_response = JSON.parse(response.body)
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
      get "/api/v0/markets/999", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Market not found")
    end
  end
end