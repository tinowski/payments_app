package domain_test

import (
	"payments_app/internal/domain"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestNewPayment(t *testing.T) {
	payment := domain.NewPayment(100.50, "USD", "Test payment")

	assert.NotEmpty(t, payment.ID)
	assert.Equal(t, 100.50, payment.Amount)
	assert.Equal(t, "USD", payment.Currency)
	assert.Equal(t, "Test payment", payment.Description)
	assert.Equal(t, domain.PaymentStatusPending, payment.Status)
	assert.False(t, payment.CreatedAt.IsZero())
	assert.False(t, payment.UpdatedAt.IsZero())
}

func TestPayment_UpdateStatus(t *testing.T) {
	payment := domain.NewPayment(100.50, "USD", "Test payment")
	originalUpdatedAt := payment.UpdatedAt

	payment.UpdateStatus(domain.PaymentStatusCompleted)

	assert.Equal(t, domain.PaymentStatusCompleted, payment.Status)
	assert.True(t, payment.UpdatedAt.After(originalUpdatedAt))
}

func TestPayment_UpdateDetails(t *testing.T) {
	payment := domain.NewPayment(100.50, "USD", "Test payment")
	originalUpdatedAt := payment.UpdatedAt

	payment.UpdateDetails(200.75, "EUR", "Updated payment")

	assert.Equal(t, 200.75, payment.Amount)
	assert.Equal(t, "EUR", payment.Currency)
	assert.Equal(t, "Updated payment", payment.Description)
	assert.True(t, payment.UpdatedAt.After(originalUpdatedAt))
}

func TestPaymentStatus_Constants(t *testing.T) {
	assert.Equal(t, domain.PaymentStatus("PENDING"), domain.PaymentStatusPending)
	assert.Equal(t, domain.PaymentStatus("COMPLETED"), domain.PaymentStatusCompleted)
	assert.Equal(t, domain.PaymentStatus("FAILED"), domain.PaymentStatusFailed)
	assert.Equal(t, domain.PaymentStatus("CANCELLED"), domain.PaymentStatusCancelled)
}
