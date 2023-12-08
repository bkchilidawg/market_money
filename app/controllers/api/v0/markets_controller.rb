require 'net/http'
require 'uri'
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

  def search
    if invalid_params?
      render json: { errors: [{ detail: "Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint." }] }, status: :unprocessable_entity
    else
      markets = Market.all
      markets = markets.where('lower(state) = ?', params[:state].downcase) if params[:state]
      markets = markets.where('lower(city) = ?', params[:city].downcase) if params[:city] && params[:state]
      markets = markets.where('lower(name) LIKE ?', "%#{params[:name].downcase}%") if params[:name]
      render json: { data: markets }, status: :ok
    end
  end

  def nearest_atms
    market = Market.find_by(id: params[:id])
    return render json: { errors: [{ detail: "Couldn't find Market with 'id'=#{params[:id]}" }] }, status: :not_found unless market

    key = "IJY6QIxeLaV66xyJminIzUTp8AM3wHyA"
    uri = URI("https://api.tomtom.com/search/2/categorySearch/ATM.json?lat=#{market.lat}&lon=#{market.lon}&categorySet=7397&view=Unified&relatedPois=child&key=#{key}")
    response = Net::HTTP.get(uri)
    atms = JSON.parse(response)["results"].map do |atm|
      {
        id: nil,
        type: 'atm',
        attributes: {
          name: atm['poi']['name'],
          address: atm['address']['freeformAddress'],
          lat: atm['position']['lat'],
          lon: atm['position']['lon'],
          distance: atm['dist']
        }
      }
    end
    render json: { data: atms }, status: :ok
  end


  private 

  def set_market
    @market = Market.find_by(id: params[:id])
  end

  def invalid_params?
    params[:city] && !params[:state] || params[:city] && params[:name] && !params[:state]
  end
end