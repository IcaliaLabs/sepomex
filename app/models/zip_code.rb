class ZipCode < ActiveRecord::Base
  default_scope { order(:id) }

  scope :filter_by_cp, lambda { |cp|
    where("d_codigo ILIKE ?", "%#{cp}%")
  }

end
