# Claude Code Hooks System

This directory contains production-tested hooks that enhance Claude Code's capabilities through automated tracking, error detection, skill activation, and code formatting.

## Available Hooks

### 1. skill-activation-prompt (UserPromptSubmit)
**Purpose**: Automatically activates skills based on user prompts

**How it works:**
- Intercepts user prompts before Claude sees them
- Reads `skill-rules.json` to find matching skills
- Injects skill activation instructions into the prompt
- **This is the breakthrough** that makes skills actually activate automatically

**Files:**
- `skill-activation-prompt.sh` - Shell wrapper
- `skill-activation-prompt.ts` - TypeScript implementation

### 2. error-handling-reminder (Stop)
**Purpose**: Gentle post-response reminder about error handling best practices

**How it works:**
- Runs after Claude finishes responding
- Analyzes edited files for risky patterns (async, Prisma, API calls, controllers)
- Shows categorized reminders only if risky code was detected
- Non-blocking (doesn't interrupt workflow)

**Files:**
- `error-handling-reminder.sh` - Shell wrapper
- `error-handling-reminder.ts` - TypeScript implementation

**Disable:** Set environment variable `SKIP_ERROR_REMINDER=1`

### 3. post-tool-use-tracker (PostToolUse)
**Purpose**: Tracks all file edits and determines affected services

**How it works:**
- Triggers after Edit, MultiEdit, or Write tools
- Auto-detects project structure (frontend, backend, database, packages)
- Stores tracking data for other hooks to use
- Builds commands for TypeScript checking and builds

**Cache location:** `$CLAUDE_PROJECT_DIR/.claude/tsc-cache/[session_id]/`

### 4. stop-prettier-formatter (Stop)
**Purpose**: Automatically format edited files with Prettier

**How it works:**
- Runs first in Stop hook chain
- Formats all edited TypeScript, JavaScript, and JSON files
- Searches upward for `.prettierrc` config
- Falls back to Prettier defaults if no config found

### 5. stop-build-check-enhanced (Stop)
**Purpose**: Run TypeScript checks and report errors

**How it works:**
- Runs second in Stop hook chain
- Executes `tsc --noEmit` on affected services
- Reports errors with actionable suggestions
- For ≥5 errors, recommends using auto-error-resolver agent

## Hook Flow

```
User Prompt
    ↓
[UserPromptSubmit] skill-activation-prompt
    ↓
Modified Prompt + Skill Instructions
    ↓
Claude Processes Request
    ↓
[PostToolUse] post-tool-use-tracker (tracks edits)
    ↓
Claude Completes Response
    ↓
[Stop] stop-prettier-formatter (formats files)
    ↓
[Stop] stop-build-check-enhanced (checks types)
    ↓
[Stop] error-handling-reminder (shows reminders)
```

## Project Structure Detection

The hooks automatically detect common project structures:

**Frontend:**
- `frontend/`, `client/`, `web/`, `app/`, `ui/`

**Backend:**
- `backend/`, `server/`, `api/`, `src/`, `services/`

**Database:**
- `database/`, `prisma/`, `migrations/`

**Monorepo:**
- `packages/*`, `examples/*`

## Cache Structure

```
$CLAUDE_PROJECT_DIR/.claude/tsc-cache/[session_id]/
├── edited-files.log      # timestamp:path:repo format
├── affected-repos.txt    # List of repos that were edited
├── commands.txt          # Build and TSC commands per repo
├── last-errors.txt       # Combined error output
├── tsc-commands.txt      # TSC commands for resolver
└── results/
    ├── [repo]-errors.txt # Error output per repo
    └── error-summary.txt # Error count summary
```

## Configuration

Hooks are registered in `.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/skill-activation-prompt.sh"
          }
        ]
      }
    ],
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
          },
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/error-handling-reminder.sh"
          }
        ]
      }
    ]
  }
}
```

## Installation

1. Copy `.claude/hooks/` directory to your project
2. Install TypeScript dependencies:
   ```bash
   cd .claude/hooks && npm install
   ```
3. Register hooks in `.claude/settings.json` (see above)
4. Create `.claude/skills/skill-rules.json` (required for skill-activation-prompt)

## Customization

### Adding New Repo Patterns

Edit `post-tool-use-tracker.sh`, function `detect_repo()`:

```bash
case "$repo" in
    your-service-dir)
        echo "$repo"
        ;;
esac
```

### Changing Error Thresholds

Edit `stop-build-check-enhanced.sh`, line with error count check:

```bash
if [[ $total_errors -ge 5 ]]; then  # Change this number
```

### Disabling Specific Hooks

Remove the hook from `.claude/settings.json` or set environment variables:
- `SKIP_ERROR_REMINDER=1` - Disable error handling reminders

## Best Practices

1. **Don't block workflow** - Hooks should enhance, not interrupt
2. **Use session cache** - Prevents duplicate reminders
3. **Exit code 0** - Skip conditions should exit cleanly
4. **Exit code 2** - Use to send feedback to Claude
5. **Test thoroughly** - Hooks run on every action

## Troubleshooting

**Hook not running:**
- Check `.claude/settings.json` registration
- Verify script has execute permissions (`chmod +x`)
- Check TypeScript compilation (`cd .claude/hooks && npx tsc`)

**False positives:**
- Adjust pattern detection in TypeScript files
- Add skip conditions for specific file types

**Performance issues:**
- Hooks run synchronously - keep them fast
- Use caching to avoid repeated work
- Consider async processing for heavy operations

## Philosophy

These hooks follow a **gentle, non-blocking** philosophy:
- **Suggest, don't block** - Provide guidance without interrupting workflow
- **Smart detection** - Only trigger when relevant
- **Session awareness** - Don't repeat the same reminder
- **Production-tested** - 6 months of real-world use

## See Also

- [HOOKS_SYSTEM.md](../../docs/HOOKS_SYSTEM.md) - Complete hooks reference
- [SKILLS_SYSTEM.md](../../docs/SKILLS_SYSTEM.md) - Skills integration guide
- [CONFIG.md](./CONFIG.md) - Configuration options
