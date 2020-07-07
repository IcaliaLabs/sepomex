# frozen_string_literal: true

class CityController < ApplicationController
  # GET '/city'
  def index
    paginate City.unscoped, per_page: 15
  end

  # GET '/city/:id'
  def show
    render json: City.find(params[:id])
  end
end
