"""Authorization service factory."""

from __future__ import annotations

from typing import TYPE_CHECKING

from primeagent.services.factory import ServiceFactory
from primeagent.services.schema import ServiceType

if TYPE_CHECKING:
    from wfx.services.authorization.base import BaseAuthorizationService
    from wfx.services.settings.service import SettingsService

    from primeagent.services.authorization.service import PrimeagentAuthorizationService


class AuthorizationServiceFactory(ServiceFactory):
    """Factory that creates the Primeagent authorization service."""

    name = ServiceType.AUTHORIZATION_SERVICE.value

    service_class: type[PrimeagentAuthorizationService]

    def __init__(self) -> None:
        """Bind the factory to the PrimeagentAuthorizationService implementation."""
        from primeagent.services.authorization.service import PrimeagentAuthorizationService

        super().__init__(PrimeagentAuthorizationService)

    def create(self, settings_service: SettingsService) -> BaseAuthorizationService:
        """Build a PrimeagentAuthorizationService using the injected settings service."""
        return self.service_class(settings_service)
