"""WFX authorization service package (abstract base + default no-op allow-all implementation)."""

from wfx.services.authorization.base import BaseAuthorizationService
from wfx.services.authorization.service import AuthorizationService

__all__ = ["AuthorizationService", "BaseAuthorizationService"]
