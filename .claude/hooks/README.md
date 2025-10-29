# Build Error Detection and Resolution System

This system automatically tracks file edits, runs build checks when Claude Code finishes responding, and can launch the auto-error-resolver agent when needed.

## Components

### 1. post-tool-use-tracker.sh
- Triggers after Edit, MultiEdit, or Write tools
- Tracks which files were edited and which repos they belong to
- Stores tracking data in `~/.claude/tsc-cache/[session_id]/`

### 2. stop-prettier-formatter.sh
- Triggers when Claude Code finishes responding (Stop event) - RUNS FIRST
- Automatically formats all edited files with Prettier
- Uses appropriate .prettierrc config based on file location (frontend, projects, or fallback)
- Only formats TypeScript, JavaScript, and JSON files

### 3. stop-build-check-enhanced.sh
- Triggers when Claude Code finishes responding (Stop event) - RUNS SECOND
- Runs TypeScript checks on all edited repos
- Decides whether to:
  - Report minor errors (< 5) for manual fixing
  - Recommend launching auto-error-resolver agent for major errors (≥ 5)

### 4. auto-error-resolver agent
- Specialized agent that fixes TypeScript errors
- Reads error information from the cache
- Systematically fixes errors and verifies the fixes

## How It Works

1. **During Editing**: Each file edit is tracked and mapped to its repository
2. **After Response**: 
   - Prettier automatically formats all edited files
   - Build checks run automatically on affected repos
3. **Error Detection**: TypeScript errors are counted and categorized
4. **Resolution**:
   - Minor errors: Displayed for manual fixing
   - Major errors: System recommends using `/agent auto-error-resolver`

## Cache Structure

```
~/.claude/tsc-cache/[session_id]/
├── edited-files.log      # Log of all edited files
├── affected-repos.txt    # List of repos that were edited
├── commands.txt          # Build and TSC commands per repo
├── last-errors.txt       # Combined error output
├── tsc-commands.txt      # TSC commands for the resolver
└── results/
    ├── [repo]-errors.txt # Error output per repo
    └── error-summary.txt # Error count summary
```

## Manual Commands

- Clean up old cache: `.claude/hooks/utils/cleanup-cache.sh`
- Check current session cache: `ls -la ~/.claude/tsc-cache/`

## Supported Repositories

- frontend (React/TypeScript)
- form, workflow, projects, email, users, utilities (Node.js services)
- database (Prisma schemas)

## Configuration

The hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/post-tool-use-tracker.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/stop-prettier-formatter.sh"
          },
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/stop-build-check-enhanced.sh"
          }
        ]
      }
    ]
  }
}
```