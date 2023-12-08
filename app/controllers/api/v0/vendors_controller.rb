class Api::V0::VendorsController < ApplicationController
  before_action :set_vendor, only: [:show]

  def show
    if @vendor
      render json: VendorSerializer.new(@vendor).serializable_hash, status: :ok
    else
      render json: { errors: "Vendor not found" }, status: :not_found
    end
  end

  def create
    @vendor = Vendor.new(vendor_params)

    if @vendor.save
      render json: VendorSerializer.new(@vendor).serializable_hash, status: :created 
    else
      render json: { errors: @vendor.errors.full_messages.map { |msg| { detail: msg } } }, status: :bad_request
    end
  end

  def update
    @vendor = Vendor.find(params[:id])

    if @vendor.update(vendor_params)
      render json: VendorSerializer.new(@vendor).serializable_hash, status: :ok
    else
      render json: ErrorsSerializer.new(ErrorMessage.new(@vendor.errors.full_messages.join(", "), :bad_request)).serialize, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound => exception
   render json: ErrorsSerializer.new(ErrorMessage.new(exception.message, :not_found)).serialize, status: :not_found
  end

  def destroy
    @vendor = Vendor.find(params[:id])

    if @vendor.destroy
      head :no_content
    else
      render json: ErrorsSerializer.new(ErrorMessage.new(@vendor.errors.full_messages.join(", "), :unprocessable_entity)).serialize, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => exception
    render json: ErrorsSerializer.new(ErrorMessage.new(exception.message, :not_found)).serialize, status: :not_found
  end
  private

  def set_vendor
    @vendor = Vendor.find_by(id: params[:id])
  end


  def vendor_params
    params.require(:vendor).permit(:name, :description, :contact_name, :contact_phone, :credit_accepted)
  end
end