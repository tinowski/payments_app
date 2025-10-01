package graph

// This file will not be regenerated automatically.
//
// It serves as dependency injection for your app, add any dependencies you require here.

type Resolver struct {
	storage PaymentStorageInterface
}

// Storage returns the storage interface for external access
func (r *Resolver) Storage() PaymentStorageInterface {
	return r.storage
}

// NewResolver creates a new resolver with in-memory storage
func NewResolver() *Resolver {
	return &Resolver{
		storage: NewPaymentStorage(),
	}
}

// NewResolverWithDatabase creates a new resolver with database storage
func NewResolverWithDatabase(dbPath string) (*Resolver, error) {
	storage, err := NewDatabaseStorage(dbPath)
	if err != nil {
		return nil, err
	}

	return &Resolver{
		storage: storage,
	}, nil
}
