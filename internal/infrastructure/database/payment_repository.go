package database

import (
	"context"
	"errors"
	"payments_app/internal/domain"
	"time"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// PaymentDB represents the database model for payments
type PaymentDB struct {
	ID          string         `gorm:"primaryKey;type:varchar(36)" json:"id"`
	Amount      float64        `gorm:"not null" json:"amount"`
	Currency    string         `gorm:"not null;type:varchar(3)" json:"currency"`
	Description string         `gorm:"not null;type:text" json:"description"`
	Status      string         `gorm:"not null;type:varchar(20);default:'PENDING'" json:"status"`
	CreatedAt   time.Time      `gorm:"not null" json:"createdAt"`
	UpdatedAt   time.Time      `gorm:"not null" json:"updatedAt"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"deletedAt,omitempty"`
}

// TableName specifies the table name for GORM
func (PaymentDB) TableName() string {
	return "payments"
}

// ToDomain converts PaymentDB to domain Payment
func (p *PaymentDB) ToDomain() *domain.Payment {
	return &domain.Payment{
		ID:          p.ID,
		Amount:      p.Amount,
		Currency:    p.Currency,
		Description: p.Description,
		Status:      domain.PaymentStatus(p.Status),
		CreatedAt:   p.CreatedAt,
		UpdatedAt:   p.UpdatedAt,
	}
}

// FromDomain converts domain Payment to PaymentDB
func (p *PaymentDB) FromDomain(payment *domain.Payment) {
	p.ID = payment.ID
	p.Amount = payment.Amount
	p.Currency = payment.Currency
	p.Description = payment.Description
	p.Status = string(payment.Status)
	p.CreatedAt = payment.CreatedAt
	p.UpdatedAt = payment.UpdatedAt
}

// PaymentRepository implements domain.PaymentRepository
type PaymentRepository struct {
	db *gorm.DB
}

// NewPaymentRepository creates a new payment repository
func NewPaymentRepository(dbPath string) (*PaymentRepository, error) {
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	// Auto-migrate the schema
	err = db.AutoMigrate(&PaymentDB{})
	if err != nil {
		return nil, err
	}

	return &PaymentRepository{db: db}, nil
}

// Create creates a new payment in the database
func (r *PaymentRepository) Create(ctx context.Context, payment *domain.Payment) error {
	paymentDB := &PaymentDB{}
	paymentDB.FromDomain(payment)

	result := r.db.WithContext(ctx).Create(paymentDB)
	return result.Error
}

// GetByID retrieves a payment by ID from the database
func (r *PaymentRepository) GetByID(ctx context.Context, id string) (*domain.Payment, error) {
	var paymentDB PaymentDB

	result := r.db.WithContext(ctx).First(&paymentDB, "id = ?", id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, errors.New("payment not found")
		}
		return nil, result.Error
	}

	return paymentDB.ToDomain(), nil
}

// GetAll retrieves all payments from the database
func (r *PaymentRepository) GetAll(ctx context.Context) ([]*domain.Payment, error) {
	var paymentsDB []PaymentDB

	result := r.db.WithContext(ctx).Find(&paymentsDB)
	if result.Error != nil {
		return nil, result.Error
	}

	payments := make([]*domain.Payment, len(paymentsDB))
	for i, paymentDB := range paymentsDB {
		payments[i] = paymentDB.ToDomain()
	}

	return payments, nil
}

// Update updates an existing payment in the database
func (r *PaymentRepository) Update(ctx context.Context, payment *domain.Payment) error {
	paymentDB := &PaymentDB{}
	paymentDB.FromDomain(payment)

	result := r.db.WithContext(ctx).Save(paymentDB)
	return result.Error
}

// Delete deletes a payment by ID from the database
func (r *PaymentRepository) Delete(ctx context.Context, id string) error {
	result := r.db.WithContext(ctx).Delete(&PaymentDB{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("payment not found")
	}

	return nil
}

// Close closes the database connection
func (r *PaymentRepository) Close() error {
	sqlDB, err := r.db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}
