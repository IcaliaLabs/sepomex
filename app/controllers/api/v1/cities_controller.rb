# frozen_string_literal: true

class Api::V1::CitiesController < ApplicationController
  # GET '/cities'
  def index
    per_page = (params[:per_page] unless params[:per_page].to_i > 200) || 15
    paginate City.unscoped, per_page: per_page
  end

  # GET '/cities/:id'
  def show
    render json: City.find(params[:id])
  end
end
