package usecases_test

import (
	"context"
	"payments_app/internal/domain"
	"payments_app/internal/usecases"
	"payments_app/tests/helpers"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestPaymentUseCase_CreatePayment_AdvancedValidation(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	tests := []struct {
		name        string
		input       usecases.CreatePaymentInput
		expectedErr string
	}{
		// Amount validation
		{
			name:        "negative amount",
			input:       usecases.CreatePaymentInput{Amount: -100, Currency: "USD", Description: "Test"},
			expectedErr: "amount must be greater than 0",
		},
		{
			name:        "zero amount",
			input:       usecases.CreatePaymentInput{Amount: 0, Currency: "USD", Description: "Test"},
			expectedErr: "amount must be greater than 0",
		},
		{
			name:        "very small positive amount",
			input:       usecases.CreatePaymentInput{Amount: 0.01, Currency: "USD", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "very large amount",
			input:       usecases.CreatePaymentInput{Amount: 999999999.99, Currency: "USD", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "amount with many decimal places",
			input:       usecases.CreatePaymentInput{Amount: 123.456789, Currency: "USD", Description: "Test"},
			expectedErr: "",
		},

		// Currency validation
		{
			name:        "empty currency",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "", Description: "Test"},
			expectedErr: "currency is required",
		},
		{
			name:        "currency with only spaces",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "   ", Description: "Test"},
			expectedErr: "currency is required",
		},
		{
			name:        "currency with leading/trailing spaces",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: " USD ", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "currency with special characters",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD-USD", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "currency with numbers",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD123", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "currency with mixed case",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "Usd", Description: "Test"},
			expectedErr: "",
		},
		{
			name:        "currency with lowercase",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "usd", Description: "Test"},
			expectedErr: "",
		},

		// Description validation
		{
			name:        "empty description",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: ""},
			expectedErr: "description is required",
		},
		{
			name:        "description with only spaces",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "   "},
			expectedErr: "description is required",
		},
		{
			name:        "description with leading/trailing spaces",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: " Test payment "},
			expectedErr: "",
		},
		{
			name:        "description with special characters",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "Test payment with special chars: !@#$%^&*()"},
			expectedErr: "",
		},
		{
			name:        "description with unicode characters",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "Test payment with unicode: 测试支付 🚀"},
			expectedErr: "",
		},
		{
			name:        "description with newlines",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "Test payment\nwith newlines"},
			expectedErr: "",
		},
		{
			name:        "description with tabs",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "Test payment\twith tabs"},
			expectedErr: "",
		},
		{
			name:        "very long description",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: strings.Repeat("A", 1000)},
			expectedErr: "",
		},
		{
			name:        "description with SQL injection attempt",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "'; DROP TABLE payments; --"},
			expectedErr: "",
		},
		{
			name:        "description with HTML tags",
			input:       usecases.CreatePaymentInput{Amount: 100, Currency: "USD", Description: "<script>alert('xss')</script>"},
			expectedErr: "",
		},

		// Valid cases
		{
			name:        "valid payment with USD",
			input:       usecases.CreatePaymentInput{Amount: 100.50, Currency: "USD", Description: "Valid payment"},
			expectedErr: "",
		},
		{
			name:        "valid payment with EUR",
			input:       usecases.CreatePaymentInput{Amount: 200.75, Currency: "EUR", Description: "Valid payment"},
			expectedErr: "",
		},
		{
			name:        "valid payment with GBP",
			input:       usecases.CreatePaymentInput{Amount: 300.25, Currency: "GBP", Description: "Valid payment"},
			expectedErr: "",
		},
		{
			name:        "valid payment with JPY",
			input:       usecases.CreatePaymentInput{Amount: 10000, Currency: "JPY", Description: "Valid payment"},
			expectedErr: "",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := useCase.CreatePayment(context.Background(), tt.input)

			if tt.expectedErr == "" {
				require.NoError(t, err, "Expected no error for valid input: %+v", tt.input)
			} else {
				require.Error(t, err, "Expected error for invalid input: %+v", tt.input)
				assert.Contains(t, err.Error(), tt.expectedErr, "Error message should contain expected text")
			}
		})
	}
}

