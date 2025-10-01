package domain_test

import (
	"payments_app/internal/domain"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestPayment_IDUniqueness(t *testing.T) {
	// Test that multiple payments have unique IDs
	ids := make(map[string]bool)

	for i := 0; i < 1000; i++ {
		payment := domain.NewPayment(100.0, "USD", "Test payment")

		// Check that ID is not empty
		assert.NotEmpty(t, payment.ID, "Payment ID should not be empty")

		// Check that ID is unique
		assert.False(t, ids[payment.ID], "Payment ID should be unique: %s", payment.ID)
		ids[payment.ID] = true
	}

	assert.Len(t, ids, 1000, "Should have generated 1000 unique IDs")
}

func TestPayment_IDUniquenessConcurrent(t *testing.T) {
	// Test ID uniqueness in concurrent scenarios
	const numGoroutines = 100
	const paymentsPerGoroutine = 10

	ids := make(map[string]bool)
	var mu sync.Mutex
	var wg sync.WaitGroup

	for i := 0; i < numGoroutines; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()

			for j := 0; j < paymentsPerGoroutine; j++ {
				payment := domain.NewPayment(100.0, "USD", "Test payment")

				mu.Lock()
				// Check that ID is unique
				assert.False(t, ids[payment.ID], "Payment ID should be unique: %s", payment.ID)
				ids[payment.ID] = true
				mu.Unlock()
			}
		}()
	}

	wg.Wait()

	expectedCount := numGoroutines * paymentsPerGoroutine
	assert.Len(t, ids, expectedCount, "Should have generated %d unique IDs", expectedCount)
}

func TestPayment_IDFormat(t *testing.T) {
	// Test ID format and characteristics
	payment := domain.NewPayment(100.0, "USD", "Test payment")

	// Check that ID is not empty
	assert.NotEmpty(t, payment.ID, "Payment ID should not be empty")

	// Check that ID has reasonable length (assuming UUID format)
	assert.GreaterOrEqual(t, len(payment.ID), 10, "Payment ID should be at least 10 characters long")
	assert.LessOrEqual(t, len(payment.ID), 50, "Payment ID should be at most 50 characters long")

	// Check that ID contains only valid characters (alphanumeric and hyphens)
	for _, char := range payment.ID {
		assert.True(t,
			(char >= 'a' && char <= 'z') ||
				(char >= 'A' && char <= 'Z') ||
				(char >= '0' && char <= '9') ||
				char == '-',
			"Payment ID should contain only alphanumeric characters and hyphens: %s", payment.ID)
	}
}

func TestPayment_IDConsistency(t *testing.T) {
	// Test that ID remains consistent
	payment := domain.NewPayment(100.0, "USD", "Test payment")
	originalID := payment.ID

	// Update payment details
	payment.UpdateDetails(200.0, "EUR", "Updated payment")

	// ID should remain the same
	assert.Equal(t, originalID, payment.ID, "Payment ID should remain consistent after updates")

	// Update status
	payment.UpdateStatus(domain.PaymentStatusCompleted)

	// ID should still remain the same
	assert.Equal(t, originalID, payment.ID, "Payment ID should remain consistent after status updates")
}

func TestPayment_IDGenerationSpeed(t *testing.T) {
	// Test ID generation speed
	start := time.Now()

	for i := 0; i < 1000; i++ {
		domain.NewPayment(100.0, "USD", "Test payment")
	}

	elapsed := time.Since(start)

	// ID generation should be fast (less than 1 second for 1000 payments)
	assert.Less(t, elapsed, time.Second, "ID generation should be fast: %v", elapsed)

	// Average time per ID should be reasonable
	avgTime := elapsed / 1000
	assert.Less(t, avgTime, time.Millisecond, "Average ID generation time should be less than 1ms: %v", avgTime)
}

func TestPayment_IDWithDifferentInputs(t *testing.T) {
	// Test that different inputs generate different IDs
	ids := make(map[string]bool)

	testCases := []struct {
		amount      float64
		currency    string
		description string
	}{
		{100.0, "USD", "Test payment 1"},
		{200.0, "USD", "Test payment 1"}, // Same description, different amount
		{100.0, "EUR", "Test payment 1"}, // Same amount, different currency
		{100.0, "USD", "Test payment 2"}, // Same amount and currency, different description
		{100.0, "USD", "Test payment 1"}, // Same inputs as first
	}

	for i, tc := range testCases {
		payment := domain.NewPayment(tc.amount, tc.currency, tc.description)

		// Check that ID is unique
		assert.False(t, ids[payment.ID], "Payment ID should be unique for test case %d: %s", i, payment.ID)
		ids[payment.ID] = true
	}

	assert.Len(t, ids, len(testCases), "Should have generated unique IDs for all test cases")
}
