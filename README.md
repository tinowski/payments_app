# 💳 Payments GraphQL API

A robust, production-ready Go + GraphQL application for managing payments with full CRUD operations, built with Clean Architecture principles and comprehensive security measures.

## 🟢 Current Status

| Component | Status | Details |
|-----------|--------|---------|
| **Application** | ✅ Running | Server active on `http://localhost:8080` |
| **Database** | ✅ Connected | SQLite with 50+ sample payments |
| **Tests** | ✅ Passing | 50+ comprehensive tests, all green |
| **Security** | ✅ Secured | Comprehensive .gitignore and privacy protection |
| **API** | ✅ Functional | GraphQL playground and endpoints working |
| **Validation** | ✅ Comprehensive | Advanced validation with edge cases and security |
| **Test Coverage** | ✅ Extensive | Currency, ID uniqueness, input validation, concurrent testing |

## ✨ Features

- **🔐 Secure**: Comprehensive security measures and proper secret management
- **💾 Persistent Storage**: SQLite database with data persistence across restarts
- **🧪 Well Tested**: 50+ comprehensive tests with extensive validation and edge case testing
- **🏗️ Clean Architecture**: Proper separation of concerns and maintainable code
- **📊 GraphQL Playground**: Interactive GraphQL interface for testing
- **🌐 CORS Support**: Cross-origin resource sharing enabled
- **❤️ Health Monitoring**: Health check endpoint for monitoring
- **🔒 Security-First**: Proper .gitignore, no sensitive data in version control
- **🌍 Internationalization**: Multi-currency support with comprehensive validation
- **🆔 Unique IDs**: Guaranteed unique ID generation with concurrent testing
- **✅ Advanced Validation**: Input validation, security testing, boundary conditions
- **⚡ Performance**: Optimized for speed with comprehensive test coverage

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
make test                    # Run all tests (legacy)
make test-unit              # Run unit tests only
make test-integration       # Run integration tests only
make test-e2e               # Run E2E tests only
make test-all               # Run all tests with new structure
make test-coverage          # Run tests with coverage report (legacy)
make test-coverage-new      # Run tests with coverage report (new structure)
make robot-install          # Install Robot Framework dependencies
make robot-test             # Run all Robot Framework tests
make robot-smoke            # Run Robot Framework smoke tests
make robot-crud             # Run Robot Framework CRUD tests
make robot-validation       # Run Robot Framework validation tests
make robot-performance      # Run Robot Framework performance tests
make robot-clean            # Clean Robot Framework results
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
│   │   └── repository.go  # Repository interfaces
│   ├── usecases/          # Application business logic
│   │   └── payment_usecase.go # Payment use cases
│   ├── interfaces/        # External interfaces (GraphQL, REST)
│   │   └── graphql/       # GraphQL resolvers
│   │       └── graphql_resolver.go
│   └── infrastructure/    # External concerns (database, external APIs)
│       └── database/      # Database implementation
│           └── payment_repository.go
├── tests/                 # Organized test suite
│   ├── unit/              # Unit tests (isolated, fast)
│   │   ├── domain/        # Domain entity tests
│   │   ├── usecases/      # Use case business logic tests
│   │   └── infrastructure/ # Database repository tests
│   ├── integration/       # Integration tests (with dependencies)
│   │   └── graphql_test.go # GraphQL API integration tests
│   ├── e2e/               # End-to-end tests (full system)
│   │   └── payments_e2e_test.go # Complete payment flow tests
│   ├── helpers/           # Shared test utilities
│   │   └── test_helpers.go # Mock repositories, test data
│   └── test_config.go     # Test configuration
├── robot_tests/          # Robot Framework API tests
│   ├── test_suites/      # Test suite files
│   │   ├── payment_crud.robot      # CRUD operation tests
│   │   ├── payment_validation.robot # Validation tests
│   │   └── performance_tests.robot # Performance tests
│   ├── resources/        # Test resources and keywords
│   │   └── api_keywords.robot      # API testing keywords
│   └── run_tests.robot   # Main test runner
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
├── graph/                 # GraphQL generated code
├── cmd/server/main.go     # Application entry point
├── go.mod                 # Go module file
├── Makefile              # Build automation
└── README.md             # This file
```

## 🧪 Testing

The application includes **50+ comprehensive tests** with full coverage reporting, following Clean Architecture principles and organized in a professional test structure with extensive validation and edge case testing.

### 🤖 Robot Framework API Testing

In addition to Go unit tests, the application includes **Robot Framework** for comprehensive API testing:

- **📊 API Testing**: Complete GraphQL API test coverage
- **🔍 Validation Testing**: Input validation and error handling
- **⚡ Performance Testing**: Response time and load testing
- **🧪 CRUD Testing**: Complete payment lifecycle testing
- **📈 Reporting**: HTML reports with detailed test results

### 📁 Test Organization

Tests are organized by type and purpose for better maintainability:

```
tests/
├── unit/                           # Unit tests (isolated, fast)
│   ├── domain/                    # Domain entity tests
│   │   ├── domain_test.go         # Basic domain tests (4 tests)
│   │   ├── currency_validation_test.go # Currency validation (15+ tests)
│   │   └── id_uniqueness_test.go  # ID uniqueness & format (8+ tests)
│   ├── usecases/                  # Use case business logic tests
│   │   ├── usecases_test.go       # Basic use case tests (7 tests)
│   │   └── validation_test.go     # Advanced validation (20+ tests)
│   └── infrastructure/            # Database repository tests
│       └── infrastructure_test.go # Database operations (6 tests)
├── integration/                   # Integration tests (with dependencies)
│   └── graphql_test.go           # GraphQL API integration tests (2 tests)
├── e2e/                          # End-to-end tests (full system)
│   └── payments_e2e_test.go      # Complete payment flow tests (7 tests)
├── helpers/                      # Shared test utilities
│   └── test_helpers.go           # Mock repositories, test data
└── test_config.go               # Test configuration
```

### 🚀 Running Tests

```bash
# Run all tests (legacy)
make test