func TestPaymentUseCase_UpdatePayment_AdvancedValidation(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	// Create a payment first
	input := usecases.CreatePaymentInput{
		Amount:      100.50,
		Currency:    "USD",
		Description: "Test payment",
	}

	createdPayment, err := useCase.CreatePayment(context.Background(), input)
	require.NoError(t, err)

	tests := []struct {
		name        string
		updateInput usecases.UpdatePaymentInput
		expectedErr string
	}{
		// Amount validation
		{
			name: "update with negative amount",
			updateInput: usecases.UpdatePaymentInput{
				ID:     createdPayment.ID,
				Amount: func() *float64 { v := -100.0; return &v }(),
			},
			expectedErr: "amount must be greater than 0",
		},
		{
			name: "update with zero amount",
			updateInput: usecases.UpdatePaymentInput{
				ID:     createdPayment.ID,
				Amount: func() *float64 { v := 0.0; return &v }(),
			},
			expectedErr: "amount must be greater than 0",
		},
		{
			name: "update with valid amount",
			updateInput: usecases.UpdatePaymentInput{
				ID:     createdPayment.ID,
				Amount: func() *float64 { v := 200.0; return &v }(),
			},
			expectedErr: "",
		},

		// Currency validation
		{
			name: "update with empty currency",
			updateInput: usecases.UpdatePaymentInput{
				ID:       createdPayment.ID,
				Currency: func() *string { v := ""; return &v }(),
			},
			expectedErr: "currency is required",
		},
		{
			name: "update with currency spaces only",
			updateInput: usecases.UpdatePaymentInput{
				ID:       createdPayment.ID,
				Currency: func() *string { v := "   "; return &v }(),
			},
			expectedErr: "currency is required",
		},
		{
			name: "update with valid currency",
			updateInput: usecases.UpdatePaymentInput{
				ID:       createdPayment.ID,
				Currency: func() *string { v := "EUR"; return &v }(),
			},
			expectedErr: "",
		},

		// Description validation
		{
			name: "update with empty description",
			updateInput: usecases.UpdatePaymentInput{
				ID:          createdPayment.ID,
				Description: func() *string { v := ""; return &v }(),
			},
			expectedErr: "description is required",
		},
		{
			name: "update with description spaces only",
			updateInput: usecases.UpdatePaymentInput{
				ID:          createdPayment.ID,
				Description: func() *string { v := "   "; return &v }(),
			},
			expectedErr: "description is required",
		},
		{
			name: "update with valid description",
			updateInput: usecases.UpdatePaymentInput{
				ID:          createdPayment.ID,
				Description: func() *string { v := "Updated description"; return &v }(),
			},
			expectedErr: "",
		},

		// Status validation
		{
			name: "update with valid status",
			updateInput: usecases.UpdatePaymentInput{
				ID:     createdPayment.ID,
				Status: func() *domain.PaymentStatus { v := domain.PaymentStatusCompleted; return &v }(),
			},
			expectedErr: "",
		},
		{
			name: "update with another valid status",
			updateInput: usecases.UpdatePaymentInput{
				ID:     createdPayment.ID,
				Status: func() *domain.PaymentStatus { v := domain.PaymentStatusFailed; return &v }(),
			},
			expectedErr: "",
		},

		// ID validation
		{
			name: "update with empty ID",
			updateInput: usecases.UpdatePaymentInput{
				ID: "",
			},
			expectedErr: "payment not found",
		},
		{
			name: "update with non-existent ID",
			updateInput: usecases.UpdatePaymentInput{
				ID: "non-existent-id",
			},
			expectedErr: "payment not found",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := useCase.UpdatePayment(context.Background(), tt.updateInput)

			if tt.expectedErr == "" {
				require.NoError(t, err, "Expected no error for valid update: %+v", tt.updateInput)
			} else {
				require.Error(t, err, "Expected error for invalid update: %+v", tt.updateInput)
				assert.Contains(t, err.Error(), tt.expectedErr, "Error message should contain expected text")
			}
		})
	}
}

func TestPaymentUseCase_EdgeCases(t *testing.T) {
	repo := helpers.NewMockPaymentRepository()
	useCase := usecases.NewPaymentUseCase(repo)

	t.Run("create payment with maximum precision amount", func(t *testing.T) {
		input := usecases.CreatePaymentInput{
			Amount:      999999999.999999,
			Currency:    "USD",
			Description: "Maximum precision amount",
		}

		payment, err := useCase.CreatePayment(context.Background(), input)
		require.NoError(t, err)
		assert.Equal(t, input.Amount, payment.Amount)
	})

	t.Run("create payment with minimum valid amount", func(t *testing.T) {
		input := usecases.CreatePaymentInput{
			Amount:      0.01,
			Currency:    "USD",
			Description: "Minimum valid amount",
		}

		payment, err := useCase.CreatePayment(context.Background(), input)
		require.NoError(t, err)
		assert.Equal(t, input.Amount, payment.Amount)
	})

	t.Run("create payment with very long description", func(t *testing.T) {
		longDescription := strings.Repeat("A", 10000)
		input := usecases.CreatePaymentInput{
			Amount:      100.0,
			Currency:    "USD",
			Description: longDescription,
		}

		payment, err := useCase.CreatePayment(context.Background(), input)
		require.NoError(t, err)
		assert.Equal(t, longDescription, payment.Description)
	})

	t.Run("create payment with unicode description", func(t *testing.T) {
		input := usecases.CreatePaymentInput{
			Amount:      100.0,
			Currency:    "USD",
			Description: "Payment with unicode: 测试支付 🚀 €£¥",
		}

		payment, err := useCase.CreatePayment(context.Background(), input)
		require.NoError(t, err)
		assert.Equal(t, input.Description, payment.Description)
	})
}
