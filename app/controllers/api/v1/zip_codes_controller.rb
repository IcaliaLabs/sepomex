# frozen_string_literal: true

class Api::V1::ZipCodesController < ApplicationController
  # GET '/zip_codes'
  def index
    per_page = (params[:per_page] unless params[:per_page].to_i > 200) || 15
    paginate ZipCode.search(params), per_page: per_page
  end
end
