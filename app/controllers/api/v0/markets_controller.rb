class Api::V0::MarketsController < ApplicationController
  before_action :set_market, only: [:show, :vendors]

  def index 
    markets = Market.all
    if markets.empty?
      render json: { error: 'No markets found' }, status: :not_found
    else
      render json: MarketSerializer.new(markets), status: :ok
    end
  end

  def show
    if @market
      render json: MarketSerializer.new(@market).serializable_hash, status: :ok
    else
      render json: { errors: [{ detail: "Couldn't find Market with 'id'=#{params[:id]}" }] }, status: :not_found
    end
  end
def vendors
  
  if @market
    render json: VendorSerializer.new(@market.vendors).serializable_hash, status: :ok
  else
    render json: { errors: [{ detail: "Couldn't find Market with 'id'=#{params[:id]}" }] }, status: :not_found
  end
end

  private 

  def set_market
    @market = Market.find_by(id: params[:id])
  end
end