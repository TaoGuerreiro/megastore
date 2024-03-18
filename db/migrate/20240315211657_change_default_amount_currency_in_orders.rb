class ChangeDefaultAmountCurrencyInOrders < ActiveRecord::Migration[7.0]
  def change
    change_column_default :orders, :amount_currency, from: 'USD', to: 'EUR'
  end
end
