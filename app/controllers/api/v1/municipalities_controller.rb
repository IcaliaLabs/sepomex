# frozen_string_literal: true

class Api::V1::MunicipalitiesController < ApplicationController
  # GET '/municipalities'
  def index
    paginate Municipality.unscoped, per_page: 15
  end

  # GET '/municipalities/:id'
  def show
    render json: Municipality.find(params[:id])
  end
end
