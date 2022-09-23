# frozen_string_literal: true

class Api::V1::StatesController < ApplicationController
  # GET '/states'
  def index
    per_page = (params[:per_page] unless params[:per_page].to_i > 200) || 15
    paginate State.unscoped, per_page: per_page
  end

  # GET '/states/:id'
  def show
    render json: State.find(params[:id])
  end

  # GET '/states/:id/municipalities'
  def municipalities
    state = State.find(params[:id])
    render json: state.municipalities.order(:id)
  end
end
