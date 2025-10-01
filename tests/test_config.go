package tests

import (
	"os"
	"testing"
)

// TestConfig holds configuration for tests
type TestConfig struct {
	ServerURL       string
	DatabasePath    string
	SkipE2E         bool
	SkipIntegration bool
	SkipUnit        bool
}

// GetTestConfig returns test configuration based on environment variables
func GetTestConfig() *TestConfig {
	return &TestConfig{
		ServerURL:       getEnv("TEST_SERVER_URL", "http://localhost:8080"),
		DatabasePath:    getEnv("TEST_DB_PATH", "test_payments.db"),
		SkipE2E:         getEnv("SKIP_E2E_TESTS", "false") == "true",
		SkipIntegration: getEnv("SKIP_INTEGRATION_TESTS", "false") == "true",
		SkipUnit:        getEnv("SKIP_UNIT_TESTS", "false") == "true",
	}
}

// ShouldRunE2E checks if E2E tests should run
func (c *TestConfig) ShouldRunE2E(t *testing.T) bool {
	if c.SkipE2E {
		t.Skip("E2E tests disabled via SKIP_E2E_TESTS")
		return false
	}
	return true
}

// ShouldRunIntegration checks if integration tests should run
func (c *TestConfig) ShouldRunIntegration(t *testing.T) bool {
	if c.SkipIntegration {
		t.Skip("Integration tests disabled via SKIP_INTEGRATION_TESTS")
		return false
	}
	return true
}

// ShouldRunUnit checks if unit tests should run
func (c *TestConfig) ShouldRunUnit(t *testing.T) bool {
	if c.SkipUnit {
		t.Skip("Unit tests disabled via SKIP_UNIT_TESTS")
		return false
	}
	return true
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
