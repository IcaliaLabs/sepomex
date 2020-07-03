# frozen_string_literal: true

class MunicipalityController < ApplicationController
  # GET '/municipalities'
  def index
    render json: Municipality.all
  end

  # GET '/municipality/:id'
  def find_by_id
    render json: Municipality.find(params[:id])
  end
end
