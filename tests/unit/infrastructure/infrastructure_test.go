package infrastructure_test

import (
	"context"
	"os"
	"payments_app/internal/domain"
	"payments_app/internal/infrastructure/database"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupTestDB(t *testing.T) *database.PaymentRepository {
	dbPath := "test_payments.db"

	repo, err := database.NewPaymentRepository(dbPath)
	require.NoError(t, err)

	return repo
}

func cleanupTestDB(t *testing.T, repo *database.PaymentRepository) {
	err := repo.Close()
	require.NoError(t, err)

	err = os.Remove("test_payments.db")
	if err != nil {
		t.Logf("Warning: Could not remove test database file: %v", err)
	}
}

func TestPaymentRepository_Create(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	payment := domain.NewPayment(100.50, "USD", "Test payment")

	err := repo.Create(context.Background(), payment)
	require.NoError(t, err)
}

func TestPaymentRepository_GetByID(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	// Create a payment first
	payment := domain.NewPayment(200.75, "EUR", "Test payment for retrieval")
	err := repo.Create(context.Background(), payment)
	require.NoError(t, err)

	// Retrieve the payment
	retrievedPayment, err := repo.GetByID(context.Background(), payment.ID)
	require.NoError(t, err)

	assert.Equal(t, payment.ID, retrievedPayment.ID)
	assert.Equal(t, payment.Amount, retrievedPayment.Amount)
	assert.Equal(t, payment.Currency, retrievedPayment.Currency)
	assert.Equal(t, payment.Description, retrievedPayment.Description)
	assert.Equal(t, payment.Status, retrievedPayment.Status)
}

func TestPaymentRepository_GetByID_NotFound(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	_, err := repo.GetByID(context.Background(), "non-existent-id")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}

func TestPaymentRepository_GetAll(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	// Create multiple payments
	payments := []*domain.Payment{
		domain.NewPayment(100, "USD", "Payment 1"),
		domain.NewPayment(200, "EUR", "Payment 2"),
		domain.NewPayment(300, "GBP", "Payment 3"),
	}

	for _, payment := range payments {
		err := repo.Create(context.Background(), payment)
		require.NoError(t, err)
	}

	// Retrieve all payments
	allPayments, err := repo.GetAll(context.Background())
	require.NoError(t, err)

	assert.Len(t, allPayments, 3)
}

func TestPaymentRepository_Update(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	// Create a payment first
	payment := domain.NewPayment(100.50, "USD", "Original payment")
	err := repo.Create(context.Background(), payment)
	require.NoError(t, err)

	// Update the payment
	payment.Amount = 200.75
	payment.Currency = "EUR"
	payment.Description = "Updated payment"
	payment.UpdateStatus(domain.PaymentStatusCompleted)

	err = repo.Update(context.Background(), payment)
	require.NoError(t, err)

	// Retrieve and verify the updated payment
	updatedPayment, err := repo.GetByID(context.Background(), payment.ID)
	require.NoError(t, err)

	assert.Equal(t, 200.75, updatedPayment.Amount)
	assert.Equal(t, "EUR", updatedPayment.Currency)
	assert.Equal(t, "Updated payment", updatedPayment.Description)
	assert.Equal(t, domain.PaymentStatusCompleted, updatedPayment.Status)
}

func TestPaymentRepository_Delete(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	// Create a payment first
	payment := domain.NewPayment(100.50, "USD", "Payment to delete")
	err := repo.Create(context.Background(), payment)
	require.NoError(t, err)

	// Delete the payment
	err = repo.Delete(context.Background(), payment.ID)
	require.NoError(t, err)

	// Verify payment is deleted
	_, err = repo.GetByID(context.Background(), payment.ID)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}

func TestPaymentRepository_Delete_NotFound(t *testing.T) {
	repo := setupTestDB(t)
	defer cleanupTestDB(t, repo)

	err := repo.Delete(context.Background(), "non-existent-id")
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "payment not found")
}
