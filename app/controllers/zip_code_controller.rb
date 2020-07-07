# frozen_string_literal: true

class ZipCodeController < ApplicationController
  # GET '/zip_code'
  def index
    paginate ZipCode.unscoped, per_page: 15
  end
end
