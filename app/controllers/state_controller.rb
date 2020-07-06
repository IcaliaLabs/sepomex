# frozen_string_literal: true

class StateController < ApplicationController
  # GET '/states'
  def index
    render json: State.all
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
