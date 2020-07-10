# frozen_string_literal: true

class ZipCodesController < ApplicationController

  # GET '/zip_codes'
  def index
    paginate ZipCode.unscoped, per_page: 15
  end
end
