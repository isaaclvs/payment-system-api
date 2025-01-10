class AddCpfToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :cpf, :string
    add_index :payments, :cpf, unique: true
  end
end
