class Payment < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :card_number, presence: true
  validates :card_holder, presence: true
  validates :expiry_date, presence: true
  validates :cvv, presence: true
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
  before_save :set_last_four_digits, if: :card_number_changed?

  # Standard scope for protecting sensitive data
  default_scope { select(:id, :user_id, :amount, :status, :gateway_used, :last_four_digits, :transaction_id, :created_at, :updated_at) }

  private

  # Masking the card number
  def mask_card_number
    return if card_number.blank?
    self.card_number = "#{card_number.first(6)}******#{card_number.last(4)}"
  end

  # Capturing the last 4 digits of the card
  def set_last_four_digits
    self.last_four_digits = card_number.last(4) if card_number.present?
  end
end