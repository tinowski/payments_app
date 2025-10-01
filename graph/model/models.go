package model

import "time"

// Payment represents a payment transaction
type Payment struct {
	ID          string        `json:"id"`
	Amount      float64       `json:"amount"`
	Currency    string        `json:"currency"`
	Description string        `json:"description"`
	Status      PaymentStatus `json:"status"`
	CreatedAt   time.Time     `json:"createdAt"`
	UpdatedAt   time.Time     `json:"updatedAt"`
}

// PaymentStatus represents the status of a payment
type PaymentStatus string

const (
	PaymentStatusPending   PaymentStatus = "PENDING"
	PaymentStatusCompleted PaymentStatus = "COMPLETED"
	PaymentStatusFailed    PaymentStatus = "FAILED"
	PaymentStatusCancelled PaymentStatus = "CANCELLED"
)
