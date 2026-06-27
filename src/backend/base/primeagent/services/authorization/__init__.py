"""OSS authorization service package (pass-through default; plugins enforce)."""

from primeagent.services.authorization.actions import (
    DeploymentAction,
    FileAction,
    FlowAction,
    KnowledgeBaseAction,
    ProjectAction,
    ShareAction,
    VariableAction,
)
from primeagent.services.authorization.audit import (
    audit_decision,
    drain_pending_audit_writes,
)
from primeagent.services.authorization.decorators import requires_flow_permission, requires_resource_permission
from primeagent.services.authorization.fetch import authorized_or_owner_scoped, deny_to_404
from primeagent.services.authorization.guards import (
    ensure_deployment_permission,
    ensure_file_permission,
    ensure_flow_permission,
    ensure_knowledge_base_permission,
    ensure_permission,
    ensure_project_permission,
    ensure_share_permission,
    ensure_variable_permission,
)
from primeagent.services.authorization.listing import filter_visible_resources
from primeagent.services.authorization.service import PrimeagentAuthorizationService

__all__ = [
    "DeploymentAction",
    "FileAction",
    "FlowAction",
    "KnowledgeBaseAction",
    "PrimeagentAuthorizationService",
    "ProjectAction",
    "ShareAction",
    "VariableAction",
    "audit_decision",
    "authorized_or_owner_scoped",
    "deny_to_404",
    "drain_pending_audit_writes",
    "ensure_deployment_permission",
    "ensure_file_permission",
    "ensure_flow_permission",
    "ensure_knowledge_base_permission",
    "ensure_permission",
    "ensure_project_permission",
    "ensure_share_permission",
    "ensure_variable_permission",
    "filter_visible_resources",
    "requires_flow_permission",
    "requires_resource_permission",
]
