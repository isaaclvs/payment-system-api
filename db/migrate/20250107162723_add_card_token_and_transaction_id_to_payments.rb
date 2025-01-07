class AddCardTokenAndTransactionIdToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :card_token, :string
    add_column :payments, :transaction_id, :string
    add_index :payments, :transaction_id
  end
end