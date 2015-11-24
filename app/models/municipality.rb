class Municipality < ActiveRecord::Base
  belongs_to :state

  scope :find_by_cp, lambda { |cp|
    where("zip_code ILIKE ?", "%#{cp}%")
  }

  def self.search(params = {})
    municipalities = all

    municipalities = municipalities.find_by_cp(params[:cp]) if params[:cp].present?

    municipalities
  end

end
