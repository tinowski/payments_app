# Payments GraphQL API

A simple Go + GraphQL application for managing payments with full CRUD operations.

## Features

- **Create Payment**: Create new payment transactions
- **Read Payments**: Retrieve all payments or a specific payment by ID
- **Update Payment**: Update payment details including status
- **Delete Payment**: Remove payments from the system
- **GraphQL Playground**: Interactive GraphQL interface for testing
- **CORS Support**: Cross-origin resource sharing enabled
- **Health Check**: Basic health monitoring endpoint

## Tech Stack

- **Go 1.21+**
- **GraphQL** with gqlgen
- **Gorilla Mux** for HTTP routing
- **In-memory storage** (thread-safe)

## Quick Start

### Prerequisites

- Go 1.21 or later
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd payments_app
```

2. Install dependencies:
```bash
go mod tidy
```

3. Run the application:
```bash
go run main.go
```

The server will start on `http://localhost:8080`

## API Endpoints

- **GraphQL Playground**: `http://localhost:8080/`
- **GraphQL Endpoint**: `http://localhost:8080/query`
- **Health Check**: `http://localhost:8080/health`

## GraphQL Schema

### Types

```graphql
type Payment {
  id: ID!
  amount: Float!
  currency: String!
  description: String!
  status: PaymentStatus!
  createdAt: String!
  updatedAt: String!
}

enum PaymentStatus {
  PENDING
  COMPLETED
  FAILED
  CANCELLED
}
```

### Queries

```graphql
# Get all payments
query {
  payments {
    id
    amount
    currency
    description
    status
    createdAt
    updatedAt
  }
}

# Get a specific payment
query {
  payment(id: "payment-id") {
    id
    amount
    currency
    description
    status
    createdAt
    updatedAt
  }
}
```

### Mutations

```graphql
# Create a new payment
mutation {
  createPayment(input: {
    amount: 100.50
    currency: "USD"
    description: "Payment for services"
  }) {
    id
    amount
    currency
    description
    status
    createdAt
    updatedAt
  }
}

# Update a payment
mutation {
  updatePayment(input: {
    id: "payment-id"
    status: COMPLETED
    amount: 150.00
  }) {
    id
    amount
    currency
    description
    status
    createdAt
    updatedAt
  }
}

# Delete a payment
mutation {
  deletePayment(id: "payment-id")
}
```

## Example Usage

### Using curl

1. **Create a payment**:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"query":"mutation { createPayment(input: { amount: 100.50, currency: \"USD\", description: \"Test payment\" }) { id amount currency description status createdAt updatedAt } }"}' \
  http://localhost:8080/query
```

2. **Get all payments**:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"query":"query { payments { id amount currency description status createdAt updatedAt } }"}' \
  http://localhost:8080/query
```

3. **Update payment status**:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"query":"mutation { updatePayment(input: { id: \"payment-id\", status: COMPLETED }) { id amount currency description status createdAt updatedAt } }"}' \
  http://localhost:8080/query
```

4. **Delete a payment**:
```bash
curl -X POST -H "Content-Type: application/json" \
  -d '{"query":"mutation { deletePayment(id: \"payment-id\") }"}' \
  http://localhost:8080/query
```

### Using GraphQL Playground

Visit `http://localhost:8080/` in your browser to access the interactive GraphQL Playground where you can:

- Explore the schema
- Test queries and mutations
- View documentation
- Debug GraphQL operations

## Project Structure

This project follows Clean Architecture principles with clear separation of concerns:

```
payments_app/
├── cmd/                    # Application entry points
│   └── server/            # Main server application
├── internal/              # Private application code
│   ├── domain/            # Business entities and rules
│   │   ├── payment.go     # Payment domain model
│   │   ├── repository.go  # Repository interfaces
│   │   └── test/          # Domain tests
│   ├── usecases/          # Application business logic
│   │   ├── payment_usecase.go # Payment use cases
│   │   └── test/          # Use case tests
│   ├── interfaces/        # External interfaces (GraphQL, REST)
│   │   ├── graphql/       # GraphQL resolvers
│   │   │   ├── graphql_resolver.go
│   │   │   └── test/      # Integration tests
│   │   └── rest/          # REST API (future)
│   └── infrastructure/    # External concerns (database, external APIs)
│       └── database/      # Database implementation
│           ├── payment_repository.go
│           └── test/      # Database tests
├── pkg/                   # Public library code
│   ├── logger/            # Logging utilities
│   └── utils/             # Common utilities
├── configs/               # Configuration files
├── scripts/               # Build and deployment scripts
├── docs/                  # Documentation
├── deployments/           # Deployment configurations
│   ├── docker/            # Docker configurations
│   └── kubernetes/        # Kubernetes configurations
├── migrations/            # Database migrations
├── graph/                 # Legacy GraphQL files (to be removed)
├── cmd/server/main.go     # Application entry point
├── go.mod                 # Go module file
├── Makefile              # Build automation
└── README.md             # This file
```

## Testing

The application includes comprehensive unit tests and integration tests following Clean Architecture principles.

### Running Tests

```bash
# Run all tests
make test

# Run tests with coverage
make test-coverage

# Run specific test packages
go test -v ./internal/domain/test
go test -v ./internal/usecases/test
go test -v ./internal/infrastructure/database/test
go test -v ./internal/interfaces/graphql/test
```

### Test Structure

The tests are organized by architectural layers:

- **Domain Tests** (`internal/domain/test/`): Test business entities and rules
- **Use Cases Tests** (`internal/usecases/test/`): Test application business logic
- **Infrastructure Tests** (`internal/infrastructure/database/test/`): Test database operations
- **Integration Tests** (`internal/interfaces/graphql/test/`): Test full GraphQL API endpoints

### Test Features

- ✅ **CRUD Operations**: All Create, Read, Update, Delete operations tested
- ✅ **Error Handling**: Tests for not found, validation errors, etc.
- ✅ **Concurrency**: Thread-safe operations tested
- ✅ **Data Persistence**: Database persistence across restarts tested
- ✅ **GraphQL Integration**: Full HTTP GraphQL API tested
- ✅ **Mock Testing**: Isolated unit tests with mocks
- ✅ **Clean Architecture**: Tests follow architectural boundaries

## Development

### Regenerating GraphQL Code

If you modify the `schema.graphql` file, regenerate the GraphQL code:

```bash
go run github.com/99designs/gqlgen generate
```

### Building

Build the application:

```bash
go build -o payments_app main.go
```

Run the binary:

```bash
./payments_app
```

## Notes

- The application uses **SQLite database** for persistent storage - data survives server restarts
- All operations are thread-safe with proper database transactions
- CORS is enabled for all origins (configure as needed for production)
- The server runs on port 8080 by default
- Database file: `payments.db` (created automatically)
- Comprehensive test suite with 85.5% code coverage

## License

This project is open source and available under the [MIT License](LICENSE).
