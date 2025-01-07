class Payment < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :card_number, presence: true
  validates :card_holder, presence: true
  validates :expiry_date, presence: true
  validates :cvv, presence: true
  validates :card_token, presence: true, on: :create
  validates :transaction_id, uniqueness: true, allow_nil: true

  enum status: {
    pending: 'pending',
    approved: 'approved',
    failed: 'failed'
  }

  enum gateway_used: {
    mercado_pago: 'mercado_pago',
    pag_seguro: 'pag_seguro'
  }

  before_save :mask_card_number, if: :card_number_changed?

  private

  def mask_card_number
    return if card_number.blank?
    self.card_number = "#{card_number.first(6)}******#{card_number.last(4)}"
  end
end