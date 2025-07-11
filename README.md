# Payment Processing API

API developed in Ruby on Rails to process payments through two gateways (Mercado Pago and PagSeguro) with automatic fallback system.

## 🎯 Overview

This API was developed as part of a technical challenge, offering:
- Integration with two payment gateways
- Automatic fallback system
- User authentication
- Role-based access control (admin/user)
- Complete payment lifecycle tracking

## 💻 Technologies Used

- Ruby 3.x
- Rails 7.1.0
- PostgreSQL
- Devise + JWT (authentication)
- RSpec (testing)
- Active Model Serializers
- Mercado Pago SDK
- HTTParty
- Rack CORS
- Dotenv Rails

## 📝 API Endpoints

### Authentication
```
POST /signup         # User registration
POST /login         # User login
DELETE /logout      # User logout
```

### Payments
```
POST /api/v1/payments      # Create payment
GET /api/v1/payments      # List payments (requires admin)
```

### Payment Request Example
```json
{
  "payment": {
    "amount": 100.0,
    "card_number": "4929291898380766",
    "card_holder": "TESTE",
    "expiry_date": "12/30",
    "cvv": "123",
    "cpf": "12345678909"
  }
}
```

### Payment Response Example
```json
{
	"status": "success",
	"message": "Payment approved via PagSeguro",
	"payment": {
		"id": null,
		"amount": "100.0",
		"status": "pending",
		"gateway_used": "pag_seguro",
		"last_four_digits": "2097",
		"created_at": "2025-01-11T10:00:00.000Z",
		"card_holder": "T***E",
		"expiry_date": "12/**",
		"cpf": "12345678909"
	}
}
```

## 🔑 Test Credentials

Use the following credentials to test the integration with payment gateways.

**Important: The application makes the request first to PagSeguro, if the transaction fails it will attempt with Mercado Pago as _fallback_.**

### PagSeguro
- **Card number**: `4539620659922097`
- **Cardholder name**: `TESTE`
- **Expiry date**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

### Mercado Pago
- **Card number**: `4929291898380766`
- **Cardholder name**: `APRO`
- **Expiry date**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

### Total Failure
- **Card number**: `4929291898380766`
- **Cardholder name**: `OTHE`
- **Expiry date**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

Make sure to configure the test environment in the code so that transactions use this test data.

## 🔐 Login Credentials

Use the credentials below to access the API with different permission levels:

### Administrator
- **Email**: `admin@test.com`
- **Password**: `password123`

### Regular User
- **Email**: `user@test.com`
- **Password**: `password123`

Make sure to create the users in the test environment or configure the data to match your database.

## 🚀 Setup and Installation

1. Clone the repository:
```bash
git clone https://github.com/isaaclvs/payment-system-api.git
cd payment-system-api
```

2. Install dependencies:
```bash
bundle install
```

3. Configure environment variables:
Create a `.env` file in the project root:
```
# Mercado Pago Credentials

MercadoPago_ACCESS_TOKEN=your_access_token_here
MercadoPago_PUBLIC_KEY=your_public_key_here

# PagSeguro Credentials

PagSeguro_Email=your_email
PagSeguro_ACCESS_TOKEN=your_access_token_here
```

4. Configure the database:
```bash
rails db:create
rails db:migrate
```

## 📊 Models

### User
```ruby
attributes:
- email (string, unique)
- role (string: 'admin'/'user')
- encrypted_password (string)
- jti (string, for JWT)

relationships:
- has_many :payments
```

### Payment
```ruby
attributes:
- amount (decimal)
- card_number (string, masked)
- card_holder (string)
- expiry_date (string)
- cvv (string)
- status (string: pending/approved/failed)
- gateway_used (string)
- transaction_id (string)
- cpf (string)
- user_id (foreign key)

relationships:
- belongs_to :user
```

## 🔒 Security

- Sensitive card data masking
- JWT authentication
- Role-based access control
- CORS protection
- Model-level validations
- Parameter sanitization

## 🧪 Testing

The project uses RSpec for testing. To run:

```bash
bundle exec rspec                  # All tests
bundle exec rspec spec/models      # Model tests
bundle exec rspec spec/requests    # Endpoint tests
bundle exec rspec spec/services    # Service tests
```

## 🚦 Error Handling

The API uses standard HTTP status codes:

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 422: Unprocessable Entity
- 500: Internal Server Error

Error response example:
```json
{
  "status": "failed",
  "message": "Payment processing failed"
}
```

## 📝 Payment Processing Flow

1. Payment request received
2. Card data validation
3. Payment attempt on Mercado Pago
4. In case of failure, automatic attempt on PagSeguro
5. Transaction result recording
6. Status return to client

## 🔍 Logging and Monitoring

The system logs important events:
- Payment attempts
- Gateway transitions
- Authentication events
- System errors

## 📄 License

This project is under the MIT license. See the `LICENSE` file for more details.
