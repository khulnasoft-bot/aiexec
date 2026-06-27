"""Logging module for wfx package."""

from wfx.log._streams import make_streams_resilient
from wfx.log.logger import configure, logger

make_streams_resilient()

__all__ = ["configure", "logger"]
