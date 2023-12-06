class Api::V0::VendorsController < ApplicationController
  before_action :set_vendor, only: [:show]

  def show
    if @vendor
      render json: VendorSerializer.new(@vendor).serializable_hash, status: :ok
    else
      render json: { errors: "Vendor not found" }, status: :not_found
    end
  end

  private

  def set_vendor
    @vendor = Vendor.find_by(id: params[:id])
  end
end