require 'rails_helper'

RSpec.describe "MarketVendors API", type: :request do
  describe "POST /api/v0/market_vendors" do
    describe "when valid market_id and vendor_id are passed in" do
      let(:market) { create(:market) }
      let(:vendor) { create(:vendor) }
      let(:valid_params) { { market_id: market.id, vendor_id: vendor.id } }

      it "creates a new MarketVendor and returns a 201 status" do
        post "/api/v0/market_vendors", params: valid_params

        expect(response).to have_http_status(201)
        expect(response.body).to include("Successfully added vendor to market")
      end

      it "associates the vendor with the market" do
        post "/api/v0/market_vendors", params: valid_params

        get "/api/v0/markets/#{market.id}/vendors"

        expect(response).to have_http_status(200)
        expect(response.body).to include(vendor.name)
      end
    end

    describe "when invalid market_id or vendor_id is passed in" do
      let(:invalid_params) { { market_id: 987654321, vendor_id: 54861 } }

      it "returns a 404 status with an error message" do
        post "/api/v0/market_vendors", params: invalid_params
        expect(response).to have_http_status(404)
        expect(response.body).to include("Couldn't find Market with 'id'=987654321")
      end
    end

    describe "when a MarketVendor with the same market_id and vendor_id already exists" do
      let(:market) { create(:market) }
      let(:vendor) { create(:vendor) }
      let!(:existing_market_vendor) { create(:market_vendor, market: market, vendor: vendor) }
      let(:duplicate_params) { { market_id: market.id, vendor_id: vendor.id } }

      it "returns a 422 status with an error message" do
        post "/api/v0/market_vendors", params: duplicate_params

        expect(response).to have_http_status(422)
        expect(response.body).to include("Market Vendor with the same market_id and vendor_id already exists")
      end
    end

    describe "when market_id or vendor_id is not passed in" do
      let(:missing_params) { {} }

      it "returns a 400 status with an error message" do
        post "/api/v0/market_vendors", params: missing_params

        expect(response).to have_http_status(400)
        expect(response.body).to include("Validation failed: Market can't be blank, Vendor can't be blank")
      end
    end

    describe "DELETE /api/v0/market_vendors" do
      let!(:market_vendor) { create(:market_vendor) }

      it "deletes the MarketVendor and returns a 204 status" do
        delete "/api/v0/market_vendors", params: { market_id: market_vendor.market_id, vendor_id: market_vendor.vendor_id }

        expect(response).to have_http_status(204)
        expect(MarketVendor.find_by(id: market_vendor.id)).to be_nil
      end

      it 'returns a 404 status if the MarketVendor is not found' do
        delete "/api/v0/market_vendors", params: { market_id: 999, vendor_id: 999 }
        expect(response).to have_http_status(404)
        expect(response.body).to include("Couldn't find MarketVendor with 'market_id'=999 and 'vendor_id'=999")
      end
    end
  end
end
