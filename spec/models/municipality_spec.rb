# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Municipality, type: :model do
  context 'Associations' do
    it { should belong_to(:state) }
  end
  context 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:zip_code) }
  end
end
