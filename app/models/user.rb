class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[admin user] }

  before_validation :set_default_role

  private

  def set_default_role
    self.role ||= 'user'
  end
end
