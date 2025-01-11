FactoryBot.define do
  factory :payment do
    amount { 100.0 }
    card_number { '4111111111111111' }
    card_holder { 'John Doe' }
    expiry_date { '12/24' }
    cvv { '123' }
    status { 'pending' }
    gateway_used { 'mercado_pago' }
    user
  end
end
