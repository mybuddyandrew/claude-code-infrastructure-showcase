# Claude Code Infrastructure Showcase

> Production-tested infrastructure patterns for building sophisticated Claude Code projects

## What Is This?

This repository showcases a comprehensive Claude Code infrastructure setup that solves the #1 problem developers face: **making skills actually activate automatically**.

After 6 months of production use on a complex multi-service application, this setup demonstrates:

- ✅ **Skills that actually activate** - No more manually invoking skills every time
- ✅ **Modular skill architecture** - Following Anthropic's 500-line rule with progressive disclosure
- ✅ **Powerful hooks system** - UserPromptSubmit, PreToolUse, PostToolUse, and Stop hooks
- ✅ **Dev docs pattern** - Documentation that survives context resets
- ✅ **PM2 integration** - Give Claude real-time access to service logs
- ✅ **Production-ready patterns** - Battle-tested over 6 months

## Why This Matters

Claude Code's skills feature is powerful but underutilized because skills often just sit there and never activate. This repository shows you how to fix that with a combination of:

1. **Hooks** - TypeScript/Bash scripts that run at key points in Claude's workflow
2. **skill-rules.json** - Configuration that tells hooks which skills to activate
3. **Trigger patterns** - Keywords, intents, file paths, and content patterns
4. **Smart enforcement** - Blocking for guardrails, suggestions for domain skills

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/claude-code-infrastructure-showcase.git
cd claude-code-infrastructure-showcase

# Follow the setup guide
cat SETUP.md
```

Setup takes **less than 15 minutes**.

## What's Included

### Infrastructure
- **5 Production Hooks** - skill-activation, error-handling, tool-use tracking, build checking, prettier formatting
- **5 Generic Skills** - skill-developer, backend-dev-guidelines, frontend-dev-guidelines, database-verification, error-tracking
- **Comprehensive skill-rules.json** - Heavily commented with examples
- **Templates** - Ready-to-use templates for skills, hooks, agents, and commands

### Examples
- **Blog API Service** - Complete Node.js/Express/TypeScript microservice
- **Dev Docs Example** - Real-world example of the dev docs pattern
- **PM2 Configuration** - Process management for multi-service projects

### Documentation
- **SETUP.md** - 15-minute setup guide
- **HOOKS_SYSTEM.md** - Complete hooks reference
- **SKILLS_SYSTEM.md** - Skills + hooks integration guide
- **DEV_DOCS_PATTERN.md** - Methodology for surviving context resets
- **PM2_DEBUGGING.md** - Giving Claude real-time log access

## The Breakthrough

The key insight: **Claude can't activate skills proactively, but hooks can**.

By using a `UserPromptSubmit` hook that reads `skill-rules.json` and pattern-matches against the user's prompt, we can inject skill activation instructions *before* Claude sees the request.

This transforms skills from "documentation that sometimes gets used" into "active, automatic assistance".

## Architecture

```
Your Prompt
    ↓
UserPromptSubmit Hook (checks skill-rules.json)
    ↓
Modified Prompt + Skill Instructions
    ↓
Claude Processes Request
    ↓
PreToolUse Hook (optional blocking for guardrails)
    ↓
Tool Execution
    ↓
PostToolUse Hook (tracking, logging)
    ↓
Stop Hook (reminders, checks, formatting)
```

## Who Is This For?

- **Claude Code users** frustrated that skills never activate
- **Teams** building complex multi-service applications
- **Developers** who want production-ready patterns, not toys
- **Anyone** who needs documentation that survives context resets

## Tech Stack (Example Application)

- Node.js 20+ / TypeScript 5+
- Express.js (REST APIs)
- Prisma (Database ORM)
- Sentry v8 (Error tracking)
- PM2 (Process management)
- React 19 + MUI v7 (Frontend examples in docs)

## Philosophy

This infrastructure emphasizes:

- **Non-blocking by default** - Gentle reminders over hard blocks
- **Progressive disclosure** - Skills reference detailed docs when needed
- **Production-ready** - All patterns tested in real applications
- **Developer experience** - Fast, helpful, not annoying

## Community

This infrastructure was featured in the viral Reddit post ["Claude Code is a Beast - Part 2"](https://reddit.com/r/ClaudeAI/...).

Questions? Issues? Ideas? Open an issue or discussion!

## License

MIT License - See LICENSE file

## Getting Started

1. Read [SETUP.md](./SETUP.md) for installation (< 15 min)
2. Read [HOOKS_SYSTEM.md](./docs/HOOKS_SYSTEM.md) to understand how hooks work
3. Read [SKILLS_SYSTEM.md](./docs/SKILLS_SYSTEM.md) to understand skills integration
4. Explore the [blog-api example](./examples/blog-api/) to see it in action
5. Use the [templates](./templates/) to create your own skills and hooks

---

**Built with ❤️ by developers frustrated that skills weren't activating automatically**
