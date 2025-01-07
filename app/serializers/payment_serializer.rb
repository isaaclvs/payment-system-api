class PaymentSerializer
  include JSONAPI::Serializer
  
  attributes :id, :amount, :status, :gateway_used, :last_four_digits, :created_at
  
  attribute :card_holder do |object|
    "#{object.card_holder[0]}#{'*' * (object.card_holder.length - 2)}#{object.card_holder[-1]}"
  end
  
  attribute :expiry_date do |object|
    "**/**"
  end
end 