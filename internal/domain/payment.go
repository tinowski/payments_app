package domain

import (
	"time"

	"github.com/google/uuid"
)

// PaymentStatus represents the status of a payment
type PaymentStatus string

const (
	PaymentStatusPending   PaymentStatus = "PENDING"
	PaymentStatusCompleted PaymentStatus = "COMPLETED"
	PaymentStatusFailed    PaymentStatus = "FAILED"
	PaymentStatusCancelled PaymentStatus = "CANCELLED"
)

// Payment represents a payment entity in the domain
type Payment struct {
	ID          string        `json:"id"`
	Amount      float64       `json:"amount"`
	Currency    string        `json:"currency"`
	Description string        `json:"description"`
	Status      PaymentStatus `json:"status"`
	CreatedAt   time.Time     `json:"createdAt"`
	UpdatedAt   time.Time     `json:"updatedAt"`
}

// NewPayment creates a new payment with generated ID and timestamps
// Note: This function expects pre-normalized data (trimmed, validated) from the use case layer
func NewPayment(amount float64, currency, description string) *Payment {
	now := time.Now()
	return &Payment{
		ID:          uuid.New().String(),
		Amount:      amount,
		Currency:    currency,
		Description: description,
		Status:      PaymentStatusPending,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
}

// UpdateStatus updates the payment status and timestamp
func (p *Payment) UpdateStatus(status PaymentStatus) {
	p.Status = status
	p.UpdatedAt = time.Now()
}

// UpdateDetails updates payment details and timestamp
func (p *Payment) UpdateDetails(amount float64, currency, description string) {
	p.Amount = amount
	p.Currency = currency
	p.Description = description
	p.UpdatedAt = time.Now()
}
