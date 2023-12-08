class Api::V0::MarketVendorsController < ApplicationController
 

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: [{ detail: exception.message }] }, status: :not_found
  end

  # POST /api/v0/market_vendors
  def create
    market_id = params[:market_id]
    vendor_id = params[:vendor_id]

    if market_id.blank? || vendor_id.blank?
      render json: { "message": "Validation failed: Market can't be blank, Vendor can't be blank" }, status: :bad_request
    else
      begin 
        market = Market.find(market_id)
        vendor = Vendor.find(vendor_id)

        raise ActiveRecord::RecordNotUnique if MarketVendor.where(market: market, vendor: vendor).exists?

        MarketVendor.create!(market: market, vendor: vendor)
        render json: { "message": "Successfully added vendor to market" }, status: :created
      rescue ActiveRecord::RecordInvalid => exception
        render json: ErrorsSerializer.new(ErrorMessage.new(exception.message, :unprocessable_entity)).serialize, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotUnique => exception
        render json: ErrorsSerializer.new(ErrorMessage.new("Market Vendor with the same market_id and vendor_id already exists", :unprocessable_entity)).serialize, status: 422
      end
    end
  end
  
  # DELETE /api/v0/market_vendors/:id
def destroy
  begin
    market_vendor = MarketVendor.find_by!(market_id: params[:market_id], vendor_id: params[:vendor_id])
    render(json: market_vendor.destroy!, status: 204)
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [{ detail: "Couldn't find MarketVendor with 'market_id'=#{params[:market_id]} and 'vendor_id'=#{params[:vendor_id]}" }] }, status: :not_found
  end
end

  
end