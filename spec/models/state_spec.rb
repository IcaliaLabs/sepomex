# frozen_string_literal: true

require 'rails_helper'

RSpec.describe State, type: :model do
  context 'Associations' do
    it { should have_many(:municipalities) }
    it { should have_many(:cities) }
  end

  context 'Validations' do
    it { should validate_presence_of(:name) }
  end
end
