# frozen_string_literal: true

class MunicipalityController < ApplicationController
  # GET '/municipality'
  def index
    render json: Municipality.all
  end

  # GET '/municipality/:id'
  def show
    render json: Municipality.find(params[:id])
  end
end
