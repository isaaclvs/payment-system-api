class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :card_number, null: false
      t.string :card_holder, null: false
      t.string :expiry_date, null: false
      t.string :cvv, null: false
      t.string :status, default: 'pending'
      t.string :gateway_used
      t.string :last_four_digits

      t.timestamps
    end
  end
end
