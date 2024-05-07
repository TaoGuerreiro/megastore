# frozen_string_literal: true

module Admin
  class PhotoPolicy < ApplicationPolicy
    def remove_photo?
      queen_or_store_record?
    end
  end
end
