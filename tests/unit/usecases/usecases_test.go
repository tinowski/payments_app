package usecases_test

import (
	"context"
	"payments_app/internal/domain"
	"payments_app/internal/usecases"
	"payments_app/tests/helpers"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPaymentUseCase_CreatePayment(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	payment, err := useCase.CreatePayment(context.Background(), input)

	require.NoError(t, err)
	assert.NotEmpty(t, payment.ID)
	assert.Equal(t, input.Amount, payment.Amount)
	assert.Equal(t, input.Currency, payment.Currency)
	assert.Equal(t, input.Description, payment.Description)
	assert.Equal(t, domain.PaymentStatusPending, payment.Status)
}

func TestPaymentUseCase_CreatePayment_Validation(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	tests := []struct {
		name        string
		input       usecases.CreatePaymentInput
		expectedErr string
	}{
		{
			name:        "negative amount",
			input:       usecases.CreatePaymentInput{Amount: -100, Currency: "USD", Description: "Test"},
			expectedErr: "amount must be greater than 0",
		},
		{
			name:        "zero amount",
			input:       usecases.CreatePaymentInput{Amount: 0, Currency: "USD", Description: "Test"},
			expectedErr: "amount must be greater than 0",
		},
		{
			name:        "empty currency",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "", Description: "Test"},
			expectedErr: "currency is required",
		},
		{
			name:        "empty description",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: ""},
			expectedErr: "description is required",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := useCase.CreatePayment(context.Background(), tt.input)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tt.expectedErr)
		})
	}
}

func TestPaymentUseCase_GetPayment(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)

	// Retrieve the payment
	retrievedPayment, err := useCase.GetPayment(context.Background(), createdPayment.ID)

	require.NoError(t, err)
	assert.Equal(t, createdPayment.ID, retrievedPayment.ID)
	assert.Equal(t, createdPayment.Amount, retrievedPayment.Amount)
}

func TestPaymentUseCase_GetPayment_NotFound(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	_, err := useCase.GetPayment(context.Background(), "non-existent-id")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}

func TestPaymentUseCase_GetAllPayments(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create multiple payments
	payments := []usecases.CreatePaymentInput{
		{Amount: 100, Currency: "USD", Description: "Payment 1"},
		{Amount: 200, Currency: "EUR", Description: "Payment 2"},
	}

	for _, input := range payments {
		_, err := useCase.CreatePayment(context.Background(), input)
		require.NoError(t, err)
	}

	// Retrieve all payments
	allPayments, err := useCase.GetAllPayments(context.Background())

	require.NoError(t, err)
	assert.Len(t, allPayments, 2)
}

func TestPaymentUseCase_UpdatePayment(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)

	// Update the payment
	newAmount := 200.75
	newStatus := domain.PaymentStatusCompleted
	updateInput := usecases.UpdatePaymentInput{
		ID:     createdPayment.ID,
		Amount: &newAmount,
		Status: &newStatus,
	}

	updatedPayment, err := useCase.UpdatePayment(context.Background(), updateInput)

	require.NoError(t, err)
	assert.Equal(t, newAmount, updatedPayment.Amount)
	assert.Equal(t, newStatus, updatedPayment.Status)
	assert.Equal(t, createdPayment.Currency, updatedPayment.Currency) // Should remain unchanged
}

func TestPaymentUseCase_DeletePayment(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)

	// Delete the payment
	err = useCase.DeletePayment(context.Background(), createdPayment.ID)
	require.NoError(t, err)

	// Verify payment is deleted
	_, err = useCase.GetPayment(context.Background(), createdPayment.ID)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}

func TestPaymentUseCase_UpdatePayment_TimestampUpdate(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)
	originalUpdatedAt := createdPayment.UpdatedAt

	// Wait a small amount to ensure timestamp difference
	time.Sleep(10 * time.Millisecond)

	// Test 1: Update payment without status change (should update timestamp)
	newAmount := 200.75
	updateInput := usecases.UpdatePaymentInput{
		ID:     createdPayment.ID,
		Amount: &newAmount,
		// No status change - this should still update the timestamp
	}

	updatedPayment, err := useCase.UpdatePayment(context.Background(), updateInput)
	require.NoError(t, err)

	// Verify the timestamp was updated
	assert.True(t, updatedPayment.UpdatedAt.After(originalUpdatedAt),
		"UpdatedAt timestamp should be newer than original timestamp")
	assert.Equal(t, newAmount, updatedPayment.Amount)
	assert.Equal(t, createdPayment.Status, updatedPayment.Status) // Status unchanged

	// Test 2: Update payment with status change (should also update timestamp)
	time.Sleep(10 * time.Millisecond)
	secondUpdateTime := updatedPayment.UpdatedAt

	newStatus := domain.PaymentStatusCompleted
	secondUpdateInput := usecases.UpdatePaymentInput{
		ID:     createdPayment.ID,
		Status: &newStatus,
	}

	finalPayment, err := useCase.UpdatePayment(context.Background(), secondUpdateInput)
	require.NoError(t, err)

	// Verify the timestamp was updated again
	assert.True(t, finalPayment.UpdatedAt.After(secondUpdateTime),
		"UpdatedAt timestamp should be newer than previous update")
	assert.Equal(t, newStatus, finalPayment.Status)
	assert.Equal(t, newAmount, finalPayment.Amount) // Amount unchanged
}

func TestPaymentUseCase_UpdatePayment_TimestampUpdate_OnlyDescription(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Original description",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)
	originalUpdatedAt := createdPayment.UpdatedAt

	// Wait a small amount to ensure timestamp difference
	time.Sleep(10 * time.Millisecond)

	// Update only the description (no status change)
	newDescription := "Updated description"
	updateInput := usecases.UpdatePaymentInput{
		ID:          createdPayment.ID,
		Description: &newDescription,
		// No status change - this should still update the timestamp
	}

	updatedPayment, err := useCase.UpdatePayment(context.Background(), updateInput)
	require.NoError(t, err)

	// Verify the timestamp was updated
	assert.True(t, updatedPayment.UpdatedAt.After(originalUpdatedAt),
		"UpdatedAt timestamp should be newer when updating description without status change")
	assert.Equal(t, newDescription, updatedPayment.Description)
	assert.Equal(t, createdPayment.Status, updatedPayment.Status) // Status unchanged
	assert.Equal(t, createdPayment.Amount, updatedPayment.Amount) // Amount unchanged
}
