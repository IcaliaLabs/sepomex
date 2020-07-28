# frozen_string_literal: true

class Api::V1::CitiesController < ApplicationController
  # GET '/cities'
  def index
    paginate City.unscoped, per_page: 15
  end

  # GET '/cities/:id'
  def show
    render json: City.find(params[:id])
  end
end
