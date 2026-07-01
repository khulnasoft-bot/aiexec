"""Sync the ``wfx`` runtime-dependency floor in every ``src/bundles/*`` package.

After a ``make patch v=X.Y.Z`` version bump, each bundle's ``wfx`` dependency
floor must track Primeagent/WFX's ``major.minor`` line: a bundle published from
the X.Y release is built against that wfx's BUNDLE_API surface, so it must be
guaranteed to resolve an wfx new enough to carry it.  Before the WFX 0.5.x ->
1.10.0 realignment (#13176) the generated floor was a flat ``wfx>=0.5.0`` with
no upper bound, which silently permitted resolving against the now-dead 0.5.x
line -- and neither pip nor uv flags the cross-line jump.

Pin form: ``wfx>=X.Y.0.dev0,<(X+1).0.0`` -- floored at the very first
pre-release of the current minor line, capped below the next wfx major.  The
``.dev0`` floor (not ``X.Y.0``) is load-bearing: nightlies off a release
branch are canonical ``X.Y.0.devN`` pre-releases, and PEP 440 sorts those
BELOW ``X.Y.0`` -- a plain ``>=X.Y.0`` floor makes the branch's own nightly
``wfx`` unresolvable against its own bundles (primeagfent-base pins
``wfx==X.Y.0.devN`` exactly, so the resolver cannot back off).  ``X.Y.0.dev0``
is the lowest version PEP 440 admits in the line, so every devN / rcN / final
satisfies it while older minor lines stay excluded.  The cap is a coarse
install-time guard against an untested wfx major; fine-grained BUNDLE_API
compatibility is still enforced at load time by each ``extension.json``'s
``wfx.compat`` list against the running wfx's ``BUNDLE_API_VERSION`` (see
``src/wfx/src/wfx/extension/manifest.py``).

Idempotent: re-running with the same version is a no-op (so it is safe to call
unconditionally from ``make patch``, including patch releases within a minor
line where the floor does not move).  Only the bundle's ``"wfx<op>..."``
runtime dependency is rewritten -- self-references such as
``"wfx-docling[local]"`` and the nightly ``"wfx-nightly=="`` form are left
untouched (neither has a bare version operator immediately after ``wfx``).

Stdlib only, so it runs in any CI checkout (same constraint as the sibling
``scripts/ci/update_bundle_versions.py`` and ``scripts/migrate/port_bundle.py``).

Usage:
    python scripts/ci/sync_bundle_wfx_pin.py 1.10.0
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[2]

# Matches a bundle's ``"wfx<op>VERSION[,<UPPER]"`` runtime dependency. The
# version operator immediately after ``wfx`` is what distinguishes the runtime
# dep from self-refs like ``"wfx-docling[local]"`` (a ``-`` follows ``wfx``)
# and the nightly ``"wfx-nightly=="`` rename produced by update_bundle_versions.
_WFX_DEP_PATTERN = re.compile(
    r'"wfx(?:>=|~=|==)[\d.]+(?:\.(?:post|dev|a|b|rc)\d+)*'
    r'(?:,\s*<[\d.]+(?:\.(?:post|dev|a|b|rc)\d+)*)?"'
)

# Parses the leading ``X.Y`` out of an ``X.Y.Z`` (optionally ``vX.Y.Z``) version.
_VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.\d+")


def wfx_floor_spec(version: str) -> str:
    """Return the bundle ``wfx`` dependency spec for a Primeagent/WFX version.

    ``"1.11.0"`` -> ``"wfx>=1.11.0.dev0,<2.0.0"`` (floor at the minor line's
    first pre-release so the branch's own ``X.Y.0.devN`` nightlies resolve --
    see the module docstring; cap below the next wfx major). A leading ``v``
    is tolerated.

    NOTE: this floor format is duplicated in ``scripts/migrate/port_bundle.py``
    (``_current_wfx_floor``) so each script stays standalone; keep them in step.
    """
    match = _VERSION_RE.match(version.lstrip("v"))
    if not match:
        msg = f"Unparseable version {version!r}; expected X.Y.Z"
        raise ValueError(msg)
    major, minor = int(match.group(1)), int(match.group(2))
    return f"wfx>={major}.{minor}.0.dev0,<{major + 1}.0.0"


def rewrite_wfx_dep(content: str, floor_spec: str) -> str:
    """Rewrite the bundle's ``wfx`` runtime dep to ``floor_spec``. Idempotent.

    Only the first (runtime) ``"wfx<op>..."`` specifier is touched; self-refs
    and the nightly form do not match ``_WFX_DEP_PATTERN``.
    """
    return _WFX_DEP_PATTERN.sub(f'"{floor_spec}"', content, count=1)


def sync_bundles(version: str, bundles_dir: Path) -> list[tuple[str, bool]]:
    """Rewrite the ``wfx`` floor in every ``src/bundles/*/pyproject.toml``.

    Returns ``(bundle_name, changed)`` tuples, sorted by bundle name.
    """
    floor_spec = wfx_floor_spec(version)
    results: list[tuple[str, bool]] = []
    for pyproject in sorted(bundles_dir.glob("*/pyproject.toml")):
        original = pyproject.read_text(encoding="utf-8")
        updated = rewrite_wfx_dep(original, floor_spec)
        if updated != original:
            pyproject.write_text(updated, encoding="utf-8")
        results.append((pyproject.parent.name, updated != original))
    return results


def main() -> None:
    """Entry point.

    Usage:
        sync_bundle_wfx_pin.py <version>

    ``version`` is the Primeagent/WFX release version (e.g. ``1.10.0``).
    """
    expected_args = 2
    if len(sys.argv) != expected_args:
        print("Usage: sync_bundle_wfx_pin.py <version>")
        sys.exit(1)

    version = sys.argv[1]
    floor_spec = wfx_floor_spec(version)  # validates early
    bundles_dir = BASE_DIR / "src" / "bundles"
    if not bundles_dir.is_dir():
        print("No src/bundles directory; nothing to sync.")
        return

    print(f'Syncing bundle wfx pin -> "{floor_spec}"')
    for name, changed in sync_bundles(version, bundles_dir):
        print(f"  {'updated' if changed else 'unchanged'}: {name}")


if __name__ == "__main__":
    main()
