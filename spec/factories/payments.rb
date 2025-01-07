FactoryBot.define do
  factory :payment do
    amount { Faker::Number.decimal(l_digits: 2) }
    card_number { '4235647728025682' }
    card_holder { 'APRO' }
    expiry_date { '12/25' }
    cvv { '123' }
    card_token { 'TEST-123456789' }
    status { 'pending' }
    association :user

    trait :approved do
      status { 'approved' }
      gateway_used { 'mercado_pago' }
      transaction_id { Faker::Number.number(digits: 10).to_s }
    end

    trait :failed do
      status { 'failed' }
      gateway_used { 'mercado_pago' }
    end
  end
end 