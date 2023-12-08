require 'rails_helper'

RSpec.describe "GET /api/v0/vendors/:id", type: :request do
  describe "returns the vendor for a valid id" do
    it "returns the vendor for a valid id" do
      vendor = create(:vendor)

      get "/api/v0/vendors/#{vendor.id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response["data"]["id"]).to eq(vendor.id.to_s)
    end
  end

  describe "returns a 404 status and error message for an invalid id" do
    it "returns a 404 status and error message for an invalid id" do
      get "/api/v0/vendors/invalid_id"

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body)

      expect(json_response["errors"]).to eq("Vendor not found")
    end
  end

  describe "POST /api/v0/vendors" do
    it "creates a new vendor with valid parameters" do
      valid_params = { vendor: { name: "Vendor Name", description: "Vendor Description", contact_name: "Contact Name", contact_phone: "Contact Phone", credit_accepted: true } }

      post "/api/v0/vendors", params: valid_params.to_json, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:created)

      json_response = JSON.parse(response.body)

      expect(json_response["data"]["attributes"]["name"]).to eq("Vendor Name")
    end

    it "returns a 400 status and error message for invalid parameters" do
      invalid_params = { vendor: { name: "", description: "Vendor Description", contact_name: "Contact Name", contact_phone: "Contact Phone", credit_accepted: true } }

      post "/api/v0/vendors", params: invalid_params.to_json, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      json_response = JSON.parse(response.body)

# require 'pry'; binding.pry
      expect(json_response["errors"].first["detail"]).to include("Name can't be blank")
    end
  end

  describe "PATCH /api/v0/vendors/:id" do
    let(:vendor) { Vendor.create(name: "Vendor Name", description: "Vendor Description", contact_name: "Contact Name", contact_phone: "Contact Phone", credit_accepted: true) }

    it "updates an existing vendor with valid parameters" do
      valid_params = { contact_name: "New Contact Name", credit_accepted: false }

      patch "/api/v0/vendors/#{vendor.id}", params: valid_params.to_json, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response["data"]["attributes"]["contact_name"]).to eq("New Contact Name")
      expect(json_response["data"]["attributes"]["credit_accepted"]).to eq(false)
    end

    it "returns a 404 status and error message for invalid vendor id" do
      invalid_id = 123123123123

      patch "/api/v0/vendors/#{invalid_id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body)

      expect(json_response["errors"].first["message"]).to eq("Couldn't find Vendor with 'id'=#{invalid_id}")
    end

    it "returns a 400 status and error message for invalid parameters" do
      invalid_params = { contact_name: "" }

      patch "/api/v0/vendors/#{vendor.id}", params: invalid_params.to_json, headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response["errors"].first["message"]).to include("Contact name can't be blank")
    end
  end

  describe "DELETE /api/v0/vendors/:id" do
    let(:vendor) { Vendor.create(name: "Vendor Name", description: "Vendor Description", contact_name: "Contact Name", contact_phone: "Contact Phone", credit_accepted: true) }

    it "destroys an existing vendor with a valid id" do
      delete "/api/v0/vendors/#{vendor.id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:no_content)
      expect(Vendor.find_by(id: vendor.id)).to be_nil
    end

    it "returns a 404 status and error message for invalid vendor id" do
      invalid_id = 123123123123

      delete "/api/v0/vendors/#{invalid_id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

      expect(response).to have_http_status(:not_found)

      json_response = JSON.parse(response.body)
      #require 'pry'; binding.pry
      expect(json_response["errors"].first["message"]).to eq("Couldn't find Vendor with 'id'=#{invalid_id}")
    end
  end
end