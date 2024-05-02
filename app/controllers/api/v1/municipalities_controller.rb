# frozen_string_literal: true

class Api::V1::MunicipalitiesController < ApplicationController
  # GET '/municipalities'
  def index
    per_page = (params[:per_page] unless params[:per_page].to_i > 200) || 15
    paginate Municipality.unscoped, per_page: per_page
  end

  # GET '/municipalities/:id'
  def show
    render json: Municipality.find(params[:id])
  end
end