# Run unit tests only
make test-unit

# Run integration tests only
make test-integration

# Run E2E tests only (requires running server)
make test-e2e

# Run all tests with new structure
make test-all

# Run tests with coverage report
make test-coverage-new

# Use the organized test script
./run_tests_organized.sh

# Run specific test categories
go test ./tests/unit/... -v
go test ./tests/integration/... -v
go test ./tests/e2e/... -v
```

### 📊 Test Results

**✅ All Tests Passing:**
- **Unit Tests**: 50+ tests - Fast, isolated tests with comprehensive validation
- **Integration Tests**: 2 tests - Tests with real dependencies (database, GraphQL)
- **E2E Tests**: 7 tests - Complete user flows against running application

### 🎯 Test Coverage Details

#### **Domain Tests (27+ tests)**
- **Basic Domain**: 4 tests - Payment creation, status updates, detail updates
- **Currency Validation**: 15+ tests - Multiple currencies, case sensitivity, special characters
- **ID Uniqueness**: 8+ tests - Uniqueness, concurrent generation, format validation

#### **Use Case Tests (27+ tests)**
- **Basic Use Cases**: 7 tests - CRUD operations, validation, error handling
- **Advanced Validation**: 20+ tests - Edge cases, security, boundary conditions

#### **Infrastructure Tests (6 tests)**
- **Database Operations**: 6 tests - Create, read, update, delete with real database

#### **Integration Tests (2 tests)**
- **GraphQL API**: 2 tests - Health checks, API integration

#### **E2E Tests (7 tests)**
- **Complete Flows**: 7 tests - Full payment lifecycle from creation to deletion

### 🏗️ Test Architecture

Tests are organized by type and Clean Architecture layers:

| Test Type | Location | Tests | Purpose | Speed |
|-----------|----------|-------|---------|-------|
| **Unit Tests** | `tests/unit/` | 50+ tests | Isolated business logic with comprehensive validation | Fast (< 2s) |
| ├─ Domain | `tests/unit/domain/` | 27+ tests | Business entities, currencies, ID uniqueness | Very Fast |
| ├─ Use Cases | `tests/unit/usecases/` | 27+ tests | Business logic with advanced validation | Fast |
| └─ Infrastructure | `tests/unit/infrastructure/` | 6 tests | Database operations | Fast |
| **Integration** | `tests/integration/` | 2 tests | GraphQL API with real DB | Medium (1-5s) |
| **E2E** | `tests/e2e/` | 7 tests | Complete user flows | Slow (5-30s) |

### ✅ Test Coverage

#### **Core Functionality**
- **CRUD Operations**: All Create, Read, Update, Delete operations tested
- **Data Persistence**: SQLite database persistence across restarts
- **GraphQL Integration**: Full HTTP GraphQL API with real database
- **Clean Architecture**: Tests respect architectural boundaries
- **Thread Safety**: Concurrent operations tested

#### **Validation & Security**
- **Input Validation**: Amount, currency, description validation with edge cases
- **Error Handling**: Comprehensive error scenarios and messages
- **Security Testing**: SQL injection, XSS, and injection attack prevention
- **Boundary Conditions**: Minimum/maximum values, precision limits
- **Unicode Support**: International characters and emojis

#### **Currency & Internationalization**
- **Multiple Currencies**: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, SEK, NOK
- **Case Sensitivity**: Uppercase, lowercase, mixed case handling
- **Special Characters**: Spaces, numbers, symbols in currency codes
- **Format Validation**: Currency code format and structure

#### **ID Management**
- **Uniqueness**: 1000+ unique IDs generated and verified
- **Concurrent Generation**: Multi-threaded ID generation testing
- **Format Validation**: ID length, character requirements
- **Consistency**: ID persistence across updates and operations

#### **Advanced Features**
- **Timestamp Updates**: Comprehensive timestamp update testing
- **Field Validation**: Empty fields, whitespace, special characters
- **Edge Cases**: Very large numbers, very long strings, precision limits
- **Performance**: ID generation speed and test execution time
- **Shared Helpers**: Reusable test utilities and mock repositories

### 🎯 Test Features

#### **Professional Organization**
- **Clear Separation**: Tests organized by type (unit, integration, e2e)
- **Logical Grouping**: Tests grouped by domain (domain, usecases, infrastructure)
- **Shared Utilities**: Common test helpers and mock repositories
- **Environment Configuration**: Flexible test configuration

#### **Comprehensive Coverage**
- **Unit Tests**: Fast, isolated tests with mocked dependencies
- **Integration Tests**: Tests with real dependencies (database, GraphQL)
- **E2E Tests**: Complete user flows against running application
- **Error Scenarios**: Invalid inputs, not found cases, edge cases

#### **Advanced Validation Testing**
- **Currency Validation**: 15+ tests covering multiple currencies, case sensitivity, special characters
- **ID Uniqueness**: 8+ tests ensuring unique ID generation and format validation
- **Input Validation**: 20+ tests covering edge cases, security, and boundary conditions
- **Concurrent Testing**: Multi-threaded operations and race condition testing

#### **Developer Experience**
- **Fast Feedback**: Run only unit tests during development
- **CI/CD Ready**: Easy to integrate with build pipelines
- **Clear Commands**: Intuitive test commands for different scenarios
- **Detailed Reporting**: Comprehensive test results and coverage

### 📋 Test File Details

#### **Domain Tests**
- **`domain_test.go`**: Basic payment creation, status updates, detail updates
- **`currency_validation_test.go`**: Currency code validation, case sensitivity, special characters
- **`id_uniqueness_test.go`**: ID uniqueness, concurrent generation, format validation

#### **Use Case Tests**
- **`usecases_test.go`**: Basic CRUD operations, validation, error handling
- **`validation_test.go`**: Advanced validation, edge cases, security testing

#### **Infrastructure Tests**
- **`infrastructure_test.go`**: Database operations with real SQLite database

#### **Integration & E2E Tests**
- **`graphql_test.go`**: GraphQL API integration and health checks
- **`payments_e2e_test.go`**: Complete payment lifecycle testing

### 🚀 Test Scripts

#### **Organized Test Runner**
```bash
# Use the professional test script
./run_tests_organized.sh
```

This script provides:
- **Colorized output** with clear test results
- **Categorized execution** by test type
- **Coverage reporting** with detailed metrics
- **Result summary** with pass/fail status

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
