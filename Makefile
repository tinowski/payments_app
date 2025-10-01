.PHONY: build run test clean docker-build docker-run help

# Variables
BINARY_NAME=payments_app
DOCKER_IMAGE=payments-api
DOCKER_TAG=latest

# Build the application
build:
	@echo "Building $(BINARY_NAME)..."
	go build -o $(BINARY_NAME) ./cmd/server

# Run the application
run: build
	@echo "Running $(BINARY_NAME)..."
	./$(BINARY_NAME)

# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Run unit tests only
test-unit:
	@echo "Running unit tests..."
	go test -v ./tests/unit/...

# Run integration tests only
test-integration:
	@echo "Running integration tests..."
	go test -v ./tests/integration/...

# Run E2E tests only
test-e2e:
	@echo "Running E2E tests..."
	go test -v ./tests/e2e/...

# Run all tests with new structure
test-all:
	@echo "Running all tests with new structure..."
	go test -v ./tests/unit/... ./tests/integration/... ./tests/e2e/...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -cover ./...
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html

# Run tests with coverage (new structure)
test-coverage-new:
	@echo "Running tests with coverage (new structure)..."
	go test -v -cover ./tests/unit/... ./tests/integration/... ./tests/e2e/...
	go test -coverprofile=coverage.out ./tests/unit/... ./tests/integration/... ./tests/e2e/...
	go tool cover -html=coverage.out -o coverage.html

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -f $(BINARY_NAME)
	rm -f coverage.out coverage.html
	rm -f *.db

# Docker build
docker-build:
	@echo "Building Docker image..."
	docker build -f deployments/docker/Dockerfile -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

# Docker run
docker-run: docker-build
	@echo "Running Docker container..."
	docker run -p 8080:8080 $(DOCKER_IMAGE):$(DOCKER_TAG)

# Docker compose up
docker-compose-up:
	@echo "Starting services with Docker Compose..."
	cd deployments/docker && docker-compose up -d

# Docker compose down
docker-compose-down:
	@echo "Stopping services with Docker Compose..."
	cd deployments/docker && docker-compose down

# Generate GraphQL code
generate:
	@echo "Generating GraphQL code..."
	go run github.com/99designs/gqlgen generate

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Lint code
lint:
	@echo "Linting code..."
	golangci-lint run

# Install dependencies
deps:
	@echo "Installing dependencies..."
	go mod tidy
	go mod download

# Help
help:
	@echo "Available commands:"
	@echo "  build           - Build the application"
	@echo "  run             - Build and run the application"
	@echo "  test            - Run all tests (legacy)"
	@echo "  test-unit       - Run unit tests only"
	@echo "  test-integration - Run integration tests only"
	@echo "  test-e2e        - Run E2E tests only"
	@echo "  test-all        - Run all tests with new structure"
	@echo "  test-coverage   - Run tests with coverage report (legacy)"
	@echo "  test-coverage-new - Run tests with coverage report (new structure)"
	@echo "  clean           - Clean build artifacts"
	@echo "  docker-build    - Build Docker image"
	@echo "  docker-run      - Build and run Docker container"
	@echo "  docker-compose-up   - Start services with Docker Compose"
	@echo "  docker-compose-down - Stop services with Docker Compose"
	@echo "  generate        - Generate GraphQL code"
	@echo "  fmt             - Format code"
	@echo "  lint            - Lint code"
	@echo "  deps            - Install dependencies"
	@echo "  help            - Show this help message"
