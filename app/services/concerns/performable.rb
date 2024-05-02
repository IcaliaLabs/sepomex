# frozen_string_literal: true

#= Performable
#
# Module with methods useful for service classes
module Performable
  def self.included(base)
    base.extend ClassMethods
  end

  def perform(...)
    perform!(...)
  rescue StandardError
    false
  end

  #= ClassMethods
  #
  # Methods used to call service classes without explicitly instanciating
  module ClassMethods
    def perform(...)
      new(...).perform
    end

    def perform!(...)
      new(...).perform!
    end
  end
end
