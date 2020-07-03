# frozen_string_literal: true

class ZipCodeController < ApplicationController
  # GET '/zipcodes'
  def index
    render json: ZipCode.all.take(50)
  end
end
