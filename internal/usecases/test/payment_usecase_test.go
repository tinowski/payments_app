package usecases_test

import (
	"context"
	"errors"
	"payments_app/internal/domain"
	"payments_app/internal/usecases"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// MockPaymentRepository is a mock implementation of PaymentRepository
type MockPaymentRepository struct {
	payments map[string]*domain.Payment
}

func NewMockPaymentRepository() *MockPaymentRepository {
	return &MockPaymentRepository{
		payments: make(map[string]*domain.Payment),
	}
}

func (m *MockPaymentRepository) Create(ctx context.Context, payment *domain.Payment) error {
	m.payments[payment.ID] = payment
	return nil
}

func (m *MockPaymentRepository) GetByID(ctx context.Context, id string) (*domain.Payment, error) {
	payment, exists := m.payments[id]
	if !exists {
		return nil, errors.New("payment not found")
	}
	return payment, nil
}

func (m *MockPaymentRepository) GetAll(ctx context.Context) ([]*domain.Payment, error) {
	payments := make([]*domain.Payment, 0, len(m.payments))
	for _, payment := range m.payments {
		payments = append(payments, payment)
	}
	return payments, nil
}

func (m *MockPaymentRepository) Update(ctx context.Context, payment *domain.Payment) error {
	_, exists := m.payments[payment.ID]
	if !exists {
		return errors.New("payment not found")
	}
	m.payments[payment.ID] = payment
	return nil
}

func (m *MockPaymentRepository) Delete(ctx context.Context, id string) error {
	_, exists := m.payments[id]
	if !exists {
		return errors.New("payment not found")
	}
	delete(m.payments, id)
	return nil
}

func TestPaymentUseCase_CreatePayment(t *testing.T) {
	repo := NewMockPaymentRepository()
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
	repo := NewMockPaymentRepository()
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
	repo := NewMockPaymentRepository()
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
	repo := NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	_, err := useCase.GetPayment(context.Background(), "non-existent-id")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}

func TestPaymentUseCase_GetAllPayments(t *testing.T) {
	repo := NewMockPaymentRepository()
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
	repo := NewMockPaymentRepository()
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
	repo := NewMockPaymentRepository()
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