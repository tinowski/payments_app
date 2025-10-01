package model

import (
	"time"

	"gorm.io/gorm"
)

// PaymentDB represents the database model for payments
type PaymentDB struct {
	ID          string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Amount      float64        `gorm:"not null" json:"amount"`
	Currency    string         `gorm:"not null;type:varchar(3)" json:"currency"`
	Description string         `gorm:"not null;type:text" json:"description"`
	Status      PaymentStatus  `gorm:"not null;type:varchar(20);default:'PENDING'" json:"status"`
	CreatedAt   time.Time      `gorm:"not null" json:"createdAt"`
	UpdatedAt   time.Time      `gorm:"not null" json:"updatedAt"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"deletedAt,omitempty"`
}

// TableName specifies the table name for GORM
func (PaymentDB) TableName() string {
	return "payments"
}

// ToPayment converts PaymentDB to Payment model
func (p *PaymentDB) ToPayment() *Payment {
	return &Payment{
		ID:          p.ID,
		Amount:      p.Amount,
		Currency:    p.Currency,
		Description: p.Description,
		Status:      p.Status,
		CreatedAt:   p.CreatedAt,
		UpdatedAt:   p.UpdatedAt,
	}
}

// FromPayment converts Payment model to PaymentDB
func (p *PaymentDB) FromPayment(payment *Payment) {
	p.ID = payment.ID
	p.Amount = payment.Amount
	p.Currency = payment.Currency
	p.Description = payment.Description
	p.Status = payment.Status
	p.CreatedAt = payment.CreatedAt
	p.UpdatedAt = payment.UpdatedAt
}
