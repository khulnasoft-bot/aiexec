"""Custom exception types for Primeagent integration."""


class PrimeagentIntegrationError(Exception):
    """Base exception for Primeagent integration errors."""

    pass


class ConversionError(PrimeagentIntegrationError):
    """Error during Primeagent to Stepflow conversion."""

    pass


class ValidationError(PrimeagentIntegrationError):
    """Error during workflow validation."""

    pass


class ExecutionError(PrimeagentIntegrationError):
    """Error during component execution."""

    pass
