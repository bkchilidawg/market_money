describe "GET /api/v0/vendors/:id" do
  it "returns the vendor for a valid id" do
    vendor = create(:vendor)

    get "/api/v0/vendors/#{vendor.id}", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

    expect(response).to have_http_status(:ok)

    json_response = JSON.parse(response.body)

    expect(json_response["data"]["id"]).to eq(vendor.id.to_s)
    # ... (add more expectations based on your Vendor model attributes)
  end

  it "returns a 404 status and error message for an invalid id" do
    get "/api/v0/vendors/999999", headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

    expect(response).to have_http_status(:not_found)

    json_response = JSON.parse(response.body)

    expect(json_response["error"]).to eq("Vendor not found")
  end
end