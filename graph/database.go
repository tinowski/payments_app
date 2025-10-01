package graph

import (
	"errors"
	"payments_app/graph/model"
	"time"

	"github.com/google/uuid"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

// DatabaseStorage handles SQLite database operations
type DatabaseStorage struct {
	db *gorm.DB
}

// NewDatabaseStorage creates a new database storage instance
func NewDatabaseStorage(dbPath string) (*DatabaseStorage, error) {
	db, err := gorm.Open(sqlite.Open(dbPath), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	// Auto-migrate the schema
	err = db.AutoMigrate(&model.PaymentDB{})
	if err != nil {
		return nil, err
	}

	return &DatabaseStorage{db: db}, nil
}

// CreatePayment creates a new payment in the database
func (s *DatabaseStorage) CreatePayment(input model.CreatePaymentInput) (*model.Payment, error) {
	id := uuid.New().String()
	now := time.Now()

	paymentDB := &model.PaymentDB{
		ID:          id,
		Amount:      input.Amount,
		Currency:    input.Currency,
		Description: input.Description,
		Status:      model.PaymentStatusPending,
		CreatedAt:   now,
		UpdatedAt:   now,
	}

	result := s.db.Create(paymentDB)
	if result.Error != nil {
		return nil, result.Error
	}

	return paymentDB.ToPayment(), nil
}

// GetPayment retrieves a payment by ID from the database
func (s *DatabaseStorage) GetPayment(id string) (*model.Payment, error) {
	var paymentDB model.PaymentDB

	result := s.db.First(&paymentDB, "id = ?", id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, errors.New("payment not found")
		}
		return nil, result.Error
	}

	return paymentDB.ToPayment(), nil
}

// GetAllPayments retrieves all payments from the database
func (s *DatabaseStorage) GetAllPayments() ([]*model.Payment, error) {
	var paymentsDB []model.PaymentDB

	result := s.db.Find(&paymentsDB)
	if result.Error != nil {
		return nil, result.Error
	}

	payments := make([]*model.Payment, len(paymentsDB))
	for i, paymentDB := range paymentsDB {
		payments[i] = paymentDB.ToPayment()
	}

	return payments, nil
}

// UpdatePayment updates an existing payment in the database
func (s *DatabaseStorage) UpdatePayment(input model.UpdatePaymentInput) (*model.Payment, error) {
	var paymentDB model.PaymentDB

	result := s.db.First(&paymentDB, "id = ?", input.ID)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, errors.New("payment not found")
		}
		return nil, result.Error
	}

	// Update fields if provided
	if input.Amount != nil {
		paymentDB.Amount = *input.Amount
	}
	if input.Currency != nil {
		paymentDB.Currency = *input.Currency
	}
	if input.Description != nil {
		paymentDB.Description = *input.Description
	}
	if input.Status != nil {
		paymentDB.Status = *input.Status
	}

	paymentDB.UpdatedAt = time.Now()

	result = s.db.Save(&paymentDB)
	if result.Error != nil {
		return nil, result.Error
	}

	return paymentDB.ToPayment(), nil
}

// DeletePayment deletes a payment by ID from the database
func (s *DatabaseStorage) DeletePayment(id string) error {
	result := s.db.Delete(&model.PaymentDB{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return errors.New("payment not found")
	}

	return nil
}

// Close closes the database connection
func (s *DatabaseStorage) Close() error {
	sqlDB, err := s.db.DB()
	if err != nil {
		return err
	}
	return sqlDB.Close()
}
