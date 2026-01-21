// Global test setup file
// This file runs before all tests

// Suppress console.error during tests to reduce noise
// Individual tests can spy on console.error if they need to verify error logging
const originalError = console.error;
beforeAll(() => {
  console.error = jest.fn();
});

afterAll(() => {
  console.error = originalError;
});
