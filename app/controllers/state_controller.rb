# frozen_string_literal: true

class StateController < ApplicationController
  # GET '/states'
  def index
    render json: State.all
  end

  # GET '/state/:id'
  def find_by_id
    render json: State.find(params[:id])
  end
end
