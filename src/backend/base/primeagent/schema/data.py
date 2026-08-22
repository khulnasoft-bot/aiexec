"""JSON and Data classes for primeagent - imports from wfx.

This maintains backward compatibility while using the wfx implementation.
JSON is the new base type; Data is an alias for backwards compatibility.
"""

from wfx.schema.data import JSON, Data, custom_serializer, serialize_data

__all__ = ["JSON", "Data", "custom_serializer", "serialize_data"]
