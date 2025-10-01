package domain

import "context"

// PaymentRepository defines the interface for payment data operations
type PaymentRepository interface {
	Create(ctx context.Context, payment *Payment) error
	GetByID(ctx context.Context, id string) (*Payment, error)
	GetAll(ctx context.Context) ([]*Payment, error)
	Update(ctx context.Context, payment *Payment) error
	Delete(ctx context.Context, id string) error
}
