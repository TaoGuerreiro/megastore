# frozen_string_literal: true

class AddHolidayToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :holiday, :boolean, default: true
    add_column :stores, :holiday_sentence, :string, default: 'Boutique en vacances'
  end
end
