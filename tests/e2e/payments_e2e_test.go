package e2e_test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	baseURL = "http://localhost:8080"
)

// TestPaymentE2E_CompleteFlow tests the complete payment flow from creation to deletion
func TestPaymentE2E_CompleteFlow(t *testing.T) {
	// Skip if server is not running
	if !isServerRunning() {
		t.Skip("Server is not running, skipping E2E test")
	}

	// Test 1: Health check
	t.Run("HealthCheck", func(t *testing.T) {
		resp, err := http.Get(baseURL + "/health")
		require.NoError(t, err)
		defer resp.Body.Close()

		assert.Equal(t, http.StatusOK, resp.StatusCode)
	})

	// Test 2: Create a payment
	var paymentID string
	t.Run("CreatePayment", func(t *testing.T) {
		query := `
			mutation {
				createPayment(input: {
					amount: 150.75
					currency: "USD"
					description: "E2E test payment"
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

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		payment := resp["data"].(map[string]interface{})["createPayment"].(map[string]interface{})
		paymentID = payment["id"].(string)

		assert.NotEmpty(t, paymentID)
		assert.Equal(t, 150.75, payment["amount"])
		assert.Equal(t, "USD", payment["currency"])
		assert.Equal(t, "E2E test payment", payment["description"])
		assert.Equal(t, "PENDING", payment["status"])
		assert.NotEmpty(t, payment["createdAt"])
		assert.NotEmpty(t, payment["updatedAt"])
	})

	// Test 3: Get all payments
	t.Run("GetAllPayments", func(t *testing.T) {
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

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		payments := resp["data"].(map[string]interface{})["payments"].([]interface{})
		assert.GreaterOrEqual(t, len(payments), 1)

		// Find our created payment
		var foundPayment map[string]interface{}
		for _, p := range payments {
			payment := p.(map[string]interface{})
			if payment["id"] == paymentID {
				foundPayment = payment
				break
			}
		}
		require.NotNil(t, foundPayment)
		assert.Equal(t, "E2E test payment", foundPayment["description"])
	})

	// Test 4: Get specific payment
	t.Run("GetPayment", func(t *testing.T) {
		query := fmt.Sprintf(`
			query {
				payment(id: "%s") {
					id
					amount
					currency
					description
					status
					createdAt
					updatedAt
				}
			}
		`, paymentID)

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		payment := resp["data"].(map[string]interface{})["payment"].(map[string]interface{})
		assert.Equal(t, paymentID, payment["id"])
		assert.Equal(t, "E2E test payment", payment["description"])
	})

	// Test 5: Update payment
	t.Run("UpdatePayment", func(t *testing.T) {
		// Wait a bit to ensure timestamp difference
		time.Sleep(10 * time.Millisecond)

		query := fmt.Sprintf(`
			mutation {
				updatePayment(input: {
					id: "%s"
					amount: 200.00
					status: COMPLETED
					description: "Updated E2E test payment"
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
		`, paymentID)

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		payment := resp["data"].(map[string]interface{})["updatePayment"].(map[string]interface{})
		assert.Equal(t, paymentID, payment["id"])
		assert.Equal(t, 200.0, payment["amount"])
		assert.Equal(t, "Updated E2E test payment", payment["description"])
		assert.Equal(t, "COMPLETED", payment["status"])
	})

	// Test 6: Delete payment
	t.Run("DeletePayment", func(t *testing.T) {
		query := fmt.Sprintf(`
			mutation {
				deletePayment(id: "%s")
			}
		`, paymentID)

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		deleted := resp["data"].(map[string]interface{})["deletePayment"].(bool)
		assert.True(t, deleted)
	})

	// Test 7: Verify payment is deleted
	t.Run("VerifyPaymentDeleted", func(t *testing.T) {
		query := fmt.Sprintf(`
			query {
				payment(id: "%s") {
					id
				}
			}
		`, paymentID)

		resp := makeGraphQLRequest(t, query)
		// This should return null for deleted payment
		payment := resp["data"].(map[string]interface{})["payment"]
		assert.Nil(t, payment)
	})
}

// TestPaymentE2E_ErrorHandling tests error scenarios
func TestPaymentE2E_ErrorHandling(t *testing.T) {
	if !isServerRunning() {
		t.Skip("Server is not running, skipping E2E test")
	}

	// Test invalid payment creation
	t.Run("CreateInvalidPayment", func(t *testing.T) {
		query := `
			mutation {
				createPayment(input: {
					amount: -100.0
					currency: ""
					description: ""
				}) {
					id
				}
			}
		`

		resp := makeGraphQLRequest(t, query)
		// Should have errors
		assert.NotNil(t, resp["errors"])
	})

	// Test getting non-existent payment
	t.Run("GetNonExistentPayment", func(t *testing.T) {
		query := `
			query {
				payment(id: "non-existent-id") {
					id
				}
			}
		`

		resp := makeGraphQLRequest(t, query)
		require.Nil(t, resp["errors"])

		payment := resp["data"].(map[string]interface{})["payment"]
		assert.Nil(t, payment)
	})
}

// Helper functions

func isServerRunning() bool {
	resp, err := http.Get(baseURL + "/health")
	if err != nil {
		return false
	}
	defer resp.Body.Close()
	return resp.StatusCode == http.StatusOK
}

func makeGraphQLRequest(t *testing.T, query string) map[string]interface{} {
	reqBody := map[string]interface{}{
		"query": query,
	}

	jsonBody, err := json.Marshal(reqBody)
	require.NoError(t, err)

	resp, err := http.Post(baseURL+"/query", "application/json", bytes.NewBuffer(jsonBody))
	require.NoError(t, err)
	defer resp.Body.Close()

	assert.Equal(t, http.StatusOK, resp.StatusCode)

	var result map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&result)
	require.NoError(t, err)

	return result
}
