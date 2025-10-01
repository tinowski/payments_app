package graph

import "payments_app/graph/model"

// PaymentStorageInterface defines the interface for payment storage operations
type PaymentStorageInterface interface {
	CreatePayment(input model.CreatePaymentInput) (*model.Payment, error)
	GetPayment(id string) (*model.Payment, error)
	GetAllPayments() ([]*model.Payment, error)
	UpdatePayment(input model.UpdatePaymentInput) (*model.Payment, error)
	DeletePayment(id string) error
}
