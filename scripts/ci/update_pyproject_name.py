#!/usr/bin/env python

import re
import sys
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent.parent
ARGUMENT_NUMBER = 3


def update_pyproject_name(pyproject_path: str, new_project_name: str) -> None:
    """Update the project name in pyproject.toml."""
    filepath = BASE_DIR / pyproject_path
    content = filepath.read_text(encoding="utf-8")

    # Regex to match the name field only within the [project] section.
    # This avoids replacing 'name' in other sections like [[tool.uv.index]].
    # Pattern matches: [project] + any content (non-greedy) + name = "value"
    pattern = re.compile(r'(\[project\]\s*\n(?:[^\[]*?))(name = ")[^"]+(")', re.DOTALL)

    if not pattern.search(content):
        msg = f'Project name not found in "{filepath}"'
        raise ValueError(msg)
    content = pattern.sub(rf"\1\g<2>{new_project_name}\3", content)

    # Update extra references in [complete] and [all] extras for nightly builds
    if new_project_name == "primeagent-base-nightly":
        # Replace primeagent-base[extra] with primeagent-base-nightly[extra] in optional dependencies
        content = re.sub(r'"primeagent-base\[([^\]]+)\]"', r'"primeagent-base-nightly[\1]"', content)
    elif new_project_name == "primeagent-nightly":
        # Replace primeagent[extra] with primeagent-nightly[extra] in optional dependencies
        content = re.sub(r'"primeagent\[([^\]]+)\]"', r'"primeagent-nightly[\1]"', content)

    filepath.write_text(content, encoding="utf-8")


def update_uv_dep(pyproject_path: str, new_project_name: str) -> None:
    """Update the primeagent-base dependency in pyproject.toml."""
    filepath = BASE_DIR / pyproject_path
    content = filepath.read_text(encoding="utf-8")

    if new_project_name == "primeagent-nightly":
        pattern = re.compile(r"primeagent = \{ workspace = true \}")
        replacement = "primeagent-nightly = { workspace = true }"
    elif new_project_name == "primeagent-base-nightly":
        pattern = re.compile(r"primeagent-base = \{ workspace = true \}")
        replacement = "primeagent-base-nightly = { workspace = true }"
    else:
        msg = f"Invalid project name: {new_project_name}"
        raise ValueError(msg)

    # Updates the dependency name for uv
    if not pattern.search(content):
        msg = f"{replacement} uv dependency not found in {filepath}"
        raise ValueError(msg)
    content = pattern.sub(replacement, content)
    filepath.write_text(content, encoding="utf-8")


def main() -> None:
    if len(sys.argv) != ARGUMENT_NUMBER:
        msg = "Must specify project name and build type, e.g. primeagent-nightly base"
        raise ValueError(msg)
    new_project_name = sys.argv[1]
    build_type = sys.argv[2]

    if build_type == "base":
        update_pyproject_name("src/backend/base/pyproject.toml", new_project_name)
        update_uv_dep("pyproject.toml", new_project_name)
    elif build_type == "main":
        update_pyproject_name("pyproject.toml", new_project_name)
        update_uv_dep("pyproject.toml", new_project_name)
    else:
        msg = f"Invalid build type: {build_type}"
        raise ValueError(msg)


if __name__ == "__main__":
    main()
