# frozen_string_literal: true

require 'rails_helper'

RSpec.describe State, type: :model do
  context 'Associations' do
    it { should validate_presence_of(:d_codigo) }
  end
end
