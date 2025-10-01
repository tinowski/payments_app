package graphql_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"payments_app/graph/generated"
	"payments_app/internal/infrastructure/database"
	"payments_app/internal/interfaces/graphql"
	"payments_app/internal/usecases"
	"testing"

	"github.com/99designs/gqlgen/graphql/handler"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupIntegrationTest(t *testing.T) (*httptest.Server, func()) {
	// Create a test database
	dbPath := "integration_test.db"
	repo, err := database.NewPaymentRepository(dbPath)
	require.NoError(t, err)

	// Initialize use cases
	paymentUseCase := usecases.NewPaymentUseCase(repo)

	// Initialize GraphQL resolver
	resolver := graphql.NewResolver(paymentUseCase)

	// Create GraphQL handler
	srv := handler.NewDefaultServer(generated.NewExecutableSchema(generated.Config{Resolvers: resolver}))

	// Create test server
	ts := httptest.NewServer(srv)

	cleanup := func() {
		ts.Close()
		repo.Close()
		os.Remove(dbPath)
	}

	return ts, cleanup
}

func TestGraphQLIntegration_CreatePayment(t *testing.T) {
	ts, cleanup := setupIntegrationTest(t)
	defer cleanup()

	query := `
		mutation {
			createPayment(input: {
				amount: 100.50
				currency: "USD"
				description: "Integration test payment"
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
	`

	reqBody := map[string]interface{}{
		"query": query,
	}

	jsonBody, err := json.Marshal(reqBody)
	require.NoError(t, err)

	resp, err := http.Post(ts.URL, "application/json", bytes.NewBuffer(jsonBody))
	require.NoError(t, err)
	defer resp.Body.Close()

	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var result map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&result)
	require.NoError(t, err)

	// Check for errors
	if errors, exists := result["errors"]; exists {
		t.Fatalf("GraphQL errors: %v", errors)
	}

	// Verify response structure
	data, exists := result["data"].(map[string]interface{})
	require.True(t, exists)

	payment, exists := data["createPayment"].(map[string]interface{})
	require.True(t, exists)

	assert.NotEmpty(t, payment["id"])
	assert.Equal(t, 100.5, payment["amount"])
	assert.Equal(t, "USD", payment["currency"])
	assert.Equal(t, "Integration test payment", payment["description"])
	assert.Equal(t, "PENDING", payment["status"])
	assert.NotEmpty(t, payment["createdAt"])
	assert.NotEmpty(t, payment["updatedAt"])
}

func TestGraphQLIntegration_GetAllPayments(t *testing.T) {
	ts, cleanup := setupIntegrationTest(t)
	defer cleanup()

	// First create a payment
	createQuery := `
		mutation {
			createPayment(input: {
				amount: 200.0
				currency: "EUR"
				description: "Test payment for query"
			}) {
				id
			}
		}
	`

	createReqBody := map[string]interface{}{
		"query": createQuery,
	}

	createJsonBody, err := json.Marshal(createReqBody)
	require.NoError(t, err)

	createResp, err := http.Post(ts.URL, "application/json", bytes.NewBuffer(createJsonBody))
	require.NoError(t, err)
	createResp.Body.Close()

	// Now query all payments
	query := `
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
	`

	reqBody := map[string]interface{}{
		"query": query,
	}

	jsonBody, err := json.Marshal(reqBody)
	require.NoError(t, err)

	resp, err := http.Post(ts.URL, "application/json", bytes.NewBuffer(jsonBody))
	require.NoError(t, err)
	defer resp.Body.Close()

	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var result map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&result)
	require.NoError(t, err)

	// Check for errors
	if errors, exists := result["errors"]; exists {
		t.Fatalf("GraphQL errors: %v", errors)
	}

	// Verify response structure
	data, exists := result["data"].(map[string]interface{})
	require.True(t, exists)

	payments, exists := data["payments"].([]interface{})
	require.True(t, exists)
	assert.Len(t, payments, 1)

	payment := payments[0].(map[string]interface{})
	assert.NotEmpty(t, payment["id"])
	assert.Equal(t, 200.0, payment["amount"])
	assert.Equal(t, "EUR", payment["currency"])
	assert.Equal(t, "Test payment for query", payment["description"])
	assert.Equal(t, "PENDING", payment["status"])
}
