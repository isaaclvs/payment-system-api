class Payment < ApplicationRecord
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :card_holder, presence: true
  validates :card_number, presence: true
  validates :expiry_date, presence: true
  validates :cvv, presence: true

  before_save :set_last_four_digits

  private

  def set_last_four_digits
    self.last_four_digits = card_number.last(4) if card_number_changed?
  end
end
