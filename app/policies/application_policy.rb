# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  private

  def queen_or_admin?
    user.queen? || Current.store.admin.id == user.id
  end

  def queen_or_store_record?
    user.queen? || record.store.admin.id == user.id
  end

  def user_id_queen_or_admin?
    user.queen? || record.id == user.id
  end
end
