"""Tests for the cross-user-fetch capability flag."""

from __future__ import annotations

from types import SimpleNamespace

import pytest
from primeagent.services.authorization.service import PrimeagentAuthorizationService
from wfx.services.authorization.base import BaseAuthorizationService
from wfx.services.authorization.service import AuthorizationService as WfxDefaultService


def _settings(*, authz_enabled: bool = False) -> SimpleNamespace:
    return SimpleNamespace(
        auth_settings=SimpleNamespace(
            AUTHZ_ENABLED=authz_enabled,
            AUTHZ_SUPERUSER_BYPASS=True,
        )
    )


@pytest.mark.anyio
async def test_base_class_default_is_false():
    """The class-level constant defaults False so subclasses must opt in."""
    assert BaseAuthorizationService.SUPPORTS_CROSS_USER_FETCH is False


@pytest.mark.anyio
async def test_wfx_default_service_does_not_support_cross_user_fetch():
    """The wfx no-op service inherits the safe default."""
    service = WfxDefaultService()
    assert await service.supports_cross_user_fetch() is False


@pytest.mark.anyio
async def test_primeagent_pass_through_does_not_support_cross_user_fetch():
    """OSS pass-through must NOT opt in — that is the strict-pass-through contract."""
    service = PrimeagentAuthorizationService(_settings())
    assert await service.supports_cross_user_fetch() is False


@pytest.mark.anyio
async def test_subclass_can_opt_in():
    """Authorization plugins flip ``SUPPORTS_CROSS_USER_FETCH=True``; the base accepts it."""

    class _Plugin(PrimeagentAuthorizationService):
        SUPPORTS_CROSS_USER_FETCH = True

    service = _Plugin(_settings())
    assert await service.supports_cross_user_fetch() is True
