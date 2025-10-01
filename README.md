# 💳 Payments GraphQL API

A robust, production-ready Go + GraphQL application for managing payments with full CRUD operations, built with Clean Architecture principles and comprehensive security measures.

## 🟢 Current Status

| Component | Status | Details |
|-----------|--------|---------|
| **Application** | ✅ Running | Server active on `http://localhost:8080` |
| **Database** | ✅ Connected | SQLite with 3 sample payments |
| **Tests** | ✅ Passing | 15+ tests, all green |
| **Security** | ✅ Secured | Comprehensive .gitignore implemented |
| **API** | ✅ Functional | GraphQL playground and endpoints working |

## ✨ Features

- **🔐 Secure**: Comprehensive security measures and proper secret management
- **💾 Persistent Storage**: SQLite database with data persistence across restarts
- **🧪 Well Tested**: 15+ comprehensive tests with full coverage reporting
- **🏗️ Clean Architecture**: Proper separation of concerns and maintainable code
- **📊 GraphQL Playground**: Interactive GraphQL interface for testing
- **🌐 CORS Support**: Cross-origin resource sharing enabled
- **❤️ Health Monitoring**: Health check endpoint for monitoring
- **🔒 Security-First**: Proper .gitignore, no sensitive data in version control

## 🛠️ Tech Stack

- **Go 1.24+** - Latest Go version
- **GraphQL** with gqlgen - Type-safe GraphQL API
- **Gorilla Mux** - HTTP routing and middleware
- **SQLite** - Persistent database storage
- **GORM** - Database ORM with migrations
- **Clean Architecture** - Maintainable, testable code structure

## Quick Start

### Prerequisites

- **Go 1.24+** (latest version)
- **Git** for version control
- **SQLite3** (usually pre-installed on macOS/Linux)

### 🚀 Installation & Setup

1. **Clone the repository**:
```bash
git clone https://github.com/tinowski/payments_app.git
cd payments_app
```

2. **Install dependencies**:
```bash
make deps
# or manually:
go mod tidy
go mod download
```

3. **Build the application**:
```bash
make build
# or manually:
go build -o payments_app ./cmd/server
```

4. **Run the application**:
```bash
make run
# or manually:
./payments_app
```

🎉 **The server will start on `http://localhost:8080`**

### 🔧 Available Commands

```bash
make help                    # Show all available commands
make build                   # Build the application
make run                     # Build and run the application
make test                    # Run all tests
make test-coverage          # Run tests with coverage report
make clean                   # Clean build artifacts
make generate               # Generate GraphQL code
make fmt                    # Format code
make lint                   # Lint code
make deps                   # Install dependencies
```

## 🌐 API Endpoints

| Endpoint | Description | Method |
|----------|-------------|---------|
| **GraphQL Playground** | `http://localhost:8080/` | GET - Interactive GraphQL interface |
| **GraphQL API** | `http://localhost:8080/query` | POST - GraphQL queries and mutations |
| **Health Check** | `http://localhost:8080/health` | GET - Application health status |

### 🔍 Quick API Test

Test if the API is working:
```bash
# Health check
curl http://localhost:8080/health

# Get all payments
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{"query": "{ payments { id amount currency description status } }"}'
```

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

## 🧪 Testing

The application includes **15+ comprehensive tests** with full coverage reporting, following Clean Architecture principles.

### 🚀 Running Tests

```bash
# Run all tests
make test

# Run tests with coverage report
make test-coverage

# Run the test script
./run_tests.sh

# Run specific test packages
go test -v ./internal/domain/test
go test -v ./internal/usecases/test
go test -v ./internal/infrastructure/database/test
go test -v ./internal/interfaces/graphql/test
```

### 📊 Test Results

**✅ All Tests Passing:**
- **Domain Tests**: 4 tests - Business entities and rules
- **Database Tests**: 6 tests - Repository operations and data persistence
- **Use Case Tests**: 7 tests - Business logic and validation
- **GraphQL Tests**: 2 tests - API integration and HTTP endpoints

### 🏗️ Test Architecture

Tests are organized by Clean Architecture layers:

| Layer | Location | Tests | Purpose |
|-------|----------|-------|---------|
| **Domain** | `internal/domain/test/` | 4 tests | Business entities and rules |
| **Use Cases** | `internal/usecases/test/` | 7 tests | Application business logic |
| **Infrastructure** | `internal/infrastructure/database/test/` | 6 tests | Database operations |
| **Interfaces** | `internal/interfaces/graphql/test/` | 2 tests | GraphQL API endpoints |

### ✅ Test Coverage

- **CRUD Operations**: All Create, Read, Update, Delete operations tested
- **Error Handling**: Validation errors, not found scenarios tested
- **Data Persistence**: SQLite database persistence across restarts
- **GraphQL Integration**: Full HTTP GraphQL API with real database
- **Clean Architecture**: Tests respect architectural boundaries
- **Thread Safety**: Concurrent operations tested

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

## 🔒 Security Features

### ✅ Security Measures Implemented

- **🔐 Comprehensive .gitignore**: All sensitive files properly excluded from version control
- **💾 Database Security**: SQLite database with proper file permissions
- **🚫 No Secrets in Code**: Environment-based configuration for sensitive data
- **🛡️ Input Validation**: Proper validation for all GraphQL inputs
- **🔍 Error Handling**: Secure error messages without sensitive data exposure

### 🚨 Security Checklist

- ✅ Database files excluded from git
- ✅ Binary files excluded from git
- ✅ Environment files excluded from git
- ✅ Log files excluded from git
- ✅ Temporary files excluded from git
- ✅ IDE files excluded from git
- ✅ Payment-specific sensitive files excluded

## 📁 Database

### 💾 SQLite Database

- **Location**: `payments.db` (in project root)
- **Type**: SQLite 3.x database
- **Persistence**: Data survives server restarts
- **Thread Safety**: All operations are thread-safe
- **Size**: ~16KB (grows with data)

### 🔍 Accessing the Database

```bash
# Command line access
sqlite3 payments.db

# View all tables
.tables

# View payments
SELECT * FROM payments;

# View schema
.schema payments
```

### 📊 Current Data

The database contains sample payment data:
- **3 payments** with different statuses
- **Multiple currencies** (USD, EUR)
- **Various amounts** and descriptions
- **Timestamps** for created/updated dates

## 🚀 Production Notes

- **Port**: 8080 (configurable via environment)
- **CORS**: Enabled for all origins (configure for production)
- **Database**: SQLite (consider PostgreSQL for production)
- **Logging**: Structured logging with different levels
- **Health Check**: Available at `/health` endpoint
- **GraphQL Playground**: Disable in production

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Submit a pull request

## 📞 Support

For questions or issues, please open an issue on GitHub or contact the maintainers.
