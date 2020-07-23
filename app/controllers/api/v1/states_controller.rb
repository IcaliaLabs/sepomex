# frozen_string_literal: true

class Api::V1::StatesController < ApplicationController
  # GET '/states'
  def index
    paginate State.unscoped, per_page: 15
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
