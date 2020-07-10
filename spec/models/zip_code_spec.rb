# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZipCode, type: :model do
  it { should validate_presence_of(:d_codigo) }
end
