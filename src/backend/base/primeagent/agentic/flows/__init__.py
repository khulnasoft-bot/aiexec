"""Primeagent Agentic Flows.

This package contains Python flow definitions for the Primeagent Assistant feature.
Python flows are preferred over JSON flows for better maintainability and type safety.

Available flows:
- primeagent_assistant: Main assistant flow for Q&A and component generation
- translation_flow: Intent classification and translation flow
"""

from primeagent.agentic.flows.primeagent_assistant import get_graph as get_primeagent_assistant_graph
from primeagent.agentic.flows.translation_flow import get_graph as get_translation_flow_graph

__all__ = [
    "get_primeagent_assistant_graph",
    "get_translation_flow_graph",
]
