# frozen_string_literal: true

class CityController < ApplicationController
  # GET '/cities'
  def index
    render json: City.all
  end

  # GET '/city/:id'
  def find_by_id
    render json: City.find(params[:id])
  end
end
