package helpers

import (
	"context"
	"errors"
	"payments_app/internal/domain"
	"time"
)

// MockPaymentRepository is a mock implementation of PaymentRepository for testing
type MockPaymentRepository struct {
	payments map[string]*domain.Payment
}

// NewMockPaymentRepository creates a new mock payment repository
func NewMockPaymentRepository() *MockPaymentRepository {
	return &MockPaymentRepository{
		payments: make(map[string]*domain.Payment),
	}
}

// Create adds a payment to the mock repository
func (m *MockPaymentRepository) Create(ctx context.Context, payment *domain.Payment) error {
	m.payments[payment.ID] = payment
	return nil
}

// GetByID retrieves a payment by ID from the mock repository
func (m *MockPaymentRepository) GetByID(ctx context.Context, id string) (*domain.Payment, error) {
	payment, exists := m.payments[id]
	if !exists {
		return nil, errors.New("payment not found")
	}
	return payment, nil
}

// GetAll retrieves all payments from the mock repository
func (m *MockPaymentRepository) GetAll(ctx context.Context) ([]*domain.Payment, error) {
	payments := make([]*domain.Payment, 0, len(m.payments))
	for _, payment := range m.payments {
		payments = append(payments, payment)
	}
	return payments, nil
}

// Update updates a payment in the mock repository
func (m *MockPaymentRepository) Update(ctx context.Context, payment *domain.Payment) error {
	_, exists := m.payments[payment.ID]
	if !exists {
		return errors.New("payment not found")
	}
	m.payments[payment.ID] = payment
	return nil
}

// Delete removes a payment from the mock repository
func (m *MockPaymentRepository) Delete(ctx context.Context, id string) error {
	_, exists := m.payments[id]
	if !exists {
		return errors.New("payment not found")
	}
	delete(m.payments, id)
	return nil
}

// TestData provides common test data for all tests
type TestData struct {
	ValidPaymentInput   domain.Payment
	InvalidPaymentInput domain.Payment
	TestCurrencies      []string
	TestStatuses        []domain.PaymentStatus
}

// GetTestData returns common test data
func GetTestData() *TestData {
	return &TestData{
		ValidPaymentInput: domain.Payment{
			ID:          "test-payment-id",
			Amount:      100.50,
			Currency:    "USD",
			Description: "Test payment",
			Status:      domain.PaymentStatusPending,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		},
		InvalidPaymentInput: domain.Payment{
			ID:          "invalid-payment-id",
			Amount:      -100.50, // Invalid negative amount
			Currency:    "",      // Invalid empty currency
			Description: "",      // Invalid empty description
			Status:      domain.PaymentStatusPending,
			CreatedAt:   time.Now(),
			UpdatedAt:   time.Now(),
		},
		TestCurrencies: []string{"USD", "EUR", "GBP", "JPY"},
		TestStatuses: []domain.PaymentStatus{
			domain.PaymentStatusPending,
			domain.PaymentStatusCompleted,
			domain.PaymentStatusFailed,
			domain.PaymentStatusCancelled,
		},
	}
}

// CreateTestPayment creates a test payment with the given parameters
func CreateTestPayment(id, currency, description string, amount float64, status domain.PaymentStatus) *domain.Payment {
	return &domain.Payment{
		ID:          id,
		Amount:      amount,
		Currency:    currency,
		Description: description,
		Status:      status,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}
