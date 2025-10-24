# build-agents-md

A Claude Code skill for automatically building comprehensive `agents.md` files by analyzing repository code and developer patterns.

## What is this?

This is a [custom skill](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills) for Claude Code that:

- Analyzes a developer's code patterns and merge request comments
- Extracts architectural patterns and best practices
- Generates AI-optimized documentation for guiding LLMs
- Optionally creates human-readable guides and modular rule files

## Requirements

- Claude Code
- GitLab repository (uses `glab` CLI)
- Git repository with commit history

**Note:** Currently GitLab-only, but GitHub support could be easily added by adapting the comment-fetching scripts.

## Installation

1. Copy this directory to your Claude Code skills folder:
   ```bash
   cp -r build-agents-md ~/.claude/skills/
   ```

2. Restart Claude Code or reload skills

3. Invoke the skill with: `/build-agents-md` or by typing "build agents md"

## What it creates

- `agents.md` - Comprehensive AI guidance file
- `docs/{repo}-dev-guide.md` - Optional human-readable developer guide
- `agent_templates/` - Optional copy-paste-ready code examples
- `.cursor/rules/*.mdc` - Optional modular rule files for Cursor integration

## Documentation

See `skill.md` for complete documentation on the skill's workflow, steps, and usage.

## License

MIT
