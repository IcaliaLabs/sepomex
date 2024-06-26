class Municipality < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :zip_code
  belongs_to :state

  scope :find_by_zip_code, lambda { |cp|
    where('zip_code ILIKE ?', "%#{cp}%")
  }

  def self.search(params = {})
    municipalities = all

    municipalities = municipalities.find_by_zip_code(params[:zip_code]) if params[:zip_code].present?

    municipalities
  end
end
