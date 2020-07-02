class Municipality < ApplicationRecord
  belongs_to :state

  scope :find_by_zip_code, lambda { |cp|
    where('zip_code ILIKE ?', "%#{cp}%")
  }

  def self.search(params = {})
    municipalities = all

    if params[:zip_code].present?
      municipalities = municipalities.find_by_zip_code(params[:zip_code])
    end

    municipalities
  end
end
