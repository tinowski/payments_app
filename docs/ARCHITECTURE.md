# Architecture Overview

This project follows Clean Architecture principles with clear separation of concerns.

## Directory Structure

```
payments_app/
├── cmd/                    # Application entry points
│   └── server/            # Main server application
├── internal/              # Private application code
│   ├── domain/            # Business entities and rules
│   ├── usecases/          # Application business logic
│   ├── interfaces/        # External interfaces (GraphQL, REST)
│   └── infrastructure/    # External concerns (database, external APIs)
├── pkg/                   # Public library code
│   ├── logger/            # Logging utilities
│   └── utils/             # Common utilities
├── api/                   # API definitions
│   ├── graphql/           # GraphQL schema and resolvers
│   └── rest/              # REST API definitions
├── configs/               # Configuration files
├── scripts/               # Build and deployment scripts
├── docs/                  # Documentation
├── deployments/           # Deployment configurations
│   ├── docker/            # Docker configurations
│   └── kubernetes/        # Kubernetes configurations
└── migrations/            # Database migrations
```

## Architecture Layers

### 1. Domain Layer (`internal/domain/`)
- **Purpose**: Contains business entities and rules
- **Dependencies**: None (pure business logic)
- **Files**:
  - `payment.go` - Payment entity and business rules
  - `repository.go` - Repository interface definitions

### 2. Use Cases Layer (`internal/usecases/`)
- **Purpose**: Application business logic and orchestration
- **Dependencies**: Domain layer only
- **Files**:
  - `payment_usecase.go` - Payment business logic

### 3. Interface Layer (`internal/interfaces/`)
- **Purpose**: External interfaces (GraphQL, REST, CLI)
- **Dependencies**: Domain and Use Cases layers
- **Files**:
  - `graphql/resolver.go` - GraphQL resolvers

### 4. Infrastructure Layer (`internal/infrastructure/`)
- **Purpose**: External concerns (database, external APIs)
- **Dependencies**: Domain layer only
- **Files**:
  - `database/payment_repository.go` - Database implementation

## Design Principles

### 1. Dependency Inversion
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)

### 2. Single Responsibility
- Each layer has a single, well-defined responsibility
- Classes and functions have one reason to change

### 3. Open/Closed Principle
- Open for extension, closed for modification
- New features can be added without changing existing code

### 4. Interface Segregation
- Clients shouldn't depend on interfaces they don't use
- Small, focused interfaces

## Data Flow

1. **Request** → GraphQL Resolver
2. **Resolver** → Use Case
3. **Use Case** → Repository Interface
4. **Repository** → Database Implementation
5. **Response** ← GraphQL Resolver

## Benefits

- **Testability**: Easy to unit test each layer in isolation
- **Maintainability**: Clear separation makes code easier to maintain
- **Flexibility**: Easy to swap implementations (e.g., different databases)
- **Scalability**: Each layer can be scaled independently
- **Team Development**: Different teams can work on different layers
