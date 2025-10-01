package usecases

import (
	"context"
	"errors"
	"payments_app/internal/domain"
	"strings"
	"time"
)

// PaymentUseCase handles payment business logic
type PaymentUseCase struct {
	repo domain.PaymentRepository
}

// NewPaymentUseCase creates a new payment use case
func NewPaymentUseCase(repo domain.PaymentRepository) *PaymentUseCase {
	return &PaymentUseCase{repo: repo}
}

// CreatePaymentInput represents input for creating a payment
type CreatePaymentInput struct {
	Amount      float64 `json:"amount"`
	Currency    string  `json:"currency"`
	Description string  `json:"description"`
}

// UpdatePaymentInput represents input for updating a payment
type UpdatePaymentInput struct {
	ID          string                `json:"id"`
	Amount      *float64              `json:"amount,omitempty"`
	Currency    *string               `json:"currency,omitempty"`
	Description *string               `json:"description,omitempty"`
	Status      *domain.PaymentStatus `json:"status,omitempty"`
}

// CreatePayment creates a new payment
func (uc *PaymentUseCase) CreatePayment(ctx context.Context, input CreatePaymentInput) (*domain.Payment, error) {
	// Validate input
	if input.Amount <= 0 {
		return nil, errors.New("amount must be greater than 0")
	}
	// Validate and normalize currency
	currency, currencyErr := validateAndNormalizeCurrency(input.Currency)
	if currencyErr != nil {
		return nil, currencyErr
	}
	if strings.TrimSpace(input.Description) == "" {
		return nil, errors.New("description is required")
	}

	// Create payment entity with normalized data
	// Note: Domain layer expects pre-normalized data (trimmed, validated)
	payment := domain.NewPayment(input.Amount, currency, strings.TrimSpace(input.Description))

	// Save to repository
	err := uc.repo.Create(ctx, payment)
	if err != nil {
		return nil, err
	}

	return payment, nil
}

// GetPayment retrieves a payment by ID
func (uc *PaymentUseCase) GetPayment(ctx context.Context, id string) (*domain.Payment, error) {
	if id == "" {
		return nil, errors.New("payment ID is required")
	}

	payment, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	return payment, nil
}

// GetAllPayments retrieves all payments
func (uc *PaymentUseCase) GetAllPayments(ctx context.Context) ([]*domain.Payment, error) {
	payments, err := uc.repo.GetAll(ctx)
	if err != nil {
		return nil, err
	}

	return payments, nil
}

// UpdatePayment updates an existing payment
func (uc *PaymentUseCase) UpdatePayment(ctx context.Context, input UpdatePaymentInput) (*domain.Payment, error) {
	if input.ID == "" {
		return nil, errors.New("payment ID is required")
	}

	// Get existing payment
	payment, err := uc.repo.GetByID(ctx, input.ID)
	if err != nil {
		return nil, err
	}

	// Update fields if provided
	if input.Amount != nil {
		if *input.Amount <= 0 {
			return nil, errors.New("amount must be greater than 0")
		}
		payment.Amount = *input.Amount
	}
	if input.Currency != nil {
		// Validate and normalize currency
		currency, currencyErr := validateAndNormalizeCurrency(*input.Currency)
		if currencyErr != nil {
			return nil, currencyErr
		}
		payment.Currency = currency
	}
	if input.Description != nil {
		if strings.TrimSpace(*input.Description) == "" {
			return nil, errors.New("description is required")
		}
		// Normalize description before assignment
		payment.Description = strings.TrimSpace(*input.Description)
	}
	if input.Status != nil {
		payment.UpdateStatus(*input.Status)
	} else {
		payment.UpdatedAt = time.Now() // Update timestamp
	}

	// Save updated payment
	err = uc.repo.Update(ctx, payment)
	if err != nil {
		return nil, err
	}

	return payment, nil
}

// DeletePayment deletes a payment by ID
func (uc *PaymentUseCase) DeletePayment(ctx context.Context, id string) error {
	if id == "" {
		return errors.New("payment ID is required")
	}

	// Check if payment exists
	_, err := uc.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Delete payment
	err = uc.repo.Delete(ctx, id)
	if err != nil {
		return err
	}

	return nil
}

// validateAndNormalizeCurrency validates and normalizes a currency code
func validateAndNormalizeCurrency(currency string) (string, error) {
	currency = strings.TrimSpace(currency)
	if currency == "" {
		return "", errors.New("currency is required")
	}
	if len(currency) != 3 {
		return "", errors.New("currency must be exactly 3 characters")
	}
	// Normalize currency to uppercase for validation
	currency = strings.ToUpper(currency)
	if !isValidCurrencyCode(currency) {
		return "", errors.New("currency must contain only letters")
	}
	return currency, nil
}

// isValidCurrencyCode validates that a currency code contains only letters
func isValidCurrencyCode(currency string) bool {
	for _, char := range currency {
		if char < 'A' || char > 'Z' {
			return false
		}
	}
	return true
}
