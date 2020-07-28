# frozen_string_literal: true

class Api::V1::ZipCodesController < ApplicationController
  # GET '/zip_codes'
  def index
    paginate ZipCode.search(params), per_page: 15
  end
end
