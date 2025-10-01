package graphql

import (
	"context"
	"payments_app/graph/generated"
	"payments_app/graph/model"
	"payments_app/internal/domain"
	"payments_app/internal/usecases"
	"time"
)

// Resolver implements the generated GraphQL resolver interface
type Resolver struct {
	paymentUseCase *usecases.PaymentUseCase
}

// NewResolver creates a new GraphQL resolver
func NewResolver(paymentUseCase *usecases.PaymentUseCase) *Resolver {
	return &Resolver{
		paymentUseCase: paymentUseCase,
	}
}

// Mutation returns the mutation resolver
func (r *Resolver) Mutation() generated.MutationResolver {
	return &mutationResolver{r}
}

// Query returns the query resolver
func (r *Resolver) Query() generated.QueryResolver {
	return &queryResolver{r}
}

// Payment returns the payment resolver
func (r *Resolver) Payment() generated.PaymentResolver {
	return &paymentResolver{r}
}

// mutationResolver handles mutation operations
type mutationResolver struct{ *Resolver }

// CreatePayment creates a new payment
func (r *mutationResolver) CreatePayment(ctx context.Context, input model.CreatePaymentInput) (*model.Payment, error) {
	useCaseInput := usecases.CreatePaymentInput{
		Amount:      input.Amount,
		Currency:    input.Currency,
		Description: input.Description,
	}

	payment, err := r.paymentUseCase.CreatePayment(ctx, useCaseInput)
	if err != nil {
		return nil, err
	}

	return r.domainToModel(payment), nil
}

// UpdatePayment updates an existing payment
func (r *mutationResolver) UpdatePayment(ctx context.Context, input model.UpdatePaymentInput) (*model.Payment, error) {
	useCaseInput := usecases.UpdatePaymentInput{
		ID:          input.ID,
		Amount:      input.Amount,
		Currency:    input.Currency,
		Description: input.Description,
	}

	if input.Status != nil {
		status := domain.PaymentStatus(*input.Status)
		useCaseInput.Status = &status
	}

	payment, err := r.paymentUseCase.UpdatePayment(ctx, useCaseInput)
	if err != nil {
		return nil, err
	}

	return r.domainToModel(payment), nil
}

// DeletePayment deletes a payment by ID
func (r *mutationResolver) DeletePayment(ctx context.Context, id string) (bool, error) {
	err := r.paymentUseCase.DeletePayment(ctx, id)
	if err != nil {
		return false, err
	}

	return true, nil
}

// queryResolver handles query operations
type queryResolver struct{ *Resolver }

// Payments retrieves all payments
func (r *queryResolver) Payments(ctx context.Context) ([]*model.Payment, error) {
	payments, err := r.paymentUseCase.GetAllPayments(ctx)
	if err != nil {
		return nil, err
	}

	result := make([]*model.Payment, len(payments))
	for i, payment := range payments {
		result[i] = r.domainToModel(payment)
	}

	return result, nil
}

// Payment retrieves a payment by ID
func (r *queryResolver) Payment(ctx context.Context, id string) (*model.Payment, error) {
	payment, err := r.paymentUseCase.GetPayment(ctx, id)
	if err != nil {
		return nil, err
	}

	return r.domainToModel(payment), nil
}

// paymentResolver handles payment field resolvers
type paymentResolver struct{ *Resolver }

// CreatedAt returns the created at timestamp as string
func (r *paymentResolver) CreatedAt(ctx context.Context, obj *model.Payment) (string, error) {
	return obj.CreatedAt.Format(time.RFC3339), nil
}

// UpdatedAt returns the updated at timestamp as string
func (r *paymentResolver) UpdatedAt(ctx context.Context, obj *model.Payment) (string, error) {
	return obj.UpdatedAt.Format(time.RFC3339), nil
}

// domainToModel converts domain Payment to GraphQL model Payment
func (r *Resolver) domainToModel(payment *domain.Payment) *model.Payment {
	return &model.Payment{
		ID:          payment.ID,
		Amount:      payment.Amount,
		Currency:    payment.Currency,
		Description: payment.Description,
		Status:      model.PaymentStatus(payment.Status),
		CreatedAt:   payment.CreatedAt,
		UpdatedAt:   payment.UpdatedAt,
	}
}
