FactoryBot.define do
  factory :payment do
    amount { Faker::Number.decimal(l_digits: 2) }
    card_number { '4111111111111111' }
    card_holder { Faker::Name.name }
    expiry_date { '12/25' }
    cvv { '123' }
    status { 'pending' }
    association :user

    trait :approved do
      status { 'approved' }
      gateway_used { 'mercado_pago' }
    end

    trait :failed do
      status { 'failed' }
      gateway_used { 'pag_seguro' }
    end
  end
end 