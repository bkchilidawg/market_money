class Api::V0::MarketsController < ApplicationController
  before_action :set_market, only: [:show]

  def index 
    render json: MarketSerializer.new(Market.all) , status: :ok
  end

  def show
    @market = Market.find(params[:id])
    render json: MarketSerializer.new(@market).serializable_hash
  end

  private 

  def set_market  
    @market = Market.find_by(id: params[:id])

    unless @market 
      render json: { error: "Market not found" }, status: :not_found
    end
  end
end