# frozen_string_literal: true

module Admin
  class ArchivePolicy < ApplicationPolicy
    def archive?
      queen_or_store_record?
    end

    def unarchive?
      queen_or_store_record?
    end
  end
end
