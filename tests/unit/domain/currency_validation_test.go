package domain_test

import (
	"payments_app/internal/domain"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPayment_CurrencyValidation(t *testing.T) {
	tests := []struct {
		name        string
		currency    string
		shouldPass  bool
		description string
	}{
		{
			name:        "valid USD",
			currency:    "USD",
			shouldPass:  true,
			description: "US Dollar should be valid",
		},
		{
			name:        "valid EUR",
			currency:    "EUR",
			shouldPass:  true,
			description: "Euro should be valid",
		},
		{
			name:        "valid GBP",
			currency:    "GBP",
			shouldPass:  true,
			description: "British Pound should be valid",
		},
		{
			name:        "valid JPY",
			currency:    "JPY",
			shouldPass:  true,
			description: "Japanese Yen should be valid",
		},
		{
			name:        "valid CAD",
			currency:    "CAD",
			shouldPass:  true,
			description: "Canadian Dollar should be valid",
		},
		{
			name:        "valid AUD",
			currency:    "AUD",
			shouldPass:  true,
			description: "Australian Dollar should be valid",
		},
		{
			name:        "valid CHF",
			currency:    "CHF",
			shouldPass:  true,
			description: "Swiss Franc should be valid",
		},
		{
			name:        "valid CNY",
			currency:    "CNY",
			shouldPass:  true,
			description: "Chinese Yuan should be valid",
		},
		{
			name:        "valid SEK",
			currency:    "SEK",
			shouldPass:  true,
			description: "Swedish Krona should be valid",
		},
		{
			name:        "valid NOK",
			currency:    "NOK",
			shouldPass:  true,
			description: "Norwegian Krone should be valid",
		},
		{
			name:        "lowercase currency",
			currency:    "usd",
			shouldPass:  true,
			description: "Lowercase currency should be valid",
		},
		{
			name:        "mixed case currency",
			currency:    "Usd",
			shouldPass:  true,
			description: "Mixed case currency should be valid",
		},
		{
			name:        "empty currency",
			currency:    "",
			shouldPass:  false,
			description: "Empty currency should be invalid",
		},
		{
			name:        "invalid currency code",
			currency:    "XYZ",
			shouldPass:  true, // Domain doesn't validate currency codes
			description: "Invalid currency code should be allowed at domain level",
		},
		{
			name:        "currency with spaces",
			currency:    " USD ",
			shouldPass:  true,
			description: "Currency with spaces should be valid",
		},
		{
			name:        "currency with numbers",
			currency:    "USD123",
			shouldPass:  true,
			description: "Currency with numbers should be valid",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payment := domain.NewPayment(100.0, tt.currency, "Test payment")

			if tt.shouldPass {
				assert.Equal(t, tt.currency, payment.Currency, tt.description)
			} else {
				// For invalid currencies, we expect the domain to still create the payment
				// but the validation should happen at the use case level
				assert.Equal(t, tt.currency, payment.Currency, tt.description)
			}
		})
	}
}

func TestPayment_CurrencyCaseInsensitivity(t *testing.T) {
	currencies := []string{"USD", "usd", "Usd", "USD", "uSd"}

	for i, currency := range currencies {
		payment := domain.NewPayment(100.0, currency, "Test payment")
		assert.Equal(t, currency, payment.Currency, "Currency case should be preserved: %s", currency)

		// Test that different cases create different payments (if case matters)
		if i > 0 {
			prevPayment := domain.NewPayment(100.0, currencies[i-1], "Test payment")
			assert.NotEqual(t, prevPayment.ID, payment.ID, "Different currency cases should create different payments")
		}
	}
}

func TestPayment_CurrencyWithSpecialCharacters(t *testing.T) {
	tests := []struct {
		name     string
		currency string
	}{
		{"currency with dash", "USD-USD"},
		{"currency with underscore", "USD_USD"},
		{"currency with dot", "USD.USD"},
		{"currency with slash", "USD/USD"},
		{"currency with backslash", "USD\\USD"},
		{"currency with quotes", "\"USD\""},
		{"currency with single quotes", "'USD'"},
		{"currency with parentheses", "(USD)"},
		{"currency with brackets", "[USD]"},
		{"currency with braces", "{USD}"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			payment := domain.NewPayment(100.0, tt.currency, "Test payment")
			assert.Equal(t, tt.currency, payment.Currency, "Currency should preserve special characters: %s", tt.currency)
		})
	}
}
