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

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -cover ./...
	go test -coverprofile=coverage.out ./...
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
	@echo "  test            - Run tests"
	@echo "  test-coverage   - Run tests with coverage report"
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
