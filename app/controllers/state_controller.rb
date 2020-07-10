# frozen_string_literal: true

class StateController < ApplicationController
  # GET '/state'
  def index
    paginate State.unscoped, per_page: 15
  end

  # GET '/state/:id'
  def show
    render json: State.find(params[:id])
  end

  # GET '/state/:id/municipalities'
  def municipalities
    state = State.find(params[:id])
    render json: state.municipalities.order(:id)
  end
end
