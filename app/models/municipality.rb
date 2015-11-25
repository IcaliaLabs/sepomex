class Municipality < ActiveRecord::Base
  belongs_to :state

  scope :find_by_zip_code, lambda { |cp|
    where("zip_code ILIKE ?", "%#{cp}%")
  }

  def self.search(params = {})
    municipalities = all

    municipalities = municipalities.find_by_cp(params[:zip_code]) if params[:zip_code].present?

    municipalities
  end

end
