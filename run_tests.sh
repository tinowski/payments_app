#!/bin/bash

echo "🧪 Running Payments API Tests"
echo "=============================="

# Run all tests
echo "📊 Running all tests..."
go test -v ./graph/...

echo ""
echo "📈 Running tests with coverage..."
go test -v -cover ./graph/...

echo ""
echo "📊 Running tests with coverage report..."
go test -v -coverprofile=coverage.out ./graph/...
go tool cover -html=coverage.out -o coverage.html

echo ""
echo "✅ Tests completed!"
echo "📄 Coverage report generated: coverage.html"
