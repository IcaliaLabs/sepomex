# frozen_string_literal: true

class MunicipalityController < ApplicationController
  # GET '/municipality'
  def index
    paginate Municipality.unscoped, per_page: 15
  end

  # GET '/municipality/:id'
  def show
    render json: Municipality.find(params[:id])
  end
end
