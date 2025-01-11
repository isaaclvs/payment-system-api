# API de Processamento de Pagamentos

API desenvolvida em Ruby on Rails para processar pagamentos através de dois gateways (Mercado Pago e PagSeguro) com sistema de fallback automático.

## 🎯 Visão Geral

Esta API foi desenvolvida como parte de um desafio técnico, oferecendo:
- Integração com dois gateways de pagamento
- Sistema de fallback automático
- Autenticação de usuários
- Controle de acesso baseado em funções (admin/user)
- Rastreamento completo do ciclo de vida do pagamento

## 💻 Tecnologias Utilizadas

- Ruby 3.x
- Rails 7.1.0
- PostgreSQL
- Devise + JWT (autenticação)
- RSpec (testes)
- Active Model Serializers
- Mercado Pago SDK
- HTTParty
- Rack CORS
- Dotenv Rails

## 📝 Endpoints da API

### Autenticação
```
POST /signup         # Registro de usuário
POST /login         # Login do usuário
DELETE /logout      # Logout do usuário
```

### Pagamentos
```
POST /api/v1/payments      # Criar pagamento
GET /api/v1/payments      # Listar pagamentos (requer admin)
```

### Exemplo de Requisição de Pagamento
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

### Exemplo de Resposta de Pagamento
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

## 🔑 Credenciais de Teste

Utilize as seguintes credenciais para testar a integração com os gateways de pagamento.

**Importante: A aplicação faz a requisição primeiro para o PagSeguro, se a transação falhar será feita a tentativa com o Mercado Pago como _fallback_.**

### PagSeguro
- **Número do cartão**: `4539620659922097`
- **Nome do titular**: `TESTE`
- **Validade**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

### Mercado Pago
- **Número do cartão**: `4929291898380766`
- **Nome do titular**: `APRO`
- **Validade**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

### Falha Total
- **Número do cartão**: `4929291898380766`
- **Nome do titular**: `OTHE`
- **Validade**: `12/30`
- **CVV**: `123`
- **CPF**: `12345678909`

Certifique-se de configurar o ambiente de testes no código para que as transações utilizem esses dados de teste.

## 🔐 Credenciais de Login

Utilize as credenciais abaixo para acessar a API com diferentes níveis de permissão:

### Administrador
- **Email**: `admin@test.com`
- **Senha**: `password123`

### Usuário Comum
- **Email**: `user@test.com`
- **Senha**: `password123`

Certifique-se de criar os usuários no ambiente de teste ou configurar os dados para corresponder ao seu banco de dados.

## 🚀 Configuração e Instalação

1. Clone o repositório:
```bash
git clone https://github.com/isaaclvs/payment-system-api.git
cd payment-system-api
```

2. Instale as dependências:
```bash
bundle install
```

3. Configure as variáveis de ambiente:
Crie um arquivo `.env` na raiz do projeto:
```
# Mercado Pago Credentials

MercadoPago_ACCESS_TOKEN=your_access_token_here
MercadoPago_PUBLIC_KEY=your_public_key_here

# PagSeguro Credentials

PagSeguro_Email=your_email
PagSeguro_ACCESS_TOKEN=your_access_token_here
```

4. Configure o banco de dados:
```bash
rails db:create
rails db:migrate
```

## 📊 Modelos

### User (Usuário)
```ruby
attributes:
- email (string, único)
- role (string: 'admin'/'user')
- encrypted_password (string)
- jti (string, para JWT)

relationships:
- has_many :payments
```

### Payment (Pagamento)
```ruby
attributes:
- amount (decimal)
- card_number (string, mascarado)
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

## 🔒 Segurança

- Mascaramento de dados sensíveis do cartão
- Autenticação via JWT
- Controle de acesso baseado em funções
- Proteção contra CORS
- Validações em nível de modelo
- Sanitização de parâmetros

## 🧪 Testes

O projeto utiliza RSpec para testes. Para executar:

```bash
bundle exec rspec                  # Todos os testes
bundle exec rspec spec/models      # Testes de modelos
bundle exec rspec spec/requests    # Testes de endpoints
bundle exec rspec spec/services    # Testes de serviços
```

## 🚦 Tratamento de Erros

A API utiliza códigos de status HTTP padrão:

- 200: Sucesso
- 201: Criado
- 400: Requisição inválida
- 401: Não autorizado
- 403: Proibido
- 422: Entidade não processável
- 500: Erro interno do servidor

Exemplo de resposta de erro:
```json
{
  "status": "failed",
  "message": "Falha no processamento do pagamento"
}
```

## 📝 Fluxo de Processamento de Pagamento

1. Recebimento da requisição de pagamento
2. Validação dos dados do cartão
3. Tentativa de pagamento no Mercado Pago
4. Em caso de falha, tentativa automática no PagSeguro
5. Registro do resultado da transação
6. Retorno do status para o cliente

## 🔍 Logs e Monitoramento

O sistema registra eventos importantes:
- Tentativas de pagamento
- Transições entre gateways
- Eventos de autenticação
- Erros do sistema

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.