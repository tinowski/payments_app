package graph

import (
	"errors"
	"payments_app/graph/model"
	"sync"
	"time"

	"github.com/google/uuid"
)

// In-memory storage for payments
type PaymentStorage struct {
	payments map[string]*model.Payment
	mutex    sync.RWMutex
}

// NewPaymentStorage creates a new payment storage instance
func NewPaymentStorage() *PaymentStorage {
	return &PaymentStorage{
		payments: make(map[string]*model.Payment),
	}
}

// CreatePayment creates a new payment
func (s *PaymentStorage) CreatePayment(input model.CreatePaymentInput) (*model.Payment, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	id := uuid.New().String()
	now := time.Now()

	payment := &model.Payment{
		ID:          id,
		Amount:      input.Amount,
		Currency:    input.Currency,
		Description: input.Description,
		Status:      model.PaymentStatusPending,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	s.payments[id] = payment
	return payment, nil
}

// GetPayment retrieves a payment by ID
func (s *PaymentStorage) GetPayment(id string) (*model.Payment, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	payment, exists := s.payments[id]
	if !exists {
		return nil, errors.New("payment not found")
	}

	return payment, nil
}

// GetAllPayments retrieves all payments
func (s *PaymentStorage) GetAllPayments() ([]*model.Payment, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	payments := make([]*model.Payment, 0, len(s.payments))
	for _, payment := range s.payments {
		payments = append(payments, payment)
	}

	return payments, nil
}

// UpdatePayment updates an existing payment
func (s *PaymentStorage) UpdatePayment(input model.UpdatePaymentInput) (*model.Payment, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	payment, exists := s.payments[input.ID]
	if !exists {
		return nil, errors.New("payment not found")
	}

	// Update fields if provided
	if input.Amount != nil {
		payment.Amount = *input.Amount
	}
	if input.Currency != nil {
		payment.Currency = *input.Currency
	}
	if input.Description != nil {
		payment.Description = *input.Description
	}
	if input.Status != nil {
		payment.Status = *input.Status
	}

	payment.UpdatedAt = time.Now()

	return payment, nil
}

// DeletePayment deletes a payment by ID
func (s *PaymentStorage) DeletePayment(id string) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	_, exists := s.payments[id]
	if !exists {
		return errors.New("payment not found")
	}

	delete(s.payments, id)
	return nil
}
