class RemoveUniqueIndexFromPaymentsCpf < ActiveRecord::Migration[7.1]
  def change
    remove_index :payments, :cpf
    add_index :payments, :cpf
  end
end
